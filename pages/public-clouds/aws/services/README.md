---
description: Overview of key AWS services and deployment methods
---

# AWS Services

This section contains detailed guides for deploying and managing common AWS services using both Terraform and the AWS CLI on Linux environments.

## Container Services

- [Amazon EKS (Elastic Kubernetes Service)](eks.md) - Managed Kubernetes service
- [Amazon ECS (Elastic Container Service)](ecs.md) - Container orchestration service
- [Amazon ECR (Elastic Container Registry)](ecr.md) - Docker container registry

## Compute Services

- [Amazon EC2 (Elastic Compute Cloud)](ec2.md) - Virtual servers in the cloud
- [AWS Lambda](lambda.md) - Serverless compute service

## Storage Services

- [Amazon S3 (Simple Storage Service)](s3.md) - Object storage service
- [Amazon EBS (Elastic Block Store)](ebs.md) - Block storage for EC2

## Database Services

- [Amazon RDS (Relational Database Service)](rds.md) - Managed relational databases
- [Amazon DynamoDB](dynamodb.md) - Managed NoSQL database

## Networking Services

- [Amazon VPC (Virtual Private Cloud)](vpc.md) - Isolated cloud resources
- [Amazon CloudFront](cloudfront.md) - Content delivery network

## Each guide includes:

1. Service overview and key concepts
2. Terraform deployment examples
3. AWS CLI deployment commands
4. Best practices
5. Common issues and troubleshooting

These guides are designed to help you deploy AWS resources programmatically using Infrastructure as Code (IaC) principles with Terraform or command-line automation with AWS CLI.