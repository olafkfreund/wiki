# Kubernetes Scaling Patterns (2024+)

## Advanced Autoscaling

### KEDA ScaledObject
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaledobject
spec:
  scaleTargetRef:
    name: deployment-name
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus.monitoring.svc.cluster.local:9090
      metricName: http_requests_total
      threshold: '100'
      query: sum(rate(http_requests_total{service="my-service"}[2m]))
```

## Vertical Pod Autoscaling

### VPA Configuration
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: ml-model-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: ml-inference
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      minAllowed:
        memory: "1Gi"
        cpu: "500m"
      maxAllowed:
        memory: "4Gi"
        cpu: "2"
      controlledResources: ["cpu", "memory"]
```

## Multi-Dimensional Scaling

### Custom Metrics
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: custom-metrics
spec:
  selector:
    matchLabels:
      app: service-name
  endpoints:
  - port: metrics
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-metric-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: service-name
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      target:
        type: AverageValue
        averageValue: 1k
```

## Best Practices

1. **Scaling Strategy**
   - Multi-metric scaling
   - Predictive scaling
   - Event-driven scaling
   - Cost optimization

2. **Resource Management**
   - Right-sizing
   - Resource quotas
   - Limit ranges
   - Quality of Service

3. **Performance**
   - Scale velocity
   - Initialization time
   - Resource utilization
   - Cost efficiency

4. **Monitoring**
   - Scaling metrics
   - Resource usage
   - Performance impact
   - Cost tracking