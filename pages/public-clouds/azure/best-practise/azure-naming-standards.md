# Azure Naming Standards

Consistent naming conventions are critical for managing Azure resources at scale. Well-defined standards improve automation, clarity, and governance, especially in enterprise and DevOps environments.

## Key Principles

- **Consistency:** Use the same pattern across all resource types and environments.
- **Readability:** Names should be easy to understand for engineers and automation tools.
- **Scalability:** Support for multiple environments, regions, and projects.
- **Automation-Friendly:** Avoid special characters and use lowercase where required (e.g., storage accounts).

## Recommended Naming Pattern

```
<resource-type-abbr>-<app/project>-<env>-<region>-<instance>
```

- `resource-type-abbr`: Short code for the resource type (see table below)
- `app/project`: Application or project name
- `env`: Environment (dev, test, prod, qa, uat, etc.)
- `region`: Azure region short code (e.g., weu for West Europe, eus for East US)
- `instance`: Optional numeric or descriptive instance (e.g., 01, db, web)

## Common Abbreviations

| Resource Type         | Abbreviation |
|----------------------|--------------|
| Resource Group       | rg           |
| Virtual Network      | vnet         |
| Subnet               | sn           |
| Network Interface    | nic          |
| Network Security Grp | nsg          |
| Virtual Machine      | vm           |
| Storage Account      | st           |
| Key Vault            | kv           |
| App Service          | app          |
| SQL Server           | sql          |
| SQL Database         | sqldb        |
| Cosmos DB            | cdb          |
| Function App         | func         |
| Application Gateway  | agw          |
| Firewall             | fw           |
| Log Analytics        | log          |

## Real-Life Examples

- **Resource Group:** `rg-myapp-prod-weu`
- **VM:** `vm-myapp-dev-weu-01`
- **Storage Account:** `stmyappprdweu01` (lowercase, no dashes)
- **Key Vault:** `kv-myapp-prod-weu`
- **App Service:** `app-myapp-test-eus`
- **SQL Database:** `sqldb-myapp-prod-weu`

## Automation Example (Terraform)

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-prod-weu"
  location = "westeurope"
}

resource "azurerm_storage_account" "main" {
  name                     = "stmyappprdweu01"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

## Automation Example (Azure CLI)

```sh
az group create --name rg-myapp-prod-weu --location westeurope
az storage account create --name stmyappprdweu01 --resource-group rg-myapp-prod-weu --location westeurope --sku Standard_LRS
```

## Best Practices

- Use [Microsoft's official naming rules](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) as a baseline.
- Document your naming convention and enforce it with Azure Policy or CI/CD checks.
- Use tags for additional metadata (e.g., owner, cost center, environment).
- Avoid using personally identifiable information (PII) in resource names.

## Common Pitfalls

- Inconsistent abbreviations or region codes.
- Exceeding Azure's resource name length limits.
- Using unsupported characters (e.g., uppercase, special symbols).

> **Joke:** Why did the Azure VM get a short name? Because it couldn't handle the character limit!
