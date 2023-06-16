---
description: >-
  This quick start describes how to create and deploy a template spec with a
  Bicep file.
---

# Template Spec for bicep

Template specs let you share deployment templates without needing to give users access to change the Bicep file. This template spec example uses a Bicep file to deploy a storage account.

When you create a template spec, the Bicep file is transpiled into JavaScript Object Notation (JSON). The template spec uses JSON to deploy Azure resources. Currently, you can't use the Microsoft Azure portal to import a Bicep file and create a template spec resource.

Using Powershell:

1. Create a new resource group to contain the template spec.

```powershell
New-AzResourceGroup `
  -Name templateSpecRG `
  -Location westus2
```

2. Create the template spec in that resource group. Give the new template spec the name _storageSpec_.

```powershell
New-AzTemplateSpec `
  -Name storageSpec `
  -Version "1.0" `
  -ResourceGroupName templateSpecRG `
  -Location westus2 `
  -TemplateFile "C:\templates\main. Bicep"
```

Using Bicep:

1. Copy the following template and save it to your computer as _main.bicep_.

```bicep
param templateSpecName string = 'storageSpec'

param templateSpecVersionName string = '1.0'

@description('Location for all resources.')
param location string = resourceGroup().location

resource createTemplateSpec 'Microsoft.Resources/templateSpecs@2021-05-01' = {
  name: templateSpecName
  location: location
}

resource createTemplateSpecVersion 'Microsoft.Resources/templateSpecs/versions@2021-05-01' = {
  parent: createTemplateSpec
  name: templateSpecVersionName
  location: location
  properties: {
    mainTemplate: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      'contentVersion': '1.0.0.0'
      'metadata': {}
      'parameters': {
        'storageAccountType': {
          'type': 'string'
          'defaultValue': 'Standard_LRS'
          'metadata': {
            'description': 'Storage account type.'
          }
          'allowedValues': [
            'Premium_LRS'
            'Premium_ZRS'
            'Standard_GRS'
            'Standard_GZRS'
            'Standard_LRS'
            'Standard_RAGRS'
            'Standard_RAGZRS'
            'Standard_ZRS'
          ]
        }
        'location': {
          'type': 'string'
          'defaultValue': '[resourceGroup().location]'
          'metadata': {
            'description': 'Location for all resources.'
          }
        }
      }
      'variables': {
        'storageAccountName': '[format(\'{0}{1}\', \'storage\', uniqueString(resourceGroup().id))]'
      }
      'resources': [
        {
          'type': 'Microsoft.Storage/storageAccounts'
          'apiVersion': '2021-08-01'
          'name': '[variables(\'storageAccountName\')]'
          'location': '[parameters(\'location\')]'
          'sku': {
            'name': '[parameters(\'storageAccountType\')]'
          }
          'kind': 'StorageV2'
          'properties': {}
        }
      ]
      'outputs': {
        'storageAccountNameOutput': {
          'type': 'string'
          'value': '[variables(\'storageAccountName\')]'
        }
      }
    }
  }
}
```

2. Use Azure PowerShell or Azure CLI to create a new resource group.

```powershell
New-AzResourceGroup `
  -Name templateSpecRG `
  -Location westus2
```

```powershell
az group create \
  --name templateSpecRG \
  --location westus2
```

3. Create the template spec in that resource group. The template spec name _storageSpec_ and version number `1.0` are parameters in the Bicep file.

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName templateSpecRG `
  -TemplateFile "C:\templates\main.bicep"
```

```powershell
az deployment group create \
  --resource-group templateSpecRG \
  --template-file "C:\templates\main.bicep"
```

### Deploy template spec <a href="#deploy-template-spec" id="deploy-template-spec"></a>

Use the template spec to deploy a storage account. This example uses the resource group name `storageRG`. You can use a different name, but you'll need to change the commands.



1. Create a resource group to contain the new storage account.

```powershell
New-AzResourceGroup `
  -Name storageRG `
  -Location westus2
```

2. Get the resource ID of the template spec.

{% code overflow="wrap" lineNumbers="true" %}
```powershell
$id = (Get-AzTemplateSpec -ResourceGroupName templateSpecRG -Name storageSpec -Version "1.0").Versions.Id
```
{% endcode %}

3. Deploy the template spec.

```powershell
New-AzResourceGroupDeployment `
  -TemplateSpecId $id `
  -ResourceGroupName storageRG
```

4. You provide parameters exactly as you would for a Bicep file deployment. Redeploy the template spec with a parameter for the storage account type.

{% code overflow="wrap" lineNumbers="true" %}
```powershell
New-AzResourceGroupDeployment `
  -TemplateSpecId $id `
  -ResourceGroupName storageRG `
  -storageAccountType Standard_GRS
```
{% endcode %}

Using Bicep:

To deploy a template spec using a Bicep file, use a module. The module links to an existing template spec. For more information, see [file in template spec](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules#file-in-template-spec).

1. Copy the following Bicep module and save it to your computer as _storage.bicep_.

```bicep
module deployTemplateSpec 'ts:<subscriptionId>/templateSpecRG/storageSpec:1.0' = {
  name: 'deployVersion1'
}
```

2. Replace `<subscriptionId>` in the module. Use Azure PowerShell or Azure CLI to get your subscription ID.

```powershell
(Get-AzContext).Subscription.Id
```

```powershell
az account show --query "id" --output tsv
```

3. Use Azure PowerShell or Azure CLI to create a new resource group for the storage account.

```powershell
New-AzResourceGroup `
  -Name storageRG `
  -Location westus2
```

```powershell
az group create \
  --name storageRG \
  --location westus2
```

4. Deploy the template spec with Azure PowerShell or Azure CLI.

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName storageRG `
  -TemplateFile "C:\templates\storage.bicep"
```

```powershell
az deployment group create \
  --resource-group storageRG \
  --template-file "C:\templates\storage.bicep"
```

5. You can add a parameter and redeploy the template spec with a different storage account type. Copy the sample and replace your _storage.bicep_ file. Then, redeploy the template spec deployment.

```bicep
module deployTemplateSpec 'ts:<subscriptionId>/templateSpecRG/storageSpec:1.0' = {
  name: 'deployVersion1'
  params: {
    storageAccountType: 'Standard_GRS'
  }
}
```

### Update template spec version <a href="#update-template-spec-version" id="update-template-spec-version"></a>

Using PowerShell:

1. Create a new version of the template spec.

```powershell
New-AzTemplateSpec `
  -Name storageSpec `
  -Version "2.0" `
  -ResourceGroupName templateSpecRG `
  -Location westus2 `
  -TemplateFile "C:\templates\main.bicep"
```

2. To deploy the new version, get the resource ID for the `2.0` version.

{% code overflow="wrap" %}
```powershell
$id = (Get-AzTemplateSpec -ResourceGroupName templateSpecRG -Name storageSpec -Version "2.0").Versions.Id
```
{% endcode %}

3. Deploy the new version and use the `storageNamePrefix` to specify a prefix for the storage account name.

```powershell
New-AzResourceGroupDeployment `
  -TemplateSpecId $id `
  -ResourceGroupName storageRG `
  -storageNamePrefix "demo"
```

