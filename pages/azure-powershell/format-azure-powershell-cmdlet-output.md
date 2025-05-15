---
description: >-
  Formatting is used for display in the PowerShell console, and conversion is
  used for generating data to be consumed by other scripts or programs.
---

# Format Azure PowerShell Cmdlet Output

Azure PowerShell cmdlets typically return structured objects with many properties. Formatting these outputs effectively is essential for both readability and data processing in your DevOps workflows. This guide covers various formatting options with practical examples for Azure resource management.

## Basic Formatting Options

PowerShell provides several cmdlets for formatting output:

- `Format-Table`: Displays output as a table with columns
- `Format-List`: Displays output as a list of properties
- `Format-Wide`: Displays output as a wide table showing a single property
- `Format-Custom`: Displays output using a customized view
- `Out-GridView`: Displays output in an interactive table (GUI window)

## Format-Table Examples

### Simple Table with Selected Properties

```powershell
Get-AzVM -ResourceGroupName "ProductionResources" |
  Format-Table -Property Name, ResourceGroupName, Location
```

This displays a concise table showing only the VM name, resource group, and Azure region.

### Auto-sized Table with Custom Properties

```powershell
Get-AzVM | Format-Table -AutoSize -Property Name, @{
    Name = 'OS Type'; 
    Expression = {$_.StorageProfile.OSDisk.OSType}
}, @{
    Name = 'Size'; 
    Expression = {$_.HardwareProfile.VmSize}
}, PowerState
```

This formats VMs in a table with custom columns for OS type and VM size, automatically sizing columns to fit the data.

### Grouping Resources by Region

```powershell
Get-AzResource | 
  Sort-Object Location | 
  Format-Table -GroupBy Location -Property Name, ResourceType, ResourceGroupName
```

This groups all Azure resources by their location, making it easy to see resource distribution across regions.

## Format-List Examples

### Display All Properties

```powershell
Get-AzVM -Name "vm-prod-web01" | Format-List
```

This displays all properties of a specific VM in a list format, which is useful for detailed inspection.

### Selected Properties with Custom Formatting

```powershell
Get-AzVM | Format-List -Property ResourceGroupName, Name, Location, @{
    Name = 'OS Type';
    Expression = {$_.StorageProfile.OSDisk.OSType}
}, @{
    Name = 'VM Size';
    Expression = {$_.HardwareProfile.VmSize}
}, @{
    Name = 'Private IP';
    Expression = {$_.NetworkProfile.NetworkInterfaces[0].Id -replace '.*networkInterfaces/'}
}
```

This creates a list with selected VM properties and custom calculated properties.

## Format-Wide Examples

### Display Resource Names in Columns

```powershell
Get-AzVM | Format-Wide -Property Name -Column 4
```

This shows VM names in 4 columns, maximizing screen real estate for quick scanning.

### Display Storage Accounts with Color

```powershell
Get-AzStorageAccount | ForEach-Object { 
    if ($_.EnableHttpsTrafficOnly -eq $true) {
        $color = "Green" 
    } else {
        $color = "Red"
    }
    Write-Host $_.StorageAccountName -ForegroundColor $color
} | Format-Wide -Column 3
```

This displays storage account names in color based on secure transfer requirement status.

## Format-Custom Examples

### Display VM Details with Custom Depth

```powershell
Get-AzVM | Format-Custom -Property Name, ResourceGroupName, Location, OSProfile -Depth 2
```

This shows VM details with a custom view, limiting nested object expansion to 2 levels.

### Custom View of Network Security Groups

```powershell
Get-AzNetworkSecurityGroup | 
  Format-Custom -Property Name, @{
      Name = 'Security Rules';
      Expression = {$_.SecurityRules | Select-Object Name, Protocol, SourcePortRange, DestinationPortRange, Access}
  } -Depth 3
```

This creates a custom view of NSGs focusing on their security rules.

## Filtering and Sorting with Format Cmdlets

### Filter, Sort and Format in a Pipeline

```powershell
Get-AzVM | 
  Where-Object {$_.PowerState -eq "VM running"} | 
  Sort-Object -Property Name | 
  Format-Table -Property Name, ResourceGroupName, Location, @{
      Name = 'VM Size';
      Expression = {$_.HardwareProfile.VmSize}
  } -AutoSize
```

This filters for running VMs, sorts them by name, and displays them in a table.

## Export and Convert Formatted Data

### Export to CSV with Custom Properties

```powershell
Get-AzVM | 
  Select-Object Name, ResourceGroupName, Location, @{
      Name = 'OS Type';
      Expression = {$_.StorageProfile.OSDisk.OSType}
  }, @{
      Name = 'VM Size';
      Expression = {$_.HardwareProfile.VmSize}
  } | 
  Export-Csv -Path "vm-inventory.csv" -NoTypeInformation
```

This exports VM information to a CSV file with selected properties.

### Convert to JSON for API Integration

```powershell
Get-AzVM -ResourceGroupName "DevResources" | 
  Select-Object Name, Location, @{
      Name = 'OS';
      Expression = {$_.StorageProfile.OSDisk.OSType}
  } | 
  ConvertTo-Json
```

This converts VM data to JSON format for use with REST APIs or other services.

## Interactive Output with Out-GridView

```powershell
Get-AzResource | Out-GridView -Title "Azure Resources" -PassThru | 
  Remove-AzResource -Force -WhatIf
```

This displays resources in an interactive grid, allowing you to select specific resources for deletion (with -WhatIf for safety).

## Best Practices for Output Formatting

1. **Use `Format-*` cmdlets at the end of pipelines only**, as they produce formatting objects that can't be further processed
2. **Use `Select-Object` for data manipulation** before formatting
3. **Prefer `Select-Object` over `Format-*` when piping to export cmdlets**
4. **Use calculated properties** to extract nested information
5. **Consider terminal width** when designing output formats
6. **Add `-AutoSize` to `Format-Table`** for better readability
7. **Use color with `Write-Host`** to highlight important information

## Practical DevOps Scenarios

### Creating a VM Inventory Report

```powershell
$report = Get-AzVM | Select-Object Name, ResourceGroupName, Location, @{
    Name = 'OS';
    Expression = {$_.StorageProfile.OSDisk.OSType}
}, @{
    Name = 'Size';
    Expression = {$_.HardwareProfile.VmSize}
}, @{
    Name = 'Private IP';
    Expression = {
        $nic = Get-AzNetworkInterface -ResourceId $_.NetworkProfile.NetworkInterfaces[0].Id
        $nic.IpConfigurations[0].PrivateIpAddress
    }
}, @{
    Name = 'PowerState';
    Expression = {(Get-AzVM -Name $_.Name -ResourceGroupName $_.ResourceGroupName -Status).Statuses[1].DisplayStatus}
}

# Export to different formats
$report | Format-Table -AutoSize  # Console display
$report | Export-Csv -Path "vm-inventory.csv" -NoTypeInformation  # CSV for Excel
$report | ConvertTo-Html -Title "VM Inventory" | Out-File "vm-inventory.html"  # HTML report
```

This comprehensive example creates a VM inventory with important properties, displaying it on screen while also exporting to CSV and HTML formats.

### Identify Orphaned Resources

```powershell
# Find orphaned disks not attached to any VM
Get-AzDisk | Where-Object {$_.ManagedBy -eq $null} | 
Format-Table -Property Name, ResourceGroupName, @{
    Name = 'Size(GB)';
    Expression = {$_.DiskSizeGB}
}, @{
    Name = 'Cost Tier';
    Expression = {$_.Sku.Name}
} -AutoSize
```

This identifies orphaned disks that may be costing money unnecessarily.

## Conclusion

Effective formatting of Azure PowerShell cmdlet output is essential for both readability and automation. By mastering these formatting techniques, you can create more readable reports and efficient DevOps scripts.

For more information, see the [official PowerShell formatting documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table).
