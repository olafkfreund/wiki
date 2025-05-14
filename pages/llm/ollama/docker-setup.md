# Running Ollama in Docker

This guide provides detailed instructions for deploying Ollama in Docker containers, enabling consistent, isolated environments and streamlined deployment across different systems.

## Why Use Ollama with Docker?

Docker provides several advantages for running Ollama:

- **Isolation**: Run Ollama in a contained environment without affecting the host system
- **Portability**: Deploy the same Ollama setup across different environments
- **Resource control**: Limit CPU, memory, and GPU resources allocated to Ollama
- **Version management**: Easily switch between different Ollama versions
- **Orchestration**: Integrate with Kubernetes or Docker Swarm for scaling

## Prerequisites

Before getting started, ensure you have:

1. Docker installed on your system:
   ```bash
   # Linux
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER
   # Log out and back in to apply group changes
   
   # Verify Docker installation
   docker --version
   ```

2. Docker Compose (optional but recommended):
   ```bash
   # Install Docker Compose V2
   sudo apt update && sudo apt install -y docker-compose-plugin
   
   # Verify installation
   docker compose version
   ```

3. At least 8GB of RAM and sufficient disk space for models (~5-10GB per model)

## Basic Ollama Docker Setup

### Using Official Docker Image

Pull and run the official Ollama Docker image:

```bash
# Pull the latest Ollama image
docker pull ollama/ollama:latest

# Create a volume for persistent storage
docker volume create ollama-data

# Run Ollama container
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v ollama-data:/root/.ollama \
  ollama/ollama
```

### Testing Your Ollama Container

```bash
# Check if the container is running
docker ps

# Download and run a model
docker exec -it ollama ollama run mistral "Hello, how are you?"

# Access the API from the host
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "What is Docker?"
}'
```

## Docker Compose Setup

A more manageable way to configure and run Ollama is using Docker Compose.

### Basic Docker Compose Configuration

Create a file named `docker-compose.yml`:

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    volumes:
      - ollama-data:/root/.ollama
    ports:
      - "11434:11434"
    restart: unless-stopped

volumes:
  ollama-data:
```

Run with:

```bash
docker compose up -d
```

### Advanced Docker Compose with Resource Limits

For more control over container resources:

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    volumes:
      - ollama-data:/root/.ollama
      - ./modelfiles:/modelfiles
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
      - OLLAMA_KEEP_ALIVE=15m
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 16G
        reservations:
          cpus: '4'
          memory: 8G
    restart: unless-stopped

volumes:
  ollama-data:
```

## GPU-Accelerated Docker Setup

### NVIDIA GPU Support

To enable NVIDIA GPU acceleration with Docker:

1. Install the NVIDIA Container Toolkit:
   ```bash
   # Add NVIDIA package repositories
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   
   # Install nvidia-container-toolkit
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   
   # Configure Docker runtime
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

2. Run Ollama with GPU support:
   ```bash
   docker run -d \
     --name ollama-gpu \
     --gpus all \
     -p 11434:11434 \
     -v ollama-data:/root/.ollama \
     ollama/ollama
   ```

### Docker Compose with NVIDIA GPUs

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-gpu
    volumes:
      - ollama-data:/root/.ollama
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_COMPUTE_TYPE=float16
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  ollama-data:
```

### AMD ROCm GPU Support

For AMD GPUs with ROCm:

```bash
docker run -d \
  --name ollama-rocm \
  --device=/dev/kfd \
  --device=/dev/dri \
  --security-opt seccomp=unconfined \
  --group-add video \
  -p 11434:11434 \
  -e OLLAMA_COMPUTE_TYPE=rocm \
  -v ollama-data:/root/.ollama \
  ollama/ollama
```

## Multi-Container Setups

### Ollama with Open WebUI

This setup combines Ollama with the Open WebUI for a more user-friendly interface:

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    volumes:
      - ollama-data:/root/.ollama
    ports:
      - "11434:11434"
    restart: unless-stopped

  open-webui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: open-webui
    volumes:
      - open-webui-data:/app/backend/data
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434/api
    depends_on:
      - ollama
    restart: unless-stopped

volumes:
  ollama-data:
  open-webui-data:
```

### Ollama for DevOps

A setup designed for DevOps workflows with Ollama and RAG capabilities:

```yaml
version: '3'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-devops
    volumes:
      - ollama-data:/root/.ollama
      - ./models:/models
      - ./devops-docs:/data
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_MODELS=/models
    restart: unless-stopped

  vector-db:
    image: chroma/chroma:latest
    container_name: chroma-db
    volumes:
      - chroma-data:/chroma/data
    ports:
      - "8000:8000"
    restart: unless-stopped

  rag-service:
    image: ghcr.io/yourusername/ollama-rag-service:latest
    container_name: rag-service
    volumes:
      - ./data:/data
    ports:
      - "5000:5000"
    environment:
      - OLLAMA_HOST=ollama:11434
      - CHROMA_HOST=vector-db:8000
    depends_on:
      - ollama
      - vector-db
    restart: unless-stopped

volumes:
  ollama-data:
  chroma-data:
```

## Docker Network Configuration

### Creating an Isolated Network

For multi-container deployments, create an isolated network:

```bash
# Create a dedicated network
docker network create ollama-network

# Run Ollama in the network
docker run -d \
  --name ollama \
  --network ollama-network \
  -p 11434:11434 \
  -v ollama-data:/root/.ollama \
  ollama/ollama
```

### Accessing Ollama from Other Containers

Other containers can access Ollama using the container name as hostname:

```bash
docker run -it --rm --network ollama-network alpine/curl \
  -X POST http://ollama:11434/api/generate \
  -d '{"model": "mistral", "prompt": "Hello!"}'
```

## Custom Ollama Docker Images

### Creating a Custom Dockerfile

Create a `Dockerfile` with pre-loaded models and custom configuration:

```dockerfile
FROM ollama/ollama:latest

# Set environment variables
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_KEEP_ALIVE=5m

# Copy custom Modelfiles
COPY ./modelfiles /modelfiles

# Pre-download models during build (optional)
RUN ollama serve & sleep 5 && \
    ollama pull mistral:7b && \
    ollama pull codellama:7b && \
    ollama create devops-assistant -f /modelfiles/DevOps-Assistant

# Expose port
EXPOSE 11434

# Default command
CMD ["ollama", "serve"]
```

Build and run your custom image:

```bash
# Build the image
docker build -t custom-ollama:latest .

# Run the container
docker run -d \
  --name custom-ollama \
  -p 11434:11434 \
  -v ollama-data:/root/.ollama \
  custom-ollama:latest
```

## Production Best Practices

### Security Considerations

1. **TLS Encryption**:
   ```yaml
   services:
     ollama:
       environment:
         - OLLAMA_TLS_CERT=/certs/cert.pem
         - OLLAMA_TLS_KEY=/certs/key.pem
       volumes:
         - ./certs:/certs
   ```

2. **Authentication** (using a reverse proxy like Nginx):
   ```
   # Example nginx.conf snippet
   server {
       listen 443 ssl;
       server_name ollama.example.com;
       
       ssl_certificate /etc/nginx/certs/cert.pem;
       ssl_certificate_key /etc/nginx/certs/key.pem;
       
       auth_basic "Ollama API";
       auth_basic_user_file /etc/nginx/.htpasswd;
       
       location / {
           proxy_pass http://ollama:11434;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

### Health Checks and Monitoring

Add health checks to your Docker Compose:

```yaml
services:
  ollama:
    # ...
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
```

## Docker Swarm and Kubernetes

### Docker Swarm Deployment

```bash
# Initialize Swarm if not already done
docker swarm init

# Deploy Ollama stack
docker stack deploy -c docker-compose.yml ollama-stack
```

### Kubernetes Deployment

Create a `kubernetes.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        volumeMounts:
        - name: ollama-data
          mountPath: /root/.ollama
        resources:
          limits:
            memory: "16Gi"
            cpu: "8"
          requests:
            memory: "8Gi"
            cpu: "4"
      volumes:
      - name: ollama-data
        persistentVolumeClaim:
          claimName: ollama-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
spec:
  selector:
    app: ollama
  ports:
  - port: 11434
    targetPort: 11434
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

Apply with:

```bash
kubectl apply -f kubernetes.yaml
```

## Troubleshooting Docker Issues

| Issue | Solution |
|-------|----------|
| Container won't start | Check logs with `docker logs ollama` |
| Permission errors | Verify volume permissions with `docker exec -it ollama ls -la /root/.ollama` |
| Network connectivity | Test with `docker exec -it ollama curl localhost:11434/api/tags` |
| Out of memory | Increase memory limits in Docker settings |
| GPU not detected | Verify the NVIDIA Container Toolkit installation and check logs |

## Next Steps

After setting up Ollama in Docker:

1. [Explore GPU acceleration](gpu-setup.md) for faster model inference
2. [Configure and optimize models](models.md) for your specific use cases
3. [Implement DevOps workflows](devops-usage.md) with Ollama
4. [Set up Open WebUI](open-webui.md) for a graphical user interface