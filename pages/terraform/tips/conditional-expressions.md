# Conditional Expressions

Conditional expressions in Terraform allow you to implement logic similar to _if/else_ statements found in languages like Python, C#, or Java. Instead of traditional if/else, Terraform uses a ternary operator for concise, inline decisions—ideal for cloud infrastructure automation.

---

## Syntax

```hcl
condition ? true_val : false_val
```

- If `condition` is true, the result is `true_val`.
- If `condition` is false, the result is `false_val`.

---

## Real-Life DevOps Examples

### 1. Conditional Resource Creation (e.g., Multi-Cloud)

Deploy an Azure resource only if the environment is set to `azure`:

```hcl
resource "azurerm_resource_group" "main" {
  count    = var.cloud == "azure" ? 1 : 0
  name     = "devops-rg"
  location = "westeurope"
}
```

### 2. Default Value Fallback

Set a default VM image if none is provided:

```hcl
locals {
  vm_image = var.image_id != "" ? var.image_id : "ubuntu-22-04-lts"
}
```

### 3. Conditional Output for Multi-Provider Deployments

Output a value only if a resource exists:

```hcl
output "azure_rg_name" {
  value       = azurerm_resource_group.main[0].name
  description = "Name of the Azure resource group (if created)"
  condition   = var.cloud == "azure"
}
```

### 4. Type Consistency in Conditionals

Always ensure both results are the same type to avoid errors:

```hcl
locals {
  instance_count = var.enable_app ? 3 : 0
  # If mixing types, use conversion:
  instance_type  = var.use_large ? tostring(4) : "standard"
}
```

---

## Best Practices

- Use conditionals for resource `count`, `for_each`, and variable defaults.
- Always match types on both sides of the conditional.
- Avoid deeply nested conditionals for readability.
- Use [Terraform functions](https://developer.hashicorp.com/terraform/language/functions) for complex logic.

---

## References

- [Terraform: Conditionals](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [Terraform Functions & Expressions](https://spacelift.io/blog/terraform-functions-expressions-loops)
- [Terraform Count and For Each](https://spacelift.io/blog/terraform-count-for-each)

> **Tip:** Use conditionals to keep your Terraform code DRY and cloud-agnostic—especially in multi-cloud and CI/CD scenarios.

---

## Add to SUMMARY.md

```markdown
- [Conditional Expressions](pages/terraform/tips/conditional-expressions.md)
```
