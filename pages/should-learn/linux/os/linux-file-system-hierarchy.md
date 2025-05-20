# Linux File System Hierarchy

Understanding the Linux file system hierarchy is essential for DevOps engineers managing cloud, container, and multi-user environments. This guide provides a practical overview, real-world examples, and best practices for navigating and using the Linux directory structure.

---

## Key Directories and Their Purpose

| Directory   | Purpose & Examples |
|------------|-------------------|
| `/`        | Root of the file system. All other directories branch from here. Only root can write here. |
| `/root`    | Home directory for the root user. |
| `/etc`     | System-wide configuration files. E.g., `/etc/resolv.conf`, `/etc/logrotate.conf`. |
| `/home`    | User home directories. E.g., `/home/alice`, `/home/bob`. |
| `/var`     | Variable data: logs, spools, cache. E.g., `/var/log/syslog`. |
| `/opt`     | Optional/add-on application software. E.g., `/opt/google/chrome`. |
| `/lib`, `/lib64` | Essential shared libraries for binaries in `/bin` and `/sbin`. 64-bit libraries in `/lib64`. |
| `/tmp`     | Temporary files, cleared on reboot. |
| `/mnt`     | Temporary mount point for filesystems. |
| `/srv`     | Site-specific data served by the system (web, FTP, VCS). |
| `/usr`     | User programs, libraries, docs. E.g., `/usr/bin`, `/usr/local`, `/usr/src`. |
| `/dev`     | Device files (disks, terminals, USB). E.g., `/dev/sda`, `/dev/null`. |
| `/proc`    | Virtual filesystem for process and kernel info. E.g., `/proc/cpuinfo`. |
| `/bin`     | Essential user binaries (e.g., `ls`, `cp`). |
| `/sbin`    | System binaries for admin tasks (e.g., `reboot`, `fdisk`). |
| `/media`   | Mount points for removable media (CD-ROM, USB). |
| `/boot`    | Boot loader files (kernel, initrd, grub). |

---

## Real-World DevOps Examples

### 1. Mounting Cloud Storage (AWS, Azure, GCP)

```sh
# Mount an EBS volume to /mnt/data (AWS EC2)
sudo mkfs.ext4 /dev/xvdf
sudo mkdir -p /mnt/data
sudo mount /dev/xvdf /mnt/data
```

### 2. Managing Logs in /var

```sh
# View system logs
sudo tail -f /var/log/syslog
# Rotate logs manually
sudo logrotate /etc/logrotate.conf
```

### 3. Using /etc for Configuration Management

```sh
# Use Ansible to manage /etc/ssh/sshd_config
- name: Ensure SSH root login is disabled
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^PermitRootLogin'
    line: 'PermitRootLogin no'
```

### 4. Container Volumes

```yaml
# Kubernetes pod mounting /data from host
volumes:
  - name: data-volume
    hostPath:
      path: /mnt/data
      type: Directory
```

---

## Best Practices

- Never store application data in `/tmp` or `/var/tmp` for production workloads.
- Use `/opt` or `/usr/local` for custom or third-party software.
- Automate configuration management for `/etc` using tools like Ansible or Terraform.
- Regularly monitor `/var` for log growth to avoid disk space issues.
- Use `/mnt` and `/media` for temporary and removable storage only.

---

## References

- [Filesystem Hierarchy Standard (FHS)](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- [Linux Filesystem Structure Explained (Red Hat)](https://www.redhat.com/sysadmin/linux-filesystem-structure)

---

> **Tip:** In cloud and container environments, always use persistent storage for important data and automate mount/configuration steps in your deployment pipeline.

<figure><img src="https://miro.medium.com/v2/resize:fit:602/0*9uDnWn-KfmXZU6DY" alt="Linux File System Hierarchy Diagram" height="623" width="602"><figcaption></figcaption></figure>
