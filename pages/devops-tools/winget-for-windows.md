---
description: Install devtools with winget command in Windows.
---

# Winget for Windows (2025)

Winget is the Windows Package Manager CLI for automating the installation of development tools, cloud CLIs, and productivity software. This is essential for DevOps engineers working in hybrid or Windows-based environments.

---

## Best Practices (2025)
- Use a version-controlled `winget` import file for reproducible environments
- Regularly update your package list to include the latest tools (Azure CLI, AWS CLI, GCP SDK, Docker, Kubernetes tools, editors)
- Use `winget upgrade --all` to keep tools up to date
- Integrate `winget` into onboarding scripts or CI/CD for Windows build agents
- Validate package identifiers with `winget search <name>`

---

## Example: DevOps Tooling Import List

Save the following as `myinstall.json`:

```json
{
  "$schema": "https://aka.ms/winget-packages.schema.2.0.json",
  "CreationDate": "2025-05-01T00:00:00.000-00:00",
  "Sources": [
    {
      "Packages": [
        { "PackageIdentifier": "Canonical.Ubuntu.2204" },
        { "PackageIdentifier": "Derailed.k9s" },
        { "PackageIdentifier": "Git.Git" },
        { "PackageIdentifier": "Hashicorp.Packer" },
        { "PackageIdentifier": "Hashicorp.Terraform" },
        { "PackageIdentifier": "JesseDuffield.lazygit" },
        { "PackageIdentifier": "kalilinux.kalilinux" },
        { "PackageIdentifier": "Kubernetes.kompose" },
        { "PackageIdentifier": "Kubernetes.kubectl" },
        { "PackageIdentifier": "Microsoft.Edge" },
        { "PackageIdentifier": "Microsoft.EdgeWebView2Runtime" },
        { "PackageIdentifier": "Microsoft.Azure.AZCopy.10" },
        { "PackageIdentifier": "Microsoft.Azure.Kubelogin" },
        { "PackageIdentifier": "Microsoft.PowerShell.Preview" },
        { "PackageIdentifier": "Microsoft.WindowsTerminal.Preview" },
        { "PackageIdentifier": "Microsoft.WindowsTerminal" },
        { "PackageIdentifier": "Insecure.Nmap" },
        { "PackageIdentifier": "JanDeDobbeleer.OhMyPosh" },
        { "PackageIdentifier": "Microsoft.OneDrive" },
        { "PackageIdentifier": "VideoLAN.VLC" },
        { "PackageIdentifier": "NordSecurity.NordPass" },
        { "PackageIdentifier": "GoLang.Go" },
        { "PackageIdentifier": "Microsoft.Azd" },
        { "PackageIdentifier": "Microsoft.Azure.DataCLI" },
        { "PackageIdentifier": "7zip.7zip" },
        { "PackageIdentifier": "Microsoft.DotNet.SDK.7" },
        { "PackageIdentifier": "Microsoft.VCRedist.2012.x86" },
        { "PackageIdentifier": "Rustlang.Rust.GNU" },
        { "PackageIdentifier": "Microsoft.VisualStudioCode" },
        { "PackageIdentifier": "Microsoft.Bicep" },
        { "PackageIdentifier": "SomePythonThings.WingetUIStore" },
        { "PackageIdentifier": "Microsoft.VCRedist.2008.x86" },
        { "PackageIdentifier": "Microsoft.VCRedist.2013.x86" },
        { "PackageIdentifier": "Microsoft.AzureCLI" },
        { "PackageIdentifier": "OpenJS.NodeJS" },
        { "PackageIdentifier": "Microsoft.VCRedist.2010.x86" },
        { "PackageIdentifier": "Puppet.pdk" }
      ],
      "SourceDetails": {
        "Argument": "https://cdn.winget.microsoft.com/cache",
        "Identifier": "Microsoft.Winget.Source_8wekyb3d8bbwe",
        "Name": "winget",
        "Type": "Microsoft.PreIndexed.Package"
      }
    },
    {
      "Packages": [
        { "PackageIdentifier": "XPDP273C0XHQH2" }
      ],
      "SourceDetails": {
        "Argument": "https://storeedgefd.dsx.mp.microsoft.com/v9.0",
        "Identifier": "StoreEdgeFD",
        "Name": "msstore",
        "Type": "Microsoft.Rest"
      }
    }
  ],
  "WinGetVersion": "1.6.1573-preview"
}
```

---

## Install All Tools from the List

```powershell
winget import -i myinstall.json
```

---

## Real-Life DevOps Usage
- Use this import file to quickly set up a new Windows DevOps workstation or CI runner
- Add or remove tools as your stack evolves (e.g., add AWS CLI, GCP SDK, Docker Desktop)
- Use `winget upgrade --all` to keep all tools current
- Integrate with onboarding scripts for new engineers

---

## References
- [Winget Documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
- [Winget Package Search](https://winget.run/)
- [Winget Import/Export](https://learn.microsoft.com/en-us/windows/package-manager/winget/import)
