---
description: >-
  This quickstart shows you how to integrate Bicep files with Azure Pipelines
  for continuous integration and continuous deployment (CI/CD).
---

# Integrate Bicep with Azure Pipelines

Use Azure Resource Manager Template Deployment task

```yaml
trigger:
- master

name: Deploy Bicep files

variables:
  vmImageName: 'ubuntu-latest'

  azureServiceConnection: '<your-connection-name>'
  resourceGroupName: 'exampleRG'
  location: '<your-resource-group-location>'
  templateFile: './main.bicep'
pool:
  vmImage: $(vmImageName)

steps:
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: '$(azureServiceConnection)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: '$(templateFile)'
    overrideParameters: '-storageAccountType Standard_LRS'
    deploymentMode: 'Incremental'
    deploymentName: 'DeployPipelineTemplate'ml
```plaintext

#### Use Azure CLI task <a href="#use-azure-cli-task" id="use-azure-cli-task"></a>

```yaml
trigger:
- master

name: Deploy Bicep files

variables:
  vmImageName: 'ubuntu-latest'

  azureServiceConnection: '<your-connection-name>'
  resourceGroupName: 'exampleRG'
  location: '<your-resource-group-location>'
  templateFile: 'main.bicep'
pool:
  vmImage: $(vmImageName)

steps:
- task: AzureCLI@2
  inputs:
    azureSubscription: $(azureServiceConnection)
    scriptType: bash
    scriptLocation: inlineScript
    useGlobalConfig: false
    inlineScript: |
      az --version
      az group create --name $(resourceGroupName) --location $(location)
      az deployment group create --resource-group $(resourceGroupName) --template-file $(templateFile)
```plaintext

To override the parameters, update the last line of `inlineScript` to:

{% code overflow="wrap" %}
```powershell
az deployment group create --resource-group $(resourceGroupName) --template-file $(templateFile) --parameters storageAccountType='Standard_GRS' location='eastus'
```plaintext
{% endcode %}
