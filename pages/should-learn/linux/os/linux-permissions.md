# Linux Permissions

Linux permissions are critical for securing files, directories, and processes in any environment—especially in cloud, container, and multi-user systems. This guide provides actionable steps, real-world DevOps examples, and best practices for managing permissions.

---

## Permission Types

- **User (u):** Owner of the file/directory
- **Group (g):** Users in the file's group
- **Other (o):** All other users

Each can have:
- **Read (r):** View file contents/list directory
- **Write (w):** Modify file/add/remove files in directory
- **Execute (x):** Run file as program/traverse directory

---

## Viewing Permissions

```sh
ls -l /path/to/file
```
Example output:
```
-rwxr-x--- 1 alice devs 4096 Jun 1 10:00 script.sh
```
- `rwx` (user: alice)
- `r-x` (group: devs)
- `---` (other)

---

## Modifying Permissions

### Change Permissions (chmod)
```sh
chmod u+x script.sh      # Add execute for user
chmod g-w file.txt       # Remove write for group
chmod 750 mydir          # rwx for user, r-x for group, --- for other
```

### Change Ownership (chown/chgrp)
```sh
chown bob:devs file.txt  # Set user to bob, group to devs
chgrp admins script.sh   # Change group only
```

---

## Real-World DevOps Examples

### 1. Secure SSH Keys (AWS, Azure, GCP)
```sh
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh
```

### 2. Docker Volumes
Ensure only the container user can access sensitive data:
```sh
docker run -v /secure/data:/data:ro myimage
```

### 3. Kubernetes Init Containers
Set permissions before app starts:
```yaml
initContainers:
  - name: fix-perms
    image: busybox
    command: ["sh", "-c", "chmod 700 /app && chown 1000:1000 /app"]
    volumeMounts:
      - name: app-volume
        mountPath: /app
```

---

## Best Practices
- Use least privilege: grant only required permissions
- Automate permission management with Ansible, Terraform, or cloud-init
- Regularly audit permissions (`find / -perm -4000` for SUID files)
- Avoid 777 permissions except in isolated test environments
- Use version control for IaC and permission scripts

---

## References
- [Linux File Permissions Guide](https://www.redhat.com/sysadmin/linux-permissions-intro)
- [chmod man page](https://man7.org/linux/man-pages/man1/chmod.1.html)
- [chown man page](https://man7.org/linux/man-pages/man1/chown.1.html)

---

> **Tip:** In cloud and container environments, always set permissions as part of your deployment pipeline to avoid drift and security risks.
