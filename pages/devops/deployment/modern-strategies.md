# Modern Deployment Strategies (2024+)

## Progressive Delivery

### Argo Rollouts
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: modern-app
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 10m}
      - setWeight: 40
      - pause: {duration: 10m}
      analysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: modern-app
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: modern-app
  template:
    metadata:
      labels:
        app: modern-app
    spec:
      containers:
      - name: app
        image: modern-app:latest
        ports:
        - containerPort: 8080
```

## GitOps Integration

### Flux Kustomization
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 10m
  path: ./apps/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: production
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: frontend
      namespace: default
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
```

## Feature Management

### Feature Flag Configuration
```yaml
apiVersion: core.openfeature.dev/v1alpha1
kind: FeatureFlag
metadata:
  name: new-feature
spec:
  flagSpec:
    key: new-feature
    variants:
      - key: "true"
        value: true
      - key: "false"
        value: false
    targeting:
      rules:
        - key: "beta-users"
          value: "true"
          conditions:
            - attribute: "user.group"
              operator: "in"
              values: ["beta"]
    defaultVariant: "false"
```

## Best Practices

1. **Deployment Safety**
   - Progressive rollouts
   - Automated rollbacks
   - Health checks
   - Traffic shifting

2. **Configuration Management**
   - GitOps workflows
   - Secret management
   - Config validation
   - Version control

3. **Feature Control**
   - Feature flags
   - A/B testing
   - Dark launches
   - Ring deployments

4. **Monitoring**
   - Deployment metrics
   - Performance impact
   - User feedback
   - Error tracking