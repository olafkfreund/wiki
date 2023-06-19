---
description: Setting up and using bicep for Azure Deployments
---

# Bicep

Microsoft Bicep is a domain-specific language (DSL) for deploying Azure resources. It is an open-source project that provides a more concise and user-friendly way to write Azure Resource Manager (ARM) templates. ARM templates are JSON files that describe the resources and configurations required for deploying an application in Azure. These templates can become complex and difficult to manage, especially as the number of resources and configurations grows. Bicep simplifies this process by providing a more streamlined and intuitive way to write ARM templates.

Bicep offers several benefits over traditional ARM templates:

1. Simplicity: Bicep simplifies the process of writing ARM templates by using a more concise syntax that is easier to read and maintain.
2. Reusability: Bicep enables the creation of modular templates, which can be reused across projects, reducing the need for duplicative code.
3. Type Safety: Bicep provides type safety, which helps catch errors early in the development process and reduces the risk of issues during deployment.
4. IntelliSense: Bicep offers IntelliSense, which provides auto-completion and code navigation, further simplifying the development process.

Bicep can be used for deploying any Azure resource, including virtual machines, storage accounts, and web applications. It is compatible with all Azure services and can be used in conjunction with other Azure tools, such as Azure DevOps and Azure CLI.

A Bicep file has the following elements.

```bicep
metadata <metadata-name> = ANY

targetScope = '<scope>'

@<decorator>(<argument>)
param <parameter-name> <parameter-data-type> = <default-value>

var <variable-name> = <variable-value>

resource <resource-symbolic-name> '<resource-type>@<api-version>' = {
  <resource-properties>
}

module <module-symbolic-name> '<path-to-file>' = {
  name: '<linked-deployment-name>'
  params: {
    <parameter-names-and-values>
  }
}

output <output-name> <output-data-type> = <output-value>
```

The following example shows an implementation of these elements.

```bicep
metadata description = 'Creates a storage account and a web app'

@description('The prefix to use for the storage account name.')
@minLength(3)
@maxLength(11)
param storagePrefix string

param storageSKU string = 'Standard_LRS'
param location string = resourceGroup().location

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

module webModule './webApp.bicep' = {
  name: 'webDeploy'
  params: {
    skuName: 'S1'
    location: location
  }
}
```
