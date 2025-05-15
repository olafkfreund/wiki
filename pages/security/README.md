# DevSecOps: Pipeline Security Implementation Guide

## Overview

This guide provides technical implementations for securing CI/CD pipelines across GitHub Actions, GitLab CI, and Azure DevOps, focusing on practical, real-world scenarios.

## Pipeline Security Controls

### 1. Access Control & Authentication

#### GitHub Actions

```yaml
# .github/workflows/secure-pipeline.yml
name: Secure Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  security-events: write
  actions: none
  
jobs:
  security-scan:
    runs-on: ubuntu-latest
    environment: production # Requires approval
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          persist-credentials: false
```

#### GitLab CI

```yaml
# .gitlab-ci.yml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      variables:
        SECURE_SCANNING: "true"

variables:
  SECURE_LOG_LEVEL: "debug"
  SCAN_KUBERNETES_MANIFESTS: "true"

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
```

#### Azure DevOps

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
  paths:
    exclude:
    - docs/*

resources:
  repositories:
    - repository: security-policies
      type: git
      name: SecurityPolicies
      ref: refs/heads/main

pool:
  vmImage: 'ubuntu-latest'

variables:
- group: Production-Secrets
```

## 2. Secrets Management

### Vault Integration Examples

#### GitHub Actions with HashiCorp Vault

```yaml
jobs:
  fetch-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Vault Authentication
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: jwt
          role: github-action
          secrets: |
            secret/data/myapp/config token | APP_TOKEN ;
            secret/data/myapp/config key | API_KEY
```

#### GitLab CI with Vault

```yaml
variables:
  VAULT_ADDR: "https://vault.example.com"
  
.vault-auth: &vault-auth
  before_script:
    - |
      VAULT_TOKEN=$(vault write -field=token auth/jwt/login \
        role=gitlab-ci \
        jwt=$CI_JOB_JWT)
      export VAULT_TOKEN
```

#### Azure DevOps with Key Vault

```yaml
steps:
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'Production'
    KeyVaultName: 'myapp-kv'
    SecretsFilter: 'API-Key,DB-Password'
    RunAsPreJob: true
```

## 3. Container Security

### Image Scanning Configuration

```yaml
# Container scanning template
container_scan: &container_scan
  image: aquasec/trivy:latest
  script: |
    trivy image \
      --exit-code 1 \
      --severity HIGH,CRITICAL \
      --no-progress \
      ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
```

### Base Image Security

```dockerfile
# Dockerfile security baseline
FROM alpine:3.18

# Set non-root user
RUN adduser -D -u 10001 appuser
USER appuser

# Metadata labels
LABEL org.opencontainers.image.vendor="Company Name" \
      org.opencontainers.image.title="Secure App" \
      org.opencontainers.image.security.policy="/security.txt"
```

## 4. Code Security Scanning

### GitHub Advanced Security

```yaml
jobs:
  codeql-analysis:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    
    steps:
    - uses: github/codeql-action/init@v2
      with:
        languages: javascript, python
        queries: security-extended
    
    - uses: github/codeql-action/analyze@v2
      with:
        category: "/language:javascript"
```

### GitLab SAST

```yaml
sast:
  variables:
    SAST_EXCLUDED_PATHS: "spec, test, tests, tmp"
    SCAN_KUBERNETES_MANIFESTS: "true"
  stage: test
  artifacts:
    reports:
      sast: gl-sast-report.json
```

### Azure DevOps Security Scanning

```yaml
- task: WhiteSource@21
  inputs:
    cwd: '$(System.DefaultWorkingDirectory)'
    projectName: '$(Build.Repository.Name)'
    
- task: SecurityAnalysis@0
  inputs:
    scanType: 'full'
    verbosity: 'Detailed'
```

## 5. Infrastructure Security

### Terraform Security Scanning

```yaml
terraform_security:
  script:
    - |
      checkov -d . --framework terraform
      tfsec .
      terrascan scan -i terraform
```

### Kubernetes Manifest Validation

```yaml
k8s_security:
  script:
    - |
      kubesec scan k8s/*.yaml
      kube-score score k8s/*.yaml
      conftest test k8s/*.yaml
```

## Real-World Implementation Examples

### E-Commerce Platform Pipeline

```yaml
# Multi-stage security pipeline
stages:
  - scan
  - build
  - test
  - deploy

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml

variables:
  SECURE_LOG_LEVEL: "debug"
  SAST_EXCLUDED_PATHS: "spec, test, tests, tmp"
  DS_EXCLUDED_PATHS: "test/*, spec/*"
  
sast:
  variables:
    SEARCH_MAX_DEPTH: 4
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

dependency_scanning:
  variables:
    DS_PYTHON_VERSION: 3
    DS_EXCLUDED_PATHS: "tests/"

container_scanning:
  variables:
    CS_SEVERITY_THRESHOLD: "Critical"
```

### Best Practices Checklist

1. Pipeline Configuration:
   - Use specific versions for actions/tasks
   - Implement least privilege access
   - Enable branch protection rules
   - Enforce code review policies

2. Secret Management:
   - Use OIDC for cloud authentication
   - Rotate secrets automatically
   - Implement secret scanning
   - Use environment segregation

3. Container Security:
   - Scan base images
   - Implement runtime security
   - Use minimal base images
   - Enable read-only root filesystem

4. Compliance:
   - Implement audit logging
   - Enforce policy as code
   - Regular security assessments
   - Compliance report generation

## Monitoring & Alerting

### Security Event Monitoring

```yaml
security_monitoring:
  script:
    - |
      # Export security metrics to Prometheus
      cat << EOF > /metrics/security.prom
      pipeline_security_score{stage="build"} $(security_score)
      pipeline_vulnerabilities_total{severity="critical"} $(vuln_count)
      EOF
```

### Alert Configuration

```yaml
# Alert manager configuration
alerts:
  rules:
    - alert: HighSeverityVulnerability
      expr: pipeline_vulnerabilities_total{severity="critical"} > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        description: "Critical vulnerability detected in pipeline"
```

## References & Tools

1. Security Scanning:
   - Trivy
   - Snyk
   - Anchore
   - Clair

2. Policy Enforcement:
   - OPA (Open Policy Agent)
   - Kyverno
   - Conftest

3. Secret Management:
   - HashiCorp Vault
   - Azure Key Vault
   - AWS Secrets Manager

4. Compliance:
   - Chef InSpec
   - OpenSCAP
   - Compliance as Code tools
