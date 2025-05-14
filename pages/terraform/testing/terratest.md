# Terratest Guide

Terratest is a Go library that provides patterns and helper functions for testing infrastructure code. This guide covers how to effectively use Terratest for testing Terraform configurations as of 2025.

## Getting Started

### Installation

1. First, ensure you have Go installed:

```bash
go version  # Should be 1.21 or higher
```

2. Create a new test directory and initialize a Go module:

```bash
mkdir test
cd test
go mod init terraform-tests
```

3. Install Terratest:

```bash
go get -u github.com/gruntwork-io/terratest@latest
```

## Basic Test Structure

### Directory Layout

```
infrastructure/
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── test/
    ├── go.mod
    ├── go.sum
    └── vpc_test.go
```

### Simple Test Example

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/vpc",
        
        // Variables to pass to our Terraform code
        Vars: map[string]interface{}{
            "vpc_name":   "test-vpc",
            "cidr_block": "10.0.0.0/16",
        },
    })
    
    // Clean up resources when the test is complete
    defer terraform.Destroy(t, terraformOptions)
    
    // Deploy the infrastructure
    terraform.InitAndApply(t, terraformOptions)
    
    // Get output variables
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    subnets := terraform.OutputList(t, terraformOptions, "subnet_ids")
    
    // Verify the infrastructure
    assert.NotEmpty(t, vpcId)
    assert.Equal(t, 3, len(subnets))
}
```

## Advanced Testing Patterns

### 1. Retry Logic

```go
func TestWithRetry(t *testing.T) {
    maxRetries := 3
    timeBetweenRetries := 5 * time.Second
    
    retry.DoWithRetry(t, "Deploy infrastructure", maxRetries, timeBetweenRetries,
        func() (string, error) {
            terraformOptions := &terraform.Options{
                TerraformDir: "../modules/app",
            }
            
            terraform.InitAndApply(t, terraformOptions)
            return "", nil
        },
    )
}
```

### 2. HTTP Testing

```go
func TestHTTPEndpoint(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/web-app",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    url := terraform.Output(t, terraformOptions, "app_url")
    
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
}
```

### 3. SSH Testing

```go
func TestSSHConnection(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/ec2",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    publicIP := terraform.Output(t, terraformOptions, "public_ip")
    keyPair := terraform.Output(t, terraformOptions, "key_pair")
    
    host := ssh.Host{
        Hostname:    publicIP,
        SshKeyPair:  keyPair,
        Username:    "ec2-user",
    }
    
    // Run command via SSH
    output := ssh.CheckSshCommand(t, host, "echo 'Hello, World!'")
    assert.Equal(t, "Hello, World!", output)
}
```

## Testing Cloud-Specific Resources

### AWS Resources

```go
func TestAWSResources(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/aws",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Test S3 bucket
    bucketName := terraform.Output(t, terraformOptions, "bucket_name")
    aws.AssertS3BucketExists(t, "us-west-2", bucketName)
    
    // Test RDS instance
    dbAddress := terraform.Output(t, terraformOptions, "db_address")
    aws.GetRdsInstanceById(t, dbAddress, "us-west-2")
}
```

### Azure Resources

```go
func TestAzureResources(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/azure",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Test Azure Container Registry
    acrName := terraform.Output(t, terraformOptions, "acr_name")
    azure.ContainerRegistryExists(t, acrName, "my-resource-group", "my-subscription")
}
```

## Test Fixtures

### 1. Example Test Fixture

```go
type TestFixture struct {
    terraform *terraform.Options
    workDir   string
}

func setupTestFixture(t *testing.T) *TestFixture {
    workDir, err := ioutil.TempDir("", "terraform-test")
    require.NoError(t, err)
    
    terraformOptions := &terraform.Options{
        TerraformDir: workDir,
        Vars: map[string]interface{}{
            "environment": "test",
        },
    }
    
    return &TestFixture{
        terraform: terraformOptions,
        workDir:   workDir,
    }
}

func (f *TestFixture) Cleanup() {
    os.RemoveAll(f.workDir)
}
```

### 2. Using Test Fixtures

```go
func TestWithFixture(t *testing.T) {
    fixture := setupTestFixture(t)
    defer fixture.Cleanup()
    
    terraform.InitAndApply(t, fixture.terraform)
    
    // Run tests...
}
```

## Test Parallelization

### 1. Parallel Test Execution

```go
func TestParallelDeployments(t *testing.T) {
    t.Parallel()
    
    uniqueId := random.UniqueId()
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/app",
        Vars: map[string]interface{}{
            "app_name": fmt.Sprintf("test-app-%s", uniqueId),
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
}
```

### 2. Resource Naming for Parallel Tests

```go
func getUniqueTestName(t *testing.T) string {
    return fmt.Sprintf("test-%s-%s", t.Name(), random.UniqueId())
}

func TestMultipleInstances(t *testing.T) {
    t.Parallel()
    
    testName := getUniqueTestName(t)
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/instance",
        Vars: map[string]interface{}{
            "instance_name": testName,
        },
    }
    
    // Deploy and test...
}
```

## Testing Best Practices

### 1. Environment Cleanup

```go
func ensureCleanup(t *testing.T, options *terraform.Options) {
    defer func() {
        if err := recover(); err != nil {
            terraform.Destroy(t, options)
            panic(err)
        }
    }()
    
    terraform.Destroy(t, options)
}
```

### 2. Test Timeouts

```go
func TestWithTimeout(t *testing.T) {
    timeout := 30 * time.Minute
    ctx, cancel := context.WithTimeout(context.Background(), timeout)
    defer cancel()
    
    done := make(chan bool)
    go func() {
        // Run your test
        terraform.InitAndApply(t, terraformOptions)
        done <- true
    }()
    
    select {
    case <-done:
        // Test completed successfully
    case <-ctx.Done():
        t.Fatal("Test timed out")
    }
}
```

### 3. Test Logging

```go
func TestWithLogging(t *testing.T) {
    logger := terraform.NewLogger(t)
    defer logger.Cleanup()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/app",
        Logger:       logger,
    }
    
    logger.Logf(t, "Starting test deployment...")
    terraform.InitAndApply(t, terraformOptions)
    logger.Logf(t, "Deployment complete")
}
```

## CI/CD Integration

```yaml
name: Terratest
on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
          
      - name: Install Terraform
        uses: hashicorp/setup-terraform@v3
        
      - name: Download dependencies
        run: |
          cd test
          go mod download
          
      - name: Run Terratest
        run: |
          cd test
          go test -v -timeout 30m
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Troubleshooting

### Common Issues and Solutions

1. **State Lock Issues**
```go
func TestWithStateLock(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/app",
        Lock:         true,
        LockTimeout:  "5m",
    }
    
    terraform.InitAndApply(t, terraformOptions)
}
```

2. **Provider Authentication**
```go
func init() {
    os.Setenv("AWS_SDK_LOAD_CONFIG", "true")
    os.Setenv("AWS_DEFAULT_REGION", "us-west-2")
}
```

3. **Resource Dependencies**
```go
func TestWithDependencies(t *testing.T) {
    // Deploy dependencies first
    depOptions := &terraform.Options{
        TerraformDir: "../modules/dependencies",
    }
    terraform.InitAndApply(t, depOptions)
    
    // Get outputs from dependencies
    dbEndpoint := terraform.Output(t, depOptions, "db_endpoint")
    
    // Use in main deployment
    appOptions := &terraform.Options{
        TerraformDir: "../modules/app",
        Vars: map[string]interface{}{
            "db_endpoint": dbEndpoint,
        },
    }
    terraform.InitAndApply(t, appOptions)
}
```
