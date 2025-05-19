# Azure Databricks

## Overview
Azure Databricks is an Apache Spark-based analytics platform optimized for Azure, enabling big data analytics and AI solutions.

## Real-life Use Cases
- **Cloud Architect:** Design scalable data pipelines for ETL and machine learning.
- **DevOps Engineer:** Automate Databricks workspace and cluster provisioning for data teams.

## Terraform Example
```hcl
resource "azurerm_databricks_workspace" "main" {
  name                = "mydatabricks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "standard"
}
```

## Bicep Example
```bicep
resource databricks 'Microsoft.Databricks/workspaces@2023-05-01' = {
  name: 'mydatabricks'
  location: resourceGroup().location
  sku: {
    name: 'standard'
  }
  properties: {}
}
```

## Azure CLI Example
```sh
az databricks workspace create --resource-group my-rg --name mydatabricks --location westeurope --sku standard
```

## Best Practices
- Use separate workspaces for dev, test, and prod.
- Integrate with Azure AD for access control.

## Common Pitfalls
- Not monitoring cluster costs.
- Over-permissioned users.

> **Joke:** Why did the Databricks cluster get promoted? It always sparked new ideas!
