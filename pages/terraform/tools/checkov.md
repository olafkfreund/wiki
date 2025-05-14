# Checkov

Checkov is a static code analysis tool for infrastructure-as-code (IaC) that scans cloud infrastructure provisioned using Terraform, CloudFormation, Kubernetes, Helm, ARM Templates and Serverless framework.

## Installation

### Using pip
```bash
pip install checkov
```

### Using Homebrew
```bash
brew install checkov
```

### Using Docker
```bash
docker pull bridgecrew/checkov
```

## Basic Usage

### Scan a Directory
```bash
checkov -d /path/to/terraform/code
```

### Scan a Specific File
```bash
checkov -f /path/to/terraform/file.tf
```

### Output Formats
```bash
# Output as JSON
checkov -d . --output json

# Output as JUnit XML
checkov -d . --output junitxml

# Output as SARIF
checkov -d . --output sarif
```

## Configuration

### Skip Checks
Create `.checkov.yaml` in your project root:

```yaml
skip-check:
  - CKV_AWS_1  # Skip check for unencrypted S3 bucket
  - CKV_AWS_23 # Skip check for unencrypted RDS instance

skip-path:
  - terraform/examples/
  - tests/

framework:
  - terraform
  - kubernetes
```

## Policy Categories

1. **Security**
   - Access Control
   - Encryption
   - Network Security
   - IAM

2. **Compliance**
   - HIPAA
   - PCI DSS
   - SOC2
   - NIST

3. **Operational Excellence**
   - Backups
   - Monitoring
   - High Availability

## CI/CD Integration

### GitHub Actions
```yaml
name: Checkov
on: [push, pull_request]

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file: results.sarif
          soft_fail: true
```

### Azure DevOps Pipeline
```yaml
steps:
- script: |
    python -m pip install --upgrade checkov
    checkov -d . --output cli --quiet
  displayName: 'Run Checkov'
```

## Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
- repo: https://github.com/bridgecrewio/checkov.git
  rev: '2.3.234'
  hooks:
    - id: checkov
      args: [--soft-fail]
```

## Common Security Checks

### 1. S3 Bucket Security
```hcl
# Secure configuration
resource "aws_s3_bucket" "compliant" {
  bucket = "my-secure-bucket"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  versioning {
    enabled = true
  }
  
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}
```

### 2. Security Group Rules
```hcl
# Secure configuration
resource "aws_security_group" "compliant" {
  name = "compliant-sg"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Custom Policies

Create `custom_policies.py`:

```python
from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class MyCustomCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure custom tag exists"
        id = "CKV_CUSTOM_1"
        supported_resources = ['aws_instance']
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)
    
    def scan_resource_conf(self, conf):
        if 'tags' in conf.keys():
            if 'CustomTag' in conf['tags'][0]:
                return CheckResult.PASSED
        return CheckResult.FAILED
```

## Best Practices

1. **Regular Scanning**
   - Integrate with CI/CD
   - Use pre-commit hooks
   - Schedule periodic scans

2. **Policy Management**
   - Document skip decisions
   - Review skipped checks regularly
   - Maintain custom policies

3. **Remediation**
   - Prioritize findings
   - Track fixes
   - Validate fixes

## Checklist

- [ ] Checkov installed and configured
- [ ] CI/CD integration implemented
- [ ] Custom policies defined (if needed)
- [ ] Skip checks documented
- [ ] Pre-commit hooks configured
- [ ] Team trained on reports
- [ ] Remediation process defined
- [ ] Regular scanning scheduled