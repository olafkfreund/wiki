# Kong

Kong is a cloud-native, open-source API gateway and Kubernetes ingress controller. It provides advanced routing, security, and observability features for microservices and APIs. Kong is widely used in AWS, Azure, GCP, and hybrid environments for managing north-south traffic, API management, and integrating legacy and modern workloads.

---

## Key Features

- **Ingress routing:** Use [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resources to configure Kong for HTTP, HTTPS, and gRPC traffic.
- **API management with plugins:** Monitor, transform, secure, and rate-limit traffic using [Kong plugins](https://docs.konghq.com/hub/).
- **Native gRPC support:** Proxy and secure gRPC traffic with full plugin support.
- **Health checking & load balancing:** Distribute requests across pods with active and passive health checks.
- **Request/response transformations:** Modify traffic on the fly using plugins.
- **Authentication:** Protect services with JWT, OAuth2, key-auth, and more.
- **Declarative configuration:** Manage Kong using Kubernetes CRDs for GitOps and automation.
- **Gateway Discovery:** Monitor and push config to all Kong Gateway replicas.

---

## Installation

**YAML (quick start):**

```sh
kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/latest/deploy/single/all-in-one-dbless.yaml
```

**Helm (recommended for production):**

```sh
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong/kong --generate-name --set ingressController.installCRDs=false
```

---

## Real-Life Example: Exposing a Microservice with Kong

### 1. Set the Kong Proxy IP

Get the external IP of the Kong proxy service:

```sh
export PROXY_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" service -n kong demo-kong-proxy)
```

### 2. Test Kong Gateway Connectivity

```sh
curl -i $PROXY_IP
```

Expected: HTTP 404 Not Found (no route configured yet)

### 3. Deploy an Upstream HTTP Application

Deploy a simple echo server:

```sh
echo "
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echo
  name: echo
spec:
  ports:
  - port: 1027
    name: http
    protocol: TCP
    targetPort: 1027
  selector:
    app: echo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: echo
  name: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - image: kong/go-echo:latest
        name: echo
        ports:
        - containerPort: 1027
" | kubectl apply -f -
```

### 4. Create an IngressClass (if needed)

```sh
echo "
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: kong
spec:
  controller: ingress-controllers.konghq.com/kong
" | kubectl apply -f -
```

### 5. Add Routing Configuration

Create an Ingress to route /echo to the echo service:

```sh
echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  annotations:
    konghq.com/strip-path: 'true'
spec:
  ingressClassName: kong
  rules:
  - host: kong.example
    http:
      paths:
      - path: /echo
        pathType: ImplementationSpecific
        backend:
          service:
            name: echo
            port:
              number: 1027
" | kubectl apply -f -
```

Test the route:

```sh
curl -i http://kong.example/echo --resolve kong.example:80:$PROXY_IP
```

---

## Real-Life Example: Securing and Rate-Limiting with Plugins

### 1. Enable a Plugin (e.g., Correlation ID)

```sh
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: request-id
config:
  header_name: my-request-id
  echo_downstream: true
plugin: correlation-id
" | kubectl apply -f -
```

Annotate the Ingress to use the plugin:

```sh
kubectl annotate ingress echo konghq.com/plugins=request-id
```

### 2. Enable Rate Limiting on a Service

```sh
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rl-by-ip
config:
  minute: 5
  limit_by: ip
  policy: local
plugin: rate-limiting
" | kubectl apply -f -
```

Annotate the Service:

```sh
kubectl annotate service echo konghq.com/plugins=rl-by-ip
```

Test the rate limit:

```sh
curl -i http://kong.example/echo --resolve kong.example:80:$PROXY_IP
```

---

## Best Practices

- Use Helm for repeatable, versioned Kong deployments
- Store all configuration (Helm values, CRDs, plugins) in Git for GitOps
- Use plugins for authentication, rate limiting, and observability
- Monitor Kong and application health with Prometheus/Grafana
- Restrict external access with network policies and firewalls

---

## References

- [Kong Ingress Controller Docs](https://docs.konghq.com/kubernetes-ingress-controller/latest/)
- [Kong Plugins Hub](https://docs.konghq.com/hub/)
- [Kong GitHub](https://github.com/Kong/kubernetes-ingress-controller)
- [Kubernetes Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

> **Tip:** Integrate Kong with CI/CD (GitHub Actions, ArgoCD, Flux) for automated API gateway and ingress management in multi-cloud environments.
