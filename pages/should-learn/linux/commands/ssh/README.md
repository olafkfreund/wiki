# Ssh

## What is SSH?

SSH (Secure Shell) is a cryptographic network protocol for securely operating network services over an unsecured network. It is most commonly used to provide secure remote access to Linux and Unix-like systems, but also supports tunneling, file transfers, and more.

## History

SSH was developed in 1995 by Tatu Ylönen as a secure replacement for older protocols like Telnet, rlogin, and FTP, which transmitted data (including passwords) in plaintext. SSH quickly became the industry standard for secure remote administration and is now included by default in nearly all Linux distributions and cloud environments (AWS, Azure, GCP).

## What Can SSH Do?

- **Remote Shell Access:** Securely log in to remote servers and manage them interactively.
- **File Transfer:** Copy files securely using `scp` (Secure Copy) or `sftp` (SSH File Transfer Protocol).
- **Port Forwarding/Tunneling:** Forward local or remote ports to securely access internal services, databases, or web UIs (see [Port Forwarding and Proxying Using OpenSSH](./port-forwarding-and-proxying-using-openssh.md)).
- **Proxying:** Route network traffic through SSH for secure access to private networks.
- **Automation:** Use SSH in scripts, Ansible, Terraform, and CI/CD pipelines for remote command execution and configuration management.
- **Key-Based Authentication:** Use SSH keys for passwordless, secure authentication and automation.
- **Agent Forwarding:** Forward your SSH agent to remote hosts for secure key management during multi-hop connections.
- **Jump Hosts (Bastion):** Access private infrastructure securely via a public-facing SSH server.

## Best Practices

- Always use SSH keys instead of passwords for authentication.
- Restrict SSH access using firewalls, security groups, and allow-lists.
- Regularly rotate SSH keys and audit authorized keys on servers.
- Use SSH config (`~/.ssh/config`) to manage multiple hosts and advanced connection options.

## References

- [OpenSSH Manual](https://man.openbsd.org/ssh)
- [SSH Config Guide](./how-to-use-ssh-config.md)

> **Tip:** SSH is foundational for DevOps automation, secure cloud access, and infrastructure management. Mastering SSH is essential for any cloud or Linux engineer.
