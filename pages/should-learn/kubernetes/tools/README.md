# Tools

| Tool         | Description                                 | AWS | Azure | GCP | Example Use Case |
|--------------|---------------------------------------------|-----|-------|-----|------------------|
| kubectl      | Kubernetes CLI for cluster management        | ✅  | ✅    | ✅  | Deploy apps, manage resources, debug pods |
| Helm         | Kubernetes package manager (charts)          | ✅  | ✅    | ✅  | Install Prometheus, NGINX Ingress, ArgoCD |
| Kustomize    | Template-free YAML customization             | ✅  | ✅    | ✅  | Overlay configs for dev/prod environments |
| K9s          | Terminal UI for managing clusters            | ✅  | ✅    | ✅  | Real-time pod monitoring and troubleshooting |
| Lens         | Kubernetes IDE (GUI)                         | ✅  | ✅    | ✅  | Visualize workloads, manage clusters |
| ArgoCD       | GitOps continuous delivery controller        | ✅  | ✅    | ✅  | Automated app deployment from Git |
| FluxCD       | GitOps continuous delivery tool              | ✅  | ✅    | ✅  | Declarative cluster state management |
| Prometheus   | Monitoring and alerting toolkit              | ✅  | ✅    | ✅  | Collect cluster and app metrics |
| Grafana      | Visualization and dashboarding               | ✅  | ✅    | ✅  | Create dashboards for Prometheus metrics |
| Velero       | Backup and restore for Kubernetes            | ✅  | ✅    | ✅  | Scheduled cluster backups to S3, Blob, GCS |
| Istio        | Service mesh for traffic management          | ✅  | ✅    | ✅  | Secure, monitor, and control microservices |
| Linkerd      | Lightweight service mesh                     | ✅  | ✅    | ✅  | Zero-trust networking for services |
| cert-manager | Automated certificate management             | ✅  | ✅    | ✅  | Issue TLS certs from Let's Encrypt |
| kube-bench   | CIS Kubernetes security checks               | ✅  | ✅    | ✅  | Audit cluster security posture |
| kube-hunter  | Kubernetes penetration testing               | ✅  | ✅    | ✅  | Find cluster vulnerabilities |
| kubeseal     | Encrypted secrets management (SealedSecrets) | ✅  | ✅    | ✅  | Store secrets safely in Git |
| krew         | Plugin manager for kubectl                   | ✅  | ✅    | ✅  | Install kubectl plugins (e.g., ctx, ns) |
| Skaffold     | CI/CD for local Kubernetes development       | ✅  | ✅    | ✅  | Rapid local dev and deployment |
| Telepresence | Local development with remote clusters       | ✅  | ✅    | ✅  | Debug services in real clusters from local machine |
| Trivy        | Container and K8s security scanner           | ✅  | ✅    | ✅  | Scan images and manifests for vulnerabilities |

**Legend:**
- ✅ = Supported/commonly used

## Real-Life Example: Helm on Azure AKS
```sh
# Add Bitnami repo and install Prometheus on AKS
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install prometheus bitnami/kube-prometheus --namespace monitoring --create-namespace
```

## Real-Life Example: Velero Backup to AWS S3
```sh
velero install \
  --provider aws \
  --bucket my-k8s-backups \
  --secret-file ./aws-credentials \
  --backup-location-config region=us-west-2
```

## Real-Life Example: ArgoCD GitOps on GKE
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Connect ArgoCD to a Git repo for automated app deployment
```

> For more, see the [Kubernetes official tools list](https://kubernetes.io/docs/tasks/tools/) and each tool's documentation.

