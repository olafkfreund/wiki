---
description: LunarVim on Fedora
---

# Lunarvim

Prerequisites for installing lvim on Fedora:

{% code overflow="wrap" lineNumbers="true" %}
```bash
sudo dnf update
sudo dnf install git make pip python npm node cargo lazygit
```plaintext
{% endcode %}

Install Lvim:

{% code overflow="wrap" lineNumbers="true" %}
```bash
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
```plaintext
{% endcode %}

Or try it with docker/podman

{% code overflow="wrap" lineNumbers="true" %}
```bash
docker run -w /root -it --rm alpine:edge sh -uelic 'apk add git neovim ripgrep alpine-sdk bash --update && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) && /root/.local/bin/lvim'
podman run -w /root -it --rm alpine:edge sh -uelic 'apk add git neovim ripgrep alpine-sdk bash --update && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) && /root/.local/bin/lvim'
```plaintext
{% endcode %}

Lunarvim for Windows:

Prerequisite for running Lunarvim on Windows

```plaintext
winget install git make pip python npm node cargo lazygit
```plaintext

{% code overflow="wrap" lineNumbers="true" %}
```powershell
pwsh -c "`$LV_BRANCH='release-1.3/neovim-0.9'; iwr https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.ps1 -UseBasicParsing | iex"
```plaintext
{% endcode %}

