# Kubernetes

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. Managed services like Azure Kubernetes Service (AKS), Amazon Elastic Kubernetes Service (EKS), and Google Kubernetes Engine (GKE) simplify cluster operations in the cloud.

---

## Real-Life Workload Examples
- **Web Applications:** Deploy scalable, highly available web frontends and APIs.
- **Big Data & Analytics:** Run Spark, Hadoop, or distributed data processing jobs.
- **Machine Learning:** Train and serve ML models using Kubeflow or custom pipelines.
- **CI/CD Runners:** Host GitHub Actions, GitLab Runners, or Jenkins agents for scalable builds.
- **Event-Driven Microservices:** Use Kafka, RabbitMQ, or NATS for event streaming and messaging.

---

## Best Practices for Kubernetes Development & Operations

- **Use Infrastructure as Code:** Provision clusters and workloads with Terraform, Helm, or Bicep for repeatability.
- **Namespace Isolation:** Organize workloads by environment (dev, staging, prod) using namespaces.
- **Resource Requests & Limits:** Always set CPU/memory requests and limits to avoid noisy neighbor issues and OOMKills.
- **Health Checks:** Define liveness and readiness probes for all pods.
- **Secrets Management:** Store secrets in Kubernetes Secrets, integrate with cloud KMS or external secret managers (e.g., Azure Key Vault, AWS Secrets Manager, GCP Secret Manager).
- **Automate Deployments:** Use GitOps tools (ArgoCD, Flux) or CI/CD pipelines (GitHub Actions, Azure Pipelines, GitLab CI) for automated, auditable deployments.
- **Monitor & Alert:** Integrate Prometheus, Grafana, and cloud-native monitoring (Azure Monitor, CloudWatch, Stackdriver) for metrics and alerting.
- **Network Policies:** Restrict pod-to-pod communication with network policies.
- **RBAC:** Use Role-Based Access Control to enforce least privilege.
- **Regular Upgrades:** Keep Kubernetes and dependencies up to date to benefit from security patches and new features.

---

## Step-by-Step: Deploying a Web App on AKS/EKS/GKE

1. **Provision a Cluster:**
   - AKS: `az aks create ...`
   - EKS: `eksctl create cluster ...`
   - GKE: `gcloud container clusters create ...`
2. **Configure kubectl:**
   - AKS: `az aks get-credentials ...`
   - EKS: `aws eks update-kubeconfig ...`
   - GKE: `gcloud container clusters get-credentials ...`
3. **Deploy an App:**
   
   ```sh
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

4. **Monitor and Troubleshoot:**
   
   ```sh
   kubectl get pods -A
   kubectl describe pod <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace>
   ```

5. **Automate with GitOps:**
   - Use ArgoCD or Flux to sync manifests from Git repositories.

---

## Common Pitfalls

- Not setting resource requests/limits (leads to instability)
- Hardcoding secrets in manifests (use secret managers)
- Ignoring pod health checks (causes undetected failures)
- Manual changes outside of GitOps or IaC (causes drift)
- Not monitoring cluster health and resource usage

---

## References

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Troubleshooting Guide](https://kubernetes.io/docs/tasks/debug/)
