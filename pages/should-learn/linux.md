# Linux for DevOps & SRE (2025)

Linux remains the backbone of modern cloud infrastructure and DevOps/SRE workflows. Mastery of Linux is essential for engineers working with AWS, Azure, GCP, and hybrid environments.

## Why DevOps & SREs Need Linux

1. **Cloud-Native Operations**: Most cloud VMs, containers, and Kubernetes nodes run Linux. Engineers must manage, troubleshoot, and optimize these systems daily.
2. **Automation & Scripting**: Bash, Python, and other scripting languages on Linux enable automated deployments, monitoring, and remediation. Tools like Ansible, Terraform, and CI/CD runners often execute on Linux hosts.
3. **Security & Compliance**: Linux offers granular access controls (SELinux, AppArmor), audit logging, and patch automation. SREs use these features to enforce compliance and respond to incidents.
4. **Observability**: Logging (journald, syslog), metrics (Prometheus node_exporter), and tracing are natively supported on Linux, making it the platform of choice for observability stacks.
5. **Open Source Ecosystem**: Most DevOps tools (Docker, Kubernetes, Helm, Git, etc.) are built for Linux first.

## Real-Life Examples

### 1. Automated Patch Management (Ansible)

```yaml
- name: Patch all Linux servers
  hosts: linux_servers
  become: yes
  tasks:
    - name: Update all packages
      apt:
        upgrade: dist
        update_cache: yes
```

### 2. Troubleshooting a Failing Pod in Kubernetes

```bash
kubectl exec -it mypod -- bash
journalctl -u myservice
cat /var/log/app.log
```

### 3. Secure SSH Access with Key Rotation

```bash
# Rotate SSH keys for all users
for user in $(cut -f1 -d: /etc/passwd); do
  ssh-keygen -f /home/$user/.ssh/id_rsa -N '' -q
  # Distribute new public keys via Ansible or cloud-init
  # ...
done
```

### 4. Monitoring with Prometheus Node Exporter

```bash
# Install node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v*/node_exporter-*.linux-amd64.tar.gz
# ...extract and run as a systemd service...
```

## Best Practices (2025)

- Use Infrastructure as Code (Terraform, Ansible) for all Linux provisioning
- Automate patching and configuration drift detection
- Enforce least privilege with sudoers and SELinux/AppArmor
- Monitor system health and logs centrally (Prometheus, ELK, Grafana)
- Use containers for reproducible environments
- Document all custom scripts and automation

## Common Pitfalls

- Not automating user and key management
- Ignoring security updates
- Overlooking log rotation and disk space
- Hardcoding credentials in scripts
- Not monitoring resource usage (CPU, memory, disk)

## References

- [Linux Foundation Training](https://training.linuxfoundation.org/)
- [Ansible Docs](https://docs.ansible.com/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Prometheus Docs](https://prometheus.io/docs/)

---

> **Linux Joke:**
> Why do DevOps engineers love Linux? Because rebooting is always the last resort, not the first step!
