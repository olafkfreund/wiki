---
description: Integrate Kosli with Azure DevOps Pipelines for automated compliance and deployment tracking
keywords: kosli, azure devops, azure pipelines, ci/cd, compliance
---

# Kosli Azure DevOps Integration

## Overview

Integrate Kosli with Azure DevOps Pipelines to track deployments and collect compliance evidence.

## Setup

### Configure Pipeline Variables

Add to **Pipeline > Variables**:
- `KOSLI_API_TOKEN` (Secret)
- `KOSLI_ORG`

### Basic Pipeline

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  KOSLI_FLOW: 'microservice-api'
  IMAGE_NAME: 'myapp:$(Build.BuildId)'

stages:
- stage: Build
  jobs:
  - job: BuildAndReport
    steps:
    - script: |
        curl -sSL https://cli.kosli.com/install.sh | sh
        export PATH=$PATH:$HOME/.kosli/bin
        echo "##vso[task.setvariable variable=PATH]$PATH:$HOME/.kosli/bin"
      displayName: 'Install Kosli CLI'

    - script: docker build -t $(IMAGE_NAME) .
      displayName: 'Build Docker Image'

    - script: |
        kosli report artifact $(IMAGE_NAME) \
          --artifact-type docker \
          --flow $(KOSLI_FLOW) \
          --build-url $(System.TeamFoundationCollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId) \
          --commit $(Build.SourceVersion) \
          --git-commit-info HEAD
      displayName: 'Report Artifact to Kosli'
      env:
        KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
        KOSLI_ORG: $(KOSLI_ORG)

- stage: Evidence
  jobs:
  - job: CollectEvidence
    steps:
    - script: pytest --junitxml=test-results.xml
      displayName: 'Run Tests'

    - script: |
        kosli report evidence test junit \
          --flow $(KOSLI_FLOW) \
          --name $(IMAGE_NAME) \
          --results-file test-results.xml
      displayName: 'Report Test Evidence'
      env:
        KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
        KOSLI_ORG: $(KOSLI_ORG)

    - script: trivy image --format json -o scan.json $(IMAGE_NAME)
      displayName: 'Security Scan'

    - script: |
        kosli report evidence generic \
          --flow $(KOSLI_FLOW) \
          --name $(IMAGE_NAME) \
          --evidence-type security-scan \
          --attachments scan.json
      displayName: 'Report Security Evidence'
      env:
        KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
        KOSLI_ORG: $(KOSLI_ORG)

- stage: Deploy
  jobs:
  - deployment: DeployProduction
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: kubectl apply -f k8s/
            displayName: 'Deploy to Kubernetes'

          - script: |
              kosli report deployment production \
                --flow $(KOSLI_FLOW) \
                --name $(IMAGE_NAME)
            displayName: 'Report Deployment'
            env:
              KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
              KOSLI_ORG: $(KOSLI_ORG)

          - script: |
              kosli snapshot k8s production \
                --namespace production
            displayName: 'Snapshot Environment'
            env:
              KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
              KOSLI_ORG: $(KOSLI_ORG)
```

## PowerShell Script Option

```yaml
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      # Install Kosli
      irm https://cli.kosli.com/install.ps1 | iex

      # Report artifact
      kosli report artifact $(IMAGE_NAME) `
        --artifact-type docker `
        --flow $(KOSLI_FLOW) `
        --commit $(Build.SourceVersion)
  env:
    KOSLI_API_TOKEN: $(KOSLI_API_TOKEN)
    KOSLI_ORG: $(KOSLI_ORG)
```

## Next Steps

- [CLI Reference](cli-reference.md)
- [Best Practices](best-practices.md)
