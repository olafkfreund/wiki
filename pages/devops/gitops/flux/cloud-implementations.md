# Cloud-Specific Progressive Delivery Configurations

## AWS Implementation

### EKS Configuration

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: progressive-delivery-cluster
  region: us-west-2
spec:
  iam:
    withOIDC: true
  addons:
    - name: aws-load-balancer-controller
    - name: aws-for-fluent-bit
    - name: aws-cloudwatch-metrics

  flux:
    gitProvider: github
    flags:
      components-extra: image-reflector-controller,image-automation-controller
```

### AWS App Mesh Integration

```yaml
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualService
metadata:
  name: app-service
spec:
  provider:
    virtualRouter:
      virtualRouterRef:
        name: app-router
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: app-router
spec:
  listeners:
    - portMapping:
        port: 8080
        protocol: http
  routes:
    - name: primary-route
      httpRoute:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeRef:
                name: app-primary
              weight: 90
            - virtualNodeRef:
                name: app-canary
              weight: 10
```

## Azure Implementation

### AKS Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    azure.workload.identity/client-id: ${AZURE_CLIENT_ID}
    azure.workload.identity/tenant-id: ${AZURE_TENANT_ID}
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"
```

### Azure Traffic Manager

```yaml
apiVersion: network.azure.io/v1
kind: TrafficManagerProfile
metadata:
  name: app-traffic
spec:
  trafficRoutingMethod: Weighted
  dnsConfig:
    relativeName: app-progressive
    ttl: 30
  monitorConfig:
    protocol: HTTPS
    port: 443
    path: /health
  endpoints:
    - name: primary
      type: ExternalEndpoints
      weight: 90
    - name: canary
      type: ExternalEndpoints
      weight: 10
```

## GCP Implementation

### GKE Configuration

```yaml
apiVersion: container.google.com/v1beta1
kind: ClusterConfig
metadata:
  name: progressive-delivery-gke
spec:
  workloadIdentityConfig:
    workloadPool: ${PROJECT_ID}.svc.id.goog
  meshConfig:
    mode: ENABLED
```

### Cloud Load Balancing

```yaml
apiVersion: networking.gke.io/v1
kind: MultiClusterIngress
metadata:
  name: app-ingress
spec:
  template:
    spec:
      backend:
        serviceName: app-backend
        servicePort: 80
      rules:
      - http:
          paths:
          - path: /*
            backend:
              serviceName: app-service
              servicePort: 80
```

## Cloud-Specific Best Practices

1. **AWS**
   - Use AWS App Mesh for service mesh
   - Implement AWS X-Ray for tracing
   - Configure CloudWatch metrics
   - Leverage IAM roles for service accounts

2. **Azure**
   - Use Azure Service Mesh
   - Implement Application Insights
   - Configure Azure Monitor
   - Use Azure Workload Identity

3. **GCP**
   - Use Anthos Service Mesh
   - Implement Cloud Trace
   - Configure Cloud Monitoring
   - Use Workload Identity

4. **Common Patterns**
   - Container Registry setup
   - DNS configuration
   - SSL/TLS management
   - Backup and DR strategies
