---
description: >-
  Terrascan is a static code analyzer for Infrastructure as Code that detects security vulnerabilities and compliance violations.
---

# Terrascan

Terrascan is a static code analyzer for Infrastructure as Code that detects security vulnerabilities and compliance violations.

## Installation

### Using Homebrew
```bash
brew install terrascan
```

### Using Docker
```bash
docker pull accurics/terrascan:latest
```

### Using Binary
```bash
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
sudo install terrascan /usr/local/bin && rm terrascan
```

## Basic Usage

### Scan Directory
```bash
terrascan scan -d /path/to/terraform/code
```

### Scan with Specific IAC Provider
```bash
terrascan scan -i terraform -d /path/to/code
```

### Output Formats
```bash
# JSON output
terrascan scan -i terraform -d . -o json

# YAML output
terrascan scan -i terraform -d . -o yaml

# JUnit XML output
terrascan scan -i terraform -d . -o junit-xml
```

## Configuration

### Config File
Create `terrascan.toml` in your project root:

```toml
[rules]
  skip-rules = [
    "AC_AWS_0001",  # Skip rule for unencrypted S3 buckets
    "AC_AWS_0002"   # Skip rule for public S3 buckets
  ]

[notifications]
  webhook {
    url = "https://webhook.example.com"
    token = "webhook-token"
  }

[severity]
  level = "high"
```

## Policy Categories

1. **Security**
   - Access Control
   - Network Security
   - Data Protection
   - Identity Management

2. **Compliance**
   - CIS Benchmarks
   - HIPAA
   - PCI
   - SOC 2

3. **Best Practices**
   - Resource Configuration
   - Tagging
   - Monitoring
   - Cost Optimization

## CI/CD Integration

### GitHub Actions
```yaml
name: Terrascan
on: [push, pull_request]

jobs:
  terrascan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run Terrascan
      uses: tenable/terrascan-action@main
      with:
        iac_type: terraform
        iac_version: v14
        policy_type: aws
        only_warn: true
        sarif_upload: true
```

### Azure DevOps Pipeline
```yaml
steps:
- script: |
    curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
    tar -xf terrascan.tar.gz terrascan
    ./terrascan scan -i terraform -d .
  displayName: 'Run Terrascan'
```

## Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
- repo: https://github.com/tenable/terrascan
  rev: v1.18.1
  hooks:
    - id: terrascan
      args: ['-i', 'terraform']
```

## Writing Custom Policies

Create `custom_policy.rego`:

```rego
package accurics

sameTags[api.id] {
    api := input.aws_api_gateway_rest_api[_]
    not api.config.tags
}

# Fails if API Gateway doesn't have required tags
deny[msg] {
    api := sameTags[_]
    msg := sprintf("API Gateway '%s' doesn't have required tags", [api.id])
}
```

## Common Security Checks

### 1. IAM Policy Validation
```hcl
# Compliant IAM policy
resource "aws_iam_policy" "compliant" {
  name = "compliant-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })
}
```

### 2. Network Security
```hcl
# Compliant security group
resource "aws_security_group" "compliant" {
  name = "compliant-sg"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "HTTPS access"
  }
}
```

## Best Practices

1. **Policy Management**
   - Use baseline policies
   - Document exceptions
   - Regular policy reviews
   - Version control policies

2. **Scan Configuration**
   - Define severity levels
   - Set appropriate thresholds
   - Configure notifications
   - Enable detailed logging

3. **Integration Strategy**
   - Early pipeline integration
   - Break builds on high severity
   - Track findings over time
   - Regular reporting

## Troubleshooting

1. **Common Issues**
   - Policy parsing errors
   - Resource validation failures
   - Rule conflicts
   - Performance problems

2. **Solutions**
   - Validate policy syntax
   - Check resource configurations
   - Review rule dependencies
   - Optimize scan scope

## Checklist

- [ ] Terrascan installed and configured
- [ ] Policy baseline established
- [ ] Custom policies implemented
- [ ] CI/CD integration complete
- [ ] Pre-commit hooks configured
- [ ] Notification setup done
- [ ] Team training completed
- [ ] Documentation updated
