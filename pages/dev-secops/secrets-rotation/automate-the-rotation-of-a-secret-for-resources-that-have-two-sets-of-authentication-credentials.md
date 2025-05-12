# Automate the rotation of a secret for resources that have two sets of authentication credentials

Here's the rotation solution described in this tutorial:

![Diagram that shows the rotation solution.](https://learn.microsoft.com/en-us/azure/key-vault/media/secrets/rotation-dual/rotation-diagram.png)

In this solution, Azure Key Vault stores storage account individual access keys as versions of the same secret, alternating between the primary and secondary key in subsequent versions. When one access key is stored in the latest version of the secret, the alternate key is regenerated and added to Key Vault as the new latest version of the secret. The solution provides the application's entire rotation cycle to refresh to the newest regenerated key.

1. Thirty days before the expiration date of a secret, Key Vault publishes the near expiry event to Event Grid.
2. Event Grid checks the event subscriptions and uses HTTP POST to call the function app endpoint that's subscribed to the event.
3. The function app identifies the alternate key (not the latest one) and calls the storage account to regenerate it.
4. The function app adds the new regenerated key to Azure Key Vault as the new version of the secret.

### Prerequisites <a href="#prerequisites" id="prerequisites"></a>

* An Azure subscription. [Create one for free.](https://azure.microsoft.com/free/?WT.mc\_id=A261C142F)
* Azure [Cloud Shell](https://shell.azure.com/). This tutorial is using portal Cloud Shell with PowerShell env
* Azure Key Vault.
* Two Azure storage accounts.

Change and deploy

```json
{  
	"$schema":"https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
	"contentVersion":"1.0.0.0",
	"parameters":{  
	   "ResourceNamePrefix":{  
		  "defaultValue":"[resourceGroup().name]",
		  "type":"string",
		  "metadata":{  
			 "description":"Prefix for resource names."
		  }
	   }
	},
	"variables":{  
	   "storageaccountid":"[concat(resourceGroup().id,'/providers/','Microsoft.Storage/storageAccounts/', parameters('ResourceNamePrefix'),'strg')]"
	},
	"resources":[  
	  
	   {  
		  "type":"Microsoft.KeyVault/vaults",
		  "apiVersion":"2018-02-14",
		  "name":"[concat(parameters('ResourceNamePrefix'),'-kv')]",
		  "location":"[resourceGroup().location]",
		  "dependsOn":[  
  
		  ],
		  "properties":{  
			 "sku":{  
				"family":"A",
				"name":"Standard"
			 },
			 "tenantId":"[subscription().tenantId]",
			 "accessPolicies":[],
			 "enabledForDeployment":false,
			 "enabledForDiskEncryption":false,
			 "enabledForTemplateDeployment":false
		  }
	   },
	   {
		"type": "Microsoft.Storage/storageAccounts",
		"apiVersion": "2019-06-01",
		"name": "[concat(parameters('ResourceNamePrefix'),'storage')]",
		"location": "[resourceGroup().location]",
		"sku": {
			"name": "Standard_LRS",
			"tier": "Standard"
		},
		"kind": "Storage"
	  },
	  {
		"type": "Microsoft.Storage/storageAccounts",
		"apiVersion": "2019-06-01",
		"name": "[concat(parameters('ResourceNamePrefix'),'storage2')]",
		"location": "[resourceGroup().location]",
		"sku": {
			"name": "Standard_LRS",
			"tier": "Standard"
		},
		"kind": "Storage"
	  }
	]
  }
```plaintext

You'll now have a key vault and two storage accounts. You can verify this setup in the Azure CLI or Azure PowerShell by running this command:

```bash
az resource list -o table -g vaultrotation
```plaintext

The result will look something like this output:

ConsoleCopy

```console
Name                     ResourceGroup         Location    Type                               Status
-----------------------  --------------------  ----------  ---------------------------------  --------
vaultrotation-kv         vaultrotation      westus      Microsoft.KeyVault/vaults
vaultrotationstorage     vaultrotation      westus      Microsoft.Storage/storageAccounts
vaultrotationstorage2    vaultrotation      westus      Microsoft.Storage/storageAccounts
```plaintext

### Create and deploy the key rotation function <a href="#create-and-deploy-the-key-rotation-function" id="create-and-deploy-the-key-rotation-function"></a>

Next, you'll create a function app with a system-managed identity, in addition to other required components. You'll also deploy the rotation function for the storage account keys.

The function app rotation function requires the following components and configuration:

* An Azure App Service plan
* A storage account to manage function app triggers
* An access policy to access secrets in Key Vault
* The Storage Account Key Operator Service role assigned to the function app so it can access storage account access keys
* A key rotation function with an event trigger and an HTTP trigger (on-demand rotation)
* An Event Grid event subscription for the **SecretNearExpiry** event

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountRG": {
            "defaultValue": "[resourceGroup().name]",
            "type": "String",
            "metadata": {
                "description": "The name of the resource group where storage account has deployed."
            }
        },
        "storageAccountName": {
            "defaultValue": "[concat(resourceGroup().name, 'storage')]",
            "type": "String",
            "metadata": {
                "description": "The name of the existing storage account with access keys to rotate."
            }
        },
        "keyVaultRG": {
            "defaultValue": "[resourceGroup().name]",
            "type": "String",
            "metadata": {
                "description": "The name of the resource group where key vault has deployed."
            }
        },
        "keyVaultName": {
            "defaultValue": "[concat(resourceGroup().name, '-kv')]",
            "type": "String",
            "metadata": {
                "description": "The name of the existing key vault where secrets are stored."
            }
        },
        "appServicePlanType": {
			"type": "string",
			"allowedValues": [
                "Consumption Plan",
                "Premium Plan"
			],
			"defaultValue": "Consumption Plan",
			"metadata": {
			"description": "The type of App Service hosting plan. Premium must be used to access key vaults behind firewall."
			}
		},
        "functionAppName": {
            "defaultValue": "[concat(resourceGroup().name, '-storagekey-rotation-fnapp')]",
            "type": "String",
            "metadata": {
                "description": "The name of the function app that you wish to create."
            }
        },
        "secretName": {
            "defaultValue": "storageKey",
            "type": "String",
            "metadata": {
                "description": "The name of the secret where storage account keys are stored."
            }
        },
        "repoURL": {
            "defaultValue": "https://github.com/Azure-Samples/KeyVault-Rotation-StorageAccountKey-PowerShell.git",
            "type": "String",
            "metadata": {
                "description": "The URL for the GitHub repository that contains the project to deploy."
            }
        }
    },
    "variables": {
        "functionStorageAccountName": "[concat(uniquestring(parameters('functionAppName')), 'fnappstrg')]",
        "eventSubscriptionName": "[concat(parameters('functionAppName'),'-',parameters('secretName'))]",
        "appServiceSKU":"[if(equals(parameters('appServicePlanType'),'Consumption Plan'),'Y1','P1V2')]"
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2019-06-01",
            "name": "[variables('functionStorageAccountName')]",
            "location": "[resourceGroup().location]",
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            },
            "kind": "Storage"
        },
        {
            "type": "Microsoft.Web/serverfarms",
            "apiVersion": "2018-02-01",
            "name": "[concat(resourceGroup().name, '-rotation-fnapp-plan')]",
            "location": "[resourceGroup().location]",
            "sku": {
                "name": "[variables('appServiceSKU')]"
            },
            "properties": {
                "name": "[concat(resourceGroup().name, '-rotation-fnapp-plan')]"
               
            }
        },
        {
            "type": "Microsoft.Web/sites",
            "apiVersion": "2018-11-01",
            "name": "[parameters('functionAppName')]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[resourceId('Microsoft.Web/serverfarms', concat(resourceGroup().name, '-rotation-fnapp-plan'))]",
                "[resourceId('Microsoft.Storage/storageAccounts', variables('functionStorageAccountName'))]"
            ],
            "kind": "functionapp",
            "identity": {
                "type": "SystemAssigned"
            },
            "properties": {
                "enabled": true,
                "serverFarmId": "[resourceId('Microsoft.Web/serverfarms',concat(resourceGroup().name, '-rotation-fnapp-plan'))]",
                "siteConfig": {
                    "appSettings": [
                        {
                            "name": "AzureWebJobsStorage",
                            "value": "[concat('DefaultEndpointsProtocol=https;AccountName=', variables('functionStorageAccountName'), ';AccountKey=', listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('functionStorageAccountName')), '2019-06-01').keys[0].value)]"
                        },
                        {
                            "name": "FUNCTIONS_EXTENSION_VERSION",
                            "value": "~3"
                        },
                        {
                            "name": "FUNCTIONS_WORKER_RUNTIME",
                            "value": "powershell"
                        },
                        {
                            "name": "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING",
                            "value": "[concat('DefaultEndpointsProtocol=https;AccountName=', variables('functionStorageAccountName'), ';EndpointSuffix=', environment().suffixes.storage, ';AccountKey=',listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('functionStorageAccountName')), '2019-06-01').keys[0].value)]"
                        },
                        {
                            "name": "WEBSITE_CONTENTSHARE",
                            "value": "[toLower(parameters('functionAppName'))]"
                        },
                        {
                            "name": "WEBSITE_NODE_DEFAULT_VERSION",
                            "value": "~10"
                        },
                        {
                            "name": "APPINSIGHTS_INSTRUMENTATIONKEY",
                            "value": "[reference(resourceId('microsoft.insights/components', parameters('functionAppName')), '2018-05-01-preview').InstrumentationKey]"
                        }
                    ]
                }
            },
            "resources": [
                {
                    "type": "sourcecontrols",
                    "apiVersion": "2018-11-01",
                    "name": "web",
                    "dependsOn": [
                        "[resourceId('Microsoft.Web/Sites', parameters('functionAppName'))]"
                    ],
                    "properties": {
                        "RepoUrl": "[parameters('repoURL')]",
                        "branch": "main",
                        "IsManualIntegration": true
                    }
                }
            ]
        },
        {
            "type": "microsoft.insights/components",
            "apiVersion": "2018-05-01-preview",
            "name": "[parameters('functionAppName')]",
            "location": "[resourceGroup().location]",
            "tags": {
                "[concat('hidden-link:', resourceId('Microsoft.Web/sites', parameters('functionAppName')))]": "Resource"
            },
            "properties": {
                "ApplicationId": "[parameters('functionAppName')]",
                "Request_Source": "IbizaWebAppExtensionCreate"
            }
        },
        {
            "name": "kv-event-subscription-and-grant-access",
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2019-10-01",
            "subscriptionId": "[subscription().subscriptionId]",
            "resourceGroup": "[parameters('keyVaultRG')]",
            "dependsOn": [
                "[resourceId('Microsoft.Web/sites', parameters('functionAppName'))]",
                "[concat(resourceId('Microsoft.Web/sites', parameters('functionAppName')),'/sourcecontrols/web')]"
            ],
            "properties": {
                "mode": "Incremental",
                "template": {
                    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                    "contentVersion": "1.0.0.0",
                    "resources": [
                        {
                            "type": "Microsoft.KeyVault/vaults/accessPolicies",
                            "name": "[concat(parameters('keyVaultName'), '/add')]",
                            "apiVersion": "2019-09-01",
                            "properties": {
                                "accessPolicies": [
                                    {
                                        "tenantId": "[subscription().tenantId]",
                                        "objectId": "[reference(resourceId('Microsoft.Web/sites', parameters('functionAppName')),'2019-08-01', 'Full').identity.principalId]",
                                        "permissions": {
                                            "secrets": [
                                                "Get",
                                                "List",
                                                "Set"
                                            ]
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            "type": "Microsoft.KeyVault/vaults/providers/eventSubscriptions",
                            "apiVersion": "2020-01-01-preview",
                            "name": "[concat(parameters('keyVaultName'),'/Microsoft.EventGrid/',variables('eventSubscriptionName'))]",
                            "location": "[resourceGroup().location]",
                            "properties": {
                                "destination": {
                                    "endpointType": "AzureFunction",
                                    "properties": {
                                        "maxEventsPerBatch": 1,
                                        "preferredBatchSizeInKilobytes": 64,
                                        "resourceId": "[concat(resourceId('Microsoft.Web/sites', parameters('functionAppName')),'/functions/AKVStorageRotation')]"
                                    }
                                },
                                "filter": {
                                    "subjectBeginsWith": "[parameters('secretName')]",
                                    "subjectEndsWith": "[parameters('secretName')]",
                                    "includedEventTypes": [ "Microsoft.KeyVault.SecretNearExpiry" ]

                                }
                            }
                        }
                    ]
                }
            }
        },
        {
            "name": "storage-grant-access",
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2019-10-01",
            "subscriptionId": "[subscription().subscriptionId]",
            "resourceGroup": "[parameters('storageAccountRG')]",
            "dependsOn": [
                "[resourceId('Microsoft.Web/sites', parameters('functionAppName'))]"
            ],
            "properties": {
                "mode": "Incremental",
                "template": {
                    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                    "contentVersion": "1.0.0.0",
                    "resources": [
                        {
                            "type": "Microsoft.Storage/storageAccounts/providers/roleAssignments",
                            "apiVersion": "2018-09-01-preview",
                            "name": "[concat(parameters('storageAccountName'), '/Microsoft.Authorization/', guid(concat(parameters('storageAccountName'),reference(resourceId('Microsoft.Web/sites', parameters('functionAppName')),'2019-08-01', 'Full').identity.principalId)))]",
                            "properties": {
                                "roleDefinitionId": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', '81a9662b-bebf-436f-a333-f67b29880f12')]",
                                "principalId": "[reference(resourceId('Microsoft.Web/sites', parameters('functionAppName')),'2019-08-01', 'Full').identity.principalId]"
                            }
                        }
                    ]
                }
            }
        }
    ]
}
```plaintext

#### Add the storage account access keys to Key Vault secrets <a href="#add-the-storage-account-access-keys-to-key-vault-secrets" id="add-the-storage-account-access-keys-to-key-vault-secrets"></a>

```bash
az keyvault set-policy --upn <email-address-of-user> --name vaultrotation-kv --secret-permissions set delete get list
```plaintext

You can now create a new secret with a storage account access key as its value. You'll also need the storage account resource ID, secret validity period, and key ID to add to the secret so the rotation function can regenerate the key in the storage account.

```bash
az storage account show -n vaultrotationstorage
```plaintext

List the storage account access keys so you can get the key values:

```bash
az storage account keys list -n vaultrotationstorage
```plaintext

Add secret to key vault with validity period for 60 days, storage account resource ID, and for demonstration purpose to trigger rotation immediately set expiration date to tomorrow. Run this command, using your retrieved values for `key1Value` and `storageAccountResourceId`:b

```bash
$tomorrowDate = (get-date).AddDays(+1).ToString("yyyy-MM-ddTHH:mm:ssZ")
az keyvault secret set --name storageKey --vault-name vaultrotation-kv --value <key1Value> --tags "CredentialId=key1" "ProviderAddress=<storageAccountResourceId>" "ValidityPeriodDays=60" --expires $tomorrowDate
```plaintext

This secret will trigger `SecretNearExpiry` event within several minutes. This event will in turn trigger the function to rotate the secret with expiration set to 60 days. In that configuration, 'SecretNearExpiry' event would be triggered every 30 days (30 days before expiry) and rotation function will alternate rotation between key1 and key2.

You can verify that access keys have regenerated by retrieving the storage account key and the Key Vault secret and compare them.

Use this command to get the secret information:

```azurecli
az keyvault secret show --vault-name vaultrotation-kv --name storageKey
```plaintext

Notice that `CredentialId` is updated to the alternate `keyName` and that `value` is regenerated:

![Screenshot that shows the output of the A Z keyvault secret show command for the first storage account.](https://learn.microsoft.com/en-us/azure/key-vault/media/secrets/rotation-dual/dual-rotation-4.png)

Retrieve the access keys to compare the values:

```bash
az storage account keys list -n vaultrotationstorage 
```plaintext

Notice that `value` of the key is same as secret in key vault:

![Screenshot that shows the output of the A Z storage account keys list command for the first storage account.](https://learn.microsoft.com/en-us/azure/key-vault/media/secrets/rotation-dual/dual-rotation-5.png)

\
More info here: [https://docs.microsoft.com/azure/key-vault/secrets/tutorial-rotation-dual](https://docs.microsoft.com/azure/key-vault/secrets/tutorial-rotation-dual)
