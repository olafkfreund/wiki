---
description: >-
  The Azure CLI is a cross-platform command-line tool that can be installed
  locally on Linux computers. You can use the Azure CLI on Linux to connect to
  Azure and execute administrative commands.
---

# AZ-CLI

Install on Fedora

{% code overflow="wrap" fullWidth="false" %}
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install azure-cli

```plaintext
{% endcode %}

Proxy settings if needed:

```bash
# No auth
export HTTP_PROXY=http://[proxy]:[port]
export HTTPS_PROXY=https://[proxy]:[port]

# Basic auth
export HTTP_PROXY=http://[username]:[password]@[proxy]:[port]
export HTTPS_PROXY=https://[username]:[password]@[proxy]:[port]
```plaintext

Docker/Podman

```bash
docker run -it mcr.microsoft.com/azure-cli
```plaintext

If you want to pick up the SSH keys from your user environment, use `-v ${HOME}/.ssh:/root/.ssh` to mount your SSH keys in the environment.

```bash
docker run -it -v ${HOME}/.ssh:/root/.ssh mcr.microsoft.com/azure-cli
```plaintext

Windows:

```powershell
winget install -e --id Microsoft.AzureCLI
```plaintext

Great source for examples:

[https://github.com/Azure-Samples/azure-cli-samples/blob/master/virtual-machine/copy-snapshots-to-storage-account/copy-snapshots-to-storage-account.sh](https://github.com/Azure-Samples/azure-cli-samples/blob/master/virtual-machine/copy-snapshots-to-storage-account/copy-snapshots-to-storage-account.sh)
