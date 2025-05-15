---
description: >-
  You can use the loadTextContent function to load a script file as a string.
  This function enables you to keep the script in a separate file and retrieve
  it as a deployment script. Updated for 2025 with best practices, cross-platform deployment, and DevOps/LLM guidance.
---

# Load Script File in Bicep (2025)

The `loadTextContent` function lets you keep deployment scripts in separate files and load them as strings in your Bicep templates. This improves maintainability, security, and enables code reuse.

## Example: Loading a Script File

The script path is relative to the Bicep file.

```bicep
resource exampleScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'exampleScript'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/{sub-id}/resourcegroups/{rg-name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{id-name}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: loadTextContent('myscript.ps1')
    retentionInterval: 'P1D'
  }
}
```

## Best Practices (2025)
- Store scripts in version control (Git) alongside Bicep files
- Use managed identities for secure script execution
- Make scripts idempotent and log output for troubleshooting
- Avoid hardcoding secrets; use Azure Key Vault or parameters
- Use LLMs (GitHub Copilot, Claude) to generate and review scripts, but always validate for security

## Deploying with Azure CLI (Linux, WSL, NixOS, macOS)
```bash
# Set variables
resourceGroupName="bicep-script-demo"
location="westeurope"

az group create --name "$resourceGroupName" --location "$location"
az deployment group create \
  --resource-group "$resourceGroupName" \
  --template-file main.bicep
```

## Real-Life DevOps Scenario
- Use `loadTextContent` to inject a Bash or PowerShell script that configures cloud resources post-deployment (e.g., register DNS, set tags, run compliance checks)
- Example: Use LLM to generate a script for automated tagging, store it as `tagging.ps1`, and load it in your Bicep deployment

## References
- [Bicep: loadTextContent](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/functions/loadtextcontent)
- [Deployment Scripts in Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)

