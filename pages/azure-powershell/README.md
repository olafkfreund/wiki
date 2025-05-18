---
description: >-
  The Azure PowerShell Az module is a rollup module. Installing the Az
  PowerShell module downloads the generally available modules and makes their
  cmdlets available for use.
---

# Azure PowerShell

Azure PowerShell (Az module) enables DevOps engineers to automate, configure, and manage Azure resources directly from the command line or CI/CD pipelines. Below are practical installation and usage instructions for Windows, Linux, and containerized environments.

## Windows Installation & Setup

```powershell
# Check for legacy AzureRM module
Get-Module -Name AzureRM -ListAvailable

# Set execution policy for current user
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Az module from PSGallery
Install-Module -Name Az -Repository PSGallery -Force
```

### Enable Command Prediction (Productivity Boost)

```powershell
Install-Module -Name Az.Tools.Predictor -Force
Enable-AzPredictor -AllSession
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionViewStyle InlineView
```

### Sign In to Azure

```powershell
Connect-AzAccount
```

## Linux Installation & Setup

> **Tip:** Use PowerShell Core (`pwsh`) for best cross-platform compatibility.

```powershell
# Install Az module
Install-Module -Name Az -Repository PSGallery -Force

# Sign in to Azure
Connect-AzAccount
```

## Docker/Podman (Containerized Azure PowerShell)

Run Azure PowerShell in an isolated container—ideal for CI/CD or ephemeral environments:

```bash
docker pull mcr.microsoft.com/azure-powershell
docker run -it mcr.microsoft.com/azure-powershell pwsh
```

## Real-Life DevOps Example: Automate Resource Group Creation

```powershell
# Create a resource group if it doesn't exist
$rgName = "devops-rg"
$location = "westeurope"
if (-not (Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $rgName -Location $location
}
```

## Best Practices
- Always use the latest Az module for new scripts.
- Avoid mixing AzureRM and Az modules in the same session.
- Use `-ErrorAction` to handle errors gracefully in automation.
- Prefer PowerShell Core (`pwsh`) for cross-platform scripts.
- Use containers for ephemeral or CI/CD automation tasks.

## References
- [Official Az Module Docs](https://learn.microsoft.com/powershell/azure/new-azureps-module-az)
- [Azure PowerShell Samples](https://learn.microsoft.com/powershell/azure/examples)
- [Az.Tools.Predictor](https://learn.microsoft.com/powershell/azure/az-predictor)

---

> **Azure PowerShell Joke:**
> Why did the DevOps engineer use Azure PowerShell in a container? To keep their scripts clean and their clusters cleaner!
