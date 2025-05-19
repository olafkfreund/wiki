# Azure Tags

Consistent tagging is essential for managing, automating, and governing Azure resources at scale. Tags enable cost allocation, compliance, automation, and resource organization—critical for DevOps and Cloud Architects.

## Why Tagging Matters

- **Resource Management:** Filter, group, and report on resources by tag.
- **Cost Allocation:** Track spend by project, environment, or owner.
- **Automation:** Drive lifecycle actions (e.g., auto-shutdown, backups) based on tags.
- **Compliance:** Enforce policies and reporting for regulatory needs.

## Recommended Standard Tags

| Key           | Example Value   | Purpose                        |
|---------------|----------------|--------------------------------|
| Environment   | prod, dev, test| Environment classification     |
| Owner         | alice, devops  | Resource owner or team         |
| Project       | website, mlops | Project or workload name       |
| CostCenter    | 1234, IT-OPS   | Cost allocation                |
| Application   | webapp, api    | Application name               |
| Department    | Finance, HR    | Business unit                  |
| Criticality   | high, medium   | Business impact                |
| ManagedBy     | terraform, bicep| Deployment tool                |
| ExpiryDate    | 2024-12-31     | Resource lifecycle management  |

## Real-Life Tagging Policy Example

- All production resources must have: `Environment`, `Owner`, `CostCenter`, and `Project` tags.
- Automation scripts enforce tagging at deployment and audit for missing tags weekly.

## Tagging with Terraform

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-prod-weu"
  location = "westeurope"
  tags = {
    Environment = "prod"
    Owner       = "alice"
    Project     = "website"
    CostCenter  = "1234"
  }
}
```

## Tagging with Bicep

```bicep
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-myapp-prod-weu'
  location: 'westeurope'
  tags: {
    Environment: 'prod'
    Owner: 'alice'
    Project: 'website'
    CostCenter: '1234'
  }
}
```

## Tagging with Azure CLI

```sh
az group create --name rg-myapp-prod-weu --location westeurope --tags Environment=prod Owner=alice Project=website CostCenter=1234
az tag create --resource-id <resource-id> --tags Department=Finance Criticality=high
```

## Best Practices

- Define and document a standard tag set for your organization.
- Enforce tags using Azure Policy or CI/CD checks.
- Use automation to remediate missing or incorrect tags.
- Avoid sensitive data in tag values.
- Regularly audit tags for consistency.

## Common Pitfalls

- Inconsistent tag keys (e.g., `owner` vs `Owner`).
- Exceeding Azure’s tag limits (50 tags per resource, 256 chars per key/value).
- Relying on manual tagging—always automate.

## References

- [Azure Tagging Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Azure Policy for Tag Enforcement](https://learn.microsoft.com/en-us/azure/governance/policy/samples/enforce-tag-and-its-value)

> **Joke:** Why did the Azure resource get tagged as 'critical'? Because it always demanded attention!
