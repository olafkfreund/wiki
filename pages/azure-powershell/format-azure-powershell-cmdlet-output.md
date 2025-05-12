---
description: >-
  Formatting is used for display in the PowerShell console, and conversion is
  used for generating data to be consumed by other scripts or programs.
---

# Format Azure PowerShell cmdlet output

```powershell
Get-AzVM -ResourceGroupName QueryExample |
  Format-Table -Property Name, ResourceGroupName, Location
```plaintext

```powershell
Get-AzVM | Format-List
```plaintext

```powershell
Get-AzVM | Format-List -Property ResourceGroupName, Name, Location
```plaintext

```powershell
Get-AzVM | Format-Wide
```plaintext

```powershell
Get-AzVM | Format-Custom -Property Name, ResourceGroupName, Location, OSProfile
```plaintext
