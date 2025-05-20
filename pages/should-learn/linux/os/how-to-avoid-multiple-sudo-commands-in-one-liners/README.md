# How to Avoid Multiple `sudo` Commands in One-Liners

Efficient use of `sudo` is essential for DevOps engineers working in Linux, WSL, or cloud environments (AWS, Azure, GCP). Repeatedly typing `sudo` in one-liners is error-prone and slows down automation. This guide shows how to streamline privilege escalation in scripts and one-liners using best practices.

---

## Problem: Repeating `sudo` in One-Liners

A common anti-pattern:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

This will prompt for your password twice if your session times out, and is verbose.

---

## Solution: Use a Single `sudo` with Here Strings

A [here string](https://www.gnu.org/software/bash/manual/html_node/Redirections.html) in Bash allows you to pass a string as standard input to a command. You can use this to run multiple commands in a single `sudo` session:

### One-Liner Example

```bash
sudo -s <<< 'apt-get update -y && apt-get upgrade -y'
```

- Only prompts for your password once
- All commands run as root in a single shell

### Multi-Line Example

For longer scripts, you can span multiple lines:

```bash
sudo -s <<< 'apt-get update -y
apt-get upgrade -y'
```

Or use a here document for more complex scripts:

```bash
sudo bash <<'EOF'
apt-get update -y
apt-get upgrade -y
EOF
```

---

## Real-World DevOps Examples

### 1. Automate Package Updates in CI/CD

```yaml
# GitHub Actions example
- name: Update packages
  run: |
    sudo -s <<< 'apt-get update -y && apt-get upgrade -y'
```

### 2. Provision Cloud VMs with Terraform/Ansible

```hcl
# Terraform remote-exec provisioner
provisioner "remote-exec" {
  inline = [
    "sudo -s <<< 'apt-get update -y && apt-get install -y nginx'"
  ]
}
```

### 3. Kubernetes Init Containers

```yaml
initContainers:
  - name: setup
    image: ubuntu
    command: ["bash", "-c", "sudo -s <<< 'apt-get update -y && apt-get install -y curl'"]
```

---

## Best Practices

- Use a single `sudo` session for related commands to reduce prompts and errors
- Prefer here documents for complex or multi-line scripts
- Avoid using `sudo` in scripts run as root (e.g., in Dockerfiles or root-owned CI jobs)
- Always validate your commands in a test environment before production

---

## References

- [Bash Redirections Manual](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [Linux sudo man page](https://man7.org/linux/man-pages/man8/sudo.8.html)

---

> **Tip:** For persistent root shells, use `sudo -i` or `sudo su -`, but be cautious with interactive sessions in automation.

---

## Add to SUMMARY.md

```markdown
- [How to Avoid Multiple sudo Commands in One-Liners](pages/should-learn/linux/os/how-to-avoid-multiple-sudo-commands-in-one-liners/README.md)
```
