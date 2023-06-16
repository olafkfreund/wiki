# Scoop for Windows

Install scoop with PowerShell:

{% code overflow="wrap" lineNumbers="true" %}
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex
```
{% endcode %}

Example use:

```powershell
scoop bucket add nerd-fonts 
```
