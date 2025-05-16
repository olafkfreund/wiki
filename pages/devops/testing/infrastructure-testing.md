# Infrastructure Testing Patterns (2024+)

## Integration Testing

### Terratest Example
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestAzureInfrastructure(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/azure",
        Vars: map[string]interface{}{
            "environment": "test",
            "location":    "westeurope",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vnetName := terraform.Output(t, terraformOptions, "vnet_name")
    assert.NotEmpty(t, vnetName)
}
```

## Policy Testing

### OPA/Conftest
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: policy-library
data:
  kubernetes.rego: |
    package main

    deny[msg] {
      input.kind == "Deployment"
      not input.spec.template.spec.securityContext.runAsNonRoot

      msg = "Containers must not run as root"
    }

    deny[msg] {
      input.kind == "Deployment"
      not input.spec.template.spec.containers[_].resources.limits

      msg = "Resource limits are required"
    }
```

## Chaos Testing

### Chaos Mesh Experiment
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: network-delay
spec:
  action: delay
  mode: one
  selector:
    namespaces:
      - default
    labelSelectors:
      app: web
  delay:
    latency: "100ms"
    correlation: "100"
    jitter: "0ms"
```

## Best Practices

1. **Test Coverage**
   - Unit testing
   - Integration testing
   - End-to-end testing
   - Performance testing

2. **Policy Validation**
   - Security policies
   - Cost policies
   - Compliance rules
   - Resource limits

3. **Chaos Engineering**
   - Network chaos
   - Resource chaos
   - Pod chaos
   - Time chaos

4. **Automation**
   - CI/CD integration
   - Test scheduling
   - Result reporting
   - Change validation