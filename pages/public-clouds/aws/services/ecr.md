---
description: Amazon Elastic Container Registry (ECR) - Fully managed container registry on AWS
---

# Amazon ECR (Elastic Container Registry)

## Overview

Amazon Elastic Container Registry (ECR) is a fully managed container registry that makes it easy to store, manage, share, and deploy container images. As of May 2025, ECR supports Docker images, Open Container Initiative (OCI) images, and OCI compatible artifacts.

ECR integrates seamlessly with Amazon ECS, Amazon EKS, and AWS Lambda, ensuring your container deployments have secure, scalable, and reliable access to container images.

## Key Concepts

### ECR Components
- **Repository**: Collection of related container images with the same name but different tags
- **Registry**: Hosts your repositories
- **Image**: The container image stored in a repository
- **Tag**: Identifier for a specific version of an image (e.g., `latest`, `v1.0.0`)
- **Image URI**: The full path to an image (e.g., `aws_account_id.dkr.ecr.region.amazonaws.com/repository:tag`)

### Security Features
- **Encryption**: Images encrypted at rest using AWS KMS
- **IAM Integration**: Fine-grained access control to repositories
- **Image Scanning**: Vulnerability scanning using Amazon Inspector or compatible tools
- **Private Registry**: Images stored in your own AWS account
- **Public Registry**: Option to share images publicly (Amazon ECR Public)

### Lifecycle Policies
- **Automated Cleanup**: Configure rules to automatically remove unused images
- **Policy Rules**: Based on image age, count, or pattern matching for tags

## Deploying ECR with Terraform

### Creating Private ECR Repositories

```hcl
provider "aws" {
  region = "us-west-2"
}

# Create a private ECR repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "my-application"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_key.arn
  }
  
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

# Create a KMS key for ECR encryption
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ECR repository encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = {
    Environment = "production"
    Service     = "ecr"
  }
}

# Lifecycle policy to keep only the latest 10 images
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep only 10 most recent images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Repository policy to allow specific IAM roles to pull images
resource "aws_ecr_repository_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPull",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::123456789012:role/EKSNodeRole"
          ]
        },
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

output "repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
```

### Creating a Public ECR Repository

```hcl
resource "aws_ecrpublic_repository" "public_repo" {
  repository_name = "my-public-app"
  
  catalog_data {
    description    = "My public container image"
    about_text     = "This is a publicly available container image for demonstration purposes."
    usage_text     = "docker pull public.ecr.aws/example/my-public-app:latest"
    operating_systems = ["Linux"]
    architectures  = ["x86-64", "ARM"]
  }
  
  tags = {
    Environment = "demo"
    Public     = "true"
  }
}
```

## Managing ECR with AWS CLI

### Prerequisites
- AWS CLI (version 2.13.0 or higher) installed and configured
- Docker installed (for building and pushing images)
- Appropriate IAM permissions for ECR operations

### 1. Create an ECR Repository

```bash
# Create a private repository
aws ecr create-repository \
  --repository-name my-application \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=KMS,kmsKey=alias/aws/ecr

# View repository details
aws ecr describe-repositories --repository-names my-application
```

### 2. Authenticate Docker to ECR

```bash
# Get authentication token and authenticate Docker
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com
```

### 3. Build, Tag, and Push a Docker Image

```bash
# Build your Docker image
docker build -t my-application:latest .

# Tag the image for your ECR repository
docker tag my-application:latest <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-application:latest

# Push the image to ECR
docker push <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-application:latest
```

### 4. List Images in a Repository

```bash
aws ecr describe-images --repository-name my-application
```

### 5. Pull an Image from ECR

```bash
docker pull <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-application:latest
```

### 6. Create a Lifecycle Policy

```bash
# Create a lifecycle policy file
cat > lifecycle-policy.json << EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only 10 most recent images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

# Apply the lifecycle policy
aws ecr put-lifecycle-policy \
  --repository-name my-application \
  --lifecycle-policy-text file://lifecycle-policy.json
```

### 7. Create a Repository Policy

```bash
# Create a repository policy file
cat > repository-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:role/EKSNodeRole"
        ]
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOF

# Apply the repository policy
aws ecr set-repository-policy \
  --repository-name my-application \
  --policy-text file://repository-policy.json
```

### 8. Scan Images for Vulnerabilities

```bash
# Start a manual image scan
aws ecr start-image-scan \
  --repository-name my-application \
  --image-id imageTag=latest

# Get scan results
aws ecr describe-image-scan-findings \
  --repository-name my-application \
  --image-id imageTag=latest
```

### 9. Delete Images and Repositories

```bash
# Delete a specific image
aws ecr batch-delete-image \
  --repository-name my-application \
  --image-ids imageTag=outdated-tag

# Delete a repository (and all images within it)
aws ecr delete-repository \
  --repository-name my-application \
  --force
```

## Integrating ECR with EKS

### Create a Kubernetes Secret for ECR Access

```bash
# Create a Secret in Kubernetes with credentials for ECR
kubectl create secret docker-registry ecr-secret \
  --docker-server=<your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-west-2) \
  --namespace=default
```

### Sample Kubernetes Deployment Using ECR Images

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-application
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-application
  template:
    metadata:
      labels:
        app: my-application
    spec:
      containers:
      - name: my-application
        image: <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-application:latest
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: ecr-secret
```

## Best Practices for ECR

1. **Security**
   - Use image scanning to detect vulnerabilities
   - Apply repository policies to restrict access
   - Use encryption with customer-managed KMS keys for sensitive repositories
   - Implement cross-account access controls when needed

2. **Cost Optimization**
   - Implement lifecycle policies to automatically clean up unused images
   - Use image tag immutability for critical images to prevent overwriting
   - Regularly audit repositories and remove unnecessary ones

3. **Performance and Efficiency**
   - Use multi-architecture images for mixed ARM/x86 environments
   - Implement image layer caching in build processes
   - Optimize Docker images to reduce size (multi-stage builds)
   - Pull from the ECR repository in the same region as your compute resources

4. **Operational Excellence**
   - Tag images with meaningful metadata (version, commit hash, build date)
   - Implement CI/CD pipeline integration for automated builds and pushes
   - Use ECR replication for multi-region availability of critical images
   - Monitor image pull rates and repository sizes

5. **Compliance**
   - Maintain image provenance information
   - Document the source and build process for each image
   - Implement image signing for supply chain security

## Reference Links

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/latest/userguide/what-is-ecr.html)
- [ECR API Reference](https://docs.aws.amazon.com/ecr/latest/APIReference/Welcome.html)
- [ECR Pricing](https://aws.amazon.com/ecr/pricing/)
- [ECR Public Gallery](https://gallery.ecr.aws/)