---
description: Install devtools with winget command in Windows.
---

# Winget for Windows

Here is the list.

{% code lineNumbers="true" fullWidth="false" %}
````json
```json
{
	"$schema" : "https://aka.ms/winget-packages.schema.2.0.json",
	"CreationDate" : "2023-06-16T13:47:49.861-00:00",
	"Sources" : 
	[
		{
			"Packages" : 
			[
				{
					"PackageIdentifier" : "Canonical.Ubuntu.2204"
				},
				{
					"PackageIdentifier" : "Derailed.k9s"
				},
				{
					"PackageIdentifier" : "Git.Git"
				},
				{
					"PackageIdentifier" : "Hashicorp.Packer"
				},
				{
					"PackageIdentifier" : "Hashicorp.Terraform"
				},
				{
					"PackageIdentifier" : "JesseDuffield.lazygit"
				},
				{
					"PackageIdentifier" : "kalilinux.kalilinux"
				},
				{
					"PackageIdentifier" : "Kubernetes.kompose"
				},
				{
					"PackageIdentifier" : "Kubernetes.kubectl"
				},
				{
					"PackageIdentifier" : "Microsoft.Edge"
				},
				{
					"PackageIdentifier" : "Microsoft.EdgeWebView2Runtime"
				},
				{
					"PackageIdentifier" : "Microsoft.Azure.AZCopy.10"
				},
				{
					"PackageIdentifier" : "Microsoft.Azure.Kubelogin"
				},
				{
					"PackageIdentifier" : "Microsoft.PowerShell.Preview"
				},
				{
					"PackageIdentifier" : "Microsoft.WindowsTerminal.Preview"
				},
				{
					"PackageIdentifier" : "Microsoft.WindowsTerminal"
				},
				{
					"PackageIdentifier" : "Insecure.Nmap"
				},
				{
					"PackageIdentifier" : "JanDeDobbeleer.OhMyPosh"
				},
				{
					"PackageIdentifier" : "Microsoft.OneDrive"
				},
				{
					"PackageIdentifier" : "VideoLAN.VLC"
				},
				{
					"PackageIdentifier" : "NordSecurity.NordPass"
				},
				{
					"PackageIdentifier" : "GoLang.Go"
				},
				{
					"PackageIdentifier" : "Microsoft.Azd"
				},
				{
					"PackageIdentifier" : "Microsoft.Azure.DataCLI"
				},
				{
					"PackageIdentifier" : "7zip.7zip"
				},
				{
					"PackageIdentifier" : "Microsoft.DotNet.SDK.7"
				},
				{
					"PackageIdentifier" : "Microsoft.VCRedist.2012.x86"
				},
				{
					"PackageIdentifier" : "Rustlang.Rust.GNU"
				},
				{
					"PackageIdentifier" : "Microsoft.VisualStudioCode"
				},
				{
					"PackageIdentifier" : "Microsoft.Bicep"
				},
				{
					"PackageIdentifier" : "SomePythonThings.WingetUIStore"
				},
				{
					"PackageIdentifier" : "Microsoft.VCRedist.2008.x86"
				},
				{
					"PackageIdentifier" : "Microsoft.VCRedist.2013.x86"
				},
				{
					"PackageIdentifier" : "Microsoft.AzureCLI"
				},
				{
					"PackageIdentifier" : "OpenJS.NodeJS"
				},
				{
					"PackageIdentifier" : "Microsoft.VCRedist.2010.x86"
				},
				{
					"PackageIdentifier" : "Puppet.pdk"
				},
			],
			"SourceDetails" : 
			{
				"Argument" : "https://cdn.winget.microsoft.com/cache",
				"Identifier" : "Microsoft.Winget.Source_8wekyb3d8bbwe",
				"Name" : "winget",
				"Type" : "Microsoft.PreIndexed.Package"
			}
		},
		{
			"Packages" : 
			[
				{
					"PackageIdentifier" : "XPDP273C0XHQH2"
				}
			],
			"SourceDetails" : 
			{
				"Argument" : "https://storeedgefd.dsx.mp.microsoft.com/v9.0",
				"Identifier" : "StoreEdgeFD",
				"Name" : "msstore",
				"Type" : "Microsoft.Rest"
			}
		}
	],
	"WinGetVersion" : "1.6.1573-preview"
}

```
````
{% endcode %}

to install from the list, use the command:

```powershell
winget import -i myinstall.json
```
