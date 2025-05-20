# Contour

Contour is a high-performance, cloud-native ingress controller for Kubernetes, built on Envoy Proxy. It is widely used in AWS, Azure, GCP, and hybrid environments for advanced HTTP/HTTPS routing, TLS termination, and integration with the Gateway API. Contour supports both traditional Ingress and modern Gateway API resources, making it a flexible choice for DevOps teams.

---

## Installation Options

### Option 1: YAML (Quick Start)

Install Contour and Envoy using the official YAML manifest:

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

Verify the Contour pods are ready:

```bash
kubectl get pods -n projectcontour -o wide
```

You should see:

- 2 Contour pods (Running, 1/1 Ready)
- 1+ Envoy pods (Running, 2/2 Ready)

### Option 2: Helm (Recommended for Production)

Install with Helm for versioned, repeatable deployments:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-release bitnami/contour --namespace projectcontour --create-namespace
```

Verify Contour and Envoy:

```bash
kubectl -n projectcontour get po,svc
```

You should see:

- pod/my-release-contour-contour (Running, 1/1 Ready)
- pod/my-release-contour-envoy (Running, 2/2 Ready)
- service/my-release-contour, service/my-release-contour-envoy

### Option 3: Contour Gateway Provisioner (Gateway API)

Provision Contour+Envoy dynamically using the Gateway API:

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
```

Verify the deployment:

```bash
kubectl -n projectcontour get deployments
```

Create a GatewayClass and Gateway:

```yaml
# GatewayClass
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: contour
spec:
  controllerName: projectcontour.io/gateway-controller
---
# Gateway
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: contour
  namespace: projectcontour
spec:
  gatewayClassName: contour
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
```

Apply with:

```bash
kubectl apply -f gateway.yaml
```

Verify Gateway and pods:

```bash
kubectl -n projectcontour get gateways
kubectl -n projectcontour get pods
```

---

## Real-Life Example: Exposing a Web Application

### 1. Deploy a Sample App (httpbin)

```bash
kubectl apply -f https://projectcontour.io/examples/httpbin.yaml
```

Verify resources:

```bash
kubectl get po,svc,ing -l app=httpbin
```

You should see:

- 3 pods/httpbin (Running, 1/1 Ready)
- 1 service/httpbin (port 80)
- 1 Ingress (port 80)

### 2. Set IngressClass (if using Helm)

```bash
kubectl patch ingress httpbin -p '{"spec":{"ingressClassName": "contour"}}'
```

### 3. Port-Forward to Envoy (for local testing)

```bash
# YAML install
kubectl -n projectcontour port-forward service/envoy 8888:80
# Helm install
kubectl -n projectcontour port-forward service/my-release-contour-envoy 8888:80
# Gateway provisioner
kubectl -n projectcontour port-forward service/envoy-contour 8888:80
```

### 4. Test the Application

In a browser or with curl:

```bash
curl http://local.projectcontour.io:8888/
```

You should see the httpbin home page.

---

## Best Practices

- Use Helm for production and GitOps workflows
- Store all manifests and Helm values in Git
- Use Gateway API for future-proof, flexible routing
- Monitor Contour and Envoy with Prometheus/Grafana
- Restrict external access with network policies and firewalls

---

## References

- [Contour Official Docs](https://projectcontour.io/docs/)
- [Contour GitHub](https://github.com/projectcontour/contour)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Kubernetes Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

> **Tip:** Integrate Contour with CI/CD (GitHub Actions, ArgoCD, Flux) for automated ingress and API gateway management in multi-cloud environments.
