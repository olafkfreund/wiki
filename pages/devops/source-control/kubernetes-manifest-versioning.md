# Kubernetes Manifest Version Control

Effective version control of Kubernetes manifests is essential for maintaining consistent, reliable, and auditable deployments across environments and cloud providers. This guide covers best practices for managing Kubernetes configurations in source control.

## Challenges of Kubernetes Manifest Management

Kubernetes manifests present unique versioning challenges:

1. **Environment-specific configurations** - Different values for dev, staging, production
2. **Cross-cloud compatibility** - Running workloads on multiple Kubernetes providers
3. **Secret management** - Securely storing and versioning sensitive data
4. **Manifest proliferation** - Managing hundreds of YAML files across multiple applications
5. **Validation and testing** - Ensuring manifests are valid before applying them

## Directory Structure Options

### Option 1: Environment-Based Structure

```
kubernetes/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── overlays/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── configmap.yaml
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── configmap.yaml
│   └── production/
│       ├── kustomization.yaml
│       └── configmap.yaml
└── README.md
```

### Option 2: Application-Based Structure

```
kubernetes/
├── frontend/
│   ├── base/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── production/
├── backend/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── database.yaml
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── production/
└── README.md
```

### Option 3: Cloud Provider Structure

```
kubernetes/
├── base/
│   ├── deployment.yaml
│   └── service.yaml
└── providers/
    ├── aws/
    │   ├── eks-specific.yaml
    │   └── kustomization.yaml
    ├── azure/
    │   ├── aks-specific.yaml
    │   └── kustomization.yaml
    └── gcp/
        ├── gke-specific.yaml
        └── kustomization.yaml
```

## Templating and Customization Tools

Several tools can help manage Kubernetes manifest variations:

### 1. Kustomize

Kustomize is built into `kubectl` and provides a way to customize manifests without templates. It's ideal for environment-specific configurations.

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../base

namespace: my-app-production

patchesStrategicMerge:
- configmap.yaml

images:
- name: my-app-image
  newTag: v1.2.3
```

### 2. Helm Charts

Helm provides templating, versioning, and package management for Kubernetes resources.

```yaml
# values.yaml (production)
replicaCount: 5
image:
  repository: myapp
  tag: v1.2.3
  pullPolicy: Always
resources:
  limits:
    cpu: 1000m
    memory: 1024Mi
```

### 3. Jsonnet/Tanka

Jsonnet is a data templating language that can generate Kubernetes manifests with powerful abstraction capabilities.

```jsonnet
// environments/production.jsonnet
local base = import '../base.jsonnet';

base {
  _config+:: {
    namespace: 'production',
    replicas: 5,
    resources: {
      limits: {
        cpu: '1',
        memory: '1Gi',
      },
    },
  },
}
```

## Version Control Best Practices

### 1. Manifest Versioning Strategy

Apply versioning to your Kubernetes manifests to track changes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  labels:
    app: api-service
    # Version label for tracking
    version: v1.2.3
    # Release tracking
    release: "20230615"
```

Use git tags to mark specific manifest versions:

```bash
# Tag Kubernetes manifests for production release
git tag -a k8s/prod/v1.2.3 -m "Production manifests for v1.2.3"
```

### 2. Using Semantic Versioning for Helm Charts

Helm charts should follow semantic versioning:

```yaml
# Chart.yaml
apiVersion: v2
name: my-application
description: A Helm chart for my application
type: application
version: 1.2.3          # Chart version
appVersion: 4.5.6       # Application version
```

### 3. Handling Secrets

Avoid storing raw secrets in version control. Instead:

- Use sealed-secrets or similar tools to encrypt secrets
- Reference external secret stores
- Use environment-specific injection methods

```yaml
# Using Sealed Secrets
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: database-credentials
spec:
  encryptedData:
    username: AgBy8hCM8FQUo2...
    password: AgCtr6jE4e1...
```

```yaml
# Using external secrets (AWS Secret Manager)
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: database-credentials
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: database-credentials
  data:
    - secretKey: username
      remoteRef:
        key: prod/db/credentials
        property: username
    - secretKey: password
      remoteRef:
        key: prod/db/credentials
        property: password
```

### 4. Drift Detection

Implement checks to detect drift between source-controlled manifests and what's running in clusters:

```bash
#!/bin/bash
# Simple drift detection script
NAMESPACE="my-app"
RESOURCE_TYPE="deployment"
RESOURCE_NAME="api-service"

# Get the live manifest
kubectl get $RESOURCE_TYPE $RESOURCE_NAME -n $NAMESPACE -o yaml > live.yaml

# Get the source-controlled manifest
cat ./kubernetes/overlays/production/deployment.yaml > source.yaml

# Compare (excluding dynamic fields)
diff <(yq 'del(.metadata.resourceVersion, .metadata.uid, .metadata.generation, .status)' live.yaml) \
     <(yq 'del(.metadata.resourceVersion, .metadata.uid, .metadata.generation, .status)' source.yaml)
```

## Multi-Cloud Kubernetes Management

### 1. Cloud-Agnostic Base Manifests

Create base manifests that work across clouds, then use overlays for provider-specific features:

```yaml
# base/deployment.yaml (cloud-agnostic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api
        image: my-app:v1.2.3
        ports:
        - containerPort: 8080
```

### 2. Provider-Specific Overlays

```yaml
# overlays/aws/eks-specific.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  template:
    spec:
      nodeSelector:
        eks.amazonaws.com/nodegroup: standard
      # AWS-specific service account annotation
      serviceAccountName: api-service-sa
      containers:
      - name: api
        env:
        - name: AWS_REGION
          value: us-west-2
```

### 3. Multi-Cluster GitOps

Tools like Flux or ArgoCD can sync manifests across multiple clusters, potentially on different cloud providers:

```yaml
# Example Flux Kustomization for multi-cloud deployment
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: api-service
  namespace: flux-system
spec:
  interval: 10m
  path: "./kubernetes/overlays/aws"
  prune: true
  sourceRef:
    kind: GitRepository
    name: api-manifests
```

## CI/CD Integration

### 1. Validation in CI Pipelines

Implement manifest validation in your CI pipeline:

```yaml
# GitHub Actions workflow for manifest validation
name: Validate Kubernetes Manifests

on:
  pull_request:
    paths:
      - 'kubernetes/**'
      - 'helm/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate Kubernetes manifests
        run: |
          kubectl validate kustomize kubernetes/overlays/production
          
      - name: Lint Helm charts
        run: |
          helm lint helm/my-application
      
      - name: Run kubeval
        run: |
          wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
          tar xf kubeval-linux-amd64.tar.gz
          find kubernetes -name "*.yaml" | grep -v kustomization | xargs ./kubeval
```

### 2. Automated Testing for Kubernetes Manifests

Use tools like [conftest](https://www.conftest.dev/) to write tests for your Kubernetes configurations:

```rego
# policy/deployment.rego
package main

deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot
  
  msg = "Containers must not run as root"
}

deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.spec.containers[_].resources.limits
  
  msg = "Resource limits must be set for all containers"
}
```

Run these tests in CI:

```bash
find kubernetes -name "*.yaml" | grep -v kustomization | xargs conftest test -p policy/
```

## Real-World Examples

### Example 1: Application Spanning Multiple Clouds

For applications deployed across AWS, Azure, and GCP:

```
app/
├── base/
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── aws/
    │   ├── kustomization.yaml
    │   ├── deployment-patch.yaml  # EKS-specific configs
    │   └── service-patch.yaml     # AWS-specific service configs
    ├── azure/
    │   ├── kustomization.yaml
    │   ├── deployment-patch.yaml  # AKS-specific configs
    │   └── service-patch.yaml     # Azure-specific service configs
    └── gcp/
        ├── kustomization.yaml
        ├── deployment-patch.yaml  # GKE-specific configs
        └── service-patch.yaml     # GCP-specific service configs
```

### Example 2: Environment-Specific ConfigMaps

```yaml
# overlays/dev/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  log_level: "debug"
  feature_flags: "experimental_feature=true,beta_feature=true"
  api_timeout: "30s"

# overlays/production/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  log_level: "info"
  feature_flags: "experimental_feature=false,beta_feature=false"
  api_timeout: "10s"
```

## Conclusion

Effective version control of Kubernetes manifests involves choosing the right organizational structure, templating tool, and versioning strategy. By following the practices in this guide, you can manage Kubernetes configurations across multiple environments and cloud providers while maintaining consistency, reliability, and auditability.

## Resources

- [Kustomize documentation](https://kustomize.io/)
- [Helm documentation](https://helm.sh/docs/)
- [Flux documentation](https://fluxcd.io/docs/)
- [ArgoCD documentation](https://argo-cd.readthedocs.io/)
- [Kubeval](https://www.kubeval.com/)
- [Conftest](https://www.conftest.dev/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [External Secrets Operator](https://external-secrets.io/)