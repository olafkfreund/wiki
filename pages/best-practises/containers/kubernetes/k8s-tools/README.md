# Kubernetes Tools for Linux and WSL

As a DevOps engineer working with Kubernetes on Linux or Windows Subsystem for Linux (WSL), these tools will boost your productivity, troubleshooting, and automation capabilities.

---

## kubectl
The official Kubernetes CLI for managing clusters, resources, and troubleshooting.
```sh
kubectl get pods -A
kubectl describe node <node-name>
```

## k9s
Terminal UI for managing Kubernetes clusters interactively.
```sh
k9s
```

## kubectx & kubens
Quickly switch between clusters (kubectx) and namespaces (kubens).
```sh
kubectx
kubens
```

## Stern
Tail and filter logs from multiple pods in real time.
```sh
stern <pod-name>
```

## Helm
Kubernetes package manager for deploying and managing applications.
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install myapp bitnami/nginx
```

## Lens
GUI for managing and visualizing Kubernetes clusters. Works on Linux and WSL with X server.

## kubeseal
Encrypt Kubernetes secrets for use with GitOps tools like Flux and ArgoCD.
```sh
kubeseal < secret.yaml > sealedsecret.yaml
```

## kustomize
Customize Kubernetes YAML configurations.
```sh
kustomize build ./overlays/dev | kubectl apply -f -
```

## ArgoCD CLI & Flux CLI
Manage GitOps workflows from the command line.
```sh
argocd app list
flux get kustomizations
```

## kubetail
Aggregate logs from multiple pods.
```sh
kubetail <pod-base-name>
```

---

### Best Practices
- Use kubectl plugins (e.g., krew) to extend functionality
- Store kubeconfigs securely and use context switching for multi-cluster work
- Automate repetitive tasks with scripts and CLIs
- Use LLMs (Copilot, Claude) to generate troubleshooting scripts or YAML manifests

---

### References
- [Kubernetes Official Tools](https://kubernetes.io/docs/tasks/tools/)
- [Awesome Kubernetes Tools](https://github.com/ramitsurana/awesome-kubernetes#tools)
- [kubectl Plugins (krew)](https://krew.sigs.k8s.io/)

