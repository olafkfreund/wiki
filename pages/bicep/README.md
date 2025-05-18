---
description: >-
  Bicep for DevOps & SRE: Modern best practices, real-world examples, and actionable guidance for Azure Infrastructure as Code (2025).
---

# Bicep - Azure Infrastructure as Code (2025)

Bicep is Microsoft's domain-specific language (DSL) for deploying Azure resources declaratively. It offers a clean syntax, modularity, and strong type safety, making it ideal for DevOps and SRE teams automating cloud infrastructure.

---

## Why Use Bicep for DevOps & SRE?
- **Readable IaC**: Simpler than ARM JSON, easy to review in code and PRs
- **Modular**: Supports reusable modules for DRY deployments
- **Native Azure Integration**: First-class support in Azure CLI, VS Code, and GitHub Actions
- **Strong Typing**: Early error detection and IntelliSense
- **Cloud-Native**: Works seamlessly with Azure DevOps, GitHub Actions, and CI/CD

---

## Getting Started

### Install Bicep CLI

```bash
az bicep install
az bicep version
```

### VS Code Extension

Install the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) for syntax highlighting, validation, and code completion.

---

## Bicep File Structure

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

---

## Real-World Examples

### 1. Deploy a Storage Account with Tags and RBAC

```bicep
param storagePrefix string
param location string = resourceGroup().location
param tags object = {
  environment: 'dev'
  owner: 'devops-team'
}

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(stg.id, 'Storage Blob Data Contributor')
  scope: stg
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: '00000000-0000-0000-0000-000000000000' // Replace with your AAD objectId
  }
}
```

### 2. Multi-Region Deployment with Module Reuse

```bicep
param regions array = [ 'eastus' 'westeurope' ]
param environment string = 'prod'

module storage './modules/storage.bicep' = [for region in regions: {
  name: 'storage-${region}'
  params: {
    location: region
    environment: environment
  }
}]
```

### 3. Secure Parameter Handling with Key Vault

```bicep
@secure()
param sqlAdminPassword string
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'my-keyvault'
}
module sql './modules/sql.bicep' = {
  name: 'sqlDeploy'
  params: {
    adminPassword: kv.getSecret('SqlAdminPassword')
  }
}
```

### 4. Conditional Resource Deployment

```bicep
param deployAppInsights bool = true
resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (deployAppInsights) {
  name: 'my-appinsights'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
```

### 5. Outputting Useful Deployment Info

```bicep
output storageAccountName string = stg.name
output storageAccountEndpoint string = stg.properties.primaryEndpoints.blob
```

---

## More Real-World DevOps & SRE Examples

### Example: Deploying a VM with Custom Script Extension

```bicep
param vmName string
param location string = resourceGroup().location
param adminUsername string
@secure()
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/networkInterfaces/${vmName}-nic'
        }
      ]
    }
  }
}

resource customScript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${vm.name}/customScript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/your-org/scripts/main/setup.sh'
      ]
      commandToExecute: 'bash setup.sh'
    }
  }
  dependsOn: [vm]
}
```

### Example: Using Bicep with Azure Policy for Compliance

```bicep
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'enforce-tagging'
  properties: {
    displayName: 'Enforce resource tagging'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/require-tag-environment'
    parameters: {
      tagName: {
        value: 'environment'
      }
      tagValue: {
        value: 'devops'
      }
    }
    scope: resourceGroup().id
  }
}
```

---

## Best Practices for DevOps & SRE (2025)
- Use modules for reusable infrastructure patterns
- Store secrets in Key Vault, not in parameters files
- Use parameter files for environment-specific values
- Validate Bicep files with `az bicep build` and `az deployment group what-if`
- Integrate Bicep deployments into CI/CD (see below)
- Use tags and naming conventions for resource governance
- Document parameters and outputs with `@description`
- Use `@secure()` for sensitive parameters

---

## CI/CD Integration

### Azure Pipelines

```yaml
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

---

## Linting, Validation, and What-If

```bash
az bicep build --file main.bicep
az deployment group what-if --resource-group my-rg --template-file main.bicep --parameters @dev.parameters.json
```

---

## Common Pitfalls
- Hardcoding secrets in Bicep or parameter files
- Not using modules for repeatable patterns
- Ignoring resource dependencies (use `dependsOn` when needed)
- Not validating templates before deployment
- Forgetting to use `@secure()` for sensitive parameters

---

## Azure & Bicep Jokes

> **Bicep Joke:** Why did the DevOps engineer love Bicep? Because it flexes with every deployment!

> **Azure Joke:** Why did the cloud engineer break up with Azure? Too many resource groups!

> **Bicep Joke:** Why did the SRE use Bicep? To avoid ARM fatigue!

> **Azure Joke:** Why did the VM get invited to all the parties? Because it always had great uptime!

> **Bicep Joke:** Why did the SRE write Bicep modules? To keep their deployments in shape!

---

## Additional Resources
- [Official Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Bicep GitHub Repository](https://github.com/Azure/bicep)
- [Bicep Playground](https://aka.ms/bicepdemo)
- [Azure QuickStart Templates](https://github.com/Azure/azure-quickstart-templates)

---

## See Also
- [Bicep with GitHub Actions](bicep-with-github-actions.md)
- [Integrate Bicep with Azure Pipelines](integrate-bicep-with-azure-pipelines.md)
- [Bicep Template Specs](template-spec-for-bicep.md)
- [Use Inline Scripts with Bicep](use-inline-scripts.md)
- [Kubernetes Provider for Bicep](kubernetes-provider.md)
- [Loading Script Files in Bicep](load-script-file.md)

---

> **Search Tip:** Use keywords like `bicep`, `azure`, `module`, `key vault`, `ci/cd`, `vm`, `policy`, or `devops` in the search bar to quickly find relevant examples and best practices.
