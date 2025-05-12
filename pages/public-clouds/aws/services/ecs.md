---
description: Comprehensive guide for deploying and managing Amazon ECS (Elastic Container Service) using Terraform and AWS CLI
---

# Amazon Elastic Container Service (ECS)

## Overview

Amazon Elastic Container Service (ECS) is a fully managed container orchestration service that allows you to run, stop, and manage Docker containers on a cluster. ECS eliminates the need to install, operate, and scale your own cluster management infrastructure. With simple API calls, you can launch and stop container-enabled applications, query the state of your cluster, and access familiar features like security groups, load balancing, and IAM roles.

## Deployment Options

ECS offers three launch types for your containers:
- **Fargate** - Serverless compute engine for containers (no EC2 instance management)
- **EC2** - Self-managed EC2 instances for more control over infrastructure
- **External** - Register external instances (on-premises or VMs) in your ECS cluster

## Deployment with Terraform

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (1.0.0+)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with appropriate credentials

### Creating an ECS Cluster with Fargate

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "~> 5.2"

  cluster_name = "ecs-fargate-cluster"

  # Enable CloudWatch Container Insights
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/fargate-cluster"
      }
    }
  }

  # Configure Fargate capacity providers with weights
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Creating an ECS Cluster with EC2 Autoscaling

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "~> 5.2"

  cluster_name = "ecs-ec2-cluster"

  # Enable CloudWatch Container Insights
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/ec2-cluster"
      }
    }
  }

  # Configure EC2 autoscaling capacity providers
  autoscaling_capacity_providers = {
    general = {
      auto_scaling_group_arn         = module.autoscaling["general"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 80
      }

      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Defining a Container Definition

```hcl
module "container_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/container-definition"
  version = "~> 5.2"

  name      = "web-app"
  image     = "nginx:latest"
  cpu       = 256
  memory    = 512
  essential = true
  
  port_mappings = [
    {
      name          = "http"
      containerPort = 80
      protocol      = "tcp"
    }
  ]

  environment = [
    {
      name  = "ENVIRONMENT"
      value = "dev"
    }
  ]

  # CloudWatch logging configuration
  enable_cloudwatch_logging = true
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/web-app"
      awslogs-region        = "us-east-1"
      awslogs-stream-prefix = "ecs"
    }
  }
}
```

### Creating an ECS Service

```hcl
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.2"

  name        = "web-service"
  cluster_arn = module.ecs.cluster_arn

  # Task definition
  cpu    = 256
  memory = 512

  # Container definition(s)
  container_definitions = {
    web-app = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = "nginx:latest"
      port_mappings = [
        {
          name          = "http"
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      
      # CloudWatch logging configuration
      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/web-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }

  # Fargate platform configuration
  launch_type = "FARGATE"
  platform_version = "LATEST"
  
  # VPC networking configuration
  network_mode = "awsvpc"
  subnet_ids   = ["subnet-abcde012", "subnet-bcde012a"]
  
  # Security configuration
  security_group_rules = {
    ingress_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
  
  # Load balancer integration
  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.this.arn
      container_name   = "web-app"
      container_port   = 80
    }
  }
  
  # Autoscaling configuration
  autoscaling_enabled = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 5
  
  # Define autoscaling policies (CPU & memory based)
  autoscaling_policies = {
    cpu = {
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 70
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value = 70
      }
    }
  }
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Deployment with AWS CLI

### Creating an ECS Cluster

```bash
# Create an ECS cluster with Fargate and Fargate Spot capacity providers
aws ecs create-cluster \
  --cluster-name my-fargate-cluster \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 capacityProvider=FARGATE_SPOT,weight=1 \
  --settings name=containerInsights,value=enabled \
  --region us-east-1
```

### Creating a Task Definition

First, create a JSON file for the task definition:

```bash
cat > task-definition.json << EOF
{
  "family": "web-app",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "web-app",
      "image": "nginx:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ENVIRONMENT",
          "value": "dev"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/web-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "cpu": 256,
      "memory": 512
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512"
}
EOF

# Register the task definition
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json \
  --region us-east-1
```

### Creating a Service

```bash
# Create a CloudWatch log group
aws logs create-log-group \
  --log-group-name /ecs/web-app \
  --region us-east-1

# Create an ECS service
aws ecs create-service \
  --cluster my-fargate-cluster \
  --service-name web-service \
  --task-definition web-app:1 \
  --launch-type FARGATE \
  --platform-version LATEST \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-abcde012,subnet-bcde012a],securityGroups=[sg-abcdef01],assignPublicIp=ENABLED}" \
  --desired-count 2 \
  --deployment-configuration "minimumHealthyPercent=100,maximumPercent=200" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/web-app-tg/1234567890abcdef,containerName=web-app,containerPort=80" \
  --region us-east-1
```

### Configuring Service Auto Scaling

```bash
# Register a scalable target for the ECS service
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/my-fargate-cluster/web-service \
  --min-capacity 1 \
  --max-capacity 5 \
  --region us-east-1

# Create a scaling policy based on CPU utilization
aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/my-fargate-cluster/web-service \
  --policy-name web-service-cpu-scaling \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 60
  }' \
  --region us-east-1
```

## Service Discovery Integration

ECS services can be registered with AWS Cloud Map for service discovery:

### Terraform Configuration

```hcl
module "ecs_service" {
  # ... previous configuration ...

  service_connect_configuration = {
    namespace = "example-namespace"
    service = {
      client_alias = {
        port     = 80
        dns_name = "web-app"
      }
      port_name      = "http"
      discovery_name = "web-app"
    }
  }

  # ... rest of configuration ...
}
```

### AWS CLI Configuration

First, create a namespace:

```bash
# Create a private DNS namespace
aws servicediscovery create-private-dns-namespace \
  --name example.local \
  --vpc vpc-abcdef01 \
  --region us-east-1

# Create a service within the namespace
aws servicediscovery create-service \
  --name web-app \
  --dns-config "NamespaceId=ns-abcdef01,RoutingPolicy=MULTIVALUE,DnsRecords=[{Type=A,TTL=60}]" \
  --health-check-custom-config "FailureThreshold=1" \
  --region us-east-1
```

Then include the service discovery configuration when creating the ECS service:

```bash
aws ecs create-service \
  --cluster my-fargate-cluster \
  --service-name web-service \
  --task-definition web-app:1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-abcde012,subnet-bcde012a],securityGroups=[sg-abcdef01],assignPublicIp=ENABLED}" \
  --service-registries "registryArn=arn:aws:servicediscovery:us-east-1:123456789012:service/srv-abcdef01234567890" \
  --desired-count 2 \
  --region us-east-1
```

## Best Practices

### Security

1. **Use IAM Roles** - Always use IAM roles with least-privilege access for tasks.
   ```bash
   # Create task execution role policy document
   cat > task-execution-policy.json << EOF
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ecr:GetAuthorizationToken",
           "ecr:BatchCheckLayerAvailability",
           "ecr:GetDownloadUrlForLayer",
           "ecr:BatchGetImage",
           "logs:CreateLogStream",
           "logs:PutLogEvents"
         ],
         "Resource": "*"
       }
     ]
   }
   EOF
   
   # Create IAM policy
   aws iam create-policy \
     --policy-name ECSTaskExecutionPolicy \
     --policy-document file://task-execution-policy.json \
     --region us-east-1
   ```

2. **Network Security** - Use security groups to restrict container traffic.
   ```hcl
   resource "aws_security_group" "ecs_tasks" {
     name        = "ecs-tasks-sg"
     description = "Allow inbound traffic to ECS tasks"
     vpc_id      = "vpc-abcdef01"
     
     ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = ["10.0.0.0/8"]
     }
     
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
   ```

3. **Secrets Management** - Use AWS Secrets Manager to manage sensitive data.
   ```hcl
   resource "aws_secretsmanager_secret" "db_password" {
     name = "db-password"
   }
   
   resource "aws_secretsmanager_secret_version" "db_password" {
     secret_id     = aws_secretsmanager_secret.db_password.id
     secret_string = jsonencode({
       username = "dbuser"
       password = "supersecretpassword" # Use variables or secure sources in production
     })
   }
   ```
   
   And reference in task definition:
   ```hcl
   container_definitions = {
     app = {
       # ... other configuration ...
       secrets = [
         {
           name      = "DB_USERNAME"
           valueFrom = "${aws_secretsmanager_secret.db_password.arn}:username::"
         },
         {
           name      = "DB_PASSWORD"
           valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
         }
       ]
     }
   }
   ```

### Cost Optimization

1. **Use Fargate Spot** - For non-critical workloads to save up to 70% compared to On-Demand pricing.
   ```hcl
   fargate_capacity_providers = {
     FARGATE_SPOT = {
       default_capacity_provider_strategy = {
         weight = 100
       }
     }
   }
   ```

2. **Right-sizing Tasks** - Match CPU and memory allocations to your application's needs.

3. **Cost Allocation** - Use tags for cost allocation and tracking.
   ```hcl
   tags = {
     Environment = "dev"
     Project     = "web-app"
     CostCenter  = "12345"
   }
   ```

### Operations

1. **Container Insights** - Enable CloudWatch Container Insights for monitoring.
   ```hcl
   cluster_configuration = {
     execute_command_configuration = {
       logging = "OVERRIDE"
       log_configuration = {
         cloud_watch_log_group_name = "/aws/ecs/my-cluster"
       }
     }
   }
   ```

2. **Health Checks** - Configure container health checks to ensure application availability.
   ```hcl
   container_definitions = {
     app = {
       # ... other configuration ...
       health_check = {
         command     = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
         interval    = 30
         timeout     = 5
         retries     = 3
         startPeriod = 60
       }
     }
   }
   ```

3. **Logging** - Use structured logging with CloudWatch Logs.
   ```hcl
   container_definitions = {
     app = {
       # ... other configuration ...
       log_configuration = {
         logDriver = "awslogs"
         options = {
           awslogs-group         = "/ecs/service-name"
           awslogs-region        = "us-east-1"
           awslogs-stream-prefix = "app"
         }
       }
     }
   }
   ```

## Common Issues and Troubleshooting

### Service Deployment Issues

If services are failing to deploy or launch tasks:

```bash
# Check service deployment status
aws ecs describe-services \
  --cluster my-fargate-cluster \
  --services web-service \
  --region us-east-1

# Check task failures
aws ecs describe-task-sets \
  --cluster my-fargate-cluster \
  --service web-service \
  --task-sets $(aws ecs list-task-sets --cluster my-fargate-cluster --service web-service --query 'taskSets[0].id' --output text) \
  --region us-east-1
```

### Resource Constraints

If tasks are failing due to resource constraints:

```bash
# Check available resources in cluster
aws ecs describe-clusters \
  --clusters my-fargate-cluster \
  --include ATTACHMENTS SETTINGS STATISTICS \
  --region us-east-1
```

### Networking Issues

If tasks are having network connectivity issues:

```bash
# Check ENI configuration for Fargate tasks
aws ec2 describe-network-interfaces \
  --filters "Name=description,Values=*fargate*" \
  --region us-east-1

# Validate security group rules
aws ec2 describe-security-groups \
  --group-ids sg-abcdef01 \
  --region us-east-1
```

## References

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/latest/developerguide/Welcome.html)
- [Terraform AWS ECS Module](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest)
- [AWS CLI ECS Reference](https://docs.aws.amazon.com/cli/latest/reference/ecs/index.html)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/ecs-bp.html)