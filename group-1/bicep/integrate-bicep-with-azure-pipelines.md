---
description: >-
  This quickstart shows you how to integrate Bicep files with Azure Pipelines
  for continuous integration and continuous deployment (CI/CD).
---

# Integrate Bicep with Azure Pipelines

This guide demonstrates how to integrate Bicep infrastructure as code with Azure Pipelines for automated deployment to Azure. You'll learn key deployment strategies, pipeline configurations for different environments, and security best practices.

## Prerequisites

- Azure DevOps organization and project
- Azure subscription
- Bicep files defining your infrastructure
- An Azure service connection in your Azure DevOps project

## Deployment Options

You can deploy Bicep files in Azure Pipelines using two primary approaches:

1. Azure Resource Manager Template Deployment task
2. Azure CLI task

## Using Azure Resource Manager Template Deployment Task

This approach uses the specialized ARM template deployment task which natively supports Bicep files:

```yaml
trigger:
- main

name: Deploy Bicep Infrastructure

variables:
  vmImageName: 'ubuntu-latest'
  azureServiceConnection: 'your-azure-service-connection'
  resourceGroupName: 'exampleRG'
  location: 'eastus'
  templateFile: './infra/main.bicep'

pool:
  vmImage: $(vmImageName)

steps:
- task: AzureResourceManagerTemplateDeployment@3
  displayName: 'Deploy Resource Group'
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: '$(azureServiceConnection)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: '$(templateFile)'
    overrideParameters: '-environment Production -storageAccountType Standard_LRS'
    deploymentMode: 'Incremental'
    deploymentName: 'BicepDeployment-$(Build.BuildNumber)'
```

## Using Azure CLI Task

This approach leverages the Azure CLI and can provide more flexibility, especially for complex deployment scenarios:

```yaml
trigger:
- main

name: Deploy Bicep with CLI

variables:
  vmImageName: 'ubuntu-latest'
  azureServiceConnection: 'your-azure-service-connection'
  resourceGroupName: 'exampleRG'
  location: 'eastus'
  templateFile: './infra/main.bicep'

pool:
  vmImage: $(vmImageName)

steps:
- task: AzureCLI@2
  displayName: 'Deploy with Azure CLI'
  inputs:
    azureSubscription: $(azureServiceConnection)
    scriptType: bash
    scriptLocation: inlineScript
    useGlobalConfig: false
    inlineScript: |
      az --version
      az group create --name $(resourceGroupName) --location $(location)
      az deployment group create \
        --resource-group $(resourceGroupName) \
        --template-file $(templateFile) \
        --parameters environment=Production storageAccountType=Standard_LRS \
        --name BicepDeployment-$(Build.BuildNumber)
```

To use a parameters file instead of inline parameters:

```yaml
inlineScript: |
  az group create --name $(resourceGroupName) --location $(location)
  az deployment group create \
    --resource-group $(resourceGroupName) \
    --template-file $(templateFile) \
    --parameters @./infra/parameters/prod.parameters.json \
    --name BicepDeployment-$(Build.BuildNumber)
```

## Advanced Multi-stage Pipeline

For production environments, it's recommended to use a multi-stage pipeline with validation, preview, and deployment steps:

```yaml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - infra/**

variables:
  vmImageName: 'ubuntu-latest'

stages:
- stage: Validate
  displayName: 'Validate Bicep Templates'
  jobs:
  - job: Validate
    displayName: 'Validate Bicep Files'
    pool:
      vmImage: $(vmImageName)
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
  displayName: 'Deploy to Development'
  dependsOn: Validate
  condition: succeeded()
  jobs:
  - deployment: DeployDev
    displayName: 'Deploy to Dev Environment'
    environment: 'Development'
    pool:
      vmImage: $(vmImageName)
    strategy:
      runOnce:
        deploy:
          steps:
          - checkout: self
          - task: AzureCLI@2
            displayName: 'Preview Changes (What-If)'
            inputs:
              azureSubscription: 'your-azure-service-connection'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az deployment group what-if \
                  --resource-group exampleRG-dev \
                  --template-file infra/main.bicep \
                  --parameters @infra/parameters/dev.parameters.json
          
          - task: AzureResourceManagerTemplateDeployment@3
            displayName: 'Deploy Infrastructure'
            inputs:
              deploymentScope: 'Resource Group'
              azureResourceManagerConnection: 'your-azure-service-connection'
              action: 'Create Or Update Resource Group'
              resourceGroupName: 'exampleRG-dev'
              location: 'eastus'
              templateLocation: 'Linked artifact'
              csmFile: 'infra/main.bicep'
              csmParametersFile: 'infra/parameters/dev.parameters.json'
              deploymentMode: 'Incremental'
              deploymentName: 'Dev-$(Build.BuildNumber)'

- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: DeployDev
  condition: succeeded()
  jobs:
  - deployment: DeployProd
    displayName: 'Deploy to Prod Environment'
    environment: 'Production'   # Requires approval in environments
    pool:
      vmImage: $(vmImageName)
    strategy:
      runOnce:
        deploy:
          steps:
          - checkout: self
          - task: AzureResourceManagerTemplateDeployment@3
            displayName: 'Deploy Infrastructure'
            inputs:
              deploymentScope: 'Resource Group'
              azureResourceManagerConnection: 'your-azure-service-connection'
              action: 'Create Or Update Resource Group'
              resourceGroupName: 'exampleRG-prod'
              location: 'eastus'
              templateLocation: 'Linked artifact'
              csmFile: 'infra/main.bicep'
              csmParametersFile: 'infra/parameters/prod.parameters.json'
              deploymentMode: 'Incremental'
              deploymentName: 'Prod-$(Build.BuildNumber)'
```

## Deployment Scopes

Bicep files can be deployed at different scopes. Here are examples for each:

### Subscription-level Deployment

```yaml
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Subscription'
    azureResourceManagerConnection: '$(azureServiceConnection)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: '$(templateFile)'
    deploymentMode: 'Incremental'
    deploymentName: 'SubscriptionDeployment'
```

### Management Group-level Deployment

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: '$(azureServiceConnection)'
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az deployment mg create \
        --management-group-id "YourManagementGroupId" \
        --location "$(location)" \
        --template-file "$(templateFile)" \
        --name "MgDeployment-$(Build.BuildNumber)"
```

## Parameterization Best Practices

### Environment-specific Parameter Files

Create separate parameter files for each environment:

```
/infra
  /main.bicep
  /modules
    /storage.bicep
    /network.bicep
  /parameters
    /dev.parameters.json
    /test.parameters.json
    /prod.parameters.json
```

Example parameter file (`dev.parameters.json`):

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "value": "Development"
    },
    "storageAccountType": {
      "value": "Standard_LRS"
    },
    "location": {
      "value": "eastus"
    }
  }
}
```

### Dynamic Variable Substitution

You can use Azure DevOps variable groups or pipeline variables to dynamically substitute values:

```yaml
variables:
- group: 'BicepDeploymentVariables'
- name: 'buildNumber'
  value: '$(Build.BuildNumber)'

steps:
- task: FileTransform@1
  inputs:
    folderPath: '$(System.DefaultWorkingDirectory)/infra/parameters'
    fileType: 'json'
    targetFiles: '**/*.parameters.json'
```

## Security Considerations

### Secure Parameter Handling

Store sensitive values in Azure Key Vault and reference them in your pipeline:

```yaml
variables:
- group: 'KeyVaultVariables' # Variable group linked to Key Vault

steps:
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    # ...other inputs
    overrideParameters: '-adminPassword "$(adminPassword)" -servicePrincipalSecret "$(spSecret)"'
```

In your Bicep file:

```bicep
@secure()
param adminPassword string

@secure()
param servicePrincipalSecret string
```

### Service Connection with RBAC

Use a service connection with appropriate RBAC permissions based on the principle of least privilege:

1. Create a custom role with only the permissions needed for deployment
2. Assign this role to the service principal used by the Azure DevOps service connection

### Azure DevOps Environments for Approvals

Configure approval gates for sensitive environments:

1. Go to **Pipelines > Environments** in Azure DevOps
2. Create environments for Development, Test, and Production
3. Add approval checks to the Production environment
4. Reference these environments in your deployment jobs

## Monitoring and Troubleshooting

### Log Deployment Output

Add steps to capture deployment logs for troubleshooting:

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: $(azureServiceConnection)
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az deployment group show \
        --resource-group $(resourceGroupName) \
        --name BicepDeployment-$(Build.BuildNumber) \
        --query properties.outputs > $(Build.ArtifactStagingDirectory)/deployment-outputs.json

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)'
    ArtifactName: 'deployment-artifacts'
    publishLocation: 'Container'
```

### Pipeline Badge

Add a deployment status badge to your README file:

```markdown
![Build Status](https://dev.azure.com/{organization}/{project}/_apis/build/status/{pipeline-name}?branchName=main)
```

## Conclusion

Integrating Bicep with Azure Pipelines provides a robust workflow for automated infrastructure deployment across different environments. By using multi-stage pipelines, environment-specific parameters, and proper security practices, you can achieve reliable, repeatable infrastructure deployments.

For more information, consult these resources:

- [Azure Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager Template Deployment Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-resource-group-deployment)
