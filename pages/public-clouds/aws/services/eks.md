---
description: Comprehensive guide for deploying and managing Amazon EKS (Elastic Kubernetes Service) using Terraform and AWS CLI
---

# Amazon Elastic Kubernetes Service (EKS)

## Overview

Amazon Elastic Kubernetes Service (EKS) is a managed Kubernetes service that makes it easy to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane. EKS is certified Kubernetes conformant, so applications managed by EKS are fully compatible with applications managed by any standard Kubernetes environment.

## Key Features

- **Managed Control Plane**: AWS manages the Kubernetes control plane, including the API servers and etcd database.
- **Highly Available**: Control plane runs across multiple availability zones.
- **Integrated Security**: Integration with AWS IAM for authentication and authorization.
- **Automated Updates**: Managed Kubernetes version updates and patches.
- **Native VPC Networking**: Uses the Amazon VPC CNI for native pod networking on AWS.
- **Extensible**: Supports standard Kubernetes add-ons and AWS integrations.

## Deployment Options

- **Managed Node Groups**: AWS-managed worker nodes with auto-scaling and lifecycle management.
- **Self-managed Nodes**: Manually configure and manage worker nodes.
- **Fargate**: Serverless compute for Kubernetes pods.
- **Windows Support**: Run Windows container workloads.

## Deployment with Terraform

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (matching your EKS version)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with appropriate credentials

### Basic EKS Cluster

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"

  cluster_endpoint_public_access = true
  
  vpc_id     = "vpc-1234567890abcdef0"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-cdef0123"]

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Enable EKS add-ons
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
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Configuring kubectl

```hcl
resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = "${path.module}/kubeconfig_${module.eks.cluster_name}"
}

# Alternatively, configure kubectl directly
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]
  
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  }
}
```

### Advanced Configuration (with Fargate)

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"

  cluster_endpoint_public_access = true
  
  vpc_id     = "vpc-1234567890abcdef0"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-cdef0123"]

  # Fargate profile configuration
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      
      subnet_ids = ["subnet-abcde012", "subnet-bcde012a"]
      
      tags = {
        Owner = "default"
      }
    }
    
    application = {
      name = "application"
      selectors = [
        {
          namespace = "app"
        }
      ]
    }
  }

  # Managed Node Group for workloads that can't run on Fargate
  eks_managed_node_groups = {
    critical = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        workload = "critical"
      }
      
      taints = [
        {
          key    = "dedicated"
          value  = "critical"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # Enable EKS add-ons
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

  # OIDC Provider configuration for service accounts
  enable_irsa = true
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Adding Cluster Autoscaler

```hcl
module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-account-eks"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cluster_autoscaler_irsa_role.iam_role_arn
    }
  }
}

resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "app" = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "cluster-autoscaler"
        }
        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"
        containers {
          name  = "cluster-autoscaler"
          image = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.23.0"
          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${module.eks.cluster_name}"
          ]
          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          volume_mount {
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
            name       = "ssl-certs"
            read_only  = true
          }
          image_pull_policy = "Always"
        }
        volumes {
          name = "ssl-certs"
          host_path {
            path = "/etc/ssl/certs/ca-certificates.crt"
          }
        }
      }
    }
  }
}
```

## Deployment with AWS CLI

### Creating an EKS Cluster

```bash
# Create an EKS cluster
aws eks create-cluster \
  --name my-eks-cluster \
  --role-arn arn:aws:iam::123456789012:role/eks-cluster-role \
  --resources-vpc-config subnetIds=subnet-abcde012,subnet-bcde012a,subnet-cdef0123,securityGroupIds=sg-abcdef01 \
  --kubernetes-version 1.28 \
  --region us-east-1

# Monitor cluster creation status
aws eks describe-cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --query "cluster.status"
```

### Creating IAM Roles for Cluster and Node Groups

Create a file named `eks-cluster-role-trust-policy.json`:

```bash
cat > eks-cluster-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the IAM role for EKS cluster
aws iam create-role \
  --role-name eks-cluster-role \
  --assume-role-policy-document file://eks-cluster-role-trust-policy.json

# Attach required policies to the role
aws iam attach-role-policy \
  --role-name eks-cluster-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create node group role
cat > eks-node-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name eks-node-role \
  --assume-role-policy-document file://eks-node-role-trust-policy.json

# Attach required policies to the node role
aws iam attach-role-policy \
  --role-name eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
  --role-name eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam attach-role-policy \
  --role-name eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
```

### Creating a Managed Node Group

```bash
# Create a node group
aws eks create-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name my-node-group \
  --node-role arn:aws:iam::123456789012:role/eks-node-role \
  --subnets subnet-abcde012 subnet-bcde012a \
  --disk-size 20 \
  --scaling-config minSize=1,maxSize=3,desiredSize=2 \
  --instance-types t3.medium \
  --region us-east-1
```

### Creating a Fargate Profile

```bash
# Create a Fargate profile
aws eks create-fargate-profile \
  --fargate-profile-name default-profile \
  --cluster-name my-eks-cluster \
  --pod-execution-role-arn arn:aws:iam::123456789012:role/eks-fargate-role \
  --subnets subnet-abcde012 subnet-bcde012a \
  --selectors namespace=default namespace=kube-system \
  --region us-east-1
```

### Configuring kubectl

```bash
# Update kubeconfig to connect to the cluster
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region us-east-1

# Verify connection to cluster
kubectl get nodes
```

### Installing Kubernetes Dashboard (Optional)

```bash
# Deploy the Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create a service account and cluster role binding for admin access
cat > admin-service-account.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: eks-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EOF

kubectl apply -f admin-service-account.yaml

# Create an authentication token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

# Start the Kubernetes Dashboard proxy
kubectl proxy
```

## Add-ons and Integrations

### Installing the AWS Load Balancer Controller

```bash
# Create an IAM policy for the AWS Load Balancer Controller
cat > load-balancer-controller-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://load-balancer-controller-policy.json \
  --region us-east-1

# Create service account and AWS IAM role binding
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::123456789012:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve \
  --region us-east-1

# Install the AWS Load Balancer Controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --namespace kube-system
```

### Installing the EBS CSI Driver

```bash
# Create an IAM policy for the EBS CSI Driver
cat > ebs-csi-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:snapshot/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "CreateVolume",
            "CreateSnapshot"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:snapshot/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/CSIVolumeName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CSIVolumeName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/created-for/pvc/name": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name AmazonEBSCSIDriverPolicy \
  --policy-document file://ebs-csi-policy.json \
  --region us-east-1

# Create service account and AWS IAM role binding
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=ebs-csi-controller-sa \
  --attach-policy-arn=arn:aws:iam::123456789012:policy/AmazonEBSCSIDriverPolicy \
  --override-existing-serviceaccounts \
  --approve \
  --region us-east-1

# Install the EBS CSI Driver using Helm
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=ebs-csi-controller-sa
```

## Best Practices

### Security

1. **Use IAM Roles for Service Accounts (IRSA)**: Avoid using long-lived AWS credentials in pods.
   ```bash
   # Enable OIDC provider for the cluster
   eksctl utils associate-iam-oidc-provider \
     --cluster my-eks-cluster \
     --approve \
     --region us-east-1
   
   # Create IAM role for service account
   eksctl create iamserviceaccount \
     --cluster=my-eks-cluster \
     --namespace=default \
     --name=my-service-account \
     --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
     --approve \
     --region us-east-1
   ```

2. **Network Policies**: Implement network policies to control pod-to-pod communication.
   ```bash
   # Install Calico
   kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-operator.yaml
   kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-crs.yaml
   
   # Example network policy
   cat > network-policy.yaml << EOF
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: default-deny
     namespace: default
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
     - Egress
   EOF
   
   kubectl apply -f network-policy.yaml
   ```

3. **Encrypt Secrets**: Use AWS KMS for encrypting Kubernetes secrets.
   ```bash
   # Enable envelope encryption of secrets
   aws eks update-cluster-config \
     --name my-eks-cluster \
     --encryption-config '[{"resources":["secrets"],"provider":{"keyArn":"arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"}}]' \
     --region us-east-1
   ```

### Cost Optimization

1. **Use Spot Instances for Non-Critical Workloads**:
   ```bash
   # Create a spot instance managed node group
   aws eks create-nodegroup \
     --cluster-name my-eks-cluster \
     --nodegroup-name spot-nodes \
     --node-role arn:aws:iam::123456789012:role/eks-node-role \
     --subnets subnet-abcde012 subnet-bcde012a \
     --capacity-type SPOT \
     --scaling-config minSize=1,maxSize=5,desiredSize=3 \
     --instance-types t3.medium,t3a.medium,m5.large,m5a.large \
     --region us-east-1
   ```

2. **Right-Size Your Nodes**: Choose instance types that fit your workloads.

3. **Use Cluster Autoscaler**: Automatically adjusts node count based on demand.

4. **Leverage Fargate for Variable Workloads**: Pay only for what you use.

### Operations

1. **Monitoring with CloudWatch Container Insights**:
   ```bash
   # Enable Container Insights
   aws eks update-cluster-config \
     --name my-eks-cluster \
     --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}' \
     --region us-east-1
   
   # Install CloudWatch agent
   kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml
   ```

2. **Implement Proper Tagging**: Tag all resources for cost allocation and organization.
   ```bash
   aws eks tag-resource \
     --resource-arn arn:aws:eks:us-east-1:123456789012:cluster/my-eks-cluster \
     --tags "Environment=dev,Team=platform,CostCenter=12345" \
     --region us-east-1
   ```

3. **Regular Updates**: Keep your EKS cluster up to date.
   ```bash
   # Update EKS cluster version
   aws eks update-cluster-version \
     --name my-eks-cluster \
     --kubernetes-version 1.28 \
     --region us-east-1
   ```

## Common Issues and Troubleshooting

### Authorization Issues

```bash
# Check if IAM authenticator is configured properly
aws eks describe-cluster \
  --name my-eks-cluster \
  --query "cluster.identity.oidc" \
  --region us-east-1

# Update aws-auth ConfigMap to add users/roles
eksctl create iamidentitymapping \
  --cluster my-eks-cluster \
  --arn arn:aws:iam::123456789012:role/admin-role \
  --username admin \
  --group system:masters \
  --region us-east-1
```

### Networking Issues

```bash
# Check VPC CNI version and configuration
kubectl describe daemonset aws-node -n kube-system

# Check pod CIDR allocation
aws ec2 describe-vpcs \
  --vpc-ids vpc-1234567890abcdef0 \
  --query "Vpcs[].CidrBlockAssociationSet" \
  --region us-east-1

# Validate security group configuration
aws ec2 describe-security-groups \
  --filters "Name=tag:aws:eks:cluster-name,Values=my-eks-cluster" \
  --region us-east-1
```

### Node Issues

```bash
# Check node status
kubectl get nodes -o wide

# Describe a problematic node
kubectl describe node <node-name>

# Check node logs
aws ec2 get-console-output \
  --instance-id i-1234567890abcdef0 \
  --region us-east-1

# Check kubelet logs on the node
ssh ec2-user@<node-ip> 'sudo journalctl -u kubelet'
```

## References

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS CLI EKS Reference](https://docs.aws.amazon.com/cli/latest/reference/eks/index.html)
- [EKS Best Practices Guides](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)