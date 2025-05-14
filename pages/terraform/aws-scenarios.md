# AWS Deployment Scenarios with Terraform

This guide provides practical deployment scenarios for AWS using Terraform, incorporating modern best practices and patterns for 2025.

## ECS Fargate with Application Load Balancer

A production-ready ECS Fargate deployment with ALB:

```hcl
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name = "production"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight = 60
      base = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight = 40
    }
  ]

  container_insights = true
}

module "ecs_service" {
  source = "./modules/ecs-service"

  name = "api-service"
  cluster_id = module.ecs_cluster.id
  
  task_definition = {
    cpu = 1024
    memory = 2048
    container_definitions = [
      {
        name = "api"
        image = "${var.ecr_repository_url}:latest"
        cpu = 512
        memory = 1024
        essential = true
        portMappings = [
          {
            containerPort = 8080
            protocol = "tcp"
          }
        ]
        environment = [
          {
            name = "ENV"
            value = "production"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = "/ecs/api-service"
            awslogs-region = var.aws_region
            awslogs-stream-prefix = "api"
          }
        }
      }
    ]
  }

  networking = {
    subnets = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer = {
    target_group_arn = module.alb.target_group_arns[0]
    container_name = "api"
    container_port = 8080
  }

  auto_scaling = {
    min_capacity = 2
    max_capacity = 10
    cpu_threshold = 75
    memory_threshold = 75
  }

  enable_execute_command = true
}
```

## Multi-Account AWS Organization

Setting up a secure multi-account AWS organization:

```hcl
module "organization" {
  source = "./modules/aws-organization"

  feature_set = "ALL"
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]

  organizational_units = {
    infrastructure = {
      name = "Infrastructure"
      accounts = ["networking", "security"]
    }
    workloads = {
      name = "Workloads"
      accounts = ["dev", "staging", "prod"]
    }
    platform = {
      name = "Platform"
      accounts = ["logging", "monitoring", "backup"]
    }
  }

  accounts = {
    networking = {
      email = "aws-networking@example.com"
      name  = "Networking Account"
    }
    security = {
      email = "aws-security@example.com"
      name  = "Security Account"
    }
    // ... other accounts
  }

  service_control_policies = {
    deny_root_user = {
      name = "DenyRootUser"
      description = "Deny root user access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid = "DenyRootUser"
            Effect = "Deny"
            Action = "*"
            Resource = "*"
            Condition = {
              StringLike = {
                "aws:PrincipalArn": [
                  "arn:aws:iam::*:root"
                ]
              }
            }
          }
        ]
      })
    }
  }
}
```

## Secure VPC with Transit Gateway

Deploy a secure VPC architecture with Transit Gateway:

```hcl
module "transit_gateway" {
  source = "./modules/transit-gateway"

  name = "main-tgw"
  description = "Main Transit Gateway"
  
  amazon_side_asn = 64512
  
  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  
  tags = local.common_tags
}

module "vpc" {
  source = "./modules/vpc"
  
  for_each = {
    prod = {
      cidr = "10.0.0.0/16"
      azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    }
    staging = {
      cidr = "10.1.0.0/16"
      azs = ["us-west-2a", "us-west-2b"]
    }
  }

  name = "${each.key}-vpc"
  cidr = each.value.cidr
  azs  = each.value.azs
  
  private_subnets = [for i, az in each.value.azs : cidrsubnet(each.value.cidr, 8, i)]
  public_subnets  = [for i, az in each.value.azs : cidrsubnet(each.value.cidr, 8, i + length(each.value.azs))]
  
  enable_nat_gateway = true
  single_nat_gateway = each.key == "staging"
  
  enable_vpn_gateway = false
  
  enable_transit_gateway_attachment = true
  transit_gateway_id = module.transit_gateway.id
  
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}
```

## EKS Cluster with Node Groups

Deploy a production-ready EKS cluster:

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "prod-eks"
  cluster_version = "1.28"

  vpc_config = {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs    = ["ADMIN_IP/32"]
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  node_groups = {
    system = {
      desired_size = 2
      min_size     = 2
      max_size     = 4

      instance_types = ["m6i.large"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        role = "system"
      }
      
      taints = [
        {
          key    = "dedicated"
          value  = "system"
          effect = "NO_SCHEDULE"
        }
      ]
    }
    
    application = {
      desired_size = 3
      min_size     = 3
      max_size     = 10

      instance_types = ["m6i.xlarge"]
      capacity_type  = "SPOT"
      
      labels = {
        role = "application"
      }
    }
  }

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
  ]

  tags = local.common_tags
}
```

## Aurora Serverless v2 Database

Deploy a highly available Aurora Serverless v2 cluster:

```hcl
module "aurora_serverless_v2" {
  source = "./modules/aurora-serverless-v2"

  cluster_name = "prod-aurora"
  engine      = "aurora-postgresql"
  engine_version = "14.6"
  
  database_name = "application"
  master_username = "admin"
  
  vpc_config = {
    vpc_id = var.vpc_id
    subnet_ids = var.database_subnet_ids
    allowed_security_group_ids = var.application_security_group_ids
  }

  serverless_config = {
    min_capacity = 0.5
    max_capacity = 16
  }

  backup_config = {
    retention_period = 30
    preferred_window = "03:00-04:00"
  }

  monitoring_config = {
    enhanced_monitoring_interval = 30
    enable_performance_insights = true
    performance_insights_retention = 7
  }

  scaling_config = {
    auto_pause = true
    min_capacity = 0.5
    max_capacity = 16
    seconds_until_auto_pause = 300
    timeout_action = "ForceApplyCapacityChange"
  }

  tags = local.common_tags
}
```

## CloudFront with S3 Origin

Deploy a secure CloudFront distribution with S3:

```hcl
module "static_website" {
  source = "./modules/static-website"

  domain_name = "example.com"
  environment = "production"

  origin_config = {
    s3_bucket_name = "example-static-content"
    
    origin_access_identity = {
      comment = "Access identity for example.com static content"
    }
  }

  cdn_config = {
    price_class = "PriceClass_All"
    
    custom_error_responses = [
      {
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
      }
    ]
    
    cache_policy = {
      min_ttl = 0
      default_ttl = 3600
      max_ttl = 86400
      
      cookies = {
        forward = "none"
      }
      
      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method"
      ]
      
      query_strings = {
        forward = "none"
      }
    }
  }

  security_config = {
    waf_web_acl_id = var.waf_web_acl_id
    ssl_certificate_arn = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.common_tags
}
```

## Best Practices

### 1. Resource Tagging Strategy

```hcl
locals {
  mandatory_tags = {
    Environment  = var.environment
    Project      = var.project_name
    Owner        = var.team_email
    CostCenter   = var.cost_center
    ManagedBy    = "terraform"
  }
  
  resource_tags = merge(local.mandatory_tags, var.additional_tags)
}

resource "aws_resourcegroups_group" "project" {
  name = "project-resources"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key = "Project"
          Values = [var.project_name]
        }
      ]
    })
  }
}
```

### 2. IAM Role Strategy

```hcl
module "iam_roles" {
  source = "./modules/iam-roles"

  environment = var.environment
  
  custom_roles = {
    application = {
      trusted_services = ["ec2.amazonaws.com"]
      custom_policies = [
        {
          name = "ApplicationS3Access"
          policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Action = [
                  "s3:GetObject",
                  "s3:ListBucket"
                ]
                Resource = [
                  "arn:aws:s3:::${var.application_bucket}",
                  "arn:aws:s3:::${var.application_bucket}/*"
                ]
              }
            ]
          })
        }
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      ]
    }
  }
}
```

### 3. Security Groups

```hcl
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id = var.vpc_id
  
  groups = {
    web = {
      name = "web-tier"
      description = "Security group for web tier"
      ingress_rules = [
        {
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from anywhere"
        }
      ]
    }
    app = {
      name = "app-tier"
      description = "Security group for application tier"
      ingress_rules = [
        {
          from_port = 8080
          to_port = 8080
          protocol = "tcp"
          source_security_group_id = "web"
          description = "Access from web tier"
        }
      ]
    }
    db = {
      name = "db-tier"
      description = "Security group for database tier"
      ingress_rules = [
        {
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          source_security_group_id = "app"
          description = "PostgreSQL access from app tier"
        }
      ]
    }
  }
}
```

## Testing

### Integration Tests with Terratest

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestECSDeployment(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/ecs-service",
        
        Vars: map[string]interface{}{
            "environment": "test",
            "region": "us-west-2",
        },
        
        EnvVars: map[string]string{
            "AWS_DEFAULT_REGION": "us-west-2",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify ECS Cluster exists
    clusterName := terraform.Output(t, terraformOptions, "cluster_name")
    cluster := aws.GetEcsCluster(t, "us-west-2", clusterName)
    assert.Equal(t, "ACTIVE", *cluster.Status)
    
    // Verify ECS Service is running
    serviceName := terraform.Output(t, terraformOptions, "service_name")
    service := aws.GetEcsService(t, "us-west-2", clusterName, serviceName)
    assert.Equal(t, "ACTIVE", *service.Status)
}
```