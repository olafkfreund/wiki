# How to Use SSH Config

Efficient SSH configuration is essential for DevOps engineers managing cloud infrastructure (AWS, Azure, GCP) and automating secure connections. This guide covers practical SSH config usage, real-world examples, and best practices.

---

## What is the SSH Config File?
- Located at `~/.ssh/config`
- Allows you to define connection settings for multiple hosts
- Simplifies SSH commands and enables advanced features (jump hosts, key management, etc.)

If the file does not exist, create it:

```bash
touch ~/.ssh/config
chmod 600 ~/.ssh/config  # Secure the config file
```

---

## Basic SSH Config Structure

```ssh-config
Host <alias>
  HostName <server_ip_or_dns>
  User <username>
  IdentityFile <path_to_private_key>
```

**Example: Connect to an AWS EC2 instance**

```ssh-config
Host nano-server
  HostName 174.129.141.81
  User ubuntu
  IdentityFile ~/t3_nano_ssh_aws_keys.pem
```

Now connect with:

```bash
ssh nano-server
```

---

## Multiple Hosts and Wildcards

You can define multiple hosts and use wildcards for bulk configuration.

```ssh-config
Host dev-*
  User devuser
  IdentityFile ~/.ssh/dev.pem

Host prod-server
  HostName 10.0.0.10
  User ubuntu
  IdentityFile ~/.ssh/prod.pem

Host ?-server
  User generic

Host !prod-server
  LogLevel DEBUG

Host *-server
  IdentityFile ~/.ssh/low-security.pem
```

- `*` matches any number of characters (e.g., `dev-*` for all dev servers)
- `?` matches a single character (e.g., `?-server`)
- `!` negates a match (e.g., `!prod-server`)

---

## Real-World DevOps Examples

### 1. Use a Jump Host (Bastion)
```ssh-config
Host private-server
  HostName 10.0.1.5
  User ec2-user
  ProxyJump bastion-host

Host bastion-host
  HostName 54.12.34.56
  User ec2-user
  IdentityFile ~/.ssh/bastion.pem
```

### 2. Use Different Keys for Different Clouds
```ssh-config
Host aws-*
  IdentityFile ~/.ssh/aws.pem
Host azure-*
  IdentityFile ~/.ssh/azure.pem
Host gcp-*
  IdentityFile ~/.ssh/gcp.pem
```

### 3. Forward SSH Agent for Git Operations
```ssh-config
Host github.com
  User git
  ForwardAgent yes
```

---

## Best Practices
- Always set permissions: `chmod 600 ~/.ssh/config`
- Use descriptive aliases for hosts
- Use wildcards to avoid repetition
- Never commit private keys or sensitive config to version control
- Use `ProxyJump` for secure access to private networks
- Document your config for team use

---

## References
- [SSH Config File Documentation](https://man.openbsd.org/ssh_config)
- [SSH Wildcards and Patterns](https://www.ssh.com/academy/ssh/config)

---

> **Tip:** Use SSH config to simplify Ansible, Terraform, and cloud CLI workflows by referencing host aliases instead of full connection strings.

---

## Add to SUMMARY.md

```markdown
- [How to Use SSH Config](pages/should-learn/linux/commands/ssh/how-to-use-ssh-config.md)
```
