# Linkerd (2025)

Linkerd is a lightweight, open-source service mesh for Kubernetes. It provides runtime debugging, observability, reliability, and security (mTLS) for microservices—without requiring code changes. Linkerd is production-proven and works on all major clouds (AKS, EKS, GKE) and on-prem clusters.

---

## What is a Service Mesh and Why Use Linkerd?

A service mesh is an infrastructure layer that transparently manages service-to-service communication. It provides:

- **Traffic management:** Fine-grained routing, retries, timeouts, circuit breaking
- **Security:** mTLS encryption, service authentication, and policy enforcement
- **Observability:** Distributed tracing, metrics, and logging for all service traffic
- **Reliability:** Automatic retries, failover, and health checks
- **Zero-trust networking:** Enforce least-privilege and secure-by-default communication

**Why Linkerd?**

- Lightweight and easy to install (no complex CRDs or sidecar bloat)
- Fast startup and low resource usage
- Works with GitOps tools (ArgoCD, Flux) for declarative, auditable deployments
- Multi-cloud and hybrid ready

---

## Pros and Cons

| Pros | Cons |
|------|------|
| Lightweight, simple to operate | Fewer advanced features than Istio |
| Fast, low resource overhead | No built-in API gateway |
| Secure by default (mTLS) | Smaller ecosystem than Istio |
| GitOps-friendly | |
| Great for SRE/DevOps teams | |

---

## Step-by-Step: Linkerd Setup and Configuration

### 0. Prerequisites

- Access to a Kubernetes cluster (AKS, EKS, GKE, or local)
- `kubectl` installed and configured
- (Optional) GitOps tool (ArgoCD, Flux) for declarative management

Validate your cluster:

```bash
kubectl version --short
```

### 1. Install the Linkerd CLI

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin
linkerd version
```

### 2. Validate Your Cluster

```bash
linkerd check --pre
```

### 3. Install the Control Plane

```bash
linkerd install | kubectl apply -f -
linkerd check
```

### 4. Install Extensions (Observability)

```bash
linkerd viz install | kubectl apply -f -
linkerd check
```

### 5. Explore the Dashboard

```bash
linkerd viz dashboard &
```

---

## Real-Life Example: GitOps with Linkerd and ArgoCD

1. Store your Linkerd manifests and Helm values in Git.
2. Define an ArgoCD Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: linkerd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-org/your-gitops-repo.git'
    targetRevision: main
    path: k8s/linkerd
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: linkerd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

3. Apply with:

```bash
kubectl apply -f linkerd-argocd-app.yaml
```

---

## Demo App: Emojivoto

Install the demo app:

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
kubectl -n emojivoto port-forward svc/web-svc 8080:80
```

Inject Linkerd sidecars:

```bash
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -
linkerd -n emojivoto check --proxy
```

---

## Best Practices (2025)

- Use GitOps (ArgoCD, Flux) for all Linkerd config and upgrades
- Enable mTLS and monitor mesh health with Prometheus/Grafana
- Use LLMs (Copilot, Claude) to generate and review mesh policies and manifests
- Document mesh usage and onboarding for your team

## Common Pitfalls

- Not enabling mTLS (misses security benefits)
- Manual changes outside Git (causes drift)
- Not monitoring mesh resource usage

---

## References

- [Linkerd Docs](https://linkerd.io/2.14/)
- [Linkerd GitHub](https://github.com/linkerd/linkerd2)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Flux Docs](https://fluxcd.io/docs/)
