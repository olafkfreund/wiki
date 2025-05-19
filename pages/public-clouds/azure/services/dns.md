# Azure DNS

## Overview
Azure DNS hosts your DNS domains in Azure, providing name resolution using Microsoft’s global infrastructure.

## Real-life Use Cases
- **Cloud Architect:** Design global DNS for multi-region apps.
- **DevOps Engineer:** Automate DNS record management for blue/green deployments.

## Terraform Example
```hcl
resource "azurerm_dns_zone" "main" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = ["1.2.3.4"]
}
```

## Bicep Example
```bicep
resource dnsZone 'Microsoft.Network/dnsZones@2020-06-01' = {
  name: 'example.com'
  location: 'global'
}

resource aRecord 'Microsoft.Network/dnsZones/A@2020-06-01' = {
  name: 'www'
  parent: dnsZone
  properties: {
    TTL: 300
    ARecords: [
      {
        ipv4Address: '1.2.3.4'
      }
    ]
  }
}
```

## Azure CLI Example
```sh
az network dns zone create --resource-group my-rg --name example.com
az network dns record-set a add-record --resource-group my-rg --zone-name example.com --record-set-name www --ipv4-address 1.2.3.4
```

## Best Practices
- Use CNAMEs for app endpoints.
- Automate DNS changes in CI/CD.

## Common Pitfalls
- Not updating TTLs during migrations.
- Misconfigured record sets.

> **Joke:** Why did Azure DNS get promoted? It always knew how to resolve issues!
