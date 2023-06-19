---
description: Azure-CLI on Fedora
---

# Azure-cli

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```

{% code overflow="wrap" %}
```bash
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
```
{% endcode %}

{% code overflow="wrap" %}
```bash
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
```
{% endcode %}

```bash
sudo dnf install azure-cli
```

When installed use: `az login --use-device-code`
