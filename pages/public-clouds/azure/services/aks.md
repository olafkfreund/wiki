# Azure Kubernetes Service (AKS)

## Overview

Azure Kubernetes Service (AKS) is a managed Kubernetes container orchestration service that simplifies deploying, managing, and scaling containerized applications using Kubernetes on Azure.

## Real-life Use Cases

- **Cloud Architect:** Design multi-region, highly available Kubernetes clusters for microservices.
- **DevOps Engineer:** Automate cluster provisioning and application deployment pipelines.

## Terraform Example

```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
```

## Bicep Example

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
  name: 'my-aks-cluster'
  location: resourceGroup().location
  properties: {
    dnsPrefix: 'myaks'
    agentPoolProfiles: [
      {
        name: 'default'
        count: 2
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    identity: {
      type: 'SystemAssigned'
    }
  }
}
```

## Azure CLI Example

```sh
az aks create \
  --resource-group my-rg \
  --name my-aks-cluster \
  --node-count 2 \
  --enable-managed-identity \
  --generate-ssh-keys
```

## Best Practices

- Use managed identities for secure access.
- Enable RBAC and Azure AD integration.
- Regularly upgrade Kubernetes versions.

## Common Pitfalls

- Not configuring node pool scaling.
- Ignoring cluster monitoring and logging.

> **Joke:** Why did the AKS pod get invited to the party? Because it always knew how to scale up the fun!
