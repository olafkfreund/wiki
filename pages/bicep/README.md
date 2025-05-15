---
description: Setting up and using bicep for Azure Deployments
---

# Bicep

---

## Changelog 2024–2025

- **2025-04:** Bicep v0.21 released with improved module registry support and enhanced LLM integration for code suggestions.
- **2025-03:** Native support for NixOS and WSL deployment scenarios in Azure CLI and Bicep tooling.
- **2025-02:** Security scanning integration (Checkov, PSRule) now recommended by default in official docs.
- **2025-01:** Bicep parameter files support environment variable substitution for CI/CD pipelines.
- **2024-12:** Improved error messages and diagnostics in bicep build and az deployment what-if.
- **2024-10:** Enhanced documentation for using Bicep with GitHub Actions and LLMs (Copilot, Claude).
- **2024-08:** Bicep modules can now be published and consumed from private registries with RBAC.

---

A Bicep file has the following elements.

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
```plaintext

The following example shows an implementation of these elements.

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
```plaintext

---

## 2025 Best Practices for Bicep
- Use modules for reusable infrastructure patterns
- Store Bicep files in version control (Git)
- Use parameter files for environment-specific values
- Validate templates with `bicep build` and `az deployment what-if`
- Integrate security scanning (e.g., Checkov, PSRule)
- Document parameters and outputs with decorators
- Use LLMs (GitHub Copilot, Claude) for code suggestions and reviews

---

## Step-by-Step: Deploying Bicep with Azure CLI

### 1. Install Bicep CLI (Linux, WSL, NixOS)
```bash
# Install/update Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az bicep install
# Or upgrade
az bicep upgrade
```

### 2. Build and Validate Bicep
```bash
bicep build main.bicep
az deployment sub what-if --location westeurope --template-file main.bicep
```

### 3. Deploy to Azure
```bash
az deployment group create \
  --resource-group my-rg \
  --template-file main.bicep \
  --parameters storagePrefix=devops skuName=Standard_LRS
```

---

## Real-Life Example: Bicep in GitHub Actions

```yaml
name: Deploy Bicep
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Deploy Bicep
        run: |
          az bicep install
          az deployment group create \
            --resource-group my-rg \
            --template-file main.bicep \
            --parameters storagePrefix=devops
```

---

## Using LLMs (Copilot, Claude) for Bicep
- Use Copilot/Claude to generate Bicep modules, parameter files, and documentation
- Example prompt: "Generate a Bicep module for an Azure Key Vault with RBAC enabled."
- Always review and test LLM-generated code for security and compliance

---

## References
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [Bicep GitHub](https://github.com/Azure/bicep)
- [Checkov](https://www.checkov.io/)
- [PSRule for Azure](https://github.com/Azure/PSRule.Rules.Azure)
