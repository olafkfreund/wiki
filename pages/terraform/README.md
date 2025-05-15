---
description: Setting up and using terraform for Azure Deployments
---

# Terraform

Terraform is HashiCorp's Infrastructure as Code (IaC) tool that enables you to safely and predictably create, change, and improve infrastructure across multiple cloud providers and services. This guide covers modern Terraform practices as of 2025, including the latest features and best practices.

## Installation Guide

### Linux Installation

#### Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

#### RHEL/CentOS/Fedora

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

### WSL2 Installation

For WSL2, you can either use the Linux distribution's package manager as above, or install via the official package:

```bash
wget -O terraform.zip https://releases.hashicorp.com/terraform/latest/terraform_*_linux_amd64.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
```

### NixOS Installation

Add Terraform to your system configuration (`configuration.nix`):

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    terraform
    # Optional but recommended tools
    terraform-ls  # Language server for IDE integration
    terraform-docs  # Documentation generator
    tflint  # Terraform linter
  ];
}
```

Or for a project-specific environment using `shell.nix`:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    terraform
    terraform-ls
    terraform-docs
    tflint
  ];
}
```

## Modern Terraform Features (2025)

### Key Features

1. **Native Support for Multi-Cloud Deployments**
   - Unified workflow across AWS, Azure, GCP, and other providers
   - Cross-cloud resource dependencies
   - Cloud-agnostic modules

2. **Enhanced State Management**
   - Improved state locking mechanisms
   - Built-in state encryption
   - Advanced state migration tools

3. **Testing and Validation**
   - Built-in testing framework
   - Policy as code integration
   - Automated validation pipelines

4. **Security Features**
   - Native secrets management
   - IAM role assumption
   - Provider authentication improvements

## Best Practices

### 1. State Management

- Use remote state storage (AWS S3, Azure Storage, GCP Cloud Storage)
- Implement state locking
- Separate state files per environment
- Enable state encryption

Example backend configuration for Azure:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate${random_string.suffix.result}"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc            = true
  }
}
```

### 2. Code Organization

- Use workspaces for environment separation
- Implement consistent naming conventions
- Maintain modular code structure

```
project/
├── environments/
│   ├── prod/
│   ├── staging/
│   └── dev/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── storage/
└── shared/
    └── provider.tf
```

### 3. Security

- Use provider authentication with OIDC
- Implement least privilege access
- Enable audit logging
- Use sensitive input variables

### 4. Performance

- Use `for_each` instead of `count` where possible
- Implement parallel resource creation
- Use data sources efficiently

### 5. Cost Management

- Implement cost estimation in CI/CD
- Use cost allocation tags
- Enable cost reports and budgets

## Deployment Scenarios

### 1. Multi-Region High Availability

```hcl
module "primary_region" {
  source = "./modules/region"
  
  providers = {
    aws = aws.us-west-2
  }
  
  is_primary = true
  region_name = "us-west-2"
}

module "secondary_region" {
  source = "./modules/region"
  
  providers = {
    aws = aws.us-east-1
  }
  
  is_primary = false
  region_name = "us-east-1"
}
```

### 2. Zero-Downtime Deployments

```hcl
resource "aws_lb" "application" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  
  enable_deletion_protection = true
  enable_http2       = true
  
  subnets = module.vpc.public_subnets
}

resource "aws_lb_listener" "blue_green" {
  load_balancer_arn = aws_lb.application.arn
  port              = "443"
  protocol          = "HTTPS"
  
  default_action {
    type = "forward"
    target_group_arn = var.environment == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  }
}
```

### 3. Secure Landing Zone

```hcl
module "landing_zone" {
  source = "./modules/landing_zone"
  
  organization_name = "example-corp"
  environment      = "prod"
  
  network_configuration = {
    vpc_cidr             = "10.0.0.0/16"
    enable_transit_gateway = true
    enable_network_firewall = true
  }
  
  security_configuration = {
    enable_guardduty     = true
    enable_security_hub  = true
    enable_config        = true
  }
}
```

## Integration with Other Tools

### 1. CI/CD Integration

GitHub Actions workflow example:

```yaml
name: 'Terraform Pipeline'
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Format
        run: terraform fmt -check
        
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

### 2. Policy as Code

Using OPA (Open Policy Agent) for policy enforcement:

```hcl
provider "opa" {
  hostname = "http://localhost:8181"
}

data "opa_document" "policy" {
  path = "terraform/policies"
  
  query = {
    resources = terraform.resources
    allowed   = true
  }
}
```

## Testing Strategies

### 1. Unit Testing

Using Terratest for infrastructure testing:

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformAwsExample(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/aws",
        Vars: map[string]interface{}{
            "region": "us-west-2",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    output := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, output)
}
```

### 2. Integration Testing

```hcl
module "integration_test" {
  source = "./test"
  
  depends_on = [module.main_infrastructure]
  
  vpc_id     = module.main_infrastructure.vpc_id
  subnet_ids = module.main_infrastructure.subnet_ids
}
```

## Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## Related Topics

- [Infrastructure as Code Overview](../iac/README.md) - Core concepts powering Terraform-based automation
- [AWS Scenarios](aws-scenarios.md) - Practical implementation patterns for AWS resources
- [Azure Scenarios](azure-scenarios.md) - Azure-specific deployment strategies with Terraform
- [GCP Scenarios](gcp-scenarios.md) - Google Cloud automation with Terraform
- [Testing and Validation](testing/) - Ensuring infrastructure reliability with automated tests
- [CI/CD Integration](cicd/) - Automating Terraform deployments in pipelines
- [Terraform Best Practices](best-practices/) - Production-ready implementation strategies
- [Bicep](../../group-1/bicep/README.md) - Alternative IaC approach for Azure-specific workloads
- [GitOps](../devops/gitops/README.md) - Git-based infrastructure delivery that works with Terraform
