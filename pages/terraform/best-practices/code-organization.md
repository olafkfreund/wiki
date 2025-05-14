# Terraform Code Organization Best Practices

This guide covers best practices for organizing Terraform code in a maintainable and scalable way.

## Project Structure

### Root Level Organization
```
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
├── templates/
└── scripts/
```

## File Naming Conventions

### Standard Files
```
├── main.tf          # Primary configuration file
├── variables.tf     # Input variables
├── outputs.tf       # Output definitions
├── versions.tf      # Required providers and versions
├── locals.tf        # Local variables
└── terraform.tfvars # Variable values (git-ignored)
```

## Module Structure

### Module Organization
```
modules/
└── networking/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    └── examples/
        └── complete/
            └── main.tf
```

### Module Interface Design
```hcl
# variables.tf
variable "resource_prefix" {
  description = "Prefix for all resources created by this module"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

## Code Style Guidelines

### Naming Conventions
```hcl
# Resource Naming
resource "aws_instance" "web_server" {
  name = "${var.environment}-${var.project}-web-server"
}

# Variable Naming
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}
```

### Resource Blocks
```hcl
resource "aws_instance" "web_server" {
  # Required parameters first
  ami           = var.ami_id
  instance_type = var.instance_type

  # Optional/computed parameters
  tags = merge(
    var.common_tags,
    {
      Name = "web-server"
    }
  )

  # Nested blocks last
  root_block_device {
    volume_size = 20
  }
}
```

## Workspaces Organization

### Environment Separation
```hcl
# prod/main.tf
module "vpc" {
  source = "../../modules/vpc"

  environment = terraform.workspace
  cidr_block  = var.vpc_cidr_blocks[terraform.workspace]
}
```

## Variables Management

### Variable Definition Structure
```hcl
# variables.tf
variable "instance_config" {
  description = "Configuration for EC2 instances"
  type = object({
    instance_type = string
    ami_id        = string
    volume_size   = number
  })
}

# terraform.tfvars
instance_config = {
  instance_type = "t3.micro"
  ami_id        = "ami-12345678"
  volume_size   = 20
}
```

## Documentation Standards

### Module Documentation
```markdown
# AWS VPC Module

## Description
Creates a VPC with public and private subnets.

## Requirements
| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | The CIDR block for the VPC | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
```

## Version Control

### .gitignore Template
```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude tfvars files that may contain sensitive data
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

## Code Review Guidelines

### Pull Request Template
```markdown
## Description
Describe the changes made in this PR.

## Type of Change
- [ ] New Resource
- [ ] Resource Modification
- [ ] Bug Fix
- [ ] Breaking Change

## Checklist
- [ ] `terraform fmt` run
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Example added (if applicable)
```

## Testing Structure

### Test Organization
```
module/
├── test/
│   ├── fixtures/
│   │   └── example/
│   │       └── main.tf
│   └── integration/
│       └── example_test.go
└── examples/
    └── complete/
        └── main.tf
```

## Best Practices Checklist

- [ ] Consistent file structure across projects
- [ ] Proper module documentation
- [ ] Variables and outputs properly documented
- [ ] Resource naming convention followed
- [ ] Code formatted with `terraform fmt`
- [ ] Sensitive variables marked as sensitive
- [ ] README.md included for each module
- [ ] Example configurations provided
- [ ] Tests implemented where appropriate
- [ ] Version constraints defined
- [ ] Git ignore rules implemented