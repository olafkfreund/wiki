# GitHub Copilot Installation Guide

This guide covers how to install GitHub Copilot on various platforms with a focus on Linux environments.

## Prerequisites

- GitHub account with Copilot subscription (individual or enterprise)
- Internet connection

## VS Code Installation

### Standard Linux Installation

1. Open VS Code
2. Navigate to Extensions (Ctrl+Shift+X)
3. Search for "GitHub Copilot"
4. Click "Install"
5. After installation, click "Sign in" and authenticate with your GitHub account

```bash
# Alternatively, you can install via the command line
code --install-extension GitHub.copilot
```

### NixOS Installation

For NixOS users, you can add GitHub Copilot to your system configuration:

1. Add VS Code with the Copilot extension to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        github.copilot
        # Add other extensions as needed
      ];
    })
  ];
}
```

2. Alternatively, using Home Manager:

```nix
{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      # Other extensions
    ];
  };
}
```

3. Apply the configuration:

```bash
sudo nixos-rebuild switch  # For system-wide configuration
home-manager switch        # For Home Manager configuration
```

### WSL Installation

GitHub Copilot in WSL works through VS Code's remote development:

1. Install VS Code on your Windows host system
2. Install the "Remote - WSL" extension in VS Code
3. Open VS Code, connect to your WSL instance
4. Once connected to WSL, install the GitHub Copilot extension
5. Sign in to GitHub when prompted

## JetBrains IDEs Installation

1. Open your JetBrains IDE (IntelliJ IDEA, PyCharm, etc.)
2. Go to File > Settings > Plugins (or Preferences > Plugins on macOS)
3. Search for "GitHub Copilot"
4. Click "Install"
5. Restart the IDE when prompted
6. Sign in to GitHub when prompted after restart

## GitHub Copilot CLI Installation

The GitHub Copilot CLI provides AI-powered assistance directly in your terminal.

### Standard Linux Installation

```bash
# Install with npm
npm install -g @githubnext/github-copilot-cli

# Authenticate
gh auth login
gh copilot auth login
```

### NixOS Installation

For NixOS users, you can create a custom package or use a flake:

```nix
# In your flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add other inputs as needed
  };

  outputs = { self, nixpkgs }: {
    # Define your outputs
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        nodejs_20
        nodePackages.npm
      ];
      shellHook = ''
        if ! command -v gh-copilot &> /dev/null; then
          echo "Installing GitHub Copilot CLI..."
          npm install -g @githubnext/github-copilot-cli
        fi
      '';
    };
  };
}
```

### WSL Installation

In your WSL Linux distribution:

```bash
# Install Node.js and npm
sudo apt update
sudo apt install -y nodejs npm

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Install GitHub Copilot CLI
npm install -g @githubnext/github-copilot-cli

# Authenticate
gh auth login
gh copilot auth login
```

## Verification

To verify that GitHub Copilot is properly installed:

### VS Code
1. Open a code file in a supported language
2. Start typing a comment describing what you want to do
3. Copilot should offer suggestions that you can accept with Tab

### CLI
Run the following command to verify the CLI installation:

```bash
gh copilot explain "ls -la | grep '^d'"
```

## Troubleshooting

### Common Issues

1. **Authentication Problems**
   - Ensure you have an active GitHub Copilot subscription
   - Try signing out and signing back in

2. **No Suggestions Appearing**
   - Check if the extension is enabled
   - Verify your internet connection
   - Try restarting your editor

3. **NixOS-Specific Issues**
   - Ensure your Nix expression is properly configured
   - Check if you're using a compatible version of VS Code

4. **WSL Connectivity Issues**
   - Verify that your Windows host can connect to the internet
   - Check if the VS Code server is properly installed in WSL

### Getting Help

- Visit [GitHub Copilot Support](https://github.com/features/copilot)
- Check the [GitHub Copilot documentation](https://docs.github.com/en/copilot)
- For NixOS-specific issues, consult the [NixOS forum](https://discourse.nixos.org/)
