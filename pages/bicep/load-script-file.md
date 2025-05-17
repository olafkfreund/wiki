---
description: >-
  You can use the loadTextContent function to load a script file as a string.
  This function enables you to keep the script in a separate file and retrieve
  it as a deployment script.
---

# Loading Script Files in Bicep

The `loadTextContent` function provides a powerful way to separate your infrastructure definitions from custom scripts. This approach improves maintainability, enables code reuse, and allows for better version control of your scripting logic.

## Basic Usage

The path you provide to the script file is relative to the Bicep file. For example, if your scripts are in a `scripts` subfolder, you would use `loadTextContent('scripts/myscript.ps1')`.

### PowerShell Example

{% code overflow="wrap" lineNumbers="true" %}
```bicep
resource powerShellScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'configureAzureResources'
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
    scriptContent: loadTextContent('scripts/configure-resources.ps1')
    retentionInterval: 'P1D'
  }
}
```
{% endcode %}

### Bash Script Example

{% code overflow="wrap" lineNumbers="true" %}
```bicep
resource bashScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'setupLinuxEnvironment'
  location: resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/{sub-id}/resourcegroups/{rg-name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{id-name}': {}
    }
  }
  properties: {
    azCliVersion: '2.40.0'
    scriptContent: loadTextContent('scripts/setup-environment.sh')
    retentionInterval: 'P1D'
  }
}
```
{% endcode %}

## Advanced Scenarios

### Parameterizing Scripts

You can combine `loadTextContent` with string interpolation to dynamically insert parameters into your scripts:

{% code overflow="wrap" lineNumbers="true" %}
```bicep
param storageAccountName string
param containerName string = 'data'

var scriptWithParams = '''
$storageAccount = '${storageAccountName}'
$container = '${containerName}'

# Rest of the script content
New-AzStorageContainer -Name $container -Context (Get-AzStorageAccount -ResourceGroupName $env:RESOURCE_GROUP -Name $storageAccount).Context -Permission Off
'''

resource parameterizedScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createStorageContainer'
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
    scriptContent: scriptWithParams
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
    ]
  }
}
```
{% endcode %}

### Conditional Script Selection

You can conditionally load different scripts based on parameters:

{% code overflow="wrap" lineNumbers="true" %}
```bicep
param environment string = 'dev'

var scriptPath = environment == 'prod' ? 'scripts/production-setup.ps1' : 'scripts/development-setup.ps1'

resource conditionalScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'setupEnvironment'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  // ...identity properties...
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: loadTextContent(scriptPath)
    retentionInterval: 'P1D'
  }
}
```
{% endcode %}

### Loading Multiple Scripts

You can combine multiple scripts together:

{% code overflow="wrap" lineNumbers="true" %}
```bicep
var combinedScript = concat(
  loadTextContent('scripts/common-functions.ps1'),
  '\n\n',
  loadTextContent('scripts/setup-resources.ps1')
)

resource multiFileScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'combinedSetupScript'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  // ...identity properties...
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: combinedScript
    retentionInterval: 'P1D'
  }
}
```
{% endcode %}

## Real-World Example: Post-Deployment Configuration

This example shows how to use a deployment script to configure a newly created Azure SQL Database:

{% code overflow="wrap" lineNumbers="true" %}
```bicep
param sqlServerName string
param sqlDatabaseName string
param adminLogin string

@secure()
param adminPassword string

// Deploy SQL Server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: resourceGroup().location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// Deploy SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

// Deploy a script that will configure the database
resource configureDatabase 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'configureDatabase'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: loadTextContent('scripts/configure-database.ps1')
    environmentVariables: [
      {
        name: 'SQL_SERVER'
        value: sqlServerName
      }
      {
        name: 'SQL_DATABASE'
        value: sqlDatabaseName
      }
      {
        name: 'SQL_ADMIN'
        value: adminLogin
      }
      {
        name: 'SQL_PASSWORD'
        secureValue: adminPassword
      }
    ]
    retentionInterval: 'P1D'
  }
  dependsOn: [
    sqlDatabase
  ]
}

// Reference to a managed identity (created separately)
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: 'deployment-identity'
}
```
{% endcode %}

Example content for `scripts/configure-database.ps1`:

```powershell
# Import required modules
Import-Module SqlServer

# Get environment variables
$sqlServerName = $env:SQL_SERVER
$databaseName = $env:SQL_DATABASE
$adminUser = $env:SQL_ADMIN
$adminPassword = $env:SQL_PASSWORD
$serverFqdn = "$sqlServerName.database.windows.net"

# Create secure credential
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($adminUser, $securePassword)

# Create tables and initial data
$query = @"
CREATE TABLE Customers (
    CustomerID int PRIMARY KEY,
    Name nvarchar(100) NOT NULL,
    Email nvarchar(255)
);

INSERT INTO Customers (CustomerID, Name, Email)
VALUES (1, 'Contoso Ltd', 'info@contoso.com');
"@

# Execute SQL query
Invoke-Sqlcmd -ServerInstance $serverFqdn -Database $databaseName -Credential $credential -Query $query

# Output success message
Write-Output "Database configuration completed successfully"
```

## Best Practices

1. **Organize Scripts in a Dedicated Folder**
   
   Keeping scripts organized in a dedicated `scripts` folder makes your Bicep project structure cleaner.

2. **Use Source Control for Scripts**
   
   Since scripts are separate files, they can be versioned separately, making changes easier to track.

3. **Handle Idempotency**
   
   Ensure your scripts are idempotent (can be run multiple times without issues) for reliable deployments.

4. **Verify Script Paths**
   
   If your script loading fails, verify the path is correct relative to the Bicep file location.

5. **Leverage Environment Variables**
   
   Use environment variables to pass parameters to your scripts rather than hardcoding values.

6. **Error Handling**
   
   Include proper error handling in your scripts with meaningful error messages.

## Limitations

- The maximum size for a loaded script is 256 KB
- Script content must be valid for the specified script type (PowerShell or Bash)
- Relative paths are resolved based on the Bicep file's location, not the deployment location

