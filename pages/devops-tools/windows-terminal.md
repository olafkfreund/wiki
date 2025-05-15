---
description: Terminal for running WSL, PowerShell, and DevOps tools in Windows 11/10. Updated for 2025 with best practices, font configuration, and real-life DevOps usage.
---

# Windows Terminal (2025)

Windows Terminal is a modern, customizable terminal for running WSL, PowerShell, Azure CLI, and other DevOps tools on Windows. It is essential for engineers working in hybrid or cloud-native environments.

---

## Installation

Install Windows Terminal using winget:
```powershell
winget install --id Microsoft.WindowsTerminal -e
```

---

## Configure Nerd Fonts for DevOps Workflows

Download and install a Nerd Font (for icons and better prompt rendering):
```powershell
curl.exe -O -J -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip
Expand-Archive .\CascadiaCode.zip -DestinationPath $env:USERPROFILE\Fonts
```

- Open **Settings > Personalization > Fonts** and install the font if not auto-installed.
- In Windows Terminal, go to **Settings > Profiles > Defaults > Appearance** and set the font to `CaskaydiaCove Nerd Font Mono`.

---

## Real-Life DevOps Usage
- Run WSL (Ubuntu, NixOS), PowerShell, Azure CLI, AWS CLI, and gcloud in tabs or panes
- Use with Oh My Posh for a cloud-aware, Git-enabled prompt
- Integrate with VS Code for seamless terminal/editor workflows
- Use with tmux or byobu for multiplexed sessions
- Run automation scripts for IaC, Kubernetes, and CI/CD pipelines

---

## Best Practices (2025)
- Use Windows Terminal as your default terminal for all shells (WSL, PowerShell, Command Prompt)
- Sync settings with your Microsoft account for portability
- Use Nerd Fonts for improved prompt and LLM (Copilot, Claude) output
- Customize key bindings and color schemes for productivity
- Keep Windows Terminal and fonts up to date

## Common Pitfalls
- Not setting the correct font in Windows Terminal settings (icons may not render)
- Forgetting to install the font for all users if using multiple accounts
- Not updating Windows Terminal, missing new features and bug fixes

---

## References
- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Oh My Posh](https://ohmyposh.dev/)
