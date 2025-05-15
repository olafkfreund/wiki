# Helm (2025)

Helm is the de facto package manager for Kubernetes, enabling engineers to define, install, and manage complex applications using reusable, parameterized charts. Helm streamlines multi-environment deployments, supports GitOps workflows, and integrates with all major clouds (AKS, EKS, GKE).

---

## Why Use Helm?
- **Reusable Templates:** Parameterize Kubernetes manifests for dev, staging, and prod
- **Environment Management:** Use values files to customize deployments per environment
- **GitOps Friendly:** Store charts and values in Git, automate with ArgoCD, Flux, or CI/CD
- **Rollbacks & Upgrades:** Easily upgrade, rollback, or uninstall releases
- **Ecosystem:** Thousands of pre-built charts for popular apps (see [Artifact Hub](https://artifacthub.io/))

---

## Helm Chart Structure

```sh
nginx/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

- `Chart.yaml`: Chart metadata (name, version, description)
- `values.yaml`: Default configuration values (can be overridden per environment)
- `templates/`: Parameterized Kubernetes manifests

---

## Real-Life Example: Multi-Environment Nginx Chart

Suppose you need to deploy Nginx to dev, QA, staging, and prod, each with different replica counts, ingress rules, and secrets. Instead of duplicating YAML, use a single chart and multiple values files:

```sh
helm install nginx-dev ./nginx -f values-dev.yaml
helm install nginx-prod ./nginx -f values-prod.yaml
```

---

## Creating a Custom Helm Chart

Generate a new chart:
```sh
helm create nginx-demo
```

This creates the standard structure. Clean up defaults:
```sh
cd nginx-demo
rm templates/*
```

Add your own `deployment.yaml`, `service.yaml`, and `configmap.yaml` templates using Helm's Go templating syntax. Example:

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

---

## Best Practices (2025)
- Use one chart with multiple values files for different environments
- Store charts and values in Git, automate with GitOps (ArgoCD, Flux)
- Use `helm lint` and `helm template` to validate before deploying
- Use semantic versioning for charts
- Document all values and templates
- Use LLMs (Copilot, Claude) to generate and review templates and values

---

## Common Pitfalls
- Hardcoding values instead of using parameters
- Not validating rendered manifests before applying
- Manual changes outside Git (causes drift in GitOps)
- Not using `helm upgrade`/`rollback` for changes

---

## Real-Life DevOps Workflow
- Store your Helm charts and values in a Git repo
- Use ArgoCD or Flux to sync charts to clusters (AKS, EKS, GKE)
- Use CI/CD (GitHub Actions, Azure Pipelines, GitLab CI) to lint, test, and package charts
- Use LLMs to generate and document complex templates

---

## References
- [Helm Docs](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Artifact Hub](https://artifacthub.io/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Flux Docs](https://fluxcd.io/docs/)
