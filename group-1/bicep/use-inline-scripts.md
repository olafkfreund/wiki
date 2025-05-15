---
description: >-
  Deployment scripts in Bicep allow you to execute custom scripts during deployment
  to fill gaps in native resource provider capabilities and handle complex automation tasks.
---

# Using Inline Scripts with Bicep

Deployment scripts enable you to execute PowerShell or Bash scripts as part of your Azure deployments. This capability bridges the gap between declarative infrastructure definitions and imperative configuration tasks that would otherwise require manual intervention after deployment.

## Basic PowerShell Deployment Script Example

The following example demonstrates a simple PowerShell deployment script that accepts a parameter and returns an output:


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
```


Save the content into a Bicep file called **inlineScript.bicep**, and use the following PowerShell script to deploy:


```powershell
$resourceGroupName = Read-Host -Prompt "Enter the name of the resource group to be created"
$location = Read-Host -Prompt "Enter the location (i.e. centralus)"

New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "inlineScript.bicep"

Write-Host "Press [ENTER] to continue ..."
```


## Bash Script Example

You can also use Bash scripts with the Azure CLI:


```bicep
param location string = resourceGroup().location
param timestamp string = utcNow()

resource bashScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'create-storage-container'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}': {}
    }
  }
  properties: {
    forceUpdateTag: timestamp
    azCliVersion: '2.45.0'
    scriptContent: '''
      #!/bin/bash
      
      # Create storage account
      az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --sku Standard_LRS
      
      # Create container
      az storage container create \
        --name $CONTAINER_NAME \
        --account-name $STORAGE_ACCOUNT_NAME \
        --auth-mode login
      
      # Set output
      echo "{ \"storageAccount\": \"$STORAGE_ACCOUNT_NAME\", \"container\": \"$CONTAINER_NAME\" }" > $AZ_SCRIPTS_OUTPUT_PATH
    '''
    environmentVariables: [
      {
        name: 'STORAGE_ACCOUNT_NAME'
        value: 'storage${uniqueString(resourceGroup().id)}'
      }
      {
        name: 'CONTAINER_NAME'
        value: 'content'
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'LOCATION'
        value: location
      }
    ]
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output storageAccountName string = contains(bashScript.properties.outputs, 'storageAccount') ? bashScript.properties.outputs.storageAccount : ''
output containerName string = contains(bashScript.properties.outputs, 'container') ? bashScript.properties.outputs.container : ''
```


## Deployment Script Properties

### Essential Properties

| Property | Description |
|----------|-------------|
| `kind` | Specifies the script type - `AzurePowerShell` or `AzureCLI` |
| `azPowerShellVersion` | Version of PowerShell to use (e.g., '8.3') |
| `azCliVersion` | Version of Azure CLI to use (e.g., '2.45.0') |
| `scriptContent` | The script to execute during deployment |
| `timeout` | Maximum allowed script execution time in ISO 8601 format (e.g., 'PT1H' for 1 hour) |
| `retentionInterval` | How long to retain script resources in ISO 8601 format (e.g., 'P1D' for 1 day) |
| `cleanupPreference` | When to clean up deployment resources: 'Always', 'OnSuccess', or 'OnExpiration' |

### Identity Configuration

Deployment scripts require an identity to execute. You can use either:

1. **User-assigned managed identity** (recommended for production):

```bicep
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}': {}
  }
}
```

2. **System-assigned managed identity** (simpler but less flexible):

```bicep
identity: {
  type: 'SystemAssigned'
}
```

## Passing Data To and From Scripts

### Input Methods

1. **Script Arguments**

```bicep
arguments: '-name ${name} -environment ${environment}'
```

2. **Environment Variables**

```bicep
environmentVariables: [
  {
    name: 'STORAGE_NAME'
    value: storageName
  }
  {
    name: 'SECRET_VALUE'
    secureValue: secretValue  // For sensitive values
  }
]
```

### Output Methods

1. **Using `$DeploymentScriptOutputs` in PowerShell**

```powershell
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs["key1"] = "value1"
$DeploymentScriptOutputs["key2"] = "value2"
```

2. **Using `$AZ_SCRIPTS_OUTPUT_PATH` in Bash**

```bash
echo '{"key1": "value1", "key2": "value2"}' > $AZ_SCRIPTS_OUTPUT_PATH
```

3. **Accessing Outputs in Bicep**

```bicep
output result1 string = deploymentScript.properties.outputs.key1
output result2 string = deploymentScript.properties.outputs.key2
```

## Practical Examples

### Example 1: Configure Azure RBAC


```bicep
param principalId string
param roleDefinitionId string
param timestamp string = utcNow()
param location string = resourceGroup().location

resource configureRbac 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'assign-rbac-role'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: timestamp
    azPowerShellVersion: '8.3'
    scriptContent: '''
      param(
        [string] $PrincipalId,
        [string] $RoleDefinitionId,
        [string] $Scope
      )

      # Check if role assignment exists
      $existing = Get-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionId $RoleDefinitionId -Scope $Scope -ErrorAction SilentlyContinue
      
      if (-not $existing) {
        # Create the role assignment
        $result = New-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionId $RoleDefinitionId -Scope $Scope
        $DeploymentScriptOutputs = @{
          'assignmentId' = $result.RoleAssignmentId
          'principalId' = $result.ObjectId
          'roleDefinitionId' = $result.RoleDefinitionId
        }
        Write-Output "Created new role assignment: $($result.RoleAssignmentId)"
      } else {
        $DeploymentScriptOutputs = @{
          'assignmentId' = $existing.RoleAssignmentId
          'principalId' = $existing.ObjectId
          'roleDefinitionId' = $existing.RoleDefinitionId
          'status' = 'AlreadyExists'
        }
        Write-Output "Role assignment already exists: $($existing.RoleAssignmentId)"
      }
    '''
    arguments: '-PrincipalId ${principalId} -RoleDefinitionId ${roleDefinitionId} -Scope ${resourceGroup().id}'
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: 'deployment-identity'
}

output rbacAssignmentId string = configureRbac.properties.outputs.assignmentId
```


### Example 2: Health Check and Validation


```bicep
param webAppName string
param location string = resourceGroup().location

resource healthCheck 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'webapp-health-check'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    forceUpdateTag: utcNow()
    azCliVersion: '2.45.0'
    scriptContent: '''
      #!/bin/bash
      
      # Get the web app URL
      WEBAPP_URL="https://$WEBAPP_NAME.azurewebsites.net/health"
      
      echo "Checking health endpoint at $WEBAPP_URL"
      
      # Wait for the web app to be responsive (max 2 minutes)
      for i in {1..12}; do
        STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" $WEBAPP_URL)
        
        if [ $STATUS_CODE -eq 200 ]; then
          echo "Health check passed with status code: $STATUS_CODE"
          echo "{ \"status\": \"Healthy\", \"statusCode\": \"$STATUS_CODE\" }" > $AZ_SCRIPTS_OUTPUT_PATH
          exit 0
        else
          echo "Attempt $i: Health check returned status code: $STATUS_CODE, retrying in 10 seconds..."
          sleep 10
        fi
      done
      
      echo "Health check failed after multiple attempts"
      echo "{ \"status\": \"Unhealthy\", \"statusCode\": \"$STATUS_CODE\" }" > $AZ_SCRIPTS_OUTPUT_PATH
      exit 1
    '''
    environmentVariables: [
      {
        name: 'WEBAPP_NAME'
        value: webAppName
      }
    ]
    timeout: 'PT5M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output healthStatus string = healthCheck.properties.outputs.status
output statusCode string = healthCheck.properties.outputs.statusCode
```


## Best Practices

### 1. Make Scripts Idempotent

Design your scripts to be safely rerunnable without causing side effects:

```powershell
# Check if resource exists before creating
if (-not (Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageName -ErrorAction SilentlyContinue)) {
    New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageName -Location $Location -SkuName Standard_LRS
    Write-Output "Storage account created"
} else {
    Write-Output "Storage account already exists"
}
```

### 2. Implement Error Handling

Add error handling to your scripts to make troubleshooting easier:

```powershell
try {
    # Your script logic here
    $result = Get-AzResource -Name $ResourceName
    $DeploymentScriptOutputs['status'] = 'Success'
} catch {
    $errorMessage = $_.Exception.Message
    Write-Error $errorMessage
    $DeploymentScriptOutputs['status'] = 'Failed'
    $DeploymentScriptOutputs['error'] = $errorMessage
    exit 1
}
```

### 3. Minimize Script Duration

Keep deployment scripts short and focused:

1. Use `async` operations where possible
2. Avoid polling loops with long intervals
3. Consider breaking complex operations into multiple scripts

### 4. Secure Secret Handling

Never hardcode secrets in your deployment scripts:

```bicep
// Use secureValue for sensitive information
environmentVariables: [
  {
    name: 'API_KEY'
    secureValue: apiKey  // apiKey should be a secure parameter
  }
]
```

### 5. Use Managed Identities

Prefer user-assigned managed identities with pre-configured permissions:

```bicep
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'script-identity'
  location: location
}

module assignRoles 'roles.bicep' = {
  name: 'assign-roles'
  params: {
    principalId: managedIdentity.properties.principalId
    roles: [
      'Reader',
      'Storage Blob Data Contributor'
    ]
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'configuration-script'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  // ...other properties
}
```

## Deployment Script Lifecycle

1. **Creation**: Azure creates a container instance to run your script
2. **Execution**: Your script runs with the specified identity and permissions
3. **Output Capture**: Results are stored in the deployment script resource
4. **Cleanup**: Container instance is deleted based on `cleanupPreference`
5. **Retention**: Deployment script resource remains available according to `retentionInterval`

## Troubleshooting Deployment Scripts

### 1. View Script Logs

```powershell
# Get logs from deployment script
$logs = Get-AzDeploymentScriptLog -ResourceGroupName "myResourceGroup" -DeploymentScriptName "myScript"
$logs
```

### 2. Access Container Logs

If `cleanupPreference` is not set to `Always`, you can access the container logs:

```powershell
# Get container logs
$containerLogs = Get-AzDeploymentScriptLog -ResourceGroupName "myResourceGroup" -DeploymentScriptName "myScript" -ContainerLog
$containerLogs
```

### 3. Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Script timeout | Increase `timeout` value or optimize script |
| Permission errors | Verify managed identity has appropriate RBAC roles |
| Missing modules | Install required modules in script using `Install-Module` |
| Script execution errors | Use try/catch blocks and output detailed error messages |

## Additional Resources

- [Official Microsoft Deployment Scripts Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template)
- [Azure PowerShell Reference](https://learn.microsoft.com/en-us/powershell/azure/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
