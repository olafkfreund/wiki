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
```plaintext

```powershell
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Repository PSGallery -Force
```plaintext

Configure command prediction:

```powershell
Install-Module -Name Az.Tools.Predictor
Enable-AzPredictor -AllSession
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionViewStyle InlineView
```plaintext

Sign In:

```powershell
Connect-AzAccount
```plaintext

Linux:

```powershell
Install-Module -Name Az -Repository PSGallery -Force
```plaintext

Sign in:

```powershell
Connect-AzAccount
```plaintext

Docker/Podman:

```bash
docker pull mcr.microsoft.com/azure-powershell
docker run -it mcr.microsoft.com/azure-powershell pwshh
```plaintext
