---
description: Setting up and using Bicep for Azure Infrastructure as Code deployments
---

# Bicep - Azure Infrastructure as Code

Bicep is Microsoft's domain-specific language (DSL) for deploying Azure resources declaratively. It provides a transparent abstraction over ARM templates with improved authoring experience, modularity, and enhanced type safety.

## Getting Started

### Installation

Install the Bicep CLI using Azure CLI:

```bash
# Install Bicep tools
az bicep install

# Verify installation
az bicep version
```

For VS Code users, install the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) for syntax highlighting, validation, and IntelliSense.

## Bicep File Structure

A Bicep file consists of the following elements:

```bicep
metadata <metadata-name> = ANY

targetScope = '<scope>'

@<decorator>(<argument>)
param <parameter-name> <parameter-data-type> = <default-value>

var <variable-name> = <variable-value>

resource <resource-symbolic-name> '<resource-type>@<api-version>' = {
  <resource-properties>
}

module <module-symbolic-name> '<path-to-file>' = {
  name: '<linked-deployment-name>'
  params: {
    <parameter-names-and-values>
  }
}

output <output-name> <output-data-type> = <output-value>
```

## Basic Example

The following example shows a Bicep file that creates a storage account and deploys a web app module:

```bicep
metadata description = 'Creates a storage account and a web app'

@description('The prefix to use for the storage account name.')
@minLength(3)
@maxLength(11)
param storagePrefix string

param storageSKU string = 'Standard_LRS'
param location string = resourceGroup().location

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

module webModule './webApp.bicep' = {
  name: 'webDeploy'
  params: {
    skuName: 'S1'
    location: location
  }
}
```

## Deployment Scopes

Bicep supports various deployment scopes:

```bicep
// Default is resourceGroup scope
targetScope = 'resourceGroup'       // Deploy to a resource group
targetScope = 'subscription'        // Deploy to a subscription
targetScope = 'managementGroup'     // Deploy to a management group
targetScope = 'tenant'              // Deploy to the tenant
```

## Practical Examples

### Multi-Region Deployment

```bicep
// Define regions for deployment
param regions array = [
  'eastus'
  'westus2'
]

// Deploy resources to each region
@batchSize(1)
module regionDeploy 'region-stack.bicep' = [for region in regions: {
  name: 'region-deploy-${region}'
  params: {
    location: region
    environment: environment
  }
}]
```

### Secure Parameter Handling

```bicep
@description('The admin username for the SQL server')
param sqlAdminUsername string

@secure()
@description('The admin password for the SQL server')
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'sql-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}
```

### Conditional Deployment

```bicep
param deployStorage bool = true
param storageName string
param location string = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = if (deployStorage) {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```

## Best Practices

### 1. Modular Design Pattern

Organize your deployments into reusable modules:

```
/bicep-project
  /modules
    /network
      vnet.bicep
      nsg.bicep
    /compute
      vm.bicep
      vmss.bicep
    /storage
      storage.bicep
  main.bicep
  parameters.json
```

### 2. Use Parameter Files

Create environment-specific parameter files:

```json
// dev.parameters.json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "value": "dev"
    },
    "vmSize": {
      "value": "Standard_D2s_v3"
    }
  }
}
```

### 3. Resource Naming

Use consistent naming conventions:

```bicep
// Define naming convention
param prefix string
param env string
var storageName = '${prefix}storage${env}${uniqueString(resourceGroup().id)}'
```

### 4. Secret Management

Store secrets in Azure Key Vault and reference them:

```bicep
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroup)
}

module webApp 'modules/webapp.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    connectionString: kv.getSecret('DbConnectionString')
  }
}
```

## DevOps Integration

### Azure Pipelines

```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: ubuntu-latest

steps:
- task: AzureCLI@2
  inputs:
    azureSubscription: 'your-azure-service-connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az bicep build --file main.bicep
      az deployment group create \
        --resource-group your-resource-group \
        --template-file main.bicep \
        --parameters @dev.parameters.json
```

### GitHub Actions

```yaml
# .github/workflows/deploy-bicep.yml
name: Deploy Bicep Template

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Deploy Bicep
      uses: azure/arm-deploy@v1
      with:
        subscriptionId: ${{ secrets.SUBSCRIPTION_ID }}
        resourceGroupName: your-resource-group
        template: ./main.bicep
        parameters: ./dev.parameters.json
```

## Linting and Validation

Validate your Bicep files before deployment:

```bash
# Validate a Bicep file
az bicep build --file main.bicep

# Preview changes (What-if)
az deployment group what-if \
  --resource-group your-resource-group \
  --template-file main.bicep \
  --parameters @dev.parameters.json
```

## Additional Resources

- [Official Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep GitHub Repository](https://github.com/Azure/bicep)
- [Bicep Playground](https://aka.ms/bicepdemo)
- [Azure QuickStart Templates](https://github.com/Azure/azure-quickstart-templates)

## See Also

- [Bicep with GitHub Actions](bicep-with-github-actions.md)
- [Integrate Bicep with Azure Pipelines](integrate-bicep-with-azure-pipelines.md)
- [Bicep Template Specs](template-spec-for-bicep.md)
- [Use Inline Scripts with Bicep](use-inline-scripts.md)
