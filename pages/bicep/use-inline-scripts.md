---
description: >-
  The following Bicep file has one resource defined with the
  Microsoft.Resources/deploymentScripts type. The highlighted part is the inline
  script.
---

# Use inline scripts

{% code overflow="wrap" lineNumbers="true" %}
```bicep
param name string = '\\"John Dole\\"'
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
```plaintext
{% endcode %}

Save the preceding content into a Bicep file called **inlineScript.bicep**, and use the following PowerShell script to deploy the Bicep file.

{% code overflow="wrap" lineNumbers="true" %}
```powershell
$resourceGroupName = Read-Host -Prompt "Enter the name of the resource group to be created"
$location = Read-Host -Prompt "Enter the location (i.e. centralus)"

New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "inlineScript.bicep"

Write-Host "Press [ENTER] to continue ..."
```plaintext
{% endcode %}
