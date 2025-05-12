# Querying dictionary results (2025 Update)

Azure CLI supports powerful querying and output formatting using the `--query` parameter (JMESPath syntax) and the `--output` parameter. Here are the latest best practices and examples:

## Basic Output Formats
```bash
az account show --output json   # JSON (default)
az account show --output yaml   # YAML (easy to read)
az account show --output table  # Table (for high-level overviews)
az account show --output tsv    # Tab-separated (for scripting)
```

## Querying Single and Nested Values
```bash
az account show --query name                # Single value
az account show --query name -o tsv         # Remove quotes for scripting
az account show --query user.name           # Nested value
az account show --query user.name -o tsv    # Nested value, no quotes
```

## Querying and Formatting Arrays
```bash
az account list --query "[].{subscription_id:id, name:name, isDefault:isDefault}" -o table
```

## Querying Multiple and Nested Values
```bash
az account show --query [name,id,user.name] -o table
```

## Renaming Properties in Output
```bash
az account show --query "{SubscriptionName: name, SubscriptionId: id, UserName: user.name}" -o table
```

## Querying Boolean and Filtering
```bash
az account list --query "[?isDefault]" -o table
az account list --query "[?isDefault].{SubscriptionName: name, SubscriptionId: id}" -o table
az account list --query "[?isDefault == `false`].name" -o table
az account list --query "[? contains(name, 'Test')].id" -o tsv
```

## Storing Output in Variables (Bash)
```bash
subscriptionId=$(az account list --query "[?isDefault].id" -o tsv)
az account set --subscription $subscriptionId
```

## Customizing Table Output
```bash
az vm list --query "[].{resource:resourceGroup, name:name}" --output table
```

## Advanced: Sorting and Filtering
```bash
az vm list --resource-group QueryDemo --query "sort_by([].{Name:name, Size:storageProfile.osDisk.diskSizeGb}, &Size)" --output table
```

## Best Practices
- Use `--query` to filter and shape output for readability and automation.
- Use `-o tsv` for scripting to avoid extra quotes.
- Use `-o table` for human-friendly summaries.
- Store sensitive output in variables, not in logs.
- Use `az config set core.output=table` to set a default output format.
- For complex JSON processing, pipe output to `jq`.

## References
- [Azure CLI Query Documentation](https://learn.microsoft.com/en-us/cli/azure/query-azure-cli)
- [JMESPath Query Language](https://jmespath.org/)
- [Azure CLI Output Formats](https://learn.microsoft.com/en-us/cli/azure/format-output-azure-cli)

