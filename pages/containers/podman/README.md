# Podman

Podman (Pod Manager) is a daemonless container engine for developing, managing, and running OCI containers on Linux. Unlike Docker, Podman can run containers as root or in rootless mode.

## Core Features

- **Daemonless Architecture**: No central daemon required, containers run in the user space
- **Rootless Containers**: Run containers without root privileges
- **Pod Support**: Native support for pods (groups of containers)
- **Docker Compatibility**: Drop-in replacement for most Docker commands
- **OCI Compliance**: Works with OCI (Open Container Initiative) images

## Installation

### On Fedora/RHEL/CentOS
```bash
sudo dnf install podman
```

### On Ubuntu
```bash
sudo apt update
sudo apt install podman
```

### On Arch Linux
```bash
sudo pacman -S podman
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
```

## Docker Compatibility

Podman provides a Docker-compatible API and command structure. You can create an alias for easy transition:

```bash
alias docker=podman
```

## Podman Compose

Podman provides its own implementation of Docker Compose:

```bash
# Install podman-compose
pip3 install podman-compose

# Run a compose file
podman-compose up -d
```

## Podman Machine

For running Podman on macOS or Windows:

```bash
# Create a new VM
podman machine init

# Start the VM
podman machine start

# List available machines
podman machine list
```

## Recent Updates (as of May 2025)

- **Podman v5.x**: Enhanced networking capabilities and increased Docker compatibility
- **Podman Desktop**: Graphical interface for managing containers across platforms
- **Improved Kubernetes integration**: Enhanced support for `podman kube` commands
- **Optimized resource usage**: Better memory and CPU management

## Related Resources

- [Podman Official Website](https://podman.io/)
- [Podman GitHub Repository](https://github.com/containers/podman)
- [Podman Documentation](https://docs.podman.io/)