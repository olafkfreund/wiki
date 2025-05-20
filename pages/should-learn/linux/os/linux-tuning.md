# Linux Tuning

Linux system tuning is essential for optimizing performance, reliability, and security, especially in cloud and containerized environments. This guide covers practical sysctl tuning, kernel parameter adjustments, and automation best practices for DevOps engineers.

---

## Why Tune Linux?

- **Improve network throughput and latency** for cloud workloads (AWS, Azure, GCP)
- **Optimize resource usage** for containers (Kubernetes, Docker)
- **Enhance security** by hardening kernel and network parameters
- **Reduce downtime** and prevent resource exhaustion

---

## How to Apply Kernel and Network Tuning

### 1. Using sysctl

`sysctl` allows you to view and modify kernel parameters at runtime.

**Example:**

```sh
# View current value
sudo sysctl net.core.somaxconn
# Set a value temporarily
sudo sysctl -w net.core.somaxconn=65535
# Persist changes (add to /etc/sysctl.conf or /etc/sysctl.d/*.conf)
echo 'net.core.somaxconn=65535' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

### 2. Example sysctl.conf for High-Performance Servers

```conf
### KERNEL TUNING ###

# Increase size of file handles and inode cache
fs.file-max = 2097152

# Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2

# Sets the time before the kernel considers migrating a process to another core
kernel.sched_migration_cost_ns = 5000000

# Group tasks by TTY
#kernel.sched_autogroup_enabled = 0

### GENERAL NETWORK SECURITY OPTIONS ###

# Number of times SYNACKs for passive TCP connection.
net.ipv4.tcp_synack_retries = 2

# Allowed local port range
net.ipv4.ip_local_port_range = 2000 65535

# Protect Against TCP Time-Wait
net.ipv4.tcp_rfc1337 = 1

# Control Syncookies
net.ipv4.tcp_syncookies = 1

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 15

# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

### TUNING NETWORK PERFORMANCE ###

# Default Socket Receive Buffer
net.core.rmem_default = 31457280

# Maximum Socket Receive Buffer
net.core.rmem_max = 33554432

# Default Socket Send Buffer
net.core.wmem_default = 31457280

# Maximum Socket Send Buffer
net.core.wmem_max = 33554432

# Increase number of incoming connections
net.core.somaxconn = 65535

# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 65536

# Increase the maximum amount of option memory buffers
net.core.optmem_max = 25165824

# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
net.ipv4.tcp_mem = 786432 1048576 26777216
net.ipv4.udp_mem = 65536 131072 262144

# Increase the read-buffer space allocatable
net.ipv4.tcp_rmem = 8192 87380 33554432
net.ipv4.udp_rmem_min = 16384

# Increase the write-buffer-space allocatable
net.ipv4.tcp_wmem = 8192 65536 33554432
net.ipv4.udp_wmem_min = 16384

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
```

---

### 3. Using TuneD (RHEL/CentOS/Fedora)

[TuneD](https://tuned-project.org/) provides profiles for automated tuning. For SQL Server or high-throughput workloads, use the `throughput-performance` or `mssql` profile.

**Example:**

```sh
sudo dnf install tuned
sudo tuned-adm profile throughput-performance
# For SQL workloads:
sudo tuned-adm profile mssql
```

---

## Cloud & Container Best Practices

- **AWS EC2:** Use [user data scripts](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) or [Ansible](https://docs.ansible.com/) to automate sysctl settings.
- **Azure VMs:** Use [Custom Script Extensions](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux) or [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) for automation.
- **Kubernetes:** Use [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) or [DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) to apply sysctl settings cluster-wide.
- **Terraform:** Use [remote-exec provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec) to apply tuning at deployment.

---

## Real-World Example: Automate sysctl with Ansible

```yaml
- name: Apply sysctl tuning
  hosts: all
  become: yes
  tasks:
    - name: Set sysctl params
      sysctl:
        name: net.core.somaxconn
        value: 65535
        state: present
        reload: yes
```

---

## References

- [Linux sysctl Documentation](https://www.kernel.org/doc/html/latest/admin-guide/sysctl/index.html)
- [TuneD Project](https://tuned-project.org/)
- [AWS EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Kubernetes sysctl docs](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/)

---

> **Tip:** Always test tuning changes in a staging environment before applying to production. Monitor system metrics (CPU, memory, network) after changes.
