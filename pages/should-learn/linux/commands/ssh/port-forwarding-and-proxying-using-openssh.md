# Port Forwarding and Proxying Using OpenSSH

SSH port forwarding (tunneling) is a critical technique for DevOps engineers to securely access internal services, databases, and applications across cloud and hybrid environments (AWS, Azure, GCP). This guide covers local, remote, and dynamic forwarding with actionable examples and best practices.

---

## 1. Local Port Forwarding

Forward a local port to a remote service through an SSH server. Useful for accessing internal databases, web UIs, or APIs from your workstation.

**Syntax:**

```bash
ssh -L <local_port>:<destination_host>:<remote_port> <user>@<ssh_server>
```

**Example 1: Forward local port 5050 to remote 4040 via a bastion**

```bash
ssh -L 5050:188.171.10.8:4040 user@bastion.host
```

**Example 2: Access a private PostgreSQL database**

```bash
ssh -L 5432:db1.host:5432 user@remote.host
# Connect locally: psql -h 127.0.0.1 -p 5432
```

**Example 3: Forward VNC port and run SSH in background**

```bash
ssh -L 5901:127.0.0.1:5901 -N -f user@remote.host
```

- `-N`: Do not execute remote command
- `-f`: Run SSH in background

**Troubleshooting:**

- Ensure `AllowTcpForwarding yes` is set in `/etc/ssh/sshd_config` on the remote server.

---

## 2. Remote Port Forwarding

Expose a local service to a remote network via the SSH server. Useful for sharing local apps or webhooks with remote/cloud systems.

**Syntax:**

```bash
ssh -R <remote_port>:localhost:<local_port> <user>@<remote.host>
```

**Example: Expose local port 3000 to remote port 8000**

```bash
ssh -R 8000:127.0.0.1:3000 -N -f user@remote.host
```

- Now, anyone on `remote.host` can access your local app at `localhost:8000`.

---

## 3. Dynamic Port Forwarding (SOCKS Proxy)

Create a local SOCKS proxy to route traffic through the SSH server. Useful for secure browsing, testing, or accessing internal networks.

**Syntax:**

```bash
ssh -D <local_port> <user>@<ssh_server>
```

**Example: Start a SOCKS proxy on port 9090**

```bash
ssh -D 9090 -N -f user@remote.host
```

- Configure your browser or CLI tool to use `localhost:9090` as a SOCKS5 proxy.

---

## Real-World DevOps Examples

### 1. Access AWS RDS or Azure SQL via Bastion

```bash
ssh -L 5432:<rds-endpoint>:5432 ec2-user@bastion-host
```

### 2. Forward Kubernetes Dashboard securely

```bash
ssh -L 8001:localhost:8001 user@k8s-master
kubectl proxy --address='127.0.0.1' --port=8001
```

### 3. Share a local web app with a remote team

```bash
ssh -R 8080:localhost:3000 user@remote.host
```

---

## Best Practices

- Use `-N -f` for background tunnels in automation scripts
- Always restrict forwarding to trusted users/networks
- Monitor and audit SSH tunnels in production
- Use SSH config (`~/.ssh/config`) to simplify complex tunnels
- For persistent tunnels, consider tools like `autossh` or systemd services

---

## References

- [OpenSSH Port Forwarding Manual](https://man.openbsd.org/ssh#PORT_FORWARDING)
- [SSH Config Guide](./how-to-use-ssh-config.md)

---

> **Tip:** Kill background SSH tunnels with `pkill -f 'ssh -L'` or `pkill ssh` as needed.
