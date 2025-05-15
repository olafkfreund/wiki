# Azure Databricks with Bicep

This document explains how to deploy Azure Databricks in a secure configuration using Bicep. The template creates a fully-featured Azure Databricks workspace with network security groups, virtual network integration, and private endpoint connectivity.

## Architecture

This deployment creates:

1. **Network Security Group (NSG)** with required rules for Databricks connectivity
2. **Virtual Network** with three subnets:
   - Public subnet for Databricks (when public access is enabled)
   - Private subnet for Databricks
   - Private Endpoint subnet for secure connectivity
3. **Azure Databricks Workspace** connected to the VNet
4. **Private Endpoint** for secure access to the Databricks UI and API
5. **Private DNS Zone** for name resolution

![Azure Databricks Architecture](https://learn.microsoft.com/en-us/azure/databricks/media/security-private-link-architecture.png)

## Deployment Instructions

### Prerequisites

- Azure CLI installed and logged in
- Bicep CLI installed
- Sufficient permissions to create resources in the target subscription

### Deployment Steps

1. Save the Bicep template to a file named `databricks-secure.bicep`
2. Deploy using Azure CLI:

```bash
# Create a resource group
az group create --name rg-databricks-secure --location eastus2

# Deploy the Bicep template
az deployment group create \
  --resource-group rg-databricks-secure \
  --template-file databricks-secure.bicep \
  --parameters workspaceName=databricks-secure-ws
```

### Common Parameter Customizations

| Parameter | Description | Common Values |
|-----------|-------------|---------------|
| `workspaceName` | Name of your Databricks workspace | `<project>-<env>-dbx` |
| `pricingTier` | Pricing tier for Databricks | `premium` for advanced security |
| `disablePublicIp` | Enable secure cluster connectivity | `true` for enhanced security |
| `publicNetworkAccess` | Allow public access to workspace | `Disabled` for private access only |

## Bicep Template

```bicep
@description('Specifies whether to deploy Azure Databricks workspace with secure cluster connectivity (SCC) enabled or not (No Public IP).')
param disablePublicIp bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the network security group to create.')
param nsgName string = 'databricks-nsg'

@description('The pricing tier of workspace.')
@allowed([
  'trial'
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('CIDR range for the private subnet.')
param privateSubnetCidr string = '10.179.0.0/18'

@description('The name of the private subnet to create.')
param privateSubnetName string = 'private-subnet'

@description('Indicates whether public network access is allowed to the workspace with private endpoint - possible values are Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('CIDR range for the public subnet.')
param publicSubnetCidr string = '10.179.64.0/18'

@description('CIDR range for the private endpoint subnet..')
param privateEndpointSubnetCidr string = '10.179.128.0/24'

@description('The name of the public subnet to create.')
param publicSubnetName string = 'public-subnet'

@description('Indicates whether to retain or remove the AzureDatabricks outbound NSG rule - possible values are AllRules or NoAzureDatabricksRules.')
@allowed([
  'AllRules'
  'NoAzureDatabricksRules'
])
param requiredNsgRules string = 'NoAzureDatabricksRules'

@description('CIDR range for the vnet.')
param vnetCidr string = '10.179.0.0/16'

@description('The name of the virtual network to create.')
param vnetName string = 'databricks-vnet'

@description('The name of the subnet to create the private endpoint in.')
param PrivateEndpointSubnetName string = 'default'

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'default'

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'
var privateEndpointName = '${workspaceName}-pvtEndpoint'
var privateDnsZoneName = 'privatelink.azuredatabricks.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }
    subnets: [
      {
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetCidr
          networkSecurityGroup: {
            id: nsg.id
          }
          delegations: [
            {
              name: 'databricks-del-public'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      }
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetCidr
          networkSecurityGroup: {
            id: nsg.id
          }
          delegations: [
            {
              name: 'databricks-del-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      }
      {
        name: PrivateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetCidr
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource workspace 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      customVirtualNetworkId: {
        value: vnet.id
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
      customPrivateSubnetName: {
        value: privateSubnetName
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
    publicNetworkAccess: publicNetworkAccess
    requiredNsgRules: requiredNsgRules
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, PrivateEndpointSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: workspace.id
          groupIds: [
            'databricks_ui_api'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-12-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Output the Workspace URL and ID
output databricksWorkspaceUrl string = workspace.properties.workspaceUrl
output databricksWorkspaceId string = workspace.id
```

## Understanding Security Components

### Network Security Group Rules

The NSG created by this template includes the following essential rules:

1. **Worker-to-Worker Inbound**: Allows cluster nodes to communicate with each other
2. **Worker-to-Webapp**: Allows workers to communicate with Databricks control plane
3. **Worker-to-SQL**: Allows connectivity to Azure SQL services
4. **Worker-to-Storage**: Allows connectivity to Azure Storage services
5. **Worker-to-Worker Outbound**: Allows outbound communication between nodes
6. **Worker-to-Eventhub**: Allows connectivity to Azure Event Hub services

### Private Endpoint Configuration

The private endpoint created by this template:

1. Connects to the `databricks_ui_api` service of the workspace
2. Configures a private DNS zone for name resolution
3. Links the DNS zone to the virtual network

## Best Practices

1. **Secure Network Configuration**:
   - Always use `disablePublicIp = true` in production environments
   - Set `publicNetworkAccess = 'Disabled'` for maximum security

2. **Subnet Sizing**:
   - Ensure subnets are sized appropriately for your workloads
   - Default configuration allows for up to ~4,000 IP addresses per subnet
   - For large clusters or many concurrent workloads, consider expanding subnet sizes

3. **DNS Resolution**:
   - The template creates a private DNS zone for `privatelink.azuredatabricks.net`
   - Ensure your network configuration allows DNS resolution from connected networks

4. **NSG Customization**:
   - Use `requiredNsgRules = 'NoAzureDatabricksRules'` to manage NSG rules manually
   - Add custom rules for additional security requirements

5. **Workspace Access**:
   - Consider Azure AD authentication for the workspace
   - Use Azure RBAC and Databricks access controls to limit user permissions

## Troubleshooting

### Common Issues

1. **Deployment Failures**:
   - Verify resource name uniqueness
   - Check for overlapping IP address ranges
   - Ensure you have sufficient permissions

2. **Connectivity Issues**:
   - Verify DNS resolution to the private endpoint
   - Check NSG rules aren't blocking required traffic
   - Validate private endpoint is properly configured

3. **Workspace Access Problems**:
   - When using private endpoint, ensure clients can resolve the private DNS
   - Verify Azure AD permissions for workspace access

## Additional Resources

- [Azure Databricks Documentation](https://learn.microsoft.com/en-us/azure/databricks/)
- [Secure Azure Databricks deployments using Private Link](https://learn.microsoft.com/en-us/azure/databricks/security/network/secure-with-private-link)
- [Network Security in Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/security/network/)
