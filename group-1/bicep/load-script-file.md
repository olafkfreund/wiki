---
description: >-
  You can use the loadTextContent function to load a script file as a string.
  This function enables you to keep the script in a separate file and retrieve
  it as a deployment script.
---

# Load script file

The path you provide to the script file is relative to the Bicep file.

The following example loads a script from a file and uses it for a deployment script.

{% code overflow="wrap" lineNumbers="true" %}
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
```plaintext
{% endcode %}

