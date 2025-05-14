# Terraform Integration Testing

Integration testing for Terraform involves testing multiple modules together and verifying their interactions. This guide covers modern integration testing approaches for infrastructure as of 2025.

## Overview

Integration tests verify that multiple Terraform modules work together correctly, testing:
- Resource dependencies
- Network connectivity
- Service interactions
- Cross-module variables
- State management

## Test Implementation

### 1. Module Integration Tests

```hcl
module "networking" {
  source = "../modules/networking"
  
  vpc_cidr     = "10.0.0.0/16"
  environment  = "test"
}

module "database" {
  source = "../modules/database"
  
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.private_subnet_ids
  security_group_ids  = [module.networking.database_security_group_id]
}

module "application" {
  source = "../modules/application"
  
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.private_subnet_ids
  database_endpoint   = module.database.endpoint
  database_port       = module.database.port
}
```

### 2. Testing with Terratest

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/stretchr/testify/assert"
)

func TestIntegration(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "environment": "test",
            "region":     "us-west-2",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test VPC and Subnet Creation
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    subnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
    assert.NotEmpty(t, vpcId)
    assert.Equal(t, 3, len(subnetIds))

    // Test Database Connectivity
    dbEndpoint := terraform.Output(t, terraformOptions, "database_endpoint")
    dbPort := terraform.Output(t, terraformOptions, "database_port")
    
    // Test Application Health
    appUrl := terraform.Output(t, terraformOptions, "application_url")
    http_helper.HttpGetWithRetry(t, appUrl, nil, 200, "OK", 30, 5*time.Second)
}
```

## Best Practices

### 1. Test Environment Isolation

```hcl
provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = "test"
      Terraform   = "true"
      Test       = "integration"
    }
  }
  
  # Use separate credentials for tests
  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/terraform-integration-tests"
  }
}
```

### 2. Data Cleanup

```go
func TestMain(m *testing.M) {
    // Setup test environment
    setup()
    
    // Run tests
    code := m.Run()
    
    // Cleanup
    cleanup()
    
    os.Exit(code)
}

func cleanup() {
    // Custom cleanup logic
    cleanupDatabases()
    cleanupStorageBuckets()
    cleanupLoadBalancers()
}
```

### 3. Test Stages

```go
func TestIntegrationStages(t *testing.T) {
    // Stage 1: Infrastructure Setup
    networkingOptions := setupNetworking(t)
    defer terraform.Destroy(t, networkingOptions)
    
    // Stage 2: Database Deployment
    databaseOptions := setupDatabase(t, networkingOptions)
    defer terraform.Destroy(t, databaseOptions)
    
    // Stage 3: Application Deployment
    applicationOptions := setupApplication(t, networkingOptions, databaseOptions)
    defer terraform.Destroy(t, applicationOptions)
    
    // Integration Tests
    runIntegrationTests(t, applicationOptions)
}
```

## Advanced Testing Scenarios

### 1. Cross-Region Testing

```go
func TestCrossRegion(t *testing.T) {
    primaryOptions := &terraform.Options{
        TerraformDir: "../examples/primary",
        Vars: map[string]interface{}{
            "region": "us-west-2",
        },
    }
    
    secondaryOptions := &terraform.Options{
        TerraformDir: "../examples/secondary",
        Vars: map[string]interface{}{
            "region": "us-east-1",
        },
    }
    
    // Deploy both regions
    terraform.InitAndApply(t, primaryOptions)
    terraform.InitAndApply(t, secondaryOptions)
    
    // Test cross-region functionality
    testReplication(t, primaryOptions, secondaryOptions)
    testFailover(t, primaryOptions, secondaryOptions)
}
```

### 2. Load Testing

```go
func TestLoadBalancing(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "../examples/load-balanced",
    }
    
    terraform.InitAndApply(t, options)
    
    endpoint := terraform.Output(t, options, "lb_endpoint")
    
    // Run load tests
    loadTest := &vegeta.Attack{
        Rate: vegeta.Rate{Freq: 100, Per: time.Second},
        Duration: 5 * time.Minute,
        Targeter: vegeta.NewStaticTargeter(vegeta.Target{
            Method: "GET",
            URL:    endpoint,
        }),
    }
    
    metrics := vegeta.Attack(loadTest)
    assert.Less(t, metrics.Latencies.P95, 500*time.Millisecond)
}
```

## Monitoring and Debugging

### 1. Test Logging

```go
func TestWithLogging(t *testing.T) {
    logger := terratest.NewLogger(t)
    logger.Logf(t, "Starting integration tests...")
    
    options := &terraform.Options{
        TerraformDir: "../examples/complete",
        Logger:       logger,
    }
    
    defer terraform.Destroy(t, options)
    terraform.InitAndApply(t, options)
    
    logger.Logf(t, "Infrastructure deployed successfully")
}
```

### 2. Resource Health Checks

```go
func checkResourceHealth(t *testing.T, options *terraform.Options) {
    resourceIds := terraform.OutputMap(t, options, "resource_ids")
    
    for name, id := range resourceIds {
        status := getResourceStatus(id)
        assert.Equal(t, "healthy", status, "Resource %s is not healthy", name)
    }
}
```

## CI/CD Pipeline Integration

```yaml
name: Integration Tests
on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  integration-test:
    runs-on: ubuntu-latest
    environment: test
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/github-actions-role
          aws-region: us-west-2
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: Run Integration Tests
        run: |
          cd test/integration
          go test -v -timeout 2h ./...
        env:
          TF_VAR_environment: test
```