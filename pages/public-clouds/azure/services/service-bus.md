# Azure Service Bus

## Overview
Azure Service Bus is a fully managed enterprise message broker for decoupling applications and services.

## Real-life Use Cases
- **Cloud Architect:** Design event-driven microservices architectures.
- **DevOps Engineer:** Buffer jobs for background processing.

## Terraform Example
```hcl
resource "azurerm_servicebus_namespace" "main" {
  name                = "myservicebusns"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}
```

## Bicep Example
```bicep
resource sbNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: 'myservicebusns'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}
```

## Azure CLI Example
```sh
az servicebus namespace create --resource-group my-rg --name myservicebusns --location westeurope --sku Standard
```

## Best Practices
- Use topics and subscriptions for pub/sub.
- Enable geo-disaster recovery.

## Common Pitfalls
- Not setting message TTLs.
- Ignoring dead-letter queues.

> **Joke:** Why did the Service Bus message get lost? It missed its queue!
