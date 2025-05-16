# FinOps Implementation Guide (2024+)

## Cost Optimization

### Kubecost Configuration
```yaml
apiVersion: cost-analyzer.kubecost.com/v1beta1
kind: CostAnalyzerConfig
metadata:
  name: cost-analyzer
spec:
  kubecostToken: "${KUBECOST_TOKEN}"
  prometheus:
    external:
      url: http://prometheus.monitoring:9090
  cloudCost:
    enabled: true
    provider: aws
    region: us-west-2
```

## Resource Management

### Vertical Pod Autoscaling
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: cost-optimized-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: application
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      minAllowed:
        cpu: 100m
        memory: 50Mi
      maxAllowed:
        cpu: 1
        memory: 500Mi
      controlledResources: ["cpu", "memory"]
```

## Cost Allocation

### Tagging Policy
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-cost-tags
spec:
  validationFailureAction: enforce
  rules:
  - name: validate-cost-tags
    match:
      resources:
        kinds:
        - Pod
        - Service
        - Deployment
    validate:
      message: "Required cost allocation tags are missing"
      pattern:
        metadata:
          labels:
            cost-center: "?*"
            environment: "?*"
            team: "?*"
```

## Cloud Cost Controls

### AWS Cost Categories
```yaml
apiVersion: aws.upbound.io/v1beta1
kind: CostCategory
metadata:
  name: environment-costs
spec:
  forProvider:
    name: EnvironmentCosts
    rules:
      - rule:
          tags:
            key: Environment
            values: ["Production", "Staging", "Development"]
          type: REGULAR
    splitChargeRules:
      - source: Environment
        targets: ["Production", "Staging"]
        method: PROPORTIONAL
```

## Best Practices

1. **Cost Visibility**
   - Resource tracking
   - Usage metrics
   - Allocation reports
   - Forecasting

2. **Optimization**
   - Right-sizing
   - Spot instances
   - Reserved capacity
   - Automatic scaling

3. **Governance**
   - Budget controls
   - Policy enforcement
   - Tagging standards
   - Approval workflows

4. **Reporting**
   - Cost attribution
   - Usage patterns
   - Trend analysis
   - ROI metrics