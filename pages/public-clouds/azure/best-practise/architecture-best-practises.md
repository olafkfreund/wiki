---
description: >-
  Azure hub and spoke architecture is considered a best practice for several
  reasons:
---

# Architecture Best Practices: Azure Hub and Spoke

The Azure hub and spoke architecture is a proven network topology for enterprise-scale cloud environments. Below are actionable best practices, real-life examples, and code snippets for DevOps Engineers and Cloud Architects.

## 1. Better Security

- **Centralized Security Controls:** Use the hub for shared services (firewall, VPN, Azure Bastion, etc.) and enforce NSGs and Azure Firewall policies centrally.
- **Example:**

```bicep
resource firewall 'Microsoft.Network/azureFirewalls@2022-05-01' = {
  name: 'hub-fw'
  location: resourceGroup().location
  properties: {
    sku: { name: 'AZFW_VNet', tier: 'Standard' }
  }
}
```

- **Best Practice:** Route all spoke traffic through the hub for inspection and logging.

## 2. Improved Network Performance

- **Optimized Routing:** Use User Defined Routes (UDRs) to control traffic flow between spokes via the hub.
- **Example:**

```hcl
resource "azurerm_route_table" "spoke" {
  name                = "spoke-rt"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location
}

resource "azurerm_route" "to-hub" {
  name                   = "to-hub"
  resource_group_name    = azurerm_resource_group.spoke.name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
```

## 3. Simplified Management

- **Centralized Logging and Monitoring:** Deploy Log Analytics and Azure Monitor in the hub for all spokes.
- **Example:**

```sh
az monitor log-analytics workspace create --resource-group rg-hub --workspace-name law-hub
az monitor diagnostic-settings create --resource-id <spoke-vnet-id> --workspace law-hub --logs '[{"category": "AllLogs", "enabled": true}]'
```

- **Best Practice:** Use Azure Policy to enforce tagging, security, and compliance across all spokes.

## 4. Scalability

- **Easily Add Spokes:** Onboard new business units or environments by deploying new spokes without impacting the hub or other spokes.
- **Example:**

```bicep
module spokeVnet 'spoke-vnet.bicep' = {
  name: 'spokeVnet1'
  params: {
    vnetName: 'spoke-vnet-1'
    addressPrefix: '10.1.0.0/16'
  }
}
```

- **Best Practice:** Use Infrastructure as Code (Bicep, Terraform) and CI/CD for repeatable spoke deployments.

## 5. Cost-Effective

- **Shared Services:** Centralize expensive resources (firewall, VPN, monitoring) in the hub to reduce duplication.
- **Example:**

```sh
# Deploy Azure Firewall once in the hub, share across all spokes
az network firewall create --name hub-fw --resource-group rg-hub --location westeurope
```

- **Best Practice:** Tag resources for cost allocation and use Azure Cost Management for chargeback.

## Real-Life Scenario

A global retailer uses hub and spoke to:

- Centralize security (Azure Firewall, Bastion, VPN Gateway) in the hub
- Isolate dev, test, and prod workloads in separate spokes
- Route all internet and inter-spoke traffic through the hub for inspection
- Use IaC (Bicep/Terraform) and Azure DevOps for automated spoke onboarding

## Common Pitfalls

- Not routing all traffic through the hub (missed inspection/logging)
- Manual spoke deployments (inconsistent configuration)
- Over-permissioned peering (avoid using 'Allow Gateway Transit' unless needed)

## References

- [Microsoft Azure Hub-Spoke Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)

> **Joke:** Why did the spoke get jealous of the hub? Because the hub was always at the center of attention!
