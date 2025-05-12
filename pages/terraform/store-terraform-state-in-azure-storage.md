# Store Terraform state in Azure Storage

1. Configure remote state storage account

{% code overflow="wrap" lineNumbers="true" %}
```bash
#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```plaintext
{% endcode %}

{% code overflow="wrap" lineNumbers="true" %}
```powershell
$RESOURCE_GROUP_NAME='tfstate'
$STORAGE_ACCOUNT_NAME="tfstate$(Get-Random)"
$CONTAINER_NAME='tfstate'

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location eastus

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location eastus -AllowBlobPublicAccess $false

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context
```plaintext
{% endcode %}

2.  ### Configure terraform backend state <a href="#3-configure-terraform-backend-state" id="3-configure-terraform-backend-state"></a>



To configure the backend state, you need the following Azure storage information:

* **storage\_account\_name**: The name of the Azure Storage account.
* **container\_name**: The name of the blob container.
* **key**: The name of the state store file to be created.
* **access\_key**: The storage access key.

{% code overflow="wrap" lineNumbers="true" %}
```bash
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```plaintext
{% endcode %}

{% code overflow="wrap" lineNumbers="true" %}
```powershell
$ACCOUNT_KEY=(Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME)[0].value
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY
```plaintext
{% endcode %}

Create a Terraform configuration with a `backend` configuration block.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "<storage_account_name>"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state-demo-secure" {
  name     = "state-demo"
  location = "eastus"
}
```plaintext

```bash
terraform init
```plaintext

```bash
terraform apply
```plaintext
