---
description: >-
  The Azure CLI is a cross-platform command-line tool for managing Azure resources. It runs on Linux, macOS, and Windows, and can be used interactively or in automation scripts. This guide covers installation, proxy configuration, container usage, and practical DevOps examples for 2025.
---

# AZ-CLI

## Installation (2025)

### Fedora / RHEL / CentOS

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install azure-cli
```

### Ubuntu / Debian

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### macOS (Homebrew)

```bash
brew update && brew install azure-cli
```

### Windows

```powershell
winget install -e --id Microsoft.AzureCLI
```

### NixOS Installation & Configuration (2025)

#### Using Nix Package Manager

```nix
# Add to your /etc/nixos/configuration.nix
environment.systemPackages = with pkgs; [ azure-cli ];
```

Apply the configuration:

```bash
sudo nixos-rebuild switch
```

#### Using Home Manager (per-user)

```nix
# Add to your home.nix
home.packages = with pkgs; [ azure-cli ];
```

Apply the configuration:

```bash
home-manager switch
```

#### Post-Install Configuration

- Ensure you have Python 3 available (NixOS provides this by default).
- If you need to use Azure CLI behind a proxy, set the `HTTP_PROXY` and `HTTPS_PROXY` environment variables as described above.
- For persistent configuration, add proxy variables to your shell profile (e.g., `.bashrc`, `.zshrc`).

---

## Proxy Settings

If you are behind a proxy, configure the following environment variables:

```bash
# No auth
export HTTP_PROXY=http://[proxy]:[port]
export HTTPS_PROXY=https://[proxy]:[port]

# Basic auth
export HTTP_PROXY=http://[username]:[password]@[proxy]:[port]
export HTTPS_PROXY=https://[username]:[password]@[proxy]:[port]
```

---

## Running Azure CLI in Docker/Podman

```bash
docker run -it mcr.microsoft.com/azure-cli
```

To use your local SSH keys (for az ssh, az vm, etc.):

```bash
docker run -it -v ${HOME}/.ssh:/root/.ssh mcr.microsoft.com/azure-cli
```

---

## Real-Life DevOps Examples (2025)

### 1. Login and Set Subscription

```bash
az login
az account set --subscription "My-Prod-Subscription"
```

### 2. Create a Resource Group

```bash
az group create --name devops-rg --location westeurope
```

### 3. Deploy Infrastructure with Bicep

```bash
az deployment group create \
  --resource-group devops-rg \
  --template-file main.bicep \
  --parameters environment=dev
```

### 4. Assign a Managed Identity to a VM

```bash
az vm identity assign --name myvm --resource-group devops-rg
```

### 5. Use Azure CLI in GitHub Actions

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
- name: Run Azure CLI Script
  run: |
    az group list --output table
```

---

## Azure CLI Jokes

> **Why did the Azure resource group break up with the VM?**
> Because it needed more space!

> **Why do Azure engineers love the CLI?**
> Because it's always az-y to automate!

> **Why did the Azure cloud get invited to all the parties?**
> Because it always brings the best resources on demand!

---

## More Examples & Resources

- [Azure CLI Official Docs](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure CLI Samples](https://github.com/Azure-Samples/azure-cli-samples)
- [Best Practices for Azure CLI in DevOps](https://learn.microsoft.com/en-us/azure/developer/cli/best-practices)

---

*Tip: Use `az upgrade` to keep your CLI up to date!*
