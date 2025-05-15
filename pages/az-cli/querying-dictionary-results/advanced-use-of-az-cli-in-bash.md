# Advanced use of az-cli in bash, zsh, and nushell (2025)

This guide demonstrates advanced scripting with the Azure CLI (az) in Bash, Zsh, and Nushell, following 2025 best practices. Real-life DevOps scenarios are included for each shell.

---

## Bash Examples (2025 Best Practices)

### If-Then-Else: Check if variable is null
```bash
if [[ -n "$resourceGroup" ]]; then
  echo "$resourceGroup"
else
  resourceGroup="msdocs-learn-bash-$randomIdentifier"
fi
```

### Create or Delete a Resource Group
```bash
# Create if not exists
if ! az group exists --name "$resourceGroup" | grep -q true; then
  az group create --name "$resourceGroup" --location "$location"
else
  echo "$resourceGroup already exists"
fi

# Delete if exists
if az group exists --name "$resourceGroup" | grep -q true; then
  az group delete --name "$resourceGroup" -y # --no-wait
else
  echo "The $resourceGroup resource group does not exist"
fi
```

### Grep: Create if not exists
```bash
az group list --query "[].name" -o tsv | grep -Fxq "$resourceGroup" || az group create --name "$resourceGroup" --location "$location"
```

### Case Statement
```bash
var=$(az group list --query "[].name" -o tsv)
case "$var" in
  *"$resourceGroup"*)
    echo "$resourceGroup already exists.";;
  *)
    az group create --name "$resourceGroup" --location "$location";;
esac
```

---

## Zsh Examples

### Null/Unset Variable Check (Zsh idiomatic)
```zsh
if [[ -n "$resourceGroup" ]]; then
  print "$resourceGroup"
else
  resourceGroup="msdocs-learn-zsh-$RANDOM"
fi
```

### Create Resource Group if Not Exists
```zsh
if ! az group exists --name "$resourceGroup" | grep -q true; then
  az group create --name "$resourceGroup" --location "$location"
else
  print "$resourceGroup already exists"
fi
```

### Using Parameter Expansion for Defaults
```zsh
: "${resourceGroup:=msdocs-learn-zsh-$RANDOM}"
```

---

## Nushell Examples

### Check and Create Resource Group
```nu
let resourceGroup = ("$env.resourceGroup" | default "msdocs-learn-nu-($random)")
if (az group exists --name $resourceGroup | from json | get value) == false {
  az group create --name $resourceGroup --location $location | from json
} else {
  print "Resource group $resourceGroup already exists"
}
```

### List and Filter Resource Groups
```nu
az group list | from json | where name == $resourceGroup | is-empty | if $in {
  az group create --name $resourceGroup --location $location | from json
} else {
  print "Resource group $resourceGroup already exists"
}
```

---

## Real-Life DevOps Scenarios

### 1. Automated Environment Provisioning (Bash/Zsh)
```bash
# .envrc (for direnv)
export resourceGroup="devops-rg-$(date +%Y%m%d)"
export location="westeurope"

direnv allow

# Provision if not exists
if ! az group exists --name "$resourceGroup" | grep -q true; then
  az group create --name "$resourceGroup" --location "$location"
fi
```

### 2. Multi-Cloud Scripting (Nushell)
```nu
let clouds = ["azure", "aws", "gcp"]
for cloud in $clouds {
  if $cloud == "azure" {
    az group list | from json | get name
  } else if $cloud == "aws" {
    aws ec2 describe-instances | from json | get Reservations
  } else if $cloud == "gcp" {
    gcloud compute instances list --format=json | from json | get name
  }
}
```

---

## Best Practices (2025)
- Always quote variables to avoid word splitting
- Use `--output json` or `from json` for reliable parsing
- Prefer parameter expansion for defaults in zsh
- Use `direnv` and `.envrc` for environment isolation
- For complex logic, prefer structured shells like Nushell

---

## References
- [Azure CLI Docs](https://learn.microsoft.com/en-us/cli/azure/)
- [Nushell Book](https://www.nushell.sh/book/)
- [Zsh Manual](https://zsh.sourceforge.io/Doc/)
- [direnv](https://direnv.net/)

