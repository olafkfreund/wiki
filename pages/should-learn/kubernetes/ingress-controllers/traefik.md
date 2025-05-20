# Traefik Ingress Controller (2025)

Traefik is a modern, cloud-native ingress controller for Kubernetes, supporting dynamic configuration, Let's Encrypt, and advanced routing. It is widely used in GitOps workflows for AKS, EKS, GKE, and on-prem clusters.

---

## Why Use Traefik?

- Simple, dynamic configuration (CRDs, YAML, Helm)
- Native support for Let's Encrypt, mTLS, and advanced routing
- Works with GitOps tools (ArgoCD, Flux) for declarative, auditable deployments
- Real-time dashboard and metrics
- Multi-cloud and hybrid ready

---

## Installation (Helm)

**Requirements:**

- Kubernetes 1.16+
- Helm 3.9+

Add the Traefik Helm repo:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

Install Traefik in a dedicated namespace:

```bash
kubectl create ns traefik-v2
helm install --namespace=traefik-v2 traefik traefik/traefik
```

---

## GitOps Setup Example (ArgoCD)

**1. Add Traefik Helm chart to your Git repo:**

```yaml
# apps/traefik/values.yaml
# (customize as needed)
```

**2. Define an ArgoCD Application:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: traefik
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-org/your-gitops-repo.git'
    targetRevision: main
    path: apps/traefik
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: traefik-v2
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**3. Apply the Application:**

```bash
kubectl apply -f traefik-argocd-app.yaml
```

---

## Exposing the Traefik Dashboard

**Port-forward (default, secure):**

```bash
kubectl port-forward -n traefik-v2 $(kubectl get pods -n traefik-v2 -l app.kubernetes.io/name=traefik -o name | head -n1) 9000:9000
```

Access at: [http://127.0.0.1:9000/dashboard/](http://127.0.0.1:9000/dashboard/)

**IngressRoute CRD Example:**

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: traefik-v2
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.localhost`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```

---

## Dynamic Routing Example

```yaml
http:
  routers:
    to-whoami:
      rule: "Host(`example.com`) && PathPrefix(`/whoami/`)"
      middlewares:
      - test-user
      service: whoami
  middlewares:
    test-user:
      basicAuth:
        users:
        - test:$apr1$H6uskkkW$IgXLP6ewTrSuBkTrqE8wj/
  services:
    whoami:
      loadBalancer:
        servers:
        - url: http://private/whoami-service
```

---

## Pros and Cons

| Pros | Cons |
|------|------|
| Easy dynamic config (CRDs, Helm) | Fewer built-in policies than NGINX |
| Native Let's Encrypt, mTLS | Smaller community than NGINX |
| Real-time dashboard | Some advanced features require CRDs |
| GitOps-friendly | May need tuning for high-traffic workloads |
| Multi-cloud support | |

---

## 2025 Best Practices

- Use GitOps (ArgoCD, Flux) for all Traefik config and upgrades
- Store all manifests and Helm values in Git (version control)
- Use RBAC and network policies to secure Traefik
- Enable HTTPS and automatic certificate management
- Monitor with Prometheus/Grafana and enable dashboard access only for admins
- Use LLMs (Copilot, Claude) to generate and review IngressRoute and middleware configs

## Common Pitfalls

- Exposing the dashboard publicly (security risk)
- Not enabling HTTPS by default
- Manual changes outside Git (causes drift in GitOps)
- Not monitoring for sync errors or drift

---

## References

- [Traefik Helm Chart](https://github.com/traefik/traefik-helm-chart)
- [Traefik Docs](https://doc.traefik.io/traefik/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Flux Docs](https://fluxcd.io/docs/)
- [Kubernetes Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
