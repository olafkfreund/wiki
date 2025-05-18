---
description: >-
  Integrate Bicep with Azure Pipelines for robust CI/CD. Latest DevOps/SRE best practices, real-world examples, and troubleshooting for 2025.
---

# Integrate Bicep with Azure Pipelines (2025)

Automate your Azure infrastructure deployments using Bicep and Azure Pipelines. This guide covers modern DevOps/SRE best practices, secure parameter handling, and real-world pipeline examples.

---

## Why Use Azure Pipelines with Bicep?

- **Enterprise CI/CD**: Integrate with Azure DevOps for approvals, gated releases, and audit trails
- **Multi-Environment**: Deploy to dev, test, and prod using parameter files
- **Validation**: Use what-if and linting for safe deployments
- **Security**: Store secrets in Azure Key Vault and use least-privilege service connections

---

## Prerequisites

- Azure DevOps project
- Azure subscription
- Bicep files in your repo (e.g., `infra/main.bicep`)
- Azure service connection with RBAC

---

## Example: Basic Bicep Deployment Pipeline

```yaml
trigger:
- main

pool:
  vmImage: ubuntu-latest

steps:
- task: AzureCLI@2
  displayName: 'Deploy Bicep Template'
  inputs:
    azureSubscription: 'your-azure-service-connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az bicep build --file infra/main.bicep
      az group create --name exampleRG --location eastus
      az deployment group create \
        --resource-group exampleRG \
        --template-file infra/main.bicep \
        --parameters @infra/parameters/dev.parameters.json
```

---

## Example: Multi-Stage Pipeline for Dev/Test/Prod

```yaml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - infra/**

stages:
- stage: Validate
  jobs:
  - job: Validate
    steps:
    - task: AzureCLI@2
      displayName: 'Validate Bicep Files'
      inputs:
        azureSubscription: 'your-azure-service-connection'
        scriptType: bash
        scriptLocation: inlineScript
        inlineScript: |
          az bicep build --file infra/main.bicep --stdout
          az deployment group validate \
            --resource-group exampleRG \
            --template-file infra/main.bicep \
            --parameters @infra/parameters/dev.parameters.json

- stage: DeployDev
  dependsOn: Validate
  jobs:
  - deployment: DeployDev
    environment: 'Development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            displayName: 'Deploy to Dev'
            inputs:
              azureSubscription: 'your-azure-service-connection'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az deployment group create \
                  --resource-group exampleRG-dev \
                  --template-file infra/main.bicep \
                  --parameters @infra/parameters/dev.parameters.json

- stage: DeployProd
  dependsOn: DeployDev
  jobs:
  - deployment: DeployProd
    environment: 'Production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            displayName: 'Deploy to Prod'
            inputs:
              azureSubscription: 'your-azure-service-connection'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az deployment group create \
                  --resource-group exampleRG-prod \
                  --template-file infra/main.bicep \
                  --parameters @infra/parameters/prod.parameters.json
```

---

## Best Practices for DevOps & SRE (2025)

- Use parameter files for each environment
- Validate Bicep with `az bicep build` and `az deployment group what-if`
- Store secrets in Azure Key Vault, not in YAML or parameters
- Use Azure DevOps Environments for gated approvals
- Assign least-privilege RBAC to service connections
- Upload deployment logs as build artifacts

---

## Monitoring & Troubleshooting

- Use `az deployment group show` to fetch outputs and status
- Add steps to publish deployment logs as artifacts
- Use pipeline badges in your README for visibility

---

## Bicep & Azure Jokes

> **Bicep Joke:** Why did the pipeline skip arm day? Because it only needed Bicep!

> **Azure Joke:** Why did the SRE love Azure Pipelines? Because every deployment was a step in the right direction!

---

## References

- [Azure Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
