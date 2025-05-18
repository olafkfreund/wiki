---
description: >-
  This guide shows how to create, manage, and deploy Template Specs with Bicep files
  for enterprise-scale infrastructure deployment.
---

# Bicep Template Specs (2025)

Template Specs in Azure let you store, version, and share Bicep (and ARM) templates as first-class Azure resources. This enables DevOps and SRE teams to standardize deployments, enforce governance, and accelerate infrastructure delivery across environments.

---

## Why Use Template Specs?
- **Versioned IaC**: Store and manage Bicep templates with version control in Azure
- **Reusability**: Share templates across teams and subscriptions
- **Governance**: Enforce standards and best practices with approved templates
- **CI/CD Integration**: Reference template specs in pipelines for consistent deployments

---

## Create a Template Spec from a Bicep File

```bash
az bicep build --file main.bicep
az ts create \
  --name myTemplateSpec \
  --version 1.0.0 \
  --resource-group my-rg \
  --location eastus \
  --template-file main.json
```

---

## Deploy from a Template Spec

```bash
az deployment group create \
  --resource-group my-rg \
  --template-spec '/subscriptions/<sub-id>/resourceGroups/my-rg/providers/Microsoft.Resources/templateSpecs/myTemplateSpec/versions/1.0.0' \
  --parameters @dev.parameters.json
```

---

## Real-Life DevOps & SRE Example: Standardized Storage Account

1. **Create a reusable storage.bicep:**

```bicep
param storageName string
param location string = resourceGroup().location
param tags object

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
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
```

2. **Publish as a template spec:**

```bash
az bicep build --file storage.bicep
az ts create \
  --name storageSpec \
  --version 1.0.0 \
  --resource-group infra-rg \
  --location eastus \
  --template-file storage.json
```

3. **Deploy from the template spec in CI/CD:**

```yaml
- name: Deploy Storage from Template Spec
  run: |
    az deployment group create \
      --resource-group dev-rg \
      --template-spec '/subscriptions/${{ secrets.AZURE_SUBSCRIPTION }}/resourceGroups/infra-rg/providers/Microsoft.Resources/templateSpecs/storageSpec/versions/1.0.0' \
      --parameters storageName=devstorage tags='{"env":"dev"}'
```

---

## Best Practices (2025)
- Use template specs for all shared, production-grade Bicep modules
- Version template specs for traceability and rollback
- Store template specs in a central infra resource group
- Reference template specs by version in CI/CD pipelines
- Document parameters and outputs for discoverability

---

## Common Pitfalls
- Not versioning template specs (makes rollbacks difficult)
- Hardcoding values instead of using parameters
- Not updating references in pipelines after publishing new versions

---

## Azure & Bicep Jokes

> **Bicep Joke:** Why did the engineer use template specs? To flex their standards across the org!

> **Azure Joke:** Why did the template spec never get lost? It always had a resource group to call home!

---

## References
- [Template Specs Documentation](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-specs)
- [Bicep Official Docs](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

---

> **Search Tip:** Use keywords like `bicep template spec`, `versioning`, `ci/cd`, or `governance` to quickly find relevant examples and best practices.

