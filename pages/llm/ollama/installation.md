# Ollama Installation Guide

This guide provides detailed instructions for installing Ollama on various Linux distributions, NixOS, and using Docker containers.

## System Requirements

Before installing Ollama, ensure your system meets these minimum requirements:

- **CPU**: 64-bit Intel/AMD (x86_64) or ARM64 processor
- **RAM**: 8GB minimum (16GB+ recommended for larger models)
- **Storage**: 10GB+ free space (varies by model size)
- **Operating System**: Linux (kernel 4.15+), macOS 12.0+, or Windows 10/11
- **GPU** (optional but recommended):
  - NVIDIA GPU with CUDA 11.4+ support
  - AMD GPU with ROCm 5.4.3+ support
  - Intel Arc GPU with OneAPI support

## Linux Installation (Direct Method)

### Using the Install Script (Recommended)

For most Linux distributions, the simplest installation method is using the official install script:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This script automatically detects your Linux distribution and installs the appropriate package.

### Manual Installation (Debian/Ubuntu)

For Debian-based distributions (Ubuntu, Debian, Linux Mint, etc.):

```bash
# Download the latest .deb package
wget https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64.deb

# Install the package
sudo dpkg -i ollama-linux-amd64.deb

# Install any missing dependencies
sudo apt-get install -f
```

### Manual Installation (Red Hat/Fedora)

For Red Hat-based distributions (RHEL, Fedora, CentOS, etc.):

```bash
# Download the latest .rpm package
wget https://github.com/ollama/ollama/releases/latest/download/ollama-linux-x86_64.rpm

# Install the package
sudo rpm -i ollama-linux-x86_64.rpm
```

### Manual Installation (Binary Installation)

If packages are not available for your distribution:

```bash
# Download the latest binary
wget https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64

# Make it executable
chmod +x ollama-linux-amd64

# Move to a directory in PATH
sudo mv ollama-linux-amd64 /usr/local/bin/ollama
```

## NixOS Installation

Ollama is available in the Nixpkgs collection, making it easy to install on NixOS.

### Using Nix Package Manager

```bash
nix-env -iA nixos.ollama
```

### NixOS Configuration (Configuration.nix)

For a system-wide installation, add Ollama to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # Enable Ollama service
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Options: none, cuda, rocm, or oneapi
    package = pkgs.ollama;
  };
  
  # Add ollama package to system packages
  environment.systemPackages = with pkgs; [
    ollama
  ];
}
```

After updating your configuration, apply the changes:

```bash
sudo nixos-rebuild switch
```

### Using Home Manager

If you're using Home Manager:

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ollama
  ];
}
```

## Docker Installation

Running Ollama in Docker provides a consistent environment across different systems.

### Basic Docker Setup

Pull and run the official Ollama Docker image:

```bash
# Pull the latest Ollama image
docker pull ollama/ollama:latest

# Run Ollama container
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  ollama/ollama
```

### Docker Compose Setup

Create a `docker-compose.yml` file:

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    volumes:
      - ollama_data:/root/.ollama
    ports:
      - "11434:11434"
    restart: unless-stopped

volumes:
  ollama_data:
```

Launch with Docker Compose:

```bash
docker-compose up -d
```

### Docker with GPU Support (NVIDIA)

To enable NVIDIA GPU support:

```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit

# Run Ollama with GPU support
docker run -d \
  --name ollama \
  --gpus all \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  ollama/ollama
```

## Post-Installation Setup

After installing Ollama, perform these steps to complete the setup:

1. Start the Ollama service:
   ```bash
   ollama serve
   ```

2. Test the installation by running a model:
   ```bash
   ollama pull mistral
   ollama run mistral
   ```

3. Verify API access:
   ```bash
   curl http://localhost:11434/api/generate -d '{
     "model": "mistral",
     "prompt": "Hello, how are you?"
   }'
   ```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**:
   ```bash
   sudo chown -R $USER:$USER ~/.ollama
   ```

2. **Network Connectivity Issues**:
   ```bash
   # Verify Ollama service is running
   ps aux | grep ollama
   
   # Check if port 11434 is open
   sudo lsof -i:11434
   ```

3. **GPU Not Detected**:
   ```bash
   # Verify CUDA installation
   nvidia-smi
   
   # Check Ollama logs
   journalctl -u ollama
   ```

## Next Steps

Now that you have Ollama installed, proceed to:

1. [Configure Ollama](configuration.md) for optimal performance
2. [Explore available models](models.md)
3. [Set up GPU acceleration](gpu-setup.md) for faster inference

For DevOps engineers, check out [DevOps Usage Examples](devops-usage.md) to see how Ollama can be integrated into your workflows.