# Modern Networking Patterns (2024+)

## Service Mesh Implementation

### Istio Configuration
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: advanced-routing
spec:
  hosts:
  - service.example.com
  http:
  - match:
    - headers:
        user-agent:
          regex: ".*Mobile.*"
    route:
    - destination:
        host: mobile-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: web-service
        subset: v1
      weight: 100
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: service-auth
spec:
  selector:
    matchLabels:
      app: backend-api
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/frontend"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/api/v1/*"]
```

## Multi-Cloud Connectivity

### Cilium ClusterMesh
```yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumClustermeshConfig
metadata:
  name: multi-cloud-mesh
spec:
  clusters:
  - name: aws-cluster
    address: aws-cluster.mesh.internal:2379
  - name: azure-cluster
    address: azure-cluster.mesh.internal:2379
---
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: cross-cluster-policy
spec:
  endpointSelector:
    matchLabels:
      app: frontend
  ingress:
  - fromEndpoints:
    - matchLabels:
        io.cilium.k8s.policy.cluster: azure-cluster
        app: backend
```

## Advanced Load Balancing

### Gateway API
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: advanced-gateway
spec:
  gatewayClassName: istio
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: advanced-routing
spec:
  parentRefs:
  - name: advanced-gateway
  rules:
  - matches:
    - headers:
      - name: "Content-Type"
        value: "application/json"
    backendRefs:
    - name: api-service
      port: 8080
      weight: 90
    - name: api-service-canary
      port: 8080
      weight: 10
```

## Best Practices

1. **Service Mesh**
   - Traffic management
   - Security policies
   - Observability
   - Load balancing

2. **Multi-Cloud**
   - Service discovery
   - Network policies
   - Traffic encryption
   - Failover handling

3. **Security**
   - Zero trust
   - mTLS everywhere
   - Access policies
   - Network isolation

4. **Performance**
   - Latency optimization
   - Traffic shaping
   - Protocol selection
   - Cache strategies