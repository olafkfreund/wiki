---
description: This is a list of tools and how to install them.
---

# DevOps tools

| Tool              | AWS                | Azure                | GCP                 | Main Cloud Services Integrated |
|-------------------|--------------------|----------------------|---------------------|-------------------------------|
| Terraform         | ✅                 | ✅                   | ✅                  | EC2, S3, IAM, AKS, GKE, VMs, Storage, Networking |
| Ansible           | ✅                 | ✅                   | ✅                  | EC2, VMSS, Compute Engine, AKS, GKE, Networking  |
| AWS CLI           | ✅                 | ❌                   | ❌                  | All AWS services              |
| Azure CLI         | ❌                 | ✅                   | ❌                  | All Azure services            |
| gcloud SDK        | ❌                 | ❌                   | ✅                  | All GCP services              |
| Kubernetes (kubectl)| ✅               | ✅                   | ✅                  | EKS, AKS, GKE                 |
| Docker            | ✅                 | ✅                   | ✅                  | ECS, ECR, ACR, GCR, App Services, Cloud Run      |
| Helm              | ✅                 | ✅                   | ✅                  | EKS, AKS, GKE                 |
| GitHub Actions    | ✅                 | ✅                   | ✅                  | CI/CD for all services        |
| Azure Pipelines   | ✅                 | ✅                   | ✅                  | CI/CD for all services        |
| GitLab CI/CD      | ✅                 | ✅                   | ✅                  | CI/CD for all services        |
| Prometheus        | ✅                 | ✅                   | ✅                  | EKS, AKS, GKE, VMs            |
| Grafana           | ✅                 | ✅                   | ✅                  | CloudWatch, Azure Monitor, Stackdriver, Prometheus|
| Vault             | ✅                 | ✅                   | ✅                  | Secrets for VMs, AKS, EKS, GKE |
| Jenkins           | ✅                 | ✅                   | ✅                  | CI/CD for all services        |
| ArgoCD            | ✅                 | ✅                   | ✅                  | EKS, AKS, GKE (GitOps)        |
| FluxCD            | ✅                 | ✅                   | ✅                  | EKS, AKS, GKE (GitOps)        |
| OpenAI/LLMs       | ✅                 | ✅                   | ✅                  | Bedrock, Azure OpenAI, Vertex AI|

**Legend:**

- ✅ = Supported/commonly used
- ❌ = Not supported

> For more details, see the official documentation for each tool and cloud provider.
