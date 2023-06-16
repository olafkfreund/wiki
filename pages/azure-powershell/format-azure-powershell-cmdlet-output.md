---
description: >-
  Formatting is used for display in the PowerShell console, and conversion is
  used for generating data to be consumed by other scripts or programs.
---

# Format Azure PowerShell cmdlet output

```powershell
Get-AzVM -ResourceGroupName QueryExample |
  Format-Table -Property Name, ResourceGroupName, Location
```

```powershell
Get-AzVM | Format-List
```

```powershell
Get-AzVM | Format-List -Property ResourceGroupName, Name, Location
```

```powershell
Get-AzVM | Format-Wide
```

```powershell
Get-AzVM | Format-Custom -Property Name, ResourceGroupName, Location, OSProfile
```
