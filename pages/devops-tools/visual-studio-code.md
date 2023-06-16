---
description: 'For Fedora:'
---

# Visual Studio Code

Install the repo

{% code overflow="wrap" lineNumbers="true" %}
```sh
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
```
{% endcode %}

Update the package cache and install

```bash
dnf check-update
sudo dnf install code
```

```bash
dnf update
sudo dnf install -y code
```

Nerd font configuration to make terminal look good :smile:

```json
"terminal.integrated.fontFamily": "'CaskaydiaCove Nerd Font Mono'",
"editor.fontLigatures": true,
"terminal.integrated.gpuAcceleration": "canvas",
"terminal.integrated.lineHeight": 1.3,
"azureTerraform.terminal": "integrated"
```
