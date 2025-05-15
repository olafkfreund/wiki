---
description: LunarVim installation and usage for Fedora, Ubuntu/WSL, NixOS, Docker/Podman, and Windows. Includes DevOps/LLM usage tips and best practices.
---

# LunarVim

LunarVim (lvim) is a modern, extensible Neovim configuration for engineers and DevOps teams. It supports Linux (Fedora, Ubuntu, NixOS), WSL, Docker/Podman, and Windows.

---

## Prerequisites

### Fedora
```bash
sudo dnf update
sudo dnf install git make pip python npm node cargo lazygit
```

### Ubuntu/WSL
```bash
sudo apt update
sudo apt install -y git make python3-pip python3 npm nodejs cargo lazygit
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ git make python3 pipx nodejs npm cargo lazygit neovim ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

---

## Install LunarVim

### Linux/WSL/NixOS
```bash
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
```

---

## Run with Docker/Podman (Ephemeral)

> Useful for testing or demo environments. Requires Docker or Podman installed.

```bash
docker run -w /root -it --rm alpine:edge sh -uelic 'apk add git neovim ripgrep alpine-sdk bash --update && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) && /root/.local/bin/lvim'
podman run -w /root -it --rm alpine:edge sh -uelic 'apk add git neovim ripgrep alpine-sdk bash --update && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) && /root/.local/bin/lvim'
```

---

## Windows

### Prerequisites
```powershell
winget install git make pip python npm node cargo lazygit
```

### Install LunarVim
```powershell
pwsh -c "$LV_BRANCH='release-1.3/neovim-0.9'; iwr https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.ps1 -UseBasicParsing | iex"
```

---

## Real-Life DevOps & LLM Usage Tips
- Use LunarVim for editing IaC (Terraform, Bicep), Kubernetes YAML, and CI/CD configs
- Install LSPs and plugins for cloud (AWS, Azure, GCP), Docker, and Kubernetes
- Use GitHub Copilot or Claude for code/infra suggestions and documentation
- Integrate with Git for version control and code review
- Use in containers for ephemeral, reproducible dev environments

---

## Best Practices
- Keep LunarVim and plugins up to date
- Use a dotfiles repo for sharing configs across machines
- Validate LLM-generated code before deploying
- Use containerized LunarVim for isolated, disposable environments

---

## References
- [LunarVim Docs](https://www.lunarvim.org/docs/)
- [LunarVim GitHub](https://github.com/LunarVim/LunarVim)
- [Neovim](https://neovim.io/)
- [GitHub Copilot](https://github.com/features/copilot)

