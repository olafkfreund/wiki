---
description: >-
  This guide shows how to create, manage, and deploy Template Specs with Bicep files
  for enterprise-scale infrastructure deployment.
---

# Template Specs for Bicep

Template Specs provide a centralized way to share Bicep-defined infrastructure as versioned, reusable artifacts without exposing the underlying code. This approach enables organizations to create governed, standardized infrastructure components that can be deployed by teams without requiring direct access to modify the templates.

## What's New in 2025

- Native Bicep support in Azure Portal for Template Specs
- Enhanced versioning with semantic versioning support
- Deployment history tracking and rollback capabilities
- Integration with Azure RBAC for fine-grained access control
- Built-in validation for compliance and governance

## Creating a Template Spec

You can create Template Specs using PowerShell, Azure CLI, or directly with Bicep.

### Using PowerShell

```powershell
# Create a resource group for storing Template Specs
New-AzResourceGroup `
  -Name templateSpecRG `
  -Location westus2

# Create a Template Spec from a Bicep file
New-AzTemplateSpec `
  -Name storageSpec `
  -Version "1.0.0" `
  -ResourceGroupName templateSpecRG `
  -Location westus2 `
  -TemplateFile "path/to/storage.bicep" `
  -DisplayName "Standard Storage Account" `
  -Description "Deploys a storage account with configurable performance tier and redundancy"
```

### Using Azure CLI

```bash
# Create a resource group for storing Template Specs
az group create \
  --name templateSpecRG \
  --location westus2

# Create a Template Spec from a Bicep file
az ts create \
  --name storageSpec \
  --version "1.0.0" \
  --resource-group templateSpecRG \
  --location westus2 \
  --template-file "path/to/storage.bicep" \
  --display-name "Standard Storage Account" \
  --description "Deploys a storage account with configurable performance tier and redundancy"
```

### Using Bicep (Infrastructure as Code approach)

Create a Bicep file (`template-spec.bicep`) to define and deploy your Template Spec:

```bicep
param templateSpecName string = 'storageSpec'
param templateSpecVersion string = '1.0.0'
param location string = resourceGroup().location

// Create the Template Spec resource
resource templateSpec 'Microsoft.Resources/templateSpecs@2022-02-01' = {
  name: templateSpecName
  location: location
  properties: {
    description: 'Enterprise Storage Account Template'
    displayName: 'Storage Account (Enterprise)'
  }
}

// Create a version of the Template Spec with an embedded storage account template
resource templateSpecVersion 'Microsoft.Resources/templateSpecs/versions@2022-02-01' = {
  parent: templateSpec
  name: templateSpecVersion
  location: location
  properties: {
    mainTemplate: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      'contentVersion': '1.0.0.0'
      'parameters': {
        'storageAccountType': {
          'type': 'string'
          'defaultValue': 'Standard_LRS'
          'allowedValues': [
            'Premium_LRS'
            'Premium_ZRS'
            'Standard_GRS'
            'Standard_GZRS'
            'Standard_LRS'
            'Standard_RAGRS'
            'Standard_RAGZRS'
            'Standard_ZRS'
          ]
          'metadata': {
            'description': 'Storage account SKU'
          }
        }
        'storageNamePrefix': {
          'type': 'string'
          'defaultValue': 'storage'
          'maxLength': 10
          'metadata': {
            'description': 'Prefix for the storage account name'
          }
        }
        'location': {
          'type': 'string'
          'defaultValue': '[resourceGroup().location]'
          'metadata': {
            'description': 'Location for resources'
          }
        }
        'enableHns': {
          'type': 'bool'
          'defaultValue': false
          'metadata': {
            'description': 'Enable hierarchical namespace for Data Lake Storage Gen2'
          }
        }
      }
      'variables': {
        'storageAccountName': '[format(''{0}{1}'', parameters(''storageNamePrefix''), uniqueString(resourceGroup().id))]'
      }
      'resources': [
        {
          'type': 'Microsoft.Storage/storageAccounts'
          'apiVersion': '2023-01-01'
          'name': '[variables(''storageAccountName'')]'
          'location': '[parameters(''location'')]'
          'sku': {
            'name': '[parameters(''storageAccountType'')]'
          }
          'kind': 'StorageV2'
          'properties': {
            'accessTier': 'Hot'
            'supportsHttpsTrafficOnly': true
            'minimumTlsVersion': 'TLS1_2'
            'allowBlobPublicAccess': false
            'isHnsEnabled': '[parameters(''enableHns'')]'
          }
        }
      ]
      'outputs': {
        'storageAccountName': {
          'type': 'string'
          'value': '[variables(''storageAccountName'')]'
        }
        'storageAccountId': {
          'type': 'string'
          'value': '[resourceId(''Microsoft.Storage/storageAccounts'', variables(''storageAccountName''))]'
        }
        'primaryEndpoint': {
          'type': 'string'
          'value': '[reference(resourceId(''Microsoft.Storage/storageAccounts'', variables(''storageAccountName''))).primaryEndpoints.blob]'
        }
      }
    }
  }
}

// Output the Template Spec ID for reference
output templateSpecId string = templateSpec.id
output templateSpecVersionId string = templateSpecVersion.id
```

Deploy this Bicep file to create your Template Spec:

```bash
# PowerShell
New-AzResourceGroupDeployment `
  -ResourceGroupName templateSpecRG `
  -TemplateFile "template-spec.bicep"

# Azure CLI
az deployment group create \
  --resource-group templateSpecRG \
  --template-file "template-spec.bicep"
```

## Deploying from a Template Spec

### PowerShell Deployment

```powershell
# Create a resource group for deployment
New-AzResourceGroup `
  -Name storageRG `
  -Location westus2

# Get the Template Spec ID
$id = (Get-AzTemplateSpec `
  -ResourceGroupName templateSpecRG `
  -Name storageSpec `
  -Version "1.0.0").Versions.Id

# Deploy the Template Spec
New-AzResourceGroupDeployment `
  -TemplateSpecId $id `
  -ResourceGroupName storageRG `
  -storageNamePrefix "finance" `
  -storageAccountType "Standard_GRS" `
  -enableHns $true
```

### Azure CLI Deployment

```bash
# Create a resource group for deployment
az group create \
  --name storageRG \
  --location westus2

# Get the Template Spec ID
templateSpecId=$(az ts show \
  --name storageSpec \
  --resource-group templateSpecRG \
  --version "1.0.0" \
  --query "id" -o tsv)

# Deploy the Template Spec
az deployment group create \
  --resource-group storageRG \
  --template-spec $templateSpecId \
  --parameters storageNamePrefix=finance storageAccountType=Standard_GRS enableHns=true
```

### Bicep Deployment

For a more declarative approach, reference the Template Spec from your Bicep files:

```bicep
// deployment.bicep
param location string = resourceGroup().location
param environment string = 'dev'
param subscriptionId string = subscription().subscriptionId

// Deploy storage from Template Spec
module storageAccount 'ts:${subscriptionId}/templateSpecRG/storageSpec:1.0.0' = {
  name: 'deploy-${environment}-storage'
  params: {
    storageNamePrefix: '${environment}st'
    storageAccountType: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
    location: location
    enableHns: true
  }
}

// Use the outputs from the Template Spec deployment
output storageAccountName string = storageAccount.outputs.storageAccountName
output storageAccountId string = storageAccount.outputs.storageAccountId
output blobEndpoint string = storageAccount.outputs.primaryEndpoint
```

## Template Spec Versioning and Management

### Creating New Versions

As your templates evolve, create new versions to maintain backward compatibility:

```powershell
# PowerShell - Create a new version
New-AzTemplateSpec `
  -Name storageSpec `
  -Version "2.0.0" `
  -ResourceGroupName templateSpecRG `
  -Location westus2 `
  -TemplateFile "path/to/updated-storage.bicep"
```

```bash
# Azure CLI - Create a new version
az ts create \
  --name storageSpec \
  --version "2.0.0" \
  --resource-group templateSpecRG \
  --location westus2 \
  --template-file "path/to/updated-storage.bicep"
```

### Listing Available Template Specs

```powershell
# PowerShell - List all Template Specs
Get-AzTemplateSpec -ResourceGroupName templateSpecRG

# PowerShell - List all versions of a Template Spec
Get-AzTemplateSpec -ResourceGroupName templateSpecRG -Name storageSpec
```

```bash
# Azure CLI - List all Template Specs
az ts list --resource-group templateSpecRG -o table

# Azure CLI - List all versions of a Template Spec
az ts list --resource-group templateSpecRG --name storageSpec -o table
```

### Removing Template Specs

```powershell
# PowerShell - Remove a specific version
Remove-AzTemplateSpec `
  -ResourceGroupName templateSpecRG `
  -Name storageSpec `
  -Version "1.0.0"

# PowerShell - Remove all versions of a Template Spec
Remove-AzTemplateSpec `
  -ResourceGroupName templateSpecRG `
  -Name storageSpec
```

```bash
# Azure CLI - Remove a specific version
az ts delete \
  --name storageSpec \
  --version "1.0.0" \
  --resource-group templateSpecRG

# Azure CLI - Remove all versions of a Template Spec
az ts delete \
  --name storageSpec \
  --resource-group templateSpecRG \
  --yes
```

## CI/CD Integration

### Azure DevOps Pipeline Integration

```yaml
# azure-pipelines.yml - Create and update Template Specs
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - 'templates/**'

pool:
  vmImage: 'ubuntu-latest'

variables:
  templateSpecName: 'storageSpec'
  templateSpecRG: 'templateSpecRG'
  templateFile: '$(Build.SourcesDirectory)/templates/storage.bicep'

steps:
- task: AzureCLI@2
  displayName: 'Create/Update Template Spec'
  inputs:
    azureSubscription: 'your-azure-service-connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Get current date for version
      CURRENT_DATE=$(date +"%Y%m%d%H")
      VERSION="1.0.$CURRENT_DATE"
      
      echo "Creating Template Spec version: $VERSION"
      
      az ts create \
        --name $(templateSpecName) \
        --version $VERSION \
        --resource-group $(templateSpecRG) \
        --location westus2 \
        --template-file "$(templateFile)" \
        --display-name "Storage Account (CI/CD)" \
        --description "Auto-generated from build pipeline"
```

### GitHub Actions Workflow

```yaml
# .github/workflows/template-spec.yml
name: Update Template Specs

on:
  push:
    branches: [ main ]
    paths:
      - 'templates/**'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Create/Update Template Spec
      run: |
        # Generate version based on date and commit hash
        VERSION="1.0.$(date +%Y%m%d)-${GITHUB_SHA::7}"
        
        echo "Creating Template Spec version: $VERSION"
        
        az ts create \
          --name storageSpec \
          --version $VERSION \
          --resource-group templateSpecRG \
          --location westus2 \
          --template-file "./templates/storage.bicep" \
          --display-name "Storage Account (GitHub)" \
          --description "Created from GitHub Actions workflow"
```

## Best Practices for Template Specs

### 1. Implement a Versioning Strategy

Use semantic versioning (MAJOR.MINOR.PATCH) for Template Spec versions:
- Increment MAJOR for breaking changes
- Increment MINOR for new features (backward compatible)
- Increment PATCH for bug fixes

### 2. Organize Template Specs by Domain

Group related Template Specs in the same resource group by domain or application:
- `network-templatespecs-rg` - For networking components
- `compute-templatespecs-rg` - For compute resources
- `data-templatespecs-rg` - For data services

### 3. Document Parameters and Outputs

Include comprehensive metadata for all parameters:

```bicep
@description('The SKU tier for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageSku string = 'Standard_LRS'
```

### 4. Implement Automated Testing

Test your Template Specs as part of CI/CD:
- Validate syntax before publishing
- Deploy to test environments
- Run what-if operations to verify expected changes

### 5. Access Control

Grant users the minimum permissions needed:
- `Template Spec Reader` - For deployments only
- `Template Spec Contributor` - For creating/updating Template Specs

```bash
# Grant user permission to deploy from Template Spec
az role assignment create \
  --assignee user@example.com \
  --role "Template Spec Reader" \
  --scope "/subscriptions/{subscriptionId}/resourceGroups/templateSpecRG"
```

## Conclusion

Template Specs provide a powerful way to standardize infrastructure deployments across an organization while maintaining control over the templates themselves. By combining Bicep's declarative syntax with Template Specs' version management, you can create reusable infrastructure components that adhere to organizational standards and compliance requirements.

For more information, refer to the [Microsoft documentation on Template Specs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs).

