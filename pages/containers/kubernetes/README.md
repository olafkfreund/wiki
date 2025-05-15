# Kubernetes (2025)

Kubernetes is the leading open-source platform for automating deployment, scaling, and management of containerized applications. It is supported by all major cloud providers and can run on-premises, in the cloud, or in hybrid environments.

## Managed Kubernetes Services

Most organizations use a managed Kubernetes service for production workloads. The three most popular are:

- **AKS (Azure Kubernetes Service)**: Managed by Microsoft Azure, integrates with Azure AD, Azure Monitor, and supports Windows and Linux nodes.
- **EKS (Amazon Elastic Kubernetes Service)**: Managed by AWS, integrates with IAM, CloudWatch, and supports deep AWS ecosystem integration.
- **GKE (Google Kubernetes Engine)**: Managed by Google Cloud, offers advanced auto-scaling, rapid upgrades, and native Anthos/multi-cloud support.

| Feature                | AKS                | EKS                | GKE                |
|------------------------|--------------------|--------------------|--------------------|
| Cloud Provider         | Azure              | AWS                | GCP                |
| OS Support             | Linux, Windows     | Linux, Windows     | Linux              |
| IAM Integration        | Azure AD           | AWS IAM            | Google IAM         |
| Monitoring             | Azure Monitor      | CloudWatch         | Stackdriver        |
| Auto-Scaling           | Yes                | Yes                | Advanced           |
| Upgrades               | Manual/Auto        | Manual/Auto        | Rapid/Auto         |
| Multi-Cloud/Hybrid     | Azure Arc          | EKS Anywhere       | Anthos             |

## Real-Life Workload Examples

- **Web Applications**: Deploy scalable web frontends and APIs using Kubernetes Deployments and Services.
- **Big Data & Analytics**: Run Spark, Hadoop, or distributed data processing jobs on Kubernetes clusters.
- **Machine Learning**: Train and serve ML models using Kubeflow, MLflow, or custom containers.
- **CI/CD Pipelines**: Use Kubernetes for dynamic build/test environments and GitOps workflows.

## 2025 Best Practices
- Use Infrastructure as Code (Terraform, Bicep) to provision clusters and resources
- Integrate with cloud-native IAM for secure access (Azure AD, AWS IAM, Google IAM)
- Automate deployments with GitHub Actions, Azure Pipelines, or GitLab CI/CD
- Use Helm for application packaging and versioning
- Enable cluster auto-scaling and node pool management
- Monitor with Prometheus, Grafana, and cloud-native tools
- Secure workloads with network policies, RBAC, and secrets management
- Use LLMs (Copilot, Claude) to generate manifests, Helm charts, and automate troubleshooting

## Example: Deploying a Web App to Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  selector:
    app: webapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

## Multi-Cloud & Hybrid Kubernetes
- Use tools like Azure Arc, EKS Anywhere, or Anthos for hybrid/multi-cloud management
- Standardize on GitOps and IaC for portability
- Monitor and secure clusters consistently across providers

## References
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
