# TFLint

TFLint is a pluggable linter for Terraform code. It can detect possible errors, enforce best practices, and provide style checking.

## Installation

### Using Homebrew
```bash
brew install tflint
```

### Using Curl
```bash
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### Docker
```bash
docker pull ghcr.io/terraform-linters/tflint
```

## Configuration

Create `.tflint.hcl` in your project root:

```hcl
plugin "aws" {
  enabled = true
  version = "0.23.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

# Disallow // comments in favor of #
rule "terraform_comment_syntax" {
  enabled = true
}

# Enforce consistent naming
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
```

## Available Rules

### Built-in Rules
```hcl
# Enforce naming conventions
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

# Check for duplicate resources
rule "terraform_duplicate_resources" {
  enabled = true
}

# Check for deprecated syntax
rule "terraform_deprecated_interpolation" {
  enabled = true
}
```

### Provider-specific Rules
```hcl
# AWS Rules
plugin "aws" {
  enabled = true
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

# Azure Rules
plugin "azurerm" {
  enabled = true
}

rule "azurerm_virtual_machine_invalid_vm_size" {
  enabled = true
}
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: Lint Terraform
on: [push, pull_request]

jobs:
  tflint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: terraform-linters/setup-tflint@v3
      with:
        tflint_version: v0.44.1

    - name: Show version
      run: tflint --version

    - name: Init TFLint
      run: tflint --init

    - name: Run TFLint
      run: tflint -f compact
```

### Azure DevOps Pipeline
```yaml
steps:
- script: |
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    tflint --init
    tflint --format=compact
  displayName: 'Run TFLint'
```

## Pre-commit Hook Integration

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/terraform-linters/tflint
    rev: v0.44.1
    hooks:
      - id: tflint
        args:
          - --format=compact
```

## Best Practices

### 1. Rule Configuration
```hcl
# Enforce consistent naming across team
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
  custom_patterns = {
    resource_names = "^[a-z][a-z0-9_]{0,31}$"
  }
}

# Enforce tags for cost tracking
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "Owner", "CostCenter"]
}
```

### 2. Plugin Management
```hcl
# Use specific versions for reproducibility
plugin "aws" {
  enabled = true
  version = "0.23.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.21.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```

### 3. Ignore Rules When Needed
```hcl
# tflint-ignore: aws_instance_invalid_type
resource "aws_instance" "special_case" {
  instance_type = "custom-instance-type"
}
```

## Common Issues and Solutions

1. **Version Mismatches**
   - Keep TFLint and plugins updated
   - Pin versions in CI/CD
   - Use version constraints

2. **Performance**
   - Use `.tflint.hcl` to enable only needed rules
   - Implement caching in CI/CD
   - Use parallel execution for large codebases

3. **False Positives**
   - Use ignore comments judiciously
   - Configure rules appropriately
   - Report issues to maintainers

## Checklist

- [ ] TFLint installed and configured
- [ ] Provider plugins enabled
- [ ] Custom rules defined
- [ ] CI/CD integration implemented
- [ ] Pre-commit hooks configured
- [ ] Version pinning implemented
- [ ] Documentation updated
- [ ] Team trained on usage
