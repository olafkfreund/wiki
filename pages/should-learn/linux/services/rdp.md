# RDP (Remote Desktop Protocol) on Linux

RDP allows remote graphical access to Linux systems, commonly used for DevOps, cloud VMs, and hybrid environments. Below are step-by-step instructions for enabling RDP on Ubuntu/Debian and NixOS, including Azure CLI and VSCode installation for cloud workflows.

---

## Ubuntu/Debian: RDP Setup Script

```bash
#!/bin/bash
set -e

# Update and upgrade system
sudo apt-get update && sudo apt-get -y upgrade

# Install GNOME desktop
sudo apt-get install -y ubuntu-gnome-desktop

# Install xrdp
sudo apt-get install -y xrdp

# Allow all users to start X sessions
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Start/restart xrdp service
sudo systemctl restart xrdp

# Install Azure CLI
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update && sudo apt-get install -y azure-cli
logger -t devvm "Azure CLI installed: $?"

# Install VSCode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update
sudo apt-get install -y code
logger -t devvm "VSCode Installed: $?"
logger -t devvm "Success"
```

---

## NixOS: RDP Configuration Example

On NixOS, use the declarative configuration system to enable xrdp and a desktop environment. Add the following to your `/etc/nixos/configuration.nix`:

```nix
# Enable xrdp and GNOME desktop on NixOS
{ config, pkgs, ... }:
{
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome"; # or "plasma5", "xfce"
  services.xrdp.openFirewall = true;

  # Enable GNOME desktop
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # (Optional) Allow password authentication for RDP
  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "yourpassword"; # Use hashedPassword for production
  };
}
```

After editing, apply the changes:
```sh
sudo nixos-rebuild switch
```

**Connect using an RDP client to `hostname:3389` with your username and password.**

---

## Best Practices
- Use strong passwords or SSH key authentication for remote access.
- Restrict RDP access to trusted IPs using firewalls or cloud security groups.
- For cloud VMs (AWS, Azure, GCP), open port 3389 only as needed.
- Use declarative configuration (NixOS) for reproducible infrastructure.

---

## References
- [xrdp on Ubuntu](https://ubuntu.com/server/docs/service-xrdp)
- [NixOS xrdp Module](https://search.nixos.org/options?channel=unstable&show=services.xrdp.enable)
- [Azure CLI Install Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [VSCode Linux Install](https://code.visualstudio.com/docs/setup/linux)

---

> **Tip:** For automated cloud deployments, use Terraform or Ansible to provision and configure RDP and desktop environments as part of your infrastructure pipeline.
