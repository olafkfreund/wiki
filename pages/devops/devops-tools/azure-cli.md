---
description: Azure-CLI on Fedora
---

# Azure-cli

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```plaintext

{% code overflow="wrap" %}
```bash
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
```plaintext
{% endcode %}

{% code overflow="wrap" %}
```bash
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
```plaintext
{% endcode %}

```bash
sudo dnf install azure-cli
```plaintext

When installed use: `az login --use-device-code`
