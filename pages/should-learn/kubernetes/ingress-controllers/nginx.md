# NGINX Ingress Controller (2025)

NGINX is the most widely used ingress controller for Kubernetes, supporting advanced routing, TLS, and integration with all major clouds (AKS, EKS, GKE) and on-prem clusters. It is GitOps-friendly and production-proven.

---

## Why Use NGINX Ingress?
- Mature, large community, and well-documented
- Supports advanced routing, TLS, and authentication
- Works with GitOps tools (ArgoCD, Flux) for declarative, auditable deployments
- Integrates with cloud load balancers (AKS, EKS, GKE)
- Highly customizable via Helm or YAML

---

## Installation (Helm)

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

- Idempotent: installs or upgrades the controller in the `ingress-nginx` namespace.
- For all configurable values:
  ```sh
  helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
  ```

## Installation (YAML Manifest)

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

- Nearly identical resources as Helm install.
- For Kubernetes <1.19, see [version-specific manifests](https://kubernetes.github.io/ingress-nginx/deploy/#running-on-Kubernetes-versions-older-than-1.19).

---

## Pre-flight Check

```sh
kubectl get pods --namespace=ingress-nginx
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

---

## Local Testing Example

Deploy a demo web server and expose it:
```sh
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
```

Create an ingress resource (host maps to localhost):
```sh
kubectl create ingress demo-localhost --class=nginx \
  --rule="demo.localdev.me/*=demo:80"
```

Port-forward to the ingress controller:
```sh
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

Test with curl:
```sh
curl --resolve demo.localdev.me:8080:127.0.0.1 http://demo.localdev.me:8080
```

---

## Online Testing (Cloud LoadBalancer)

Get the external IP:
```sh
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

- Set up a DNS record for your domain to point to the external IP.
- Create an ingress resource for your domain:
  ```sh
  kubectl create ingress demo --class=nginx \
    --rule="www.demo.io/*=demo:80"
  ```

---

## GitOps Example (ArgoCD)

1. Store your ingress manifests in Git.
2. Define an ArgoCD Application:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: nginx-ingress
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: 'https://github.com/your-org/your-gitops-repo.git'
       targetRevision: main
       path: k8s/ingress-nginx
     destination:
       server: 'https://kubernetes.default.svc'
       namespace: ingress-nginx
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```
3. Apply with:
   ```sh
   kubectl apply -f nginx-ingress-argocd-app.yaml
   ```

---

## Pros and Cons
| Pros | Cons |
|------|------|
| Large community, mature | Can be complex to tune for high scale |
| Advanced routing, TLS, auth | Some features require custom templates |
| Works with all clouds | Default config may need hardening |
| GitOps-friendly | |

---

## 2025 Best Practices
- Use GitOps (ArgoCD, Flux) for all NGINX config and upgrades
- Store all manifests and Helm values in Git
- Enable RBAC and network policies for security
- Use HTTPS and automatic certificate management
- Monitor with Prometheus/Grafana
- Use LLMs (Copilot, Claude) to generate and review ingress configs

## Common Pitfalls
- Exposing services without TLS
- Manual changes outside Git (causes drift)
- Not monitoring for sync errors or drift

---

## References
- [NGINX Ingress Docs](https://kubernetes.github.io/ingress-nginx/)
- [Helm Chart](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Flux Docs](https://fluxcd.io/docs/)
