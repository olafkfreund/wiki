# Infrastructure as Code Testing (2024+)

## Modern Testing Approaches

### Policy Testing
```hcl
# OPA policy test example
policy "cloud_resource_naming" {
  enforcement_level = "mandatory"
  
  validate_resource "aws_s3_bucket" {
    name_pattern = "^[a-z0-9-]+$"
    description = "S3 bucket names must be lowercase alphanumeric with hyphens"
  }
}
```

### End-to-End Testing
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformDeployment(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "environment": "test",
            "region":     "us-west-2",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    output := terraform.Output(t, terraformOptions, "cluster_endpoint")
    assert.NotEmpty(t, output)
}
```

## Compliance Validation

### Checkov Implementation
```yaml
name: IaC Security Scan
on: [pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@v12
      with:
        directory: terraform/
        framework: terraform
        quiet: true
        soft_fail: false
```

## Test Categories

### Unit Tests
* Resource validation
* Input validation
* Output validation
* Variable constraints

### Integration Tests
* Resource dependencies
* Service connections
* Network connectivity
* IAM permissions

### Security Tests
* CIS benchmarks
* Compliance checks
* Security group rules
* IAM policies

### Performance Tests
* Deployment time
* Resource limits
* Cost estimation
* Scaling behavior

## Best Practices

1. **Test Environments**
   - Isolated testing accounts
   - Clean state management
   - Resource cleanup
   - Cost controls

2. **Continuous Testing**
   - Pre-commit hooks
   - CI/CD integration
   - Automated validation
   - Drift detection

3. **Documentation**
   - Test coverage reports
   - Compliance documentation
   - Change tracking
   - Test scenarios