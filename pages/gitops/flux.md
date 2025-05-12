---
description: GitOps for AKS
---

# Flux GitOps for AKS and Azure Arc (2025 Update)

Flux is a CNCF GitOps operator for Kubernetes, integrated with Azure Arc and AKS for declarative, automated cluster management. Below are the latest best practices and command updates for 2025:

## Prerequisites
- Register required resource providers:
  ```bash
  az provider register --namespace Microsoft.Kubernetes
  az provider register --namespace Microsoft.ContainerService
  az provider register --namespace Microsoft.KubernetesConfiguration
  ```
- Install/upgrade the latest CLI extensions:
  ```bash
  az extension add -n k8s-configuration --upgrade
  az extension add -n k8s-extension --upgrade
  ```

## Create a Flux Configuration
- Works with AKS (`-t managedClusters`), Azure Arc (`-t connectedClusters`), and AKS hybrid (`-t provisionedClusters`).
- Example for Azure Arc:
  ```bash
  az k8s-configuration flux create -g flux-demo-rg \
    -c flux-demo-arc \
    -n cluster-config \
    --namespace cluster-config \
    -t connectedClusters \
    --scope cluster \
    -u https://github.com/Azure/gitops-flux2-kustomize-helm-mt \
    --branch main \
    --kustomization name=infra path=./infrastructure prune=true \
    --kustomization name=apps path=./apps/staging prune=true dependsOn=["infra"]
  ```
- For AKS, use `-t managedClusters` and set `-c` to your AKS cluster name.

## Best Practices (2025)
- Use separate namespaces for Flux system and configuration objects.
- Use `prune=true` to ensure deleted resources in Git are also removed from the cluster.
- Use `dependsOn` to control kustomization order.
- Store secrets in Azure Key Vault and reference them securely in manifests.
- Use branch protection and signed commits for GitOps repos.
- Monitor compliance state with `az k8s-configuration flux show ...`.
- Use private Git repos and deploy with SSH or token authentication for production.

## Validate Deployment
- Check compliance state:
  ```bash
  az k8s-configuration flux show -g flux-demo-rg -c flux-demo-arc -n cluster-config -t connectedClusters
  ```
- Confirm namespaces:
  ```bash
  kubectl get namespaces
  ```
- Confirm Flux controllers:
  ```bash
  kubectl get pods -n flux-system
  ```
- Confirm kustomizations, sources, and releases:
  ```bash
  kubectl get kustomizations -A
  kubectl get gitrepositories -A
  kubectl get helmreleases -A
  ```

## References
- [Azure Arc GitOps with Flux v2](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2)
- [FluxCD Documentation](https://fluxcd.io/docs/)
- [AKS GitOps](https://learn.microsoft.com/en-us/azure/aks/gitops-flux)
