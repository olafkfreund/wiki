# Platform Engineering Patterns (2024+)

## Developer Self-Service Portal

### Frontend Configuration
```typescript
interface ServiceTemplate {
  name: string;
  description: string;
  parameters: Parameter[];
  resources: CloudResource[];
}

interface CloudResource {
  provider: 'aws' | 'azure' | 'gcp';
  type: string;
  configuration: Record<string, unknown>;
}

const webAppTemplate: ServiceTemplate = {
  name: 'Web Application',
  description: 'Production-ready web application with monitoring',
  parameters: [
    { name: 'environment', type: 'string', allowed: ['dev', 'staging', 'prod'] },
    { name: 'instanceSize', type: 'string', default: 't3.micro' }
  ],
  resources: [/* template resources */]
};
```

## Golden Path Implementation

### Resource Templates
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: web-service-template
  title: Web Service Template
  description: Production-ready web service with monitoring
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Details
      required:
        - serviceName
        - owner
      properties:
        serviceName:
          title: Service Name
          type: string
          pattern: ^[a-z0-9-]+$
        owner:
          title: Owner
          type: string
          ui:field: OwnerPicker
  steps:
    - id: template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          serviceName: ${{ parameters.serviceName }}
          owner: ${{ parameters.owner }}
```

## Internal Developer Platform

### API Definition
```yaml
openapi: 3.0.0
info:
  title: Platform API
  version: '1.0'
paths:
  /environments:
    post:
      summary: Create Environment
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                template:
                  type: string
                team:
                  type: string
      responses:
        '201':
          description: Environment created
  /services:
    post:
      summary: Deploy Service
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                template:
                  type: string
                environment:
                  type: string
      responses:
        '201':
          description: Service deployed