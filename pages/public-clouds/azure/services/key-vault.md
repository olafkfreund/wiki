# Azure Key Vault

## Overview
Azure Key Vault safeguards cryptographic keys, secrets, and certificates used by cloud applications and services.

## Real-life Use Cases
- **Cloud Architect:** Centralize secrets management for microservices.
- **DevOps Engineer:** Automate secret rotation in CI/CD pipelines.

## Terraform Example
```hcl
resource "azurerm_key_vault" "main" {
  name                        = "my-keyvault"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}
```

## Bicep Example
```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'my-keyvault'
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}
```

## Azure CLI Example
```sh
az keyvault create --name my-keyvault --resource-group my-rg --location westeurope
```

## Best Practices
- Enable soft-delete and purge protection.
- Use RBAC for access control.

## Common Pitfalls
- Storing secrets in code.
- Not monitoring access logs.

> **Joke:** Why did the secret leave Key Vault? It couldn’t handle the pressure!
