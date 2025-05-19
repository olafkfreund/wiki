# Azure App Service

## Overview

Azure App Service is a fully managed platform for building, deploying, and scaling web apps and APIs.

## Real-life Use Cases

- **Cloud Architect:** Rapidly prototype and deploy web apps.
- **DevOps Engineer:** Automate blue/green deployments for zero downtime.

## Terraform Example

```hcl
resource "azurerm_app_service_plan" "main" {
  name                = "my-appservice-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "my-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
}
```

## Bicep Example

```bicep
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'my-appservice-plan'
  location: resourceGroup().location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: 'my-app'
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
```

## Azure CLI Example

```sh
az appservice plan create --name my-appservice-plan --resource-group my-rg --sku S1
az webapp create --name my-app --resource-group my-rg --plan my-appservice-plan
```

## Best Practices

- Use deployment slots for zero-downtime releases.
- Enable autoscaling.

## Common Pitfalls

- Not configuring custom domains.
- Ignoring app health checks.

> **Joke:** Why did App Service get so popular? It always knew how to scale up a party!
