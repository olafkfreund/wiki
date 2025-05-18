---
description: >-
  Deployment scripts in Bicep allow you to execute custom scripts during deployment
  to fill gaps in native resource provider capabilities and handle complex automation tasks.
---

# Use Inline Scripts with Bicep (2025)

Bicep supports running inline scripts (PowerShell, Bash, Azure CLI) as part of your deployment. This is useful for DevOps and SRE teams who need to bootstrap, configure, or validate resources during provisioning.

---

## Why Use Inline Scripts?
- **Automation**: Run custom logic during deployments (e.g., post-provisioning config)
- **Validation**: Check resource state or compliance after deployment
- **Flexibility**: Integrate with existing scripts and tools

---

## Real-Life DevOps & SRE Examples

### 1. Run a Bash Script to Tag Resources

```bicep
resource tagScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'tag-script'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.53.0'
    scriptContent: '''
      az resource tag --tags environment=devops owner=sre \
        --ids ${resourceId('Microsoft.Storage/storageAccounts', 'mystorageaccount')}
    '''
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: uniqueString(newGuid())
  }
}
```

### 2. Run a PowerShell Script to Set Diagnostic Settings

```bicep
resource diagScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'diagnostic-script'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '10.4'
    scriptContent: '''
      $resourceId = (Get-AzResource -Name "myvm").ResourceId
      Set-AzDiagnosticSetting -ResourceId $resourceId -WorkspaceId "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.OperationalInsights/workspaces/xxx" -Enabled $true
    '''
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: uniqueString(newGuid())
  }
}
```

---

## Best Practices (2025)
- Use deployment scripts for tasks not natively supported by Bicep
- Store scripts in source control and reference with `scriptContent` or `scriptUri`
- Use `forceUpdateTag` to ensure script re-runs on changes
- Clean up resources with `cleanupPreference`
- Limit script permissions to least privilege

---

## Common Pitfalls
- Overusing scripts for tasks Bicep can do natively
- Hardcoding secrets in scripts (use Key Vault references)
- Not handling script errors (check exit codes)

---

## Azure & Bicep Jokes

> **Bicep Joke:** Why did the script love Bicep? Because it always had the right parameters!

> **Azure Joke:** Why did the deployment script never get lonely? It always had a resource group to run with!

---

## References
- [Deployment Scripts in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-script-bicep)
- [Bicep Official Docs](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

---

> **Search Tip:** Use keywords like `bicep deployment script`, `inline script`, `powershell`, or `bash` to quickly find relevant examples and best practices.
