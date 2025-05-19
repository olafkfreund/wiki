# Azure SQL Database

## Overview
Azure SQL Database is a fully managed relational database service, compatible with Microsoft SQL Server, designed for high availability and scalability.

## Real-life Use Cases
- **Cloud Architect:** Design multi-region, highly available database backends for enterprise apps.
- **DevOps Engineer:** Automate database provisioning and configuration for CI/CD pipelines.

## Terraform Example
```hcl
resource "azurerm_sql_server" "main" {
  name                         = "sqlserverdemo"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssword1234!"
}

resource "azurerm_sql_database" "main" {
  name                = "sqldbdemo"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  server_name         = azurerm_sql_server.main.name
  sku_name            = "S0"
}
```

## Bicep Example
```bicep
resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: 'sqlserverdemo'
  location: resourceGroup().location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'P@ssword1234!'
    version: '12.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01' = {
  name: 'sqldbdemo'
  parent: sqlServer
  properties: {}
  sku: {
    name: 'S0'
  }
}
```

## Azure CLI Example
```sh
az sql server create --name sqlserverdemo --resource-group my-rg --location westeurope --admin-user sqladmin --admin-password P@ssword1234!
az sql db create --resource-group my-rg --server sqlserverdemo --name sqldbdemo --service-objective S0
```

## Best Practices
- Use geo-replication for high availability.
- Enable Advanced Threat Protection.
- Use managed identities for app authentication.

## Common Pitfalls
- Hardcoding credentials in code or scripts.
- Not configuring firewall rules for access.

> **Joke:** Why did the Azure SQL query get a timeout? It couldn’t commit to a relationship!
