# Terraform for_each, count, and for Expressions

Terraform provides several ways to create multiple resources dynamically, which is essential for scalable, cloud-agnostic DevOps workflows across AWS, Azure, and GCP. The most common patterns are `count`, `for_each`, and `for` expressions. Below are real-life, production-ready examples and best practices.

---

## Using `count` (Index-Based Iteration)

Use `count` to create resources from a list, referencing each item by its index. This is simple but less flexible for complex objects or maps.

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
```

---

## Using `for_each` (Keyed Iteration)

Use `for_each` to iterate over a set, map, or list (converted to a set). This is preferred for named resources, as it allows referencing by key and is more robust for updates.

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
```

---

## Using the `for` Expression (List/Map Comprehension)

Use `for` expressions to transform or filter lists/maps, or to output values from resources created with `for_each` or `count`.

```hcl
resource "azurerm_storage_account" "my_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

output "storage_account_ids" {
  value = [for name in var.storage_account_names : azurerm_storage_account.my_storage[name].id]
}
```

---

## Filtering with `for` and `if` (Conditional Comprehension)

You can filter resources or outputs using an `if` clause in a `for` expression.

```hcl
locals {
  grs_storage_accounts = [for sa in azurerm_storage_account.my_storage : sa if sa.account_replication_type == "GRS"]
}

output "grs_storage_account_names" {
  value = [for sa in local.grs_storage_accounts : sa.name]
}
```

---

## Conditional Arguments in Resources

Use conditionals to set resource arguments dynamically (e.g., for multi-environment or multi-cloud deployments):

```hcl
variable "environment" {
  default = "prod"
}

resource "azurerm_storage_account" "my_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
}
```

---

## Best Practices
- Use `for_each` for named resources and maps; use `count` for simple lists.
- Use `for` expressions for output transformation and filtering.
- Always use unique keys with `for_each` to avoid resource drift.
- Prefer `for_each` for cloud resources that may be updated or deleted individually.
- Use conditionals for multi-cloud, multi-environment, or feature-flagged deployments.

---

## References
- [Terraform: for_each vs count](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Terraform for Expressions](https://developer.hashicorp.com/terraform/language/expressions/for)
- [Terraform Conditionals](https://developer.hashicorp.com/terraform/language/expressions/conditionals)

> **Tip:** Use these patterns to keep your Terraform code DRY, scalable, and cloud-agnostic—especially in CI/CD and multi-cloud DevOps workflows.

---

## Add to SUMMARY.md

```markdown
- [Terraform for_each, count, and for Expressions](pages/terraform/tips/terraform-for_each.md)
```
