# Service Mesh Implementation Guide (2024+)

## Multi-Cloud Service Mesh

### Istio Configuration
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: multi-cluster-mesh
spec:
  profile: default
  components:
    pilot:
      k8s:
        env:
          - name: PILOT_TRACE_SAMPLING
            value: "100"
  meshConfig:
    enableTracing: true
    defaultConfig:
      tracing:
        sampling: 100
        zipkin:
          address: otel-collector.observability:9411
```

## Cross-Cluster Communication

### Service Discovery
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: cross-cluster-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: tls
      protocol: TLS
    tls:
      mode: MUTUAL
    hosts:
    - "*.mesh.internal"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: cross-cluster-routing
spec:
  hosts:
  - "service-b.mesh.internal"
  gateways:
  - cross-cluster-gateway
  http:
  - route:
    - destination:
        host: service-b
        port:
          number: 8080
```

## Security Implementation

### mTLS and Authorization
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: service-auth
spec:
  selector:
    matchLabels:
      app: backend-service
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/frontend/sa/frontend-service"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/api/v1/*"]
```

## Observability Integration

### Telemetry Collection
```yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: mesh-telemetry
spec:
  tracing:
  - customTags:
      cluster_name:
        literal:
          value: ${CLUSTER_NAME}
    providers:
    - name: otel
    randomSamplingPercentage: 100.0
  metrics:
  - providers:
    - name: prometheus
    overrides:
    - match:
        metric: REQUEST_COUNT
        mode: CLIENT_AND_SERVER
      tagOverrides:
        service.name:
          value: "$upstream_cluster"