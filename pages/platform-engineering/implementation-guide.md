# Platform Engineering Implementation Guide (2024+)

## Self-Service Portal

### Crossplane Configuration
```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-config
spec:
  package: xpkg.upbound.io/platform/config:v1.0.0
---
apiVersion: platform.org/v1alpha1
kind: ApplicationTemplate
metadata:
  name: web-application
spec:
  components:
    - name: frontend
      type: kubernetes
      properties:
        replicas: 2
        image: nginx:latest
    - name: database
      type: rds
      properties:
        engine: postgres
        size: small
```

## Internal Developer Platform

### Backstage Implementation
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: service-template
  annotations:
    github.com/project-slug: 'org/service-template'
    backstage.io/techdocs-ref: dir:.
spec:
  type: template
  owner: platform-team
  lifecycle: production
  system: developer-platform
  parameters:
    - title: Service Details
      properties:
        name:
          title: Name
          type: string
          pattern: '^[a-z0-9-]+$'
        language:
          title: Language
          type: string
          enum: ['python', 'typescript', 'go']
```

## Developer Experience

### Backstage Implementation
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: service-template
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: internal-platform
  dependsOn:
    - component:default/auth-service
    - resource:default/postgres-db
---
apiVersion: backstage.io/v1alpha1
kind: Template
metadata:
  name: microservice-template
spec:
  parameters:
    - title: Service Details
      required:
        - serviceName
        - owner
  steps:
    - id: template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.serviceName }}
          owner: ${{ parameters.owner }}
```

## Service Catalog

### Resource Templates
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: microservice-template
  title: Microservice Template
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Information
      properties:
        name:
          title: Name
          type: string
        description:
          title: Description
          type: string
  steps:
    - id: template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
    - id: publish
      name: Publish
      action: publish:github
      input:
        repoUrl: github.com?owner=org&repo=${{ parameters.name }}
```

## Infrastructure Automation

### Terraform Controller
```yaml
apiVersion: infra.contrib.fluxcd.io/v1alpha2
kind: Terraform
metadata:
  name: platform-resources
spec:
  interval: 1h
  path: ./environments/prod
  sourceRef:
    kind: GitRepository
    name: platform-infra
  vars:
    - name: environment
      value: production
  approvePlan: auto
  destroyResourcesOnDeletion: false
```

## Service Mesh Integration

### Linkerd Configuration
```yaml
apiVersion: linkerd.io/v1alpha2
kind: ServiceProfile
metadata:
  name: platform-api
  namespace: platform
spec:
  routes:
    - name: createService
      condition:
        method: POST
        pathRegex: /api/v1/services
      responseClasses:
        - condition:
            status:
              min: 200
              max: 299
          isFailure: false
    - name: getService
      condition:
        method: GET
        pathRegex: /api/v1/services/[^/]*$
      timeoutMs: 500
```

## Best Practices

1. **Developer Self-Service**
   - Service templates
   - Environment provisioning
   - Pipeline automation
   - Documentation

2. **Platform Governance**
   - Policy enforcement
   - Resource quotas
   - Security controls
   - Cost management

3. **Service Lifecycle**
   - Creation workflows
   - Update processes
   - Retirement procedures
   - Version control

4. **Observability**
   - Platform metrics
   - Usage analytics
   - Cost tracking
   - Performance monitoring