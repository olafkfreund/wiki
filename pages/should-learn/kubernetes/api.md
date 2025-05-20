# Kubernetes API: Practical Guide for DevOps Engineers

The Kubernetes API is the foundation for managing clusters, workloads, and resources across AWS, Azure, GCP, and on-prem environments. Mastery of the API enables automation, integration, and advanced troubleshooting in real-world DevOps workflows.

---

## Official Documentation

- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
- [Cluster API (CAPI)](https://cluster-api.sigs.k8s.io/introduction.html) — Declarative cluster lifecycle management

---

## Real-Life Examples

### 1. Querying the Kubernetes API Directly

Use `kubectl` to interact with the API server:

```bash
kubectl get pods -n devops-tools -o yaml
kubectl get deployment myapp -o json
```

### 2. Using the API with `curl` (ServiceAccount Token)

```bash
APISERVER=https://<cluster-endpoint>
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k \
  -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/default/pods
```

### 3. Automating with Python (Official Client)

```python
from kubernetes import client, config
config.load_kube_config()
v1 = client.CoreV1Api()
for pod in v1.list_namespaced_pod("default").items:
    print(pod.metadata.name)
```

### 4. Cluster API (CAPI) for Declarative Cluster Management

Cluster API enables you to manage Kubernetes clusters as custom resources (CRDs):

```yaml
# cluster.yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: dev-cluster
spec:
  ... # cloud provider-specific config
```

Apply with:

```bash
kubectl apply -f cluster.yaml
```

### 5. Integrating with Terraform

Use the [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) to manage resources declaratively:

```hcl
resource "kubernetes_namespace" "devops" {
  metadata {
    name = "devops-tools"
  }
}
```

### 6. LLM Integration Example

Use an LLM to generate a Kubernetes manifest from a prompt:

```text
Prompt: "Generate a Deployment YAML for a Python app with 3 replicas and resource limits."
# LLM returns a ready-to-apply manifest
```

---

## Best Practices

- Use `kubectl explain <resource>` to discover API fields
- Automate repetitive tasks with the official client libraries (Python, Go, etc.)
- Use RBAC to restrict API access
- Integrate API calls into CI/CD for GitOps workflows
- Monitor API server logs for troubleshooting

---

> **Tip:** Always reference the [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/) for the latest resource definitions and fields.
