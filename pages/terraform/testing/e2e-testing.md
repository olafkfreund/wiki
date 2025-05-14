# End-to-End Testing for Terraform

End-to-end (E2E) testing for Terraform involves testing complete infrastructure deployments in conditions that closely match production environments. This guide covers modern E2E testing approaches for infrastructure as of 2025.

## Overview

E2E tests verify:
- Complete infrastructure deployment
- Real-world service interactions
- Production-like configurations
- Actual cloud provider behavior
- Data persistence and recovery
- Infrastructure scaling

## Implementation Strategy

### 1. Environment Setup

```hcl
# environments/e2e/main.tf
module "complete_infrastructure" {
  source = "../../"
  
  environment = "e2e"
  region     = var.primary_region
  
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    azs        = ["us-west-2a", "us-west-2b", "us-west-2c"]
  }
  
  database_config = {
    instance_class    = "db.t3.medium"
    engine_version    = "13.7"
    storage_encrypted = true
  }
  
  application_config = {
    instance_type = "t3.medium"
    min_size      = 2
    max_size      = 4
  }
}
```

### 2. Test Implementation

```go
package test

import (
    "testing"
    "time"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/stretchr/testify/assert"
)

func TestE2E(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../../environments/e2e",
        Vars: map[string]interface{}{
            "primary_region": "us-west-2",
        },
        EnvVars: map[string]string{
            "AWS_SDK_LOAD_CONFIG": "true",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test infrastructure deployment
    testInfrastructureDeployment(t, terraformOptions)
    
    // Test scaling and performance
    testAutoScaling(t, terraformOptions)
    
    // Test failure scenarios
    testFailureRecovery(t, terraformOptions)
    
    // Test data persistence
    testDataPersistence(t, terraformOptions)
}

func testInfrastructureDeployment(t *testing.T, options *terraform.Options) {
    // Verify VPC and networking
    vpcId := terraform.Output(t, options, "vpc_id")
    aws.GetVpcById(t, vpcId, options.Vars["primary_region"].(string))
    
    // Verify load balancer
    lbDNS := terraform.Output(t, options, "load_balancer_dns")
    assert.Eventually(t, func() bool {
        return isEndpointHealthy(lbDNS)
    }, 5*time.Minute, 10*time.Second)
    
    // Verify database
    dbEndpoint := terraform.Output(t, options, "database_endpoint")
    assert.Eventually(t, func() bool {
        return isDatabaseConnectable(dbEndpoint)
    }, 5*time.Minute, 10*time.Second)
}

func testAutoScaling(t *testing.T, options *terraform.Options) {
    asgName := terraform.Output(t, options, "autoscaling_group_name")
    
    // Generate load
    generateLoad(t, terraform.Output(t, options, "application_url"))
    
    // Verify scaling
    assert.Eventually(t, func() bool {
        size := getAsgSize(asgName)
        return size > 2 // Min size is 2
    }, 10*time.Minute, 30*time.Second)
}
```

## Infrastructure Testing Patterns

### 1. Disaster Recovery Testing

```go
func testDisasterRecovery(t *testing.T, options *terraform.Options) {
    // Simulate primary region failure
    primaryRegion := options.Vars["primary_region"].(string)
    secondaryRegion := options.Vars["secondary_region"].(string)
    
    // Force failover
    terraform.Apply(t, options, map[string]interface{}{
        "force_failover": true,
    })
    
    // Verify secondary region
    endpoint := terraform.Output(t, options, "current_endpoint")
    assert.Contains(t, endpoint, secondaryRegion)
    
    // Verify data consistency
    checkDataConsistency(t, endpoint)
    
    // Recover primary
    terraform.Apply(t, options, map[string]interface{}{
        "force_failover": false,
    })
}
```

### 2. Security Testing

```go
func testSecurityControls(t *testing.T, options *terraform.Options) {
    // Test IAM roles and permissions
    iamRoles := terraform.OutputList(t, options, "iam_role_arns")
    for _, role := range iamRoles {
        permissions := aws.GetIAMRolePolicy(t, role, options.Vars["primary_region"].(string))
        assert.True(t, validateLeastPrivilege(permissions))
    }
    
    // Test network security
    securityGroups := terraform.OutputList(t, options, "security_group_ids")
    for _, sg := range securityGroups {
        rules := aws.GetSecurityGroupRules(t, sg, options.Vars["primary_region"].(string))
        assert.False(t, hasPublicIngress(rules))
    }
    
    // Test encryption
    validateEncryption(t, options)
}
```

## Performance Testing

### 1. Load Testing Configuration

```go
func setupLoadTest(t *testing.T) *vegeta.Attacker {
    return vegeta.NewAttacker(
        vegeta.Workers(10),
        vegeta.MaxWorkers(20),
        vegeta.Timeout(30*time.Second),
    )
}

func runLoadTest(t *testing.T, endpoint string) *vegeta.Metrics {
    rate := vegeta.Rate{Freq: 100, Per: time.Second}
    duration := 5 * time.Minute
    
    targeter := vegeta.NewStaticTargeter(vegeta.Target{
        Method: "GET",
        URL:    endpoint,
    })
    
    attacker := setupLoadTest(t)
    var metrics vegeta.Metrics
    
    for res := range attacker.Attack(targeter, rate, duration, "Load Test") {
        metrics.Add(res)
    }
    metrics.Close()
    
    return &metrics
}
```

### 2. Scalability Testing

```go
func testScalability(t *testing.T, options *terraform.Options) {
    endpoint := terraform.Output(t, options, "application_url")
    asgName := terraform.Output(t, options, "autoscaling_group_name")
    
    // Baseline metrics
    baselineMetrics := runLoadTest(t, endpoint)
    
    // Scale test
    scaleTestMetrics := make([]*vegeta.Metrics, 3)
    for i := 0; i < 3; i++ {
        // Increase load
        metrics := runLoadTest(t, endpoint)
        scaleTestMetrics[i] = metrics
        
        // Verify scaling behavior
        currentSize := getAsgSize(asgName)
        assert.True(t, currentSize <= 4) // Max size
        
        // Check performance
        assert.Less(t, metrics.Latencies.P95, 500*time.Millisecond)
    }
}
```

## Monitoring and Observability

### 1. Test Metrics Collection

```go
func collectTestMetrics(t *testing.T, options *terraform.Options) {
    // CloudWatch metrics
    metricCollector := aws.NewCloudWatchMetricCollector(
        options.Vars["primary_region"].(string),
    )
    
    metrics := metricCollector.GetMetrics(map[string]string{
        "Namespace": "AWS/EC2",
        "Period":    "300",
    })
    
    // Log test results
    logger := terratest.NewLogger(t)
    logger.Logf(t, "Test Metrics: %v", metrics)
}
```

### 2. Test Result Analysis

```go
func analyzeTestResults(t *testing.T, metrics []*vegeta.Metrics) {
    var summary TestSummary
    
    for _, m := range metrics {
        summary.AddMetrics(m)
    }
    
    // Generate report
    report := summary.GenerateReport()
    
    // Save results
    if err := saveTestResults(report); err != nil {
        t.Errorf("Failed to save test results: %v", err)
    }
}
```

## CI/CD Integration

```yaml
name: E2E Tests
on:
  schedule:
    - cron: '0 0 * * *'  # Daily
  workflow_dispatch:

jobs:
  e2e-test:
    runs-on: ubuntu-latest
    environment: e2e
    timeout-minutes: 120
    
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
      
      - name: Run E2E Tests
        run: |
          cd test/e2e
          go test -v -timeout 2h ./...
        env:
          TF_VAR_environment: e2e
          TEST_REPORT_PATH: ${{ github.workspace }}/test-results
      
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/
```