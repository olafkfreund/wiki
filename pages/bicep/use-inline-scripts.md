---
description: >-
  The following Bicep file has one resource defined with the
  Microsoft.Resources/deploymentScripts type. The highlighted part is the inline
  script. Updated for 2025 with cross-platform deployment and best practices.
---

# Use Inline Scripts in Bicep (2025)

Inline scripts in Bicep are useful for automation, configuration, and custom tasks during deployment. The example below uses an Azure PowerShell script, but you can also use Bash for Linux-based automation.

## Example: Inline PowerShell Script in Bicep

```bicep
param name string = 'John Dole'
param utcValue string = utcNow()
param location string = resourceGroup().location

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInlineWithOutput'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '8.3'
    scriptContent: '''
      param([string] $name)
      $output = "Hello {0}" -f $name
      Write-Output $output
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs["text"] = $output
    '''
    arguments: '-name ${name}'
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output result string = runPowerShellInlineWithOutput.properties.outputs.text
```

Save this as **inlineScript.bicep**.

---

## Deploying the Bicep File

### PowerShell (Windows, Azure Cloud Shell)
```powershell
$resourceGroupName = Read-Host -Prompt "Enter the name of the resource group to be created"
$location = Read-Host -Prompt "Enter the location (i.e. centralus)"

New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "inlineScript.bicep"
```

### Azure CLI (Linux, WSL, NixOS, macOS)
```bash
# Set variables
resourceGroupName="my-inline-rg"
location="westeurope"

az group create --name "$resourceGroupName" --location "$location"
az deployment group create \
  --resource-group "$resourceGroupName" \
  --template-file inlineScript.bicep \
  --parameters name="Jane Doe"
```

---

## Best Practices (2025)
- Use inline scripts for tasks not natively supported by ARM/Bicep
- Prefer idempotent scripts (safe to run multiple times)
- Log output and errors for troubleshooting
- Avoid hardcoding secrets; use Azure Key Vault or parameters
- Use Bash scripts for Linux automation (set `kind: AzureCLI`)
- Review and test scripts for security and compliance

---

## Real-Life DevOps Scenario
- Use inline scripts to automate post-deployment configuration (e.g., register DNS, set tags, run compliance checks)
- Example: Run a Bash script to install tools on a VM after provisioning

---

## References
- [Bicep Deployment Scripts](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep)
- [Microsoft.Resources/deploymentScripts](https://learn.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
