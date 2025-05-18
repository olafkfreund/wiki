# Conversion to other data formats

## Convert Azure VM Data to CSV

```powershell
Get-AzVM | ConvertTo-Csv | Out-File "vms.csv"
```

- Exports VM details to a CSV file for use in Excel or reporting tools.

## Convert Azure VM Data to JSON

```powershell
Get-AzVM | ConvertTo-Json | Out-File "vms.json"
```

- Useful for integrations, automation, or sharing data with APIs.

## Convert Azure VM Data to XML

```powershell
Get-AzVM | ConvertTo-Xml | Out-File "vms.xml"
```

- XML is often used for configuration or interoperability with legacy systems.

## Convert Azure VM Data to HTML

```powershell
Get-AzVM | ConvertTo-Html | Out-File "vms.html"
```

- Generates a simple HTML report for web viewing or sharing.

---

**Best Practices:**

- Always use `Out-File` or `Set-Content` to save output to disk.
- For large datasets, consider filtering or selecting only required properties with `Select-Object`.
- Validate output files for completeness and encoding (e.g., UTF-8).

**References:**

- [ConvertTo-Csv](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-csv)
- [ConvertTo-Json](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-json)
- [ConvertTo-Xml](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-xml)
- [ConvertTo-Html](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-html)
