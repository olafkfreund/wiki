---
description: 'Install and use bat, a modern alternative to cat, on Fedora, Ubuntu, NixOS, and WSL. Includes DevOps usage examples and best practices.'
---

# Bat: A Modern Alternative to cat

[bat](https://github.com/sharkdp/bat) is a feature-rich, cross-platform replacement for `cat` that provides syntax highlighting, Git integration, and more. It's useful for DevOps engineers who need to quickly inspect files, logs, and configuration with better readability.

---

## Installation

### Fedora
```bash
sudo dnf install bat
```

### Ubuntu/Debian/WSL
```bash
sudo apt-get update
sudo apt-get install bat
# On Ubuntu, the binary is called 'batcat' by default
# Add an alias for convenience:
echo 'alias bat="batcat"' >> ~/.bashrc
source ~/.bashrc
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ bat ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

---

## Real-Life DevOps Usage Examples

- View logs with syntax highlighting:
  ```bash
  bat /var/log/syslog
  bat /var/log/nginx/access.log
  ```
- Compare configuration files with Git integration:
  ```bash
  bat --diff ~/.kube/config
  ```
- Preview YAML/JSON for Kubernetes or Terraform:
  ```bash
  bat deployment.yaml
  bat main.tf
  ```
- Use in scripts for better output:
  ```bash
  bat config.yaml || cat config.yaml
  ```

---

## Best Practices
- Use `bat` for quick, readable file inspection in CI/CD logs and troubleshooting
- Set up an alias if your distro uses `batcat` as the binary name
- Integrate with LLMs (e.g., Copilot, Claude) to review and explain config/log output
- Use `--style=plain` for machine-readable output in scripts

## Common Pitfalls
- On Ubuntu/WSL, the binary is `batcat` (not `bat`) unless aliased
- Large files may be slow to render with syntax highlighting

---

## References
- [bat GitHub](https://github.com/sharkdp/bat)
- [bat Manual](https://github.com/sharkdp/bat#manual)
