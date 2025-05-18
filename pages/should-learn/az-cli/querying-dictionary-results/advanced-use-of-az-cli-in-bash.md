# Advanced use of az-cli in bash

This page demonstrates advanced Bash and Zsh scripting techniques for managing Azure resources with az-cli. All examples assume you have Azure CLI installed and authenticated.

---

## Bash Examples

### If-Then-Else: Check if Variable is Null

```bash
if [ -n "$resourceGroup" ]; then
   echo "$resourceGroup"
else
   resourceGroup="msdocs-learn-bash-$RANDOM"
fi
```

### If-Then: Create or Delete a Resource Group

Create if not exists:

```bash
if [ "$(az group exists --name "$resourceGroup")" = false ]; then 
   az group create --name "$resourceGroup" --location "$location"
else
   echo "$resourceGroup already exists."
fi
```

Delete if exists:

```bash
if [ "$(az group exists --name "$resourceGroup")" = true ]; then 
   az group delete --name "$resourceGroup" -y # --no-wait
else
   echo "The $resourceGroup resource group does not exist."
fi
```

### Grep: Create Resource Group if Not Exists

```bash
az group list --output tsv | grep -q "$resourceGroup" || az group create --name "$resourceGroup" --location "$location"
```

### Case Statement: Create Resource Group if Not Exists

```bash
var=$(az group list --query "[?name=='$resourceGroup'].name" --output tsv)
case "$resourceGroup" in
  $var)
    echo "The $resourceGroup resource group already exists." ;;
  *)
    az group create --name "$resourceGroup" --location "$location" ;;
esac
```

---

## Zsh Examples & Configuration

Zsh syntax is nearly identical to Bash for these use cases. Ensure variables are quoted and use parameter expansion for null checks.

### If-Then-Else: Check if Variable is Null

```zsh
if [[ -n "$resourceGroup" ]]; then
  echo "$resourceGroup"
else
  resourceGroup="msdocs-learn-zsh-$RANDOM"
fi
```

### If-Then: Create or Delete a Resource Group

Create if not exists:

```zsh
if [[ "$(az group exists --name "$resourceGroup")" == false ]]; then
  az group create --name "$resourceGroup" --location "$location"
else
  echo "$resourceGroup already exists."
fi
```

Delete if exists:

```zsh
if [[ "$(az group exists --name "$resourceGroup")" == true ]]; then
  az group delete --name "$resourceGroup" -y # --no-wait
else
  echo "The $resourceGroup resource group does not exist."
fi
```

### Grep: Create Resource Group if Not Exists

```zsh
az group list --output tsv | grep -q "$resourceGroup" || az group create --name "$resourceGroup" --location "$location"
```

### Case Statement: Create Resource Group if Not Exists

```zsh
var=$(az group list --query "[?name=='$resourceGroup'].name" --output tsv)
case "$resourceGroup" in
  $var)
    echo "The $resourceGroup resource group already exists." ;;
  *)
    az group create --name "$resourceGroup" --location "$location" ;;
esac
```

---

## Best Practices

- Always quote variables to prevent word splitting and globbing.
- Use `-n`/`-z` for null checks in Bash/Zsh.
- Use `--output tsv` for scripting to simplify parsing.
- Prefer `[[ ... ]]` for conditionals in Zsh.
- Use `$RANDOM` for unique resource group names in scripts.

---

## References

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Bash Reference](https://www.gnu.org/software/bash/manual/bash.html)
- [Zsh Reference](https://zsh.sourceforge.io/Doc/)
