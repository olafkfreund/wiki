# Terraform Security Best Practices

A comprehensive guide to securing your Terraform configurations and infrastructure deployments.

## Provider Authentication

### Secure Credentials Management

1. **Never Store Credentials in Code**
   ```hcl
   # DON'T do this
   provider "aws" {
     access_key = "AKIAIOSFODNN7EXAMPLE"  # WRONG!
     secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"  # WRONG!
   }
   ```

   Instead, use:
   - Environment variables
   - Instance profiles/managed identities
   - Vault integration
   - Cloud-native credential management

2. **Use Provider Authentication Best Practices**

   AWS Example:
   ```hcl
   provider "aws" {
     region = "us-west-2"
     assume_role {
       role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
     }
   }
   ```

   Azure Example:
   ```hcl
   provider "azurerm" {
     features {}
     use_msi = true
   }
   ```

## Infrastructure Security

### Network Security

1. **Default Security Groups**
   ```hcl
   resource "aws_security_group" "default" {
     ingress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]  # WRONG!
     }
   }
   ```

   Instead:
   ```hcl
   resource "aws_security_group" "secure" {
     ingress {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = [var.allowed_cidr]
     }
   }
   ```

2. **Network Isolation**
   - Use private subnets for resources
   - Implement proper network segmentation
   - Use VPC endpoints where possible

### Access Management

1. **IAM Best Practices**
   - Use least privilege principle
   - Implement role-based access control
   - Regular rotation of access keys
   - Enable MFA for user accounts

2. **Resource Policies**
   ```hcl
   resource "aws_s3_bucket" "secure_bucket" {
     bucket = "my-secure-bucket"
     
     versioning {
       enabled = true
     }
     
     server_side_encryption_configuration {
       rule {
         apply_server_side_encryption_by_default {
           sse_algorithm = "AES256"
         }
       }
     }
   }
   ```

## Code Security

### Secret Management

1. **Use Secret Management Tools**
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager

2. **Sensitive Data Handling**
   ```hcl
   variable "database_password" {
     type      = string
     sensitive = true
   }
   ```

### Module Security

1. **Module Source Control**
   ```hcl
   module "secure_vpc" {
     source = "git::https://github.com/example/terraform-modules.git//vpc?ref=v1.2.3"
   }
   ```

2. **Version Pinning**
   - Pin provider versions
   - Pin module versions
   - Use checksums for external modules

## Compliance and Auditing

### Compliance Controls

1. **Resource Tagging**
   ```hcl
   resource "aws_instance" "example" {
     tags = {
       Environment = var.environment
       Owner       = var.owner
       CostCenter  = var.cost_center
       Compliance  = var.compliance_level
     }
   }
   ```

2. **Compliance Validation**
   - Use terraform-compliance
   - Implement OPA/Conftest
   - Regular security scanning

### Audit Logging

1. **Enable Provider Logging**
   - AWS CloudTrail
   - Azure Activity Logs
   - GCP Audit Logs

2. **Infrastructure Changes Tracking**
   - Use detailed commit messages
   - Implement change management
   - Track state changes

## Security Testing

### Automated Security Checks

1. **Static Analysis**
   - tfsec
   - checkov
   - terrascan

2. **Dynamic Testing**
   - Inspec
   - ServerSpec
   - Custom validation scripts

## Incident Response

### Security Incident Handling

1. **Preparation**
   - Document emergency procedures
   - Maintain backup states
   - Keep destruction procedures ready

2. **Recovery**
   - State recovery procedures
   - Infrastructure rebuild process
   - Secure state restoration

## Security Checklist

- [ ] Secure credential management implemented
- [ ] Network security controls in place
- [ ] IAM policies follow least privilege
- [ ] Secret management solution integrated
- [ ] Module sources verified and pinned
- [ ] Compliance controls implemented
- [ ] Audit logging enabled
- [ ] Security testing automated
- [ ] Incident response procedures documented
- [ ] Regular security reviews scheduled