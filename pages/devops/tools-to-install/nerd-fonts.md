---
description: Install Nerd Fonts on Fedora
---

# Nerd Fonts

## Installation with GetNF

Use the GetNF tool to install NF

### Method 1: Manual clone and install

```bash
git clone https://github.com/getnf/getnf.git
cd getnf
./install.sh
```

### Method 2: One-command installation

Or with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash -s -- --silent
```

## Fedora-specific Installation Methods

### Using DNF with COPR Repository

```bash
# Enable the COPR repository for Nerd Fonts
sudo dnf copr enable atim/nerd-fonts

# Install specific Nerd Fonts (examples)
sudo dnf install nerd-fonts-fira-code
sudo dnf install nerd-fonts-hack
sudo dnf install nerd-fonts-jetbrains-mono
sudo dnf install nerd-fonts-source-code-pro

# Or install multiple fonts at once
sudo dnf install nerd-fonts-fira-code nerd-fonts-hack nerd-fonts-jetbrains-mono
```

### Manual Installation on Fedora

```bash
# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download and extract your preferred Nerd Font (example with JetBrainsMono)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
rm JetBrainsMono.zip

# Update font cache
fc-cache -fv
```

### Using RPM Fusion (if available)

Some Nerd Fonts might be available through RPM Fusion:

```bash
# Enable RPM Fusion repositories if not already enabled
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install fonts (check availability)
sudo dnf search nerd-fonts
```

