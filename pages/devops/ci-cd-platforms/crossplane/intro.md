# Intro

## Prerequisites <a href="#f54a" id="f54a"></a>

1. A Kubernetes cluster (On-Prem, AKS, EKS, GKE, Kind, etc.).
2. An AWS account (or other supported cloud provider).

### Story Resources <a href="#596f" id="596f"></a>

1. **GitHub Link**: [https://github.com/olafkfreund/crossplane-terraform-manifests/](https://github.com/olafkfreund/crossplane-terraform-manifests/tree/crossplane)
2. **GitHub Branch**: crossplane

---

## Install Crossplane (2025 Best Practices)

You can use any Kubernetes cluster for this demo. For local testing, [Kind](https://kind.sigs.k8s.io/) is recommended. For production, use a managed service (AKS, EKS, GKE, etc.).

### 1. Add the Crossplane Helm repo and install the latest version
```bash
kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane \
  --version 1.16.0 # (replace with latest if newer)
```
- Check for the latest version: https://artifacthub.io/packages/helm/crossplane/crossplane
- Confirm installation:
```bash
kubectl get all -n crossplane-system
```

### 2. Install Crossplane CLI (optional, for local development)
```bash
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
```

---

## Install a Provider (AWS example)

1. **Apply the official AWS provider package (v0.47.0 or newer):**
```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.47.0
```
Apply with:
```bash
kubectl apply -f aws-provider.yaml
```
- Check provider status:
```bash
kubectl get providers.pkg.crossplane.io
```

2. **Configure AWS credentials securely:**
- Use IRSA (EKS), Workload Identity (GKE), or Azure AD Workload Identity (AKS) for production.
- For local/dev, use a Kubernetes secret:
```bash
AWS_PROFILE=default
aws configure export-credentials --profile $AWS_PROFILE --format env > creds.env
kubectl create secret generic aws-secret-creds -n crossplane-system --from-env-file=creds.env
```

3. **Create a ProviderConfig:**
```yaml
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-secret-creds
      key: creds.env
```

---

## Best Practices (2025)
- Use the latest Crossplane and provider versions (see ArtifactHub).
- Use managed identity for cloud credentials in production (avoid static secrets).
- Use Composition/Composite Resources for platform engineering and self-service.
- Use ProviderConfigUsage to scope credentials.
- Use RBAC and namespace isolation for multi-tenancy.
- Monitor Crossplane health with Prometheus/Grafana or Upbound Cloud.
- Use GitOps for all manifests (ArgoCD, Flux, etc.).

---

## References
- [Crossplane Docs](https://docs.crossplane.io/)
- [Upbound Provider AWS](https://marketplace.upbound.io/providers/upbound/provider-aws)
- [Crossplane Helm Chart](https://artifacthub.io/packages/helm/crossplane/crossplane)
- [Production Patterns](https://docs.crossplane.io/latest/concepts/best-practices/)
