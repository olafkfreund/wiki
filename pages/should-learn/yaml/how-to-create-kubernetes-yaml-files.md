# How to Create Kubernetes YAML Files (2025)

Creating and managing Kubernetes YAML files is a core DevOps and SRE skill. YAML defines your infrastructure, deployments, and policies across AWS, Azure, GCP, and on-prem clusters. This guide covers practical, real-world approaches and tools for engineers.

---

## Create vs Generate

When starting out, avoid over-relying on generators. Instead, copy-paste from [Kubernetes docs](https://kubernetes.io/) and experiment. This builds foundational knowledge. Once you find writing YAML repetitive, introduce tools to automate and scale your workflow.

**Best Practice:**

- Learn the structure of core resources (Pod, Deployment, Service, ConfigMap, Secret).
- Use generators only after you understand the basics.

---

## 1. yq: YAML Command-Line Power

[yq](https://mikefarah.gitbook.io/yq/) is a must-have for DevOps/SREs. It lets you query, filter, and modify YAML files directly from the CLI. Example:

```bash
yq e '.spec.template.spec.containers[0].image' deployment.yaml
```

**Use Cases:**

- Extracting image names for vulnerability scanning
- Bulk updating resource limits across manifests
- Merging multiple YAML files for GitOps pipelines

---

## 2. kubectl: Generate and Clean Up YAML

[kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/) can generate YAML for most resources. Use `--dry-run=client -o yaml` to scaffold manifests:

```bash
kubectl run nginx --image=nginx --port=8080 --env=env=DEV --labels=app=nginx,owner=user --dry-run=client -o yaml > nginx-pod.yaml
```

**Tip:** Clean up the generated YAML before using in production. Remove unnecessary fields and add comments for clarity.

**Real-Life Example:**

- Use `kubectl create deployment my-dep --image=nginx --dry-run=client -o yaml > deployment.yaml`
- Use `yq` to merge or update fields as needed for automation.

---

## 3. Kompose: Docker Compose to Kubernetes

If you have a `docker-compose.yaml`, use [kompose](https://kompose.io/) to convert it to Kubernetes manifests:

```bash
kompose convert -f docker-compose.yaml -o k8s-manifests/
```

**Best Practice:**

- Review and adjust generated manifests for production readiness (resource requests, probes, labels).

---

## 4. VS Code Plugins for YAML

- [Kubernetes Templates](https://marketplace.visualstudio.com/items?itemName=lunuan.kubernetes-templates): Quickly scaffold resources with snippets.
- [YAML by Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml): Adds schema validation and smart completion.

**Setup:**

```json
"yaml.schemas": {
  "Kubernetes": "*.yaml"
}
```

---

## 5. CDK8s: YAML as Code

[CDK8s](https://cdk8s.io/) lets you define Kubernetes manifests using Python, TypeScript, Java, or Go. This is ideal for large, repeatable, or parameterized deployments.

**Example (Python):**

```python
from constructs import Construct
from cdk8s import App, Chart
from imports.k8s import KubeDeployment

class MyChart(Chart):
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id)
        KubeDeployment(self, 'nginx',
            spec={
                'replicas': 2,
                'template': {
                    'spec': {
                        'containers': [{
                            'name': 'nginx',
                            'image': 'nginx:latest'
                        }]
                    }
                }
            })

app = App()
MyChart(app, "nginx-chart")
app.synth()
```

---

## 6. NAML: Go-Based Manifest Generation

[NAML](https://github.com/kris-nova/naml) lets you define and install Kubernetes resources using Go code. Great for Go-centric teams who want to avoid YAML.

---

## Best Practices (2025)

- Use version control (Git) for all YAML files
- Validate YAML with `kubectl apply --dry-run=client -f file.yaml`
- Use comments and clear labels/annotations
- Parameterize with Kustomize or Helm for multi-environment deployments
- Integrate YAML linting in CI/CD pipelines

## Common Pitfalls

- Blindly using generated YAML without review
- Not specifying resource requests/limits
- Hardcoding secrets in YAML (use Kubernetes Secrets or external vaults)
- Ignoring schema validation errors

## References

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [yq Documentation](https://mikefarah.gitbook.io/yq/)
- [Kompose Docs](https://kompose.io/)
- [CDK8s Docs](https://cdk8s.io/docs/latest/)

---

> **YAML Joke:**
> Why did the DevOps engineer break up with YAML? Too many unresolved issues with indentation!
