# Podman

Podman (Pod Manager) is a daemonless container engine for developing, managing, and running OCI containers on Linux. Unlike Docker, Podman can run containers as root or in rootless mode, making it an increasingly popular choice for enterprise container deployments as of 2025.

## Core Features

- **Daemonless Architecture**: No central daemon required, containers run in the user space
- **Rootless Containers**: Run containers without root privileges
- **Pod Support**: Native support for pods (groups of containers)
- **Docker Compatibility**: Drop-in replacement for most Docker commands
- **OCI Compliance**: Works with OCI (Open Container Initiative) images
- **Systemd Integration**: Native support for generating systemd units for containers
- **Quadlet Support**: Declarative container definition format (new in Podman 4.4+)

## Installation

### On Fedora/RHEL/CentOS
```bash
sudo dnf install podman podman-compose podman-docker
```

### On Ubuntu
```bash
# Ubuntu 22.04+ or with backports
sudo apt update
sudo apt install podman podman-compose
```

### On Arch Linux
```bash
sudo pacman -S podman podman-compose podman-docker
```

### On NixOS
Add to your configuration.nix:
```nix
{ config, pkgs, ... }:
{
  virtualisation = {
    podman = {
      enable = true;
      # Enable Docker compatibility
      dockerCompat = true;
      # For rootless operation
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
```
Then rebuild your system with:
```bash
sudo nixos-rebuild switch
```

### On Windows Subsystem for Linux (WSL2)

1. First, install a compatible Linux distribution in WSL2
2. Then install Podman within your WSL2 distribution:

For Ubuntu WSL:
```bash
sudo apt update
sudo apt install -y podman
```

For enhanced WSL2 integration with systemd support (recommended for Podman):
```bash
# Create or edit /etc/wsl.conf in your WSL distribution
[boot]
systemd=true
```
Then restart your WSL instance:
```bash
wsl --shutdown
```

## Best Practices for Podman in 2025

### Security

1. **Always Use Rootless Mode in Production**
   ```bash
   # Check current user mapping
   podman unshare cat /proc/self/uid_map
   
   # Run containers rootless
   podman run --rm --security-opt=no-new-privileges alpine ls
   ```

2. **Apply Security Policies**
   ```bash
   # Apply SECcomp profile
   podman run --security-opt seccomp=custom-profile.json nginx
   ```

3. **Use Read-Only Containers**
   ```bash
   # Mount file system as read-only
   podman run --read-only --tmpfs /tmp nginx
   ```

### Resource Management

1. **Set Resource Limits**
   ```bash
   # Limit memory and CPU
   podman run --memory=2g --cpus=2 nginx
   ```

2. **Use Cgroup v2**
   Modern Linux distributions use cgroup v2, which Podman fully supports:
   ```bash
   # Check if using cgroup v2
   cat /sys/fs/cgroup/cgroup.controllers
   
   # Run with explicit cgroup parent
   podman run --cgroup-parent=app.slice nginx
   ```

### Networking

1. **Use Podman Networks for Isolation**
   ```bash
   # Create custom network
   podman network create app-network
   
   # Run container in network
   podman run --network app-network nginx
   ```

2. **Enable DNS for Container-to-Container Communication**
   ```bash
   # Create a pod with shared network namespace
   podman pod create --name webapp-pod
   
   # Add containers to the pod
   podman run --pod webapp-pod --name frontend -d nginx
   podman run --pod webapp-pod --name backend -d my-api
   ```

## Real-Life Examples

### Production Web Application Deployment

This example shows a typical web application stack with a frontend, API, and database:

```bash
# Create network
podman network create webapp

# Create persistent volumes
podman volume create db-data

# Run database with volume
podman run -d --name postgres \
  --network webapp \
  -e POSTGRES_PASSWORD=secure_password \
  -e POSTGRES_USER=app_user \
  -e POSTGRES_DB=app_db \
  -v db-data:/var/lib/postgresql/data \
  postgres:15

# Run API service
podman run -d --name api \
  --network webapp \
  -e DB_HOST=postgres \
  -e DB_USER=app_user \
  -e DB_PASSWORD=secure_password \
  -e DB_NAME=app_db \
  my-company/api-service:v2.5

# Run frontend with port mapping
podman run -d --name frontend \
  --network webapp \
  -p 443:8443 \
  -e API_URL=http://api:8000 \
  my-company/frontend:v1.7
```

Create a systemd service file for auto-starting containers:

```bash
# Generate systemd files
podman generate systemd --new --files --name postgres
podman generate systemd --new --files --name api
podman generate systemd --new --files --name frontend

# Move to systemd user directory
mkdir -p ~/.config/systemd/user/
mv container-postgres.service ~/.config/systemd/user/
mv container-api.service ~/.config/systemd/user/
mv container-frontend.service ~/.config/systemd/user/

# Enable and start services
systemctl --user daemon-reload
systemctl --user enable --now container-postgres.service
systemctl --user enable --now container-api.service
systemctl --user enable --now container-frontend.service

# Enable lingering to allow services to run without user login
loginctl enable-linger $(whoami)
```

### CI/CD Pipeline Configuration

Real-life GitHub Actions workflow using Podman:

```yaml
name: Build and Push Image

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Podman
        run: |
          sudo apt update
          sudo apt install -y podman
          
      - name: Login to Registry
        run: |
          podman login --username ${{ secrets.REGISTRY_USER }} \
                       --password ${{ secrets.REGISTRY_TOKEN }} \
                       quay.io
                       
      - name: Build and Push
        run: |
          podman build -t quay.io/myorg/myapp:${{ github.sha }} .
          podman push quay.io/myorg/myapp:${{ github.sha }}
```

### Quadlet Configuration (Podman 4.4+)

Quadlet lets you define containers declaratively. Create a file `web-app.container` in `~/.config/containers/systemd/`:

```ini
[Container]
Image=nginx:latest
PublishPort=8080:80
Volume=./website:/usr/share/nginx/html:Z
Environment=NGINX_HOST=example.com

[Service]
Restart=always

[Install]
WantedBy=default.target
```

Then enable and start it:
```bash
systemctl --user daemon-reload
systemctl --user enable --now web-app
```

## Basic Commands

### Running Containers
```bash
# Run a container
podman run -dt --name my-container nginx

# Run a container in the background with port mapping
podman run -dt -p 8080:80 --name web-server nginx

# Run a container with volume mounting
podman run -v ./local-dir:/container-dir -dt my-image
```

### Managing Containers
```bash
# List running containers
podman ps

# List all containers
podman ps -a

# Stop a container
podman stop my-container

# Start a container
podman start my-container

# Remove a container
podman rm my-container

# Execute commands in a running container
podman exec -it my-container bash
```

### Working with Images
```bash
# Pull an image
podman pull docker.io/library/ubuntu

# List images
podman images

# Build an image
podman build -t my-image:tag .

# Remove an image
podman rmi my-image:tag

# Build with BuildKit for improved performance
podman build --format=docker --build-arg BUILDKIT_INLINE_CACHE=1 -t my-image:tag .

# Create an optimized multi-stage build
podman build --tag slim-app -f - <<EOF
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

FROM alpine:3.18
COPY --from=builder /app/myapp /usr/local/bin/
ENTRYPOINT ["myapp"]
EOF
```

### Pod Management
```bash
# Create a pod
podman pod create --name my-pod

# Run a container in a pod
podman run --pod my-pod -dt nginx

# List pods
podman pod list

# Stop a pod
podman pod stop my-pod

# Remove a pod
podman pod rm my-pod

# Create a pod with resource limits
podman pod create --name web-pod --cpus 2 --memory 2G -p 8080:80
```

## Rootless Mode

Podman allows containers to be run as a non-root user, which improves security:

```bash
# Running as a normal user
podman run --rm docker.io/library/alpine echo hello
```

To enable rootless mode with user namespaces:

```bash
# Check if your system supports user namespaces
sysctl kernel.unprivileged_userns_clone
# If it returns 0, enable it
sudo sysctl -w kernel.unprivileged_userns_clone=1

# Set up subordinate UID/GID ranges if not already configured
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $(whoami)
```

## Docker Compatibility

Podman provides a Docker-compatible API and command structure. You can create an alias for easy transition:

```bash
alias docker=podman
```

For full Docker API compatibility, enable the podman socket:

```bash
# Enable and start the podman socket for current user
systemctl --user enable --now podman.socket

# Set Docker socket environment variable
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
```

## Podman Compose

Podman provides its own implementation of Docker Compose:

```bash
# Install podman-compose
pip3 install podman-compose

# Run a compose file
podman-compose up -d

# Modern approach (Podman v4+)
podman compose up -d
```

Example `compose.yaml` for a web application:

```yaml
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./content:/usr/share/nginx/html:Z
    restart: always
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - postgres-data:/var/lib/postgresql/data
volumes:
  postgres-data:
```

## Podman Machine

For running Podman on macOS or Windows:

```bash
# Create a new VM
podman machine init

# Create VM with custom resources
podman machine init --cpus 4 --memory 8192 --disk-size 60

# Start the VM
podman machine start

# List available machines
podman machine list

# SSH into the machine
podman machine ssh

# Stop the VM
podman machine stop
```

## Podman vs Docker: Comparison (2025)

| Feature | Podman | Docker |
|---------|--------|--------|
| **Architecture** | Daemonless | Client-server with daemon |
| **Root Privileges** | Works in rootless mode by default | Traditionally required root (daemon) |
| **Pod Support** | Native | Requires Docker Compose or Swarm |
| **Kubernetes Compatibility** | Native support for pods, generates kube YAML | Requires additional tools |
| **Systemd Integration** | Native | Limited |
| **Corporate Backing** | Red Hat | Docker, Inc. / Mirantis |
| **Runtime** | Uses various OCI runtimes (runc, crun) | Uses containerd/runc |
| **Remote Management** | REST API via systemd socket activation | Always-on daemon |
| **Windows/macOS Support** | Via Podman Machine | Native Docker Desktop |
| **License** | Apache 2.0 | Mix of open source and proprietary |

### Pros of Podman

1. **Enhanced Security**: Rootless by default, reduced attack surface with no daemon
2. **Kubernetes-like Experience**: Native pod concept for easier migration to K8s
3. **No Licensing Costs**: Free for commercial use at any scale
4. **SystemD Integration**: Better system service management
5. **Enterprise Ready**: Strong backing from Red Hat with long-term support
6. **Lower Resources**: More efficient without a persistent daemon

### Cons of Podman

1. **Less Mature Ecosystem**: Fewer third-party tools compared to Docker
2. **Learning Curve**: Some differences in behavior compared to Docker
3. **Windows/macOS Support**: Less polished than Docker Desktop
4. **Community Size**: Smaller community than Docker's

## Recent Updates (as of May 2025)

- **Podman v5.x**: Enhanced networking capabilities and increased Docker compatibility
- **Podman Desktop**: Graphical interface for managing containers across platforms
- **Improved Kubernetes integration**: Enhanced support for `podman kube` commands
- **Optimized resource usage**: Better memory and CPU management
- **Enhanced Quadlet Support**: Richer declarative container definition format
- **Native Secrets Management**: Integrated with system keyring
- **Image Verification**: Enhanced signing and verification capabilities

## Related Resources

- [Podman Official Website](https://podman.io/)
- [Podman GitHub Repository](https://github.com/containers/podman)
- [Podman Documentation](https://docs.podman.io/)
- [Podman Desktop](https://podman-desktop.io/)
- [Red Hat Podman Guide](https://www.redhat.com/en/topics/containers/what-is-podman)
- [IBM Cloud Podman Guide](https://www.ibm.com/cloud/learn/podman)