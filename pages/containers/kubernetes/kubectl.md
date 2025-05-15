# Kubectl (2025)

Kubectl is the standard command-line tool for interacting with Kubernetes clusters across all major cloud providers (AKS, EKS, GKE) and on-premises environments. It enables you to deploy, manage, and troubleshoot Kubernetes resources efficiently.

---

## Installation

### Linux/WSL
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ kubectl ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

---

## Connecting to Managed Clusters
- **AKS:** `az aks get-credentials --resource-group <rg> --name <cluster>`
- **EKS:** `aws eks update-kubeconfig --region <region> --name <cluster>`
- **GKE:** `gcloud container clusters get-credentials <cluster> --region <region>`

---

## Common Usage Examples

- Create a deployment:
  ```bash
  kubectl create deployment webapp --image=nginx:1.25
  ```
- View deployment status:
  ```bash
  kubectl rollout status deployment/webapp
  ```
- Scale a deployment:
  ```bash
  kubectl scale deployment/webapp --replicas=5
  ```
- Update deployment image:
  ```bash
  kubectl set image deployment/webapp nginx=nginx:1.26
  ```
- Create a service:
  ```bash
  kubectl expose deployment webapp --type=LoadBalancer --port=80
  ```
- View pod logs:
  ```bash
  kubectl logs <pod-name>
  ```
- Create a secret:
  ```bash
  kubectl create secret generic mysecret --from-literal=key=value
  ```
- Create a ConfigMap:
  ```bash
  kubectl create configmap myconfig --from-literal=key=value
  ```

---

## Real-Life DevOps Scenarios
- Use `kubectl` in CI/CD pipelines (GitHub Actions, Azure Pipelines, GitLab CI) for automated deployments and rollbacks.
- Integrate with GitOps tools (ArgoCD, Flux) for declarative cluster management.
- Use LLMs (Copilot, Claude) to generate manifests and troubleshoot errors.
- Automate cluster context switching for multi-cloud workflows.

---

## Best Practices (2025)
- Always use the latest stable version of kubectl
- Use `kubectl --context` to manage multiple clusters
- Validate YAML with `kubectl apply --dry-run=client -f <file>`
- Use `kubectl explain <resource>` for quick documentation
- Prefer declarative (`apply`) over imperative (`create`, `edit`) workflows
- Use RBAC and namespaces for security and isolation

## Common Pitfalls
- Not matching kubectl version to cluster version (can cause errors)
- Forgetting to set the correct context before running commands
- Applying unvalidated YAML (syntax or schema errors)

---

## References
- [Kubectl Official Docs](https://kubernetes.io/docs/reference/kubectl/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [AKS Quickstart](https://learn.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [GKE Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart)
