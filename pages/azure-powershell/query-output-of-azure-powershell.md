---
description: >-
  Usually, you query output from Azure PowerShell with the Select-Object cmdlet.
  Output can be filtered with Where-Object.
---

# Query output of Azure PowerShell

```powershell
Get-AzVM -Name TestVM -ResourceGroupName TestGroup |
  Select-Object -Property *
```plaintext

```powershell
Get-AzVM -Name TestVM -ResourceGroupName TestGroup |
  Select-Object -Property Name, VmId, ProvisioningState
```plaintext

Select nested properties:

{% code overflow="wrap" %}
```powershell
Get-AzVM -ResourceGroupName TestGroup |
  Select-Object -Property Name, @{label='OSType'; expression={$_.StorageProfile.OSDisk.OSType}}
```plaintext
{% endcode %}

Filter results:

```powershell
Get-AzVM -ResourceGroupName TestGroup |
  Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'Linux'} |
  Select-Object -Property Name, VmID, ProvisioningState
```plaintext
