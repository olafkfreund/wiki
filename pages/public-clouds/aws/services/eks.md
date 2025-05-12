---
description: Amazon Elastic Kubernetes Service (EKS) - Managed Kubernetes service on AWS
---

# Amazon EKS (Elastic Kubernetes Service)

## Overview

Amazon Elastic Kubernetes Service (EKS) is a managed Kubernetes service that makes it easy to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane. As of May 2025, EKS supports Kubernetes versions 1.26 through 1.30 and automatically manages the availability and scalability of the Kubernetes control plane nodes.

## Key Concepts

### EKS Architecture
- **Control Plane**: Managed by AWS across multiple availability zones
- **Worker Nodes**: EC2 instances that run your containerized applications
- **Node Groups**: Collection of EC2 instances managed as a group
- **Fargate Profiles**: Serverless compute for EKS pods
- **VPC CNI Plugin**: Provides networking for pods using AWS VPC

### Access Management
- **IAM Integration**: Role-based access using AWS IAM
- **OIDC Provider**: Authentication via OpenID Connect
- **Cluster IAM Role**: Role that allows EKS to manage resources
- **Node IAM Role**: Role that allows worker nodes to access AWS services

### Networking
- **VPC Requirements**: EKS has specific networking requirements
- **Pod Networking**: Managed through AWS VPC CNI
- **LoadBalancer Services**: Integration with AWS ALB/NLB
- **Cluster Endpoint Access**: Public, private, or both

## Deploying EKS with Terraform

### Basic EKS Cluster

```hcl
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"
  
  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"
  
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.30"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  eks_managed_node_groups = {
    main = {
      min_size     = 2
      max_size     = 10
      desired_size = 2
      
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster"
}
```

### Advanced EKS Configuration

```hcl
# Additional configuration for Fargate profiles
resource "aws_eks_fargate_profile" "example" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "example-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"
    labels = {
      "fargate" = "true"
    }
  }
}

# Example of adding managed add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  addon_version = "v1.16.0-eksbuild.1"  # Check for the latest version
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  addon_version = "v1.11.0-eksbuild.1"  # Check for the latest version
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  addon_version = "v1.30.0-eksbuild.1"  # Check for the latest version
}
```

## Deploying EKS with AWS CLI

### Pre-requisites
Before you begin, ensure you have:
- AWS CLI (version 2.13.0 or higher) installed and configured
- `kubectl` installed
- IAM permissions to create EKS clusters

### 1. Create an IAM Role for EKS

```bash
# Create the policy document for EKS
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

# Create the IAM role
aws iam create-role \
  --role-name EKSClusterRole \
  --assume-role-policy-document file://eks-cluster-role-trust-policy.json

# Attach required policies to the role
aws iam attach-role-policy \
  --role-name EKSClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
```

### 2. Create a VPC for EKS

You can use AWS CloudFormation to deploy a VPC compatible with EKS:

```bash
aws cloudformation create-stack \
  --stack-name eks-vpc \
  --template-url https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2023-02-09/amazon-eks-vpc-sample.yaml
```

### 3. Create the EKS Cluster

```bash
aws eks create-cluster \
  --name my-eks-cluster \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/EKSClusterRole \
  --resources-vpc-config subnetIds=subnet-<ID1>,subnet-<ID2>,subnet-<ID3>,securityGroupIds=sg-<ID> \
  --kubernetes-version 1.30
```

Wait for the cluster to be created (10-15 minutes):

```bash
aws eks describe-cluster \
  --name my-eks-cluster \
  --query "cluster.status"
```

### 4. Create Node IAM Role

```bash
# Create the policy document
cat > node-role-trust-policy.json << EOF
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

# Create the IAM role
aws iam create-role \
  --role-name EKSNodeRole \
  --assume-role-policy-document file://node-role-trust-policy.json

# Attach required policies
aws iam attach-role-policy \
  --role-name EKSNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
  --role-name EKSNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam attach-role-policy \
  --role-name EKSNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
```

### 5. Create a Node Group

```bash
aws eks create-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name my-eks-nodegroup \
  --node-role arn:aws:iam::<ACCOUNT_ID>:role/EKSNodeRole \
  --subnets subnet-<ID1> subnet-<ID2> subnet-<ID3> \
  --instance-types t3.medium \
  --scaling-config minSize=2,maxSize=5,desiredSize=3
```

### 6. Configure kubectl to Work with Your EKS Cluster

```bash
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region us-west-2
```

### 7. Verify the Cluster and Nodes

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Best Practices for EKS

1. **Security**
   - Use IAM roles for service accounts (IRSA) to provide fine-grained permissions
   - Enable network policies for pod-to-pod traffic control
   - Utilize Security Groups for Pods to apply AWS security groups to pods
   - Implement Pod Security Standards

2. **Networking**
   - Plan your CIDR ranges carefully to avoid IP exhaustion
   - Use VPC CNI custom networking when pod density is high
   - Implement AWS Load Balancer Controller for advanced ingress features
   - Consider AWS PrivateLink for private EKS API endpoint access

3. **Cost Optimization**
   - Use Fargate for infrequently used or burst workloads
   - Implement Cluster Autoscaler for automatic scaling of node groups
   - Consider Spot Instances for non-critical workloads
   - Use Graviton (ARM) instances for better price-performance ratio

4. **Reliability**
   - Deploy across multiple availability zones
   - Use managed add-ons for core components (CoreDNS, kube-proxy)
   - Implement proper resource requests and limits
   - Use Pod Disruption Budgets for critical workloads

5. **Operational Excellence**
   - Use EKS Blueprints for GitOps-based provisioning
   - Implement AWS Observability solutions (CloudWatch, Container Insights)
   - Regularly upgrade EKS versions to stay within support window
   - Utilize EKS add-ons for streamlined management of common components

## Reference Links

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [EKS Workshop](https://www.eksworkshop.com/)
- [AWS EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)