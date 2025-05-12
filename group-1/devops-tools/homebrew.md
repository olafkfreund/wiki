---
description: Homebrew for Fedora
---

# Homebrew

Prerequisites for installing Homebrew on Fedora:

```bash
sudo dnf groupinstall "Development Tools"
```plaintext

Install Homebrew by running the following command in a terminal:

{% code overflow="wrap" lineNumbers="true" %}
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```plaintext
{% endcode %}

Once finished, run the following commands to add brew to your PATH:

{% code overflow="wrap" lineNumbers="true" %}
```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```plaintext
{% endcode %}
