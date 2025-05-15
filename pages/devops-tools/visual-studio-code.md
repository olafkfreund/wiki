---
description: 'Install and configure Visual Studio Code for Fedora, Ubuntu/WSL, and NixOS. Includes DevOps/LLM usage tips and best practices.'
---

# Visual Studio Code

Visual Studio Code (VS Code) is a popular, cross-platform code editor with rich support for DevOps, cloud, and LLM workflows. Below are installation steps for Fedora, Ubuntu/WSL, and NixOS, plus real-life engineering tips.

---

## Installation

### Fedora
Install the Microsoft repo:
```sh
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
```
Update and install:
```bash
dnf check-update
sudo dnf install -y code
```

### Ubuntu/WSL
```bash
sudo apt update
sudo apt install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ vscode ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

---

## Nerd Font Configuration (for a great terminal look)
Add to your VS Code `settings.json`:
```json
{
  "terminal.integrated.fontFamily": "'CaskaydiaCove Nerd Font Mono'",
  "editor.fontLigatures": true,
  "terminal.integrated.gpuAcceleration": "canvas",
  "terminal.integrated.lineHeight": 1.3,
  "azureTerraform.terminal": "integrated"
}
```

---

## Real-Life DevOps & LLM Usage Tips
- Install extensions: Docker, Kubernetes, Terraform, Ansible, GitHub Copilot, Azure CLI, AWS Toolkit, Google Cloud Code
- Use Remote - SSH or Remote - Containers for cloud/devbox workflows
- Use GitHub Copilot or Claude for code/infra suggestions and documentation
- Integrate with GitHub Actions, Azure Pipelines, or GitLab CI/CD for automation
- Use built-in terminal for running CLI tools (az, aws, gcloud, kubectl, terraform)

---

## Best Practices
- Sync settings and extensions with a Microsoft or GitHub account
- Use workspaces for multi-repo or multi-cloud projects
- Keep VS Code and extensions up to date
- Use keyboard shortcuts for productivity (see Help > Keyboard Shortcuts)
- Review and validate LLM-generated code before deploying

---

## References
- [VS Code Docs](https://code.visualstudio.com/docs)
- [VS Code Marketplace](https://marketplace.visualstudio.com/vscode)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [GitHub Copilot](https://github.com/features/copilot)
