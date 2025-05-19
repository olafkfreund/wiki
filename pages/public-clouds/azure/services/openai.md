# Azure OpenAI Service

## Overview
Azure OpenAI Service provides access to OpenAI’s powerful language models (like GPT) with enterprise-grade security and compliance.

## Real-life Use Cases
- **Cloud Architect:** Integrate GenAI into customer-facing applications.
- **DevOps Engineer:** Automate content generation and summarization workflows.

## Terraform Example
> **Note:** Native support is limited. Use azurerm_cognitive_account for resource creation.
```hcl
resource "azurerm_cognitive_account" "openai" {
  name                = "openaiaccount"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"
}
```

## Bicep Example
```bicep
resource openaiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'openaiaccount'
  location: resourceGroup().location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {}
}
```

## Azure CLI Example
```sh
az cognitiveservices account create --name openaiaccount --resource-group my-rg --kind OpenAI --sku S0 --location westeurope
```

## Best Practices
- Secure API keys and endpoints.
- Monitor usage and costs.

## Common Pitfalls
- Not handling model output validation.
- Underestimating latency for large models.

> **Joke:** Why did the developer use Azure OpenAI? To get a prompt response every time!
