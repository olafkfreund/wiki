---
description: Using nixos-generators to build images for Azure VM and QEMU
---

# NixOS Generators: Azure VM & QEMU Image Creation

[nixos-generators](https://github.com/nix-community/nixos-generators) is a tool to build NixOS images for various platforms, including Azure and QEMU. This guide covers how to generate images for both.

## Prerequisites

- Nix installed with flakes enabled
- nixos-generators installed (as a flake or via `nix run`)

## General Usage

You can use nixos-generators as a flake or with `nix run`:

```bash
nix run github:nix-community/nixos-generators -- --format <format> [options]
```

Or with flakes:

```bash
nix build github:nix-community/nixos-generators#nixos-generate -- --format <format> [options]
```

## 1. Generate a NixOS Image for Azure VM

Azure uses the VHD format. You can generate a VHD image as follows:

```bash
nix run github:nix-community/nixos-generators -- --format azure -c /etc/nixos/configuration.nix
```

- The output will be a `.vhd` file, which you can upload to Azure as a managed disk or custom image.
- You can specify a custom configuration with `-c` or use the default.

### Uploading the VHD to Azure

```bash
# Upload to Azure Storage
az storage blob upload \
  --account-name <storage-account> \
  --container-name <container> \
  --name nixos-custom.vhd \
  --file ./result/nixos.vhd \
  --type page

# Create a managed disk from the VHD
az disk create \
  --resource-group <resource-group> \
  --name nixos-disk \
  --source https://<storage-account>.blob.core.windows.net/<container>/nixos-custom.vhd

# Create a VM from the managed disk
az vm create \
  --resource-group <resource-group> \
  --name nixos-vm \
  --attach-os-disk nixos-disk \
  --os-type linux
```

## 2. Generate a NixOS Image for QEMU

QEMU uses the `qcow2` format. To generate a QEMU image:

```bash
nix run github:nix-community/nixos-generators -- --format qcow2 -c /etc/nixos/configuration.nix
```

- The output will be a `.qcow2` file, which you can use directly with QEMU or other virtualization tools.

### Running the Image with QEMU

```bash
qemu-system-x86_64 -m 2048 -drive file=./result/nixos.qcow2,format=qcow2 -nographic
```

## Customizing the Configuration

You can pass a custom NixOS configuration file with the `-c` flag. For example:

```bash
nix run github:nix-community/nixos-generators -- --format azure -c ./my-azure-config.nix
```

## References

- [nixos-generators GitHub](https://github.com/nix-community/nixos-generators)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [QEMU Documentation](https://www.qemu.org/docs/)
