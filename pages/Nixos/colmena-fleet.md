---
description: Deploying a fleet of NixOS servers with Colmena
---

# Deploying a Fleet of NixOS Servers with Colmena

[Colmena](https://github.com/zhaofengli/colmena) is a simple, fast, and flexible NixOS configuration and deployment tool for managing fleets of NixOS machines. It is similar to NixOps but is more lightweight and uses SSH for remote deployment.

## Why use Colmena?
- **Declarative fleet management**: Manage many NixOS hosts from a single configuration.
- **Fast and parallel**: Builds and deploys in parallel over SSH.
- **Flexible**: Supports per-host and shared configuration.
- **No daemon**: Just a CLI tool, no persistent service required.

## Installation

```bash
nix profile install github:zhaofengli/colmena
# Or with flakes
nix run github:zhaofengli/colmena -- --help
```

## Example: Deploying a Fleet

Suppose you want to manage three NixOS servers: `web1`, `web2`, and `db1`.

### 1. Project Structure
```
colmena-fleet/
├── colmena.nix
├── hosts/
│   ├── web1.nix
│   ├── web2.nix
│   └── db1.nix
└── shared.nix
```

### 2. Example `colmena.nix`
```nix
{ pkgs, ... }:
{
  meta = {
    nixpkgs = import <nixpkgs> {};
    nodeNixpkgs = {
      web1 = import <nixpkgs> {};
      web2 = import <nixpkgs> {};
      db1 = import <nixpkgs> {};
    };
  };

  defaults = import ./shared.nix;

  web1 = { name, ... }: {
    imports = [ ./hosts/web1.nix ];
    deployment.targetHost = "web1.example.com";
  };
  web2 = { name, ... }: {
    imports = [ ./hosts/web2.nix ];
    deployment.targetHost = "web2.example.com";
  };
  db1 = { name, ... }: {
    imports = [ ./hosts/db1.nix ];
    deployment.targetHost = "db1.example.com";
  };
}
```

### 3. Example `shared.nix`
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ vim git htop ];
  services.openssh.enable = true;
  users.users.deploy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3..." ]; # Replace with your key
  };
}
```

### 4. Example `hosts/web1.nix`
```nix
{ config, pkgs, ... }:
{
  networking.hostName = "web1";
  services.nginx.enable = true;
}
```

### 5. Example `hosts/web2.nix`
```nix
{ config, pkgs, ... }:
{
  networking.hostName = "web2";
  services.nginx.enable = true;
}
```

### 6. Example `hosts/db1.nix`
```nix
{ config, pkgs, ... }:
{
  networking.hostName = "db1";
  services.postgresql.enable = true;
}
```

## Deploying the Fleet

1. **Check the deployment plan:**
   ```bash
   colmena apply --show-trace
   ```
2. **Deploy to all hosts:**
   ```bash
   colmena apply
   ```
3. **Deploy to a single host:**
   ```bash
   colmena apply --on web1
   ```

Colmena will build the configurations and deploy them over SSH to each target host.

## References
- [Colmena GitHub](https://github.com/zhaofengli/colmena)
- [Colmena Manual](https://colmena.cli.rs/manual.html)
- [NixOS Wiki: Colmena](https://nixos.wiki/wiki/Colmena)
