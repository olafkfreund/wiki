# GitOps

GitOps is a modern DevOps practice that uses Git as the single source of truth for declarative infrastructure and application configuration. Changes to infrastructure or workloads are made via pull requests, automatically applied to environments by automation tools (e.g., ArgoCD, Flux).

---

## Why Use GitOps?
- **Auditability:** Every change is tracked in Git history (who, what, when, why)
- **Consistency:** Environments are reproducible and drift is minimized
- **Automation:** CI/CD pipelines and GitOps controllers apply changes automatically
- **Rollback:** Easy to revert to a previous state by reverting a commit
- **Collaboration:** Teams use familiar Git workflows (PRs, reviews)
- **Security:** Git-based approval and RBAC, plus integration with secrets management

---

## Real-Life Usage Scenarios
- **Multi-Cloud Kubernetes:** Manage AKS, EKS, and GKE clusters from a single Git repo using ArgoCD or Flux
- **Disaster Recovery:** Restore infrastructure by re-applying Git state after a failure
- **Compliance:** Enforce policies and approvals via Git PRs and code reviews
- **Self-Service Deployments:** Developers submit PRs to deploy or update apps, with automation handling the rollout

---

## Example: GitOps with ArgoCD and Kubernetes

### 1. Install ArgoCD (Kubernetes)
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Connect ArgoCD to Your Git Repository
```yaml
# app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/org/repo.git'
    targetRevision: main
    path: k8s/app
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
Apply with:
```bash
kubectl apply -f app.yaml
```

### 3. Make a Change and Deploy
- Edit a Kubernetes manifest in your Git repo (e.g., update image tag)
- Open a pull request, review, and merge
- ArgoCD detects the change and syncs it to the cluster automatically

---

## Example: GitOps with Terraform and GitHub Actions

```yaml
# .github/workflows/terraform.yaml
name: Terraform GitOps
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

---

## Setup and Configuration
- Use a dedicated Git repo (or mono-repo) for infrastructure and app manifests
- Use branch protection and required reviews for main branches
- Integrate with CI/CD (GitHub Actions, Azure Pipelines, GitLab CI)
- Deploy a GitOps controller (ArgoCD, Flux) to your Kubernetes clusters
- Store secrets in a secure system (e.g., Azure Key Vault, AWS Secrets Manager, Sealed Secrets)
- Use Infrastructure as Code (Terraform, Bicep, Pulumi) for cloud resources

---

## Pros and Cons

| Pros                                   | Cons                                      |
|----------------------------------------|-------------------------------------------|
| Full audit trail (Git history)         | Requires Git and IaC knowledge            |
| Easy rollback and disaster recovery    | Initial setup can be complex              |
| Consistent, reproducible environments  | Secret management needs extra care        |
| Enables self-service and automation    | May require new workflows for some teams  |
| Works across clouds and on-premises    | Tooling sprawl if not standardized        |

---

## 2025 Best Practices
- Use declarative IaC for all resources (Kubernetes, cloud, networking)
- Automate everything: use GitHub Actions, ArgoCD, Flux, or similar
- Protect main branches and require PR reviews
- Use LLMs (Copilot, Claude) to generate and review manifests, policies, and IaC
- Monitor for drift and sync failures (ArgoCD/Flux dashboards, alerts)
- Document GitOps workflows and onboarding in your repo

## Common Pitfalls
- Not managing secrets securely (avoid plain text in Git)
- Manual changes outside Git (causes drift)
- Lack of branch protection or code review
- Not monitoring for sync errors or drift

---

## References
- [GitOps Principles](https://opengitops.dev/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Flux Docs](https://fluxcd.io/docs/)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)

