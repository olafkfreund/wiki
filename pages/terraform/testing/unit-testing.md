# Terraform Unit Testing

Unit testing in Terraform involves testing individual modules or resources in isolation to ensure they work as expected. This guide covers modern unit testing approaches for Terraform as of 2025.

## Test Framework Options

### 1. Terratest

Terratest is the most popular testing framework for Terraform. Here's a basic example:

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "environment": "test",
            "region":     "us-west-2",
        },
    }

    // Clean up resources after the test
    defer terraform.Destroy(t, terraformOptions)
    
    // Deploy the infrastructure
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate the outputs
    output := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, output)
}
```

### 2. Built-in Testing Framework

As of Terraform 1.6+, there's a built-in testing framework:

```hcl
variables {
  environment = "test"
  region     = "us-west-2"
}

run "verify_vpc_creation" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block must be 10.0.0.0/16"
  }
}

run "verify_subnet_creation" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Must create 3 private subnets"
  }
}
```

## Best Practices

### 1. Test Structure

Organize your tests following this structure:
```
module/
├── main.tf
├── variables.tf
├── outputs.tf
└── test/
    ├── main_test.go
    ├── fixtures/
    │   ├── complete/
    │   │   └── main.tf
    │   └── minimal/
    │       └── main.tf
    └── helper/
        └── helper.go
```

### 2. Test Cases to Include

- Input validation
- Resource creation
- Output verification
- Error handling
- Edge cases
- Security configurations

### 3. Mocking Strategies

```go
// Mock AWS provider responses
provider "aws" {
  region                      = "us-west-2"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}
```

### 4. Automated Validation

Set up pre-commit hooks for automated testing:

```yaml
repos:
  - repo: local
    hooks:
      - id: terraform-test
        name: Terraform Unit Tests
        entry: make test
        language: system
        files: \.tf$
        pass_filenames: false
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Terraform Tests
on:
  pull_request:
    paths:
      - '**.tf'
      - '**.go'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
          
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        
      - name: Run Tests
        run: |
          cd test
          go test -v ./...
```

## Common Testing Patterns

### 1. Resource Configuration Testing

```go
func TestResourceTags(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/tags",
        Vars: map[string]interface{}{
            "tags": map[string]string{
                "Environment": "test",
                "Project":    "example",
            },
        },
    }
    
    output := terraform.PlanAndShowWithStruct(t, terraformOptions)
    resourceChanges := output.ResourceChangesMap
    
    // Verify all resources have required tags
    for _, resource := range resourceChanges {
        tags := resource.Change.After.(map[string]interface{})["tags"]
        assert.Contains(t, tags, "Environment")
        assert.Contains(t, tags, "Project")
    }
}
```

### 2. Security Configuration Testing

```go
func TestSecurityGroupRules(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/security",
    }
    
    plan := terraform.InitAndPlan(t, terraformOptions)
    
    // Verify no security groups allow 0.0.0.0/0 ingress
    terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_security_group.example")
    securityGroup := plan.ResourcePlannedValuesMap["aws_security_group.example"]
    
    ingressRules := securityGroup.AttributeValues["ingress"].([]interface{})
    for _, rule := range ingressRules {
        cidrBlocks := rule.(map[string]interface{})["cidr_blocks"].([]string)
        assert.NotContains(t, cidrBlocks, "0.0.0.0/0")
    }
}
```

## Troubleshooting

### Common Issues and Solutions

1. **Test Cleanup Failures**
   ```go
   // Use custom cleanup logic
   defer func() {
       terraform.Destroy(t, terraformOptions)
       cleanupArtifacts(t, terraformOptions)
   }()
   ```

2. **Parallel Test Conflicts**
   ```go
   func TestParallel(t *testing.T) {
       t.Parallel()
       uniqueID := random.UniqueId()
       terraformOptions := &terraform.Options{
           TerraformDir: "../examples/complete",
           Vars: map[string]interface{}{
               "name_prefix": fmt.Sprintf("test-%s", uniqueID),
           },
       }
       // ... rest of test
   }
   ```

3. **Provider Authentication**
   ```go
   os.Setenv("AWS_DEFAULT_REGION", "us-west-2")
   os.Setenv("AWS_SDK_LOAD_CONFIG", "true")
   ```