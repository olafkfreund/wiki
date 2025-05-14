# GPU Setup Guide for Ollama

This guide provides detailed instructions for configuring Ollama to utilize GPU acceleration on different hardware platforms including NVIDIA, AMD, and Intel GPUs.

## GPU Acceleration Overview

GPU acceleration dramatically improves Ollama's performance, enabling:

- Faster model loading times
- Increased inference speed (token generation)
- Higher throughput for concurrent requests
- Ability to run larger models efficiently

## Hardware Requirements

| GPU Manufacturer | Minimum Requirements | Recommended |
|-----------------|----------------------|-------------|
| NVIDIA | CUDA-capable GPU (Compute 5.0+)<br>Pascal/10xx series or newer | RTX series (30xx/40xx) |
| AMD | ROCm-compatible GPU (CDNA/RDNA)<br>Radeon RX 6000+ series | Radeon RX 7000 series |
| Intel | Intel Arc GPUs with OneAPI support | Intel Arc A770/A750 |

## NVIDIA GPU Setup

NVIDIA GPUs offer the best performance and compatibility with Ollama through CUDA integration.

### Prerequisites

1. Install the NVIDIA driver:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install -y nvidia-driver-535 nvidia-utils-535
   
   # RHEL/CentOS/Fedora
   sudo dnf install -y akmod-nvidia
   ```

2. Install the CUDA toolkit (11.4 or newer recommended):
   ```bash
   # Download and install CUDA toolkit
   wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
   sudo sh cuda_11.8.0_520.61.05_linux.run
   ```

3. Add CUDA to your PATH:
   ```bash
   echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
   echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

### Configuring Ollama for NVIDIA GPUs

Ollama automatically detects NVIDIA GPUs when available. You can customize GPU utilization with environment variables:

```bash
# Use specific GPUs (zero-indexed)
export CUDA_VISIBLE_DEVICES=0,1

# Limit memory usage per GPU (in MiB)
export GPU_MEMORY_UTILIZATION=90

# Start Ollama with GPU acceleration
ollama serve
```

### Verifying GPU Usage

```bash
# Check if CUDA is detected
ollama run mistral "Are you using my GPU?" --verbose

# Monitor GPU usage
nvidia-smi -l 1
```

### NVIDIA Docker Setup

For Docker-based deployments:

```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit

# Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Run Ollama with GPU support
docker run --gpus all -p 11434:11434 ollama/ollama
```

## AMD GPU Setup

AMD GPU support in Ollama uses the ROCm platform.

### Prerequisites

1. Install the ROCm driver stack:
   ```bash
   # Add ROCm apt repository
   wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
   echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/5.4.3/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list
   
   # Install ROCm
   sudo apt update
   sudo apt install -y rocm-dev rocm-libs miopen-hip
   ```

2. Add your user to the render group:
   ```bash
   sudo usermod -aG render $USER
   sudo usermod -aG video $USER
   ```

3. Set up environment variables:
   ```bash
   echo 'export PATH=/opt/rocm/bin:$PATH' >> ~/.bashrc
   echo 'export HSA_OVERRIDE_GFX_VERSION=10.3.0' >> ~/.bashrc
   source ~/.bashrc
   ```

### Configuring Ollama for AMD GPUs

```bash
# Configure Ollama for AMD GPUs
export OLLAMA_COMPUTE_TYPE=rocm

# For specific AMD GPU settings
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Start Ollama
ollama serve
```

### Verifying AMD GPU Support

```bash
# Check if ROCm is detected
rocm-smi

# Check Ollama logs
ollama run mistral "Are you using my GPU?" --verbose
```

### AMD Docker Setup

```bash
# Set up Docker container with ROCm
docker run --device=/dev/kfd --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --group-add render \
    -p 11434:11434 \
    -e OLLAMA_COMPUTE_TYPE=rocm \
    -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
    ollama/ollama
```

## Intel GPU Setup

Intel Arc GPUs can accelerate Ollama through OneAPI integration.

### Prerequisites

1. Install the Intel GPU drivers:
   ```bash
   # Ubuntu
   sudo apt update
   sudo apt install -y intel-opencl-icd intel-level-zero-gpu level-zero
   
   # Install Intel oneAPI base toolkit
   wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh
   sudo sh l_BaseKit_p_2022.2.0.262_offline.sh
   ```

2. Add OneAPI to your PATH:
   ```bash
   echo 'source /opt/intel/oneapi/setvars.sh' >> ~/.bashrc
   source ~/.bashrc
   ```

### Configuring Ollama for Intel GPUs

```bash
# Enable Intel GPU acceleration
export NEOCommandLine="-cl-intel-greater-than-4GB-buffer-required"
export OLLAMA_COMPUTE_TYPE=sycl

# Start Ollama
ollama serve
```

### Verifying Intel GPU Support

```bash
# Check OneAPI configuration
sycl-ls

# Test with Ollama
ollama run mistral "Are you using my GPU?" --verbose
```

## Troubleshooting GPU Issues

### Common NVIDIA Issues

| Issue | Solution |
|-------|----------|
| CUDA not found | Verify CUDA installation: `nvcc --version` |
| Insufficient memory | Reduce model size or context window: `ollama run mistral:7b-q4_0 -c 2048` |
| Multiple GPU conflict | Specify device: `export CUDA_VISIBLE_DEVICES=0` |
| Driver/CUDA mismatch | Install compatible versions: [NVIDIA Compatibility](https://docs.nvidia.com/deploy/cuda-compatibility/) |

### Common AMD Issues

| Issue | Solution |
|-------|----------|
| ROCm device not found | Check installation: `rocm-smi` |
| Hip runtime error | Set `HSA_OVERRIDE_GFX_VERSION=10.3.0` |
| Permission issues | Add user to render group: `sudo usermod -aG render $USER` |

### Common Intel Issues

| Issue | Solution |
|-------|----------|
| GPU not detected | Verify driver installation: `clinfo` |
| Memory allocation failed | Set `-cl-intel-greater-than-4GB-buffer-required` |
| Driver too old | Update Intel GPU driver |

## Performance Optimization

### NVIDIA Performance Tips

```bash
# Use mixed precision for better performance
export OLLAMA_COMPUTE_TYPE=float16

# For large models on limited VRAM
export OLLAMA_GPU_LAYERS=35
```

### AMD Performance Tips

```bash
# Adjust compute type for better performance
export OLLAMA_COMPUTE_TYPE=float16

# For large models on limited VRAM
export HIP_VISIBLE_DEVICES=0
export OLLAMA_GPU_LAYERS=28
```

### Intel Performance Tips

```bash
# Optimize for Intel GPUs
export OLLAMA_COMPUTE_TYPE=float16
export SYCL_CACHE_PERSISTENT=1
```

## Multi-GPU Configuration

For systems with multiple GPUs:

```bash
# Use specific GPUs (comma-separated, zero-indexed)
export CUDA_VISIBLE_DEVICES=0,1  # NVIDIA
export HIP_VISIBLE_DEVICES=0,1   # AMD

# Set number of GPUs to use
export OLLAMA_NUM_GPU=2
```

## Real-World Deployment Examples

### High-Performance Server (4x NVIDIA RTX 4090)

```bash
# Create a systemd service
sudo nano /etc/systemd/system/ollama.service
```

```ini
[Unit]
Description=Ollama Service
After=network.target

[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="CUDA_VISIBLE_DEVICES=0,1,2,3"
Environment="OLLAMA_COMPUTE_TYPE=float16"
Environment="OLLAMA_NUM_GPU=4"
ExecStart=/usr/local/bin/ollama serve
Restart=always
User=ollama

[Install]
WantedBy=multi-user.target
```

### Mixed GPU Environment (NVIDIA + AMD)

For environments with both NVIDIA and AMD GPUs:

```bash
# For NVIDIA
CUDA_VISIBLE_DEVICES=0 ollama serve

# For AMD (in separate instance)
HIP_VISIBLE_DEVICES=0 OLLAMA_COMPUTE_TYPE=rocm ollama serve --port 11435
```

## NixOS GPU Configuration

For NixOS users, configure GPU acceleration in `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA driver and CUDA
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;

  # Enable Ollama service with GPU acceleration
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Options: none, cuda, rocm, or oneapi
    package = pkgs.ollama;
    environmentFiles = [ "/etc/ollama/env.conf" ]; # Custom environment variables
  };
  
  # Create file with: 
  # OLLAMA_COMPUTE_TYPE=float16
  # OLLAMA_HOST=0.0.0.0:11434
}
```

## Next Steps

After configuring GPU acceleration for Ollama:

1. [Explore available models](models.md) optimized for GPU acceleration
2. [Set up advanced configurations](configuration.md) for optimal performance
3. [Try real-world DevOps usage examples](devops-usage.md)
4. [Set up Open WebUI](open-webui.md) for a graphical interface