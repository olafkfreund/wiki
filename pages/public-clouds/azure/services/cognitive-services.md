# Azure Cognitive Services

## Overview
Azure Cognitive Services are a suite of AI services and APIs to build intelligent apps for vision, speech, language, and decision-making.

## Real-life Use Cases
- **Cloud Architect:** Add speech-to-text and translation to global apps.
- **DevOps Engineer:** Automate image analysis in CI/CD pipelines.

## Terraform Example
```hcl
resource "azurerm_cognitive_account" "main" {
  name                = "cogsvcaccount"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}
```

## Bicep Example
```bicep
resource cogAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'cogsvcaccount'
  location: resourceGroup().location
  kind: 'CognitiveServices'
  sku: {
    name: 'S0'
  }
  properties: {}
}
```

## Azure CLI Example
```sh
az cognitiveservices account create --name cogsvcaccount --resource-group my-rg --kind CognitiveServices --sku S0 --location westeurope
```

## Best Practices
- Use managed identities for secure access.
- Monitor API usage and costs.

## Common Pitfalls
- Not securing API keys.
- Over-provisioning resources.

> **Joke:** Why did the app use Cognitive Services? It wanted to see, hear, and speak for itself!
