# Kustomize (2025)

Kustomize is a Kubernetes-native configuration management tool that lets you customize raw, template-free YAML files for different environments. It is built into `kubectl` and works seamlessly with AKS (Azure), EKS (AWS), and GKE (GCP) clusters.

---

## Installation

### Linux/WSL
```bash
# Install via package manager
sudo apt-get install -y kustomize || curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ kustomize ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

---

## Real-Life DevOps Workflow (AKS, EKS, GKE)

Suppose you have a directory named `my-app` with the following structure:

```plaintext
my-app/
├── base/
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── patch.yaml
    └── prod/
        ├── patch.yaml
        └── service.yaml
```

### 1. Build and Apply an Overlay
```bash
cd my-app/overlays/dev
kustomize build | kubectl apply -f -
```

- For AKS: Ensure your `kubectl` context is set with `az aks get-credentials ...`
- For EKS: Use `aws eks update-kubeconfig ...`
- For GKE: Use `gcloud container clusters get-credentials ...`

### 2. Generate YAML for Review or GitOps
```bash
kustomize build > dev-manifest.yaml
```
Use this manifest in GitOps tools like ArgoCD or Flux for automated deployments.

---

## Example: Adding a Label to All Resources
```bash
kustomize edit add label environment=dev
```

## Example: Adding a Patch
```bash
kustomize edit add patch patch.yaml
```

---

## 2025 Best Practices
- Store base and overlays in Git for version control
- Use overlays for environment-specific changes (dev, staging, prod)
- Integrate with GitOps (ArgoCD, Flux) for automated, auditable deployments
- Use LLMs (Copilot, Claude) to generate and review Kustomize patches and overlays
- Validate output with `kustomize build` before applying
- Avoid duplicating YAML—prefer patches and strategic overlays
- Document overlays and patches for team clarity

## Common Pitfalls
- Forgetting to update overlays when base changes
- Overusing overlays, leading to complexity
- Not validating generated manifests before applying

---

## References
- [Kustomize Official Docs](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [Kustomize GitHub](https://github.com/kubernetes-sigs/kustomize)
- [Kustomize with AKS](https://learn.microsoft.com/en-us/azure/aks/kubernetes-kustomize)
- [Kustomize with EKS](https://aws.amazon.com/blogs/opensource/kustomize-eks/)
- [Kustomize with GKE](https://cloud.google.com/architecture/devops/kustomize-gke)
