# Installing NixOS: PC, Mac (Darwin), and WSL

NixOS can be installed on bare metal, in a VM, on macOS (via nix-darwin), and even inside Windows (via WSL). This guide covers all major scenarios with examples and configuration tips.

---

## 1. Install NixOS on a PC (Bare Metal or VM)

### Download and Boot
- Download the latest ISO: https://nixos.org/download.html
- Write to USB: `sudo dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress`
- Boot from USB and select "Install NixOS."

### Partition, Format, and Mount
Example (UEFI, single disk):
```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 2 esp on
mkfs.ext4 /dev/sda1
mkfs.fat -F 32 /dev/sda2
mount /dev/sda1 /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
```

### Generate and Edit Configuration
```bash
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix
```
Example minimal config:
```nix
{ config, pkgs, ... }:
{
  imports = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos";
  time.timeZone = "Europe/Berlin";
  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = ""; # Set with passwd after install
  };
  environment.systemPackages = with pkgs; [ vim git wget ];
  services.openssh.enable = true;
}
```

### Install and Reboot
```bash
nixos-install
reboot
```

---

## 2. Install NixOS in a VM
- Use any hypervisor (VirtualBox, VMware, QEMU, Parallels, etc.).
- Attach the ISO, follow the same steps as above.
- For QEMU (Linux):
```bash
qemu-img create -f qcow2 nixos.img 20G
qemu-system-x86_64 -m 4096 -enable-kvm -cdrom nixos.iso -boot d -drive file=nixos.img,format=qcow2
```

---

## 3. Nix on macOS (nix-darwin)

### Install Nix Package Manager
```bash
sh <(curl -L https://nixos.org/nix/install)
```

### Install nix-darwin
```bash
nix run github:LnL7/nix-darwin --extra-experimental-features 'nix-command flakes'
```

### Example `~/.nixpkgs/darwin-configuration.nix`
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ git vim htop ];
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
}
```

Apply config:
```bash
darwin-rebuild switch
```

---

## 4. NixOS on WSL (Windows Subsystem for Linux)

### Install NixOS-WSL
- Prerequisite: WSL2 enabled, Ubuntu or other WSL Linux installed.
- Install NixOS-WSL:
```bash
wsl --import NixOS C:\WSL\NixOS https://github.com/nix-community/NixOS-WSL/releases/latest/download/rootfs.tar.gz
wsl -d NixOS
```

### Configure NixOS-WSL
Edit `/etc/nixos/configuration.nix` as usual. Example:
```nix
{ config, pkgs, ... }:
{
  networking.hostName = "nixos-wsl";
  environment.systemPackages = with pkgs; [ git vim curl ];
  services.openssh.enable = true;
  wsl.enable = true;
}
```
Apply changes:
```bash
sudo nixos-rebuild switch
```

---

## References
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
- [NixOS Wiki: Installation Guide](https://nixos.wiki/wiki/Installation_Guide)

NixOS can be run and managed on nearly any platform, with full reproducibility and declarative configuration.
