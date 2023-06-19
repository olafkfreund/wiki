---
description: >-
  The Azure PowerShell Az module is a rollup module. Installing the Az
  PowerShell module downloads the generally available modules and makes their
  cmdlets available for use.
---

# Azure Powershell

Windows:

```powershell
Get-Module -Name AzureRM -ListAvailable
```

```powershell
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Repository PSGallery -Force
```

Configure command prediction:

```powershell
Install-Module -Name Az.Tools.Predictor
Enable-AzPredictor -AllSession
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionViewStyle InlineView
```

Sign In:

```powershell
Connect-AzAccount
```

Linux:

```powershell
Install-Module -Name Az -Repository PSGallery -Force
```

Sign in:

```powershell
Connect-AzAccount
```

Docker/Podman:

```bash
docker pull mcr.microsoft.com/azure-powershell
docker run -it mcr.microsoft.com/azure-powershell pwshh
```
