---
description: >-
  The Azure CLI is a cross-platform command-line tool for managing Azure resources. This guide covers 2025 best practices, installation on Linux/WSL/NixOS, real-life DevOps scenarios, LLM integration, authentication, profile management, and environment control.
---

# Azure CLI (az)

## 2025 Best Practices
- Always use the latest Azure CLI version (`az upgrade`)
- Use service principals or managed identities for automation, not personal accounts
- Store secrets in Azure Key Vault, not in scripts or environment variables
- Use `--output json` for scripting and automation
- Leverage `az account set` and named profiles for multi-tenant/multi-subscription work
- Use `.envrc` and direnv for environment isolation
- Automate with LLMs (GitHub Copilot, Claude) for repeatable workflows
- Enable CLI telemetry only if required for troubleshooting

## Installation

### Linux (Ubuntu/Debian/Fedora/Arch)
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Fedora
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install azure-cli

# Arch Linux
yay -S azure-cli
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ azure-cli ];
}
```
Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Windows Subsystem for Linux (WSL)
Follow the Linux instructions inside your WSL terminal. For persistent PATH, add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH=$PATH:/usr/local/bin
```

### Docker/Podman
```bash
docker run -it mcr.microsoft.com/azure-cli
# Or with SSH keys:
docker run -it -v ${HOME}/.ssh:/root/.ssh mcr.microsoft.com/azure-cli
```

### Windows
```powershell
winget install -e --id Microsoft.AzureCLI
```

## Authentication & Profile Management

### Login
```bash
az login                # Interactive browser login
az login --use-device-code   # For headless/remote
az login --service-principal -u <appId> -p <password|cert> --tenant <tenant>
```

### List and Set Subscriptions
```bash
az account list --output table
az account set --subscription <subscription-id>
```

### Named Profiles (2025+)
```bash
az account set --subscription <sub-id> --name dev
az account set --subscription <sub-id> --name prod
# Switch profiles
ez az account set --name dev
```

### Using .envrc and direnv for Environment Isolation
Create a `.envrc` in your project directory:
```bash
export AZURE_SUBSCRIPTION_ID="<sub-id>"
export AZURE_TENANT_ID="<tenant-id>"
export AZURE_DEFAULTS_GROUP="my-rg"
export AZURE_DEFAULTS_LOCATION="westeurope"
az account set --subscription $AZURE_SUBSCRIPTION_ID
```
Enable direnv:
```bash
direnv allow
```

## Real-Life Scenarios

### 1. Provision a VM with Terraform and az CLI
```hcl
# main.tf
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}
```
```bash
az login
terraform init && terraform apply
```

### 2. Automate AKS Authentication and kubectl Context
```bash
az aks get-credentials --resource-group my-rg --name my-aks --overwrite-existing
kubectl get nodes
```

### 3. Use az CLI with GitHub Copilot or Claude
- Use Copilot/Claude to generate az CLI scripts for resource automation:
```bash
# Example prompt to Copilot/Claude:
# "Generate a script to create a storage account and upload a file using az CLI."
```
- Review, test, and version-control generated scripts.

### 4. Multi-Cloud/Hybrid Automation
- Use az CLI in GitHub Actions, Azure Pipelines, or GitLab CI/CD for IaC and deployment.
- Example GitHub Actions step:
```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
- name: Deploy Bicep
  run: az deployment group create -g my-rg -f main.bicep
```

## Authenticating Against AKS and Other Services

### AKS
```bash
az aks get-credentials --resource-group my-rg --name my-aks
kubectl get pods
```

### Azure Container Registry (ACR)
```bash
az acr login --name myregistry
```

### Azure Key Vault
```bash
az keyvault secret show --vault-name myvault --name mysecret
```

## Useful Resources
- [Azure CLI Docs](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure CLI Samples](https://github.com/Azure-Samples/azure-cli-samples)
- [direnv](https://direnv.net/)
- [GitHub Copilot](https://github.com/features/copilot)
- [Claude LLM](https://www.anthropic.com/claude)
