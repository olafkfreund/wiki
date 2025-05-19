# Azure Monitor

## Overview
Azure Monitor provides full-stack monitoring, advanced analytics, and intelligent insights for your applications and infrastructure.

## Real-life Use Cases
- **Cloud Architect:** Design centralized monitoring for multi-region deployments.
- **DevOps Engineer:** Set up alerts for auto-scaling and incident response.

## Terraform Example
```hcl
resource "azurerm_monitor_action_group" "alerts" {
  name                = "devops-alerts"
  resource_group_name = var.resource_group
  short_name          = "alerts"
  email_receiver {
    name          = "devops"
    email_address = "devops@example.com"
  }
}
```

## Bicep Example
```bicep
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-15' = {
  name: 'devops-alerts'
  location: 'Global'
  properties: {
    groupShortName: 'alerts'
    emailReceivers: [
      {
        name: 'devops'
        emailAddress: 'devops@example.com'
      }
    ]
  }
}
```

## Azure CLI Example
```sh
az monitor action-group create --resource-group my-rg --name devops-alerts --short-name alerts --action email devops devops@example.com
```

## Best Practices
- Centralize logs and metrics.
- Use action groups for alerting.

## Common Pitfalls
- Not setting log retention policies.
- Too many noisy alerts.

> **Joke:** Why did Azure Monitor break up with the VM? Too many signals, not enough commitment!
