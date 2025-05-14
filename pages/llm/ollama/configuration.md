# Ollama Configuration Guide

This guide covers essential configuration options for optimizing Ollama performance, managing resources, and customizing model behavior.

## Environment Variables

Ollama's behavior can be controlled using environment variables, which can be set before running the `ollama` command:

```bash
# Example: Setting environment variables
export OLLAMA_MODELS=/path/to/models
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

### Core Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OLLAMA_HOST` | Network address to listen on | `127.0.0.1:11434` |
| `OLLAMA_MODELS` | Directory to store models | `~/.ollama/models` |
| `OLLAMA_KEEP_ALIVE` | Keep models loaded in memory (minutes) | `5` |
| `OLLAMA_TIMEOUT` | Request timeout (seconds) | `30` |

### Performance Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CUDA_VISIBLE_DEVICES` | Control which NVIDIA GPUs are used | All available |
| `OLLAMA_NUM_GPU` | Number of GPUs to use | All available |
| `OLLAMA_NUM_THREAD` | Number of CPU threads to use | Auto-detected |
| `OLLAMA_COMPUTE_TYPE` | Compute type for inference (float16, float32, auto) | `auto` |

### Security Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OLLAMA_ORIGINS` | CORS origins to allow | All (*) |
| `OLLAMA_TLS_CERT` | Path to TLS certificate | None |
| `OLLAMA_TLS_KEY` | Path to TLS key | None |

## Configuration File

Ollama supports a JSON configuration file located at `~/.ollama/config.json`:

```json
{
  "host": "127.0.0.1:11434",
  "models_path": "/path/to/models",
  "keep_alive": 15,
  "num_threads": 12,
  "compute_type": "float16",
  "tls": {
    "cert": "/path/to/cert.pem",
    "key": "/path/to/key.pem"
  }
}
```

## GPU Configuration

### NVIDIA GPU Setup

For NVIDIA GPUs, ensure you have the CUDA toolkit installed:

```bash
# Check CUDA availability
nvidia-smi

# Set specific GPUs (e.g., use only GPU 0)
export CUDA_VISIBLE_DEVICES=0
ollama serve
```

### AMD ROCm Setup

For AMD GPUs with ROCm support:

```bash
# Check ROCm installation
rocminfo

# Set environment variables for AMD GPUs
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export OLLAMA_COMPUTE_TYPE=float16
ollama serve
```

### Intel GPU Setup

For Intel Arc GPUs:

```bash
# Install Intel oneAPI toolkit
sudo apt-get install intel-oneapi-runtime-opencl

# Enable Intel GPU acceleration
export NEOCommandLine="-cl-intel-greater-than-4GB-buffer-required"
export OLLAMA_COMPUTE_TYPE=float16
ollama serve
```

## Memory Management

Optimize Ollama's memory usage with these settings:

```bash
# Reduce model context size (trade-off between memory and context length)
ollama run mistral:latest -c 4096

# Unload models when not in use (in minutes)
export OLLAMA_KEEP_ALIVE=0
```

## Network Configuration

### Binding to External Interfaces

To make Ollama accessible from other machines on your network:

```bash
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

### Configuring TLS

For secure communications:

```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Enable TLS
export OLLAMA_TLS_CERT=/path/to/cert.pem
export OLLAMA_TLS_KEY=/path/to/key.pem
ollama serve
```

## Model Configuration with Modelfiles

Create custom models with Modelfiles:

```
# Example Modelfile
FROM mistral:latest
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM You are a helpful DevOps assistant.

# Save as Modelfile and create the model
ollama create devops-assistant -f ./Modelfile
```

### Modelfile Commands

| Command | Description | Example |
|---------|-------------|---------|
| `FROM` | Base model | `FROM mistral:latest` |
| `PARAMETER` | Set inference parameter | `PARAMETER temperature 0.7` |
| `SYSTEM` | Set system message | `SYSTEM You are a helpful assistant` |
| `TEMPLATE` | Define prompt template | `TEMPLATE <s>{{.System}}</s>{{.Prompt}}` |
| `LICENSE` | Specify model license | `LICENSE MIT` |

## Real-world Configuration Examples

### High-Performance Server Setup

For a dedicated Ollama server with multiple powerful GPUs:

```bash
# Create a systemd service file
sudo nano /etc/systemd/system/ollama.service
```

```ini
[Unit]
Description=Ollama Service
After=network.target

[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/mnt/storage/ollama/models"
Environment="OLLAMA_KEEP_ALIVE=60"
Environment="OLLAMA_NUM_THREAD=32"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=5
User=ollama
Group=ollama

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

### Low Resource Environment

For systems with limited resources:

```bash
# Minimal configuration for resource-constrained systems
export OLLAMA_KEEP_ALIVE=0
export OLLAMA_NUM_THREAD=4
export OLLAMA_COMPUTE_TYPE=float32

# Run smaller models
ollama pull tinyllama
ollama run tinyllama -c 2048
```

## API Configuration

Configure the Ollama API for integration with other tools:

```bash
# Start the API server
ollama serve

# Test API access
curl http://localhost:11434/api/tags
```

### API Rate Limiting

Add rate limiting with a reverse proxy like Nginx:

```nginx
http {
    limit_req_zone $binary_remote_addr zone=ollama_api:10m rate=5r/s;
    
    server {
        listen 80;
        server_name ollama.example.com;
        
        location / {
            limit_req zone=ollama_api burst=10 nodelay;
            proxy_pass http://127.0.0.1:11434;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

## Multi-User Setup

For shared environments, use Docker with multiple containers:

```yaml
# docker-compose.yml for multi-user setup
version: '3'

services:
  ollama-user1:
    image: ollama/ollama:latest
    ports:
      - "11435:11434"
    volumes:
      - ollama_user1:/root/.ollama
    environment:
      - OLLAMA_KEEP_ALIVE=30
      - OLLAMA_HOST=0.0.0.0:11434
    
  ollama-user2:
    image: ollama/ollama:latest
    ports:
      - "11436:11434"
    volumes:
      - ollama_user2:/root/.ollama
    environment:
      - OLLAMA_KEEP_ALIVE=30
      - OLLAMA_HOST=0.0.0.0:11434

volumes:
  ollama_user1:
  ollama_user2:
```

## Troubleshooting Configuration Issues

| Issue | Possible Solution |
|-------|------------------|
| Model loads slowly | Check `OLLAMA_NUM_THREAD` and `OLLAMA_COMPUTE_TYPE` |
| High memory usage | Reduce context size or use smaller models |
| Network timeout | Increase `OLLAMA_TIMEOUT` or check firewall |
| Permission errors | Check file ownership of `OLLAMA_MODELS` directory |

## Next Steps

After configuring Ollama:
- [Explore available models](models.md)
- [Set up GPU acceleration](gpu-setup.md)
- [Try the Open WebUI](open-webui.md) for a graphical interface
- [Integrate Ollama in your DevOps workflow](devops-usage.md)