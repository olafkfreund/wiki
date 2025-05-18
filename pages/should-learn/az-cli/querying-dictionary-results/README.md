# Querying Dictionary Results with Azure CLI

Azure CLI supports powerful querying and formatting using JMESPath. This enables you to extract, filter, and format data directly from CLI commands—ideal for automation, scripting, and DevOps workflows.

## Output Formats

```bash
az account show
az account show --output json   # JSON is the default format
az account show --output yaml   # YAML output
az account show --output table  # Human-readable table
```

## Querying and Formatting Single and Nested Values

```bash
az account show --query name                # Single value
az account show --query name -o tsv         # Removes quotes
az account show --query user.name           # Nested value
az account show --query user.name -o tsv    # Nested value, no quotes
```

## Querying Properties from Arrays

```bash
az account list --query "[].{subscription_id:id, name:name, isDefault:isDefault}" -o table
```

## Querying and Formatting Multiple Values (Including Nested)

```bash
az account show --query [name,id,user.name]                # Multiple values
az account show --query [name,id,user.name] -o table       # As table
```

## Renaming Properties in a Query

```bash
az account show --query "{SubscriptionName: name, SubscriptionId: id, UserName: user.name}"
az account show --query "{SubscriptionName: name, SubscriptionId: id, UserName: user.name}" -o table
```

## Querying Boolean Values and Filtering

```bash
az account list --query "[?isDefault]" -o table
az account list --query "[?isDefault].[name,id]" -o table
az account list --query "[?isDefault].{SubscriptionName: name, SubscriptionId: id}" -o table
az account list --query "[?isDefault == `false`].name" -o table
az account list --query "[?isDefault].id" -o tsv
subscriptionId="$(az account list --query '[?isDefault].id' -o tsv)"
az account set -s $subscriptionId
```

## Advanced Filtering Examples

```bash
az account list --query "[? contains(name, 'Test')].id" -o tsv
subscriptionId="$(az account list --query '[? contains(name, `Test`)].id' -o tsv)"
az account set -s $subscriptionId
```

## Working with Spaces and Quotation Marks in Bash

```bash
resourceGroup="msdocs-learn-bash-$RANDOM"
location="East US"
az group create --name "$resourceGroup" --location "$location"
```

> **Tip:** Always quote variables with spaces to avoid command errors.

## Real-Life DevOps Example: Automate Subscription Switching in CI/CD

```yaml
- name: Get Default Subscription ID
  run: |
    export SUBSCRIPTION_ID=$(az account list --query '[?isDefault].id' -o tsv)
    echo "Using subscription: $SUBSCRIPTION_ID"
- name: Set Subscription
  run: az account set -s $SUBSCRIPTION_ID
```

## Best Practices

- Use `-o tsv` for scripting to avoid extra quotes.
- Use JMESPath queries to filter and format output for automation.
- Always quote variables with spaces in Bash.
- Validate your queries with `az ... --query ...` before using in scripts.

## References

- [Azure CLI Query Documentation](https://learn.microsoft.com/en-us/cli/azure/query-azure-cli)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html)

---

> **Azure CLI Joke:**
> Why did the DevOps engineer use JMESPath with Azure CLI? Because they wanted to query their way to cloud nine!
