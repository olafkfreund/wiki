# Ingress Controllers in Kubernetes

Ingress controllers are specialized Kubernetes resources that manage external access to services within a cluster, typically HTTP/HTTPS traffic. They act as reverse proxies, routing requests from outside the cluster to the appropriate internal services based on rules defined in Ingress resources.

---

## Why Use an Ingress Controller?

- **Consolidate access:** Manage all external traffic through a single entry point.
- **TLS termination:** Handle SSL/TLS at the ingress layer.
- **Path and host-based routing:** Route traffic based on URL paths or hostnames.
- **Load balancing:** Distribute requests across multiple backend pods.
- **Security:** Enforce authentication, rate limiting, and web application firewall (WAF) policies.

---

## How Ingress Controllers Work

1. **Deploy an ingress controller** (e.g., NGINX, Traefik, Kong, Gloo Edge) as a pod in your cluster.
2. **Create Ingress resources** that define routing rules (host/path to service mapping).
3. The ingress controller watches for Ingress resources and configures itself to route traffic accordingly.

---

## Example: Deploying NGINX Ingress Controller (AKS/EKS/GKE)

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

**Verify deployment:**

```sh
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

**Sample Ingress resource:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: demo.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

---

## Best Practices

- Use a managed ingress controller (e.g., AWS ALB Ingress, Azure Application Gateway) for production workloads.
- Always enable TLS for secure communication.
- Use path and host-based routing to organize microservices.
- Monitor ingress controller logs and metrics for troubleshooting.
- Store ingress manifests in Git for GitOps workflows.

---

## Common Pitfalls

- Not exposing the ingress controller service (type: LoadBalancer or NodePort).
- Missing DNS records for host-based routing.
- Forgetting to update firewall/network security group rules.
- Overlooking resource limits for ingress controller pods.

---

## References

- [Kubernetes Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [NGINX Ingress Controller Docs](https://kubernetes.github.io/ingress-nginx/)
- [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Kong Ingress Controller](https://docs.konghq.com/kubernetes-ingress-controller/latest/introduction/)
- [Gloo Edge Ingress Controller](https://docs.solo.io/gloo-edge/latest/guides/)
