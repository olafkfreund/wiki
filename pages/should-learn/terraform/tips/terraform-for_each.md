# Terraform For\_each

### Using Terraform Count

The example below uses the `count` meta-argument to loop through a list of storage account names and create a storage account with the name specified for each.

The name argument uses the `count.index` expression to access the current index of the loop (starting from 0) and select the storage account name from the `storage_account_names` list using the index. The rest of the arguments are the same for each storage account.

```hcl
variable "storage_account_names" {
  type    = list(string)
  default = ["jackuksstr001", "jackuksstr002", "jackuksstr003"]
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "my_storage" {
  count                    = length(var.storage_account_names)
  name                     = var.storage_account_names[count.index]
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
```plaintext

### Using Terraform For\_each

The example below uses a `for_each` loop to iterate through a list of the same storage account names and create a storage account with the name specified for each. The rest of the arguments are the same for each storage account.

The result will be the same as the example using `count` above.

```hcl
variable "storage_account_names" {
  type    = list(string)
  default = ["jackuksstr001", "jackuksstr002", "jackuksstr003"]
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "my_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
```plaintext

### Using the For Expression

The example below builds on the previous one and shows how to output a list of storage account IDs from the given list. The `for` expression is used to iterate over the `storage_account_names` list and retrieve the ID for each storage account instance with the corresponding name.

```hcl
variable "storage_account_names" {
  type    = list(string)
  default = ["jackuksstr001", "jackuksstr002", "jackuksstr003"]
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "my_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

output "storage_account_names" {
  value = [
    for storage in var.storage_account_names:
    azurerm_storage_account.my_storage.example[storage].id
  ]
}
```plaintext

### The For Expression With If Clause

A `for` expression can also include an `if` clause to filter elements from the source variable, producing a value with fewer elements than the source value, and is commonly used to split lists based on a condition.

The syntax looks like the below:

```hcl
[for VAR in COLLECTION: IF CONDITION_EXPRESSION: VAR]
```plaintext

`VAR` is the name of the variable that represents each item in the collection, `COLLECTION` is the collection to be filtered, and `CONDITION_EXPRESSION` is the boolean expression that determines whether each item should be included in the filtered collection.

In the example below, we use the `for` expression with the `if` condition to output a list of storage account names that have the `account_replication_type` set to `GRS`. This example will output the three storage account names provided in the `storage_account_names` variable, as they will all have their `account_replication_type` set to `GRS`.

```hcl
variable "storage_account_names" {
  type    = list(string)
  default = ["jackuksstr001", "jackuksstr002", "jackuksstr003"]
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "my_storage" {
  count                    = length(var.storage_account_names)
  name                     = var.storage_account_names[count.index]
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

locals {
  grs_storage_accounts = [for sa in azurerm_storage_account.my_storage: sa if sa.account_replication_type == "GRS"]
}

output "grs_storage_account_names" {
  value = [for sa in local.grs_storage_accounts: sa.name]
}
```plaintext

### The For\_each Expression With If Clause

The `if` clause can be used to conditionally include or exclude certain expressions based on a boolean condition.

The syntax for using the `if` clause in an expression is as follows:

```hcl
${condition ? true_value : false_value}
```plaintext

In the example below, we use the `if` condition to set the `account_replication_type` to `GRS` if the `environment` variable is set to `prod` , if it is not, then the `account_replication_type` will be set to `LRS` .

Because the default value for the `environment` variable is set to `prod` in the below example, the three storage accounts created using the `for_each` loop will all have their `account_replication_type`set to `GRS`.

```hcl
variable "storage_account_names" {
  type    = list(string)
  default = ["jackuksstr001", "jackuksstr002", "jackuksstr003"]
}

variable "environment" {
  default = "prod"
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "my_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "${var.environment == "prod" ? "GRS" : "LRS"}"
}
```plaintext

### Key
