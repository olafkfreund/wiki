# Terraform State Management Best Practices

State management is crucial for maintaining infrastructure with Terraform. This guide covers best practices for managing Terraform state effectively and securely.

## Remote State Storage

### Use Remote Backend

Always use a remote backend for state storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate${random_string.suffix.result}"
    container_name       = "tfstate"
    key                 = "prod.terraform.tfstate"
  }
}
```

### Backend Options by Cloud Provider

- **AWS**: S3 with DynamoDB for state locking
- **Azure**: Azure Storage Account with blob container
- **GCP**: Google Cloud Storage bucket
- **HashiCorp**: Terraform Cloud/Enterprise

## State File Security

1. **Encryption at Rest**
   - Enable encryption for storage backends
   - Use customer-managed keys where available

2. **Access Control**
   - Implement least-privilege access
   - Use separate state files for different environments
   - Enable version control on storage containers

## State Organization

### State Separation

Maintain separate states for:

- Different environments (dev, staging, prod)
- Different regions
- Different business units or applications

Example structure:

```
└── terraform/
    ├── prod/
    │   ├── main.tf
    │   └── backend.tf
    ├── staging/
    │   ├── main.tf
    │   └── backend.tf
    └── dev/
        ├── main.tf
        └── backend.tf
```

## State Operations Best Practices

1. **State Locking**
   - Always enable state locking
   - Use a robust locking mechanism (e.g., DynamoDB for AWS)

2. **Regular Backups**
   - Enable versioning on state storage
   - Implement regular backup procedures

3. **State Manipulation**
   - Avoid manual state manipulation
   - Use `terraform state` commands when necessary
   - Document any state changes

## Common Commands

```bash
# List resources in state
terraform state list

# Move an item in state
terraform state mv aws_instance.example aws_instance.new_name

# Remove an item from state
terraform state rm aws_instance.example

# Show state contents
terraform show
```

## Workspaces

Use workspaces for managing multiple states of the same configuration:

```bash
# Create and switch to a new workspace
terraform workspace new dev

# List available workspaces
terraform workspace list

# Switch between workspaces
terraform workspace select prod
```

## Troubleshooting

Common issues and solutions:

1. **State Lock Issues**
   - Check for stale locks
   - Use `terraform force-unlock` as a last resort

2. **State Corruption**
   - Restore from backup
   - Use state push/pull carefully

3. **Performance Issues**
   - Split large states into smaller ones
   - Use -refresh=false for faster plans

## Best Practices Checklist

- [ ] Remote backend configured
- [ ] State locking enabled
- [ ] Encryption at rest enabled
- [ ] Access controls implemented
- [ ] Regular backups configured
- [ ] State separated by environment
- [ ] Workspace strategy defined
- [ ] Documentation updated

## Related Topics

- [Terraform Security](security.md) - Securing your state files and credentials
- [Code Organization](code-organization.md) - Structuring projects for optimal state management
- [GitHub Actions Integration](../cicd/github-actions.md) - Automating state management in CI/CD
- [Azure DevOps Pipelines](../cicd/azure-pipelines.md) - State management with Azure DevOps
