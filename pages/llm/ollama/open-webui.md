# Open WebUI Integration for Ollama

This guide covers the installation, configuration, and usage of Open WebUI with Ollama, providing a user-friendly graphical interface for interacting with your local large language models.

## What is Open WebUI?

Open WebUI (formerly Ollama WebUI) is an open-source web interface designed specifically for Ollama. It provides:

- A chat-like interface for interacting with models
- File upload and RAG capabilities
- Multi-modal support (text and images)
- Vision features for supported models
- Prompt templates and history
- User management
- API integrations
- Custom model configurations

## Prerequisites

Before installing Open WebUI, ensure you have:

1. A working Ollama installation (follow the [installation guide](installation.md))
2. Docker and Docker Compose (recommended for easy setup)
3. 4GB+ RAM available (in addition to what Ollama requires)
4. At least one model installed in Ollama
5. Ollama running and accessible on port 11434

## Installation Methods

### Method 1: Docker (Recommended)

The easiest way to install Open WebUI is using Docker:

```bash
# Pull the latest Open WebUI image
docker pull ghcr.io/open-webui/open-webui:latest

# Run Open WebUI container connecting to local Ollama
docker run -d --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
  -v open-webui-data:/app/backend/data \
  ghcr.io/open-webui/open-webui:latest
```

Access the interface at http://localhost:3000

### Method 2: Docker Compose

Create a `docker-compose.yml` file containing both Ollama and Open WebUI:

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

Deploy with:

```bash
docker compose up -d
```

Access the interface at http://localhost:3000

### Method 3: Manual Installation

For users who prefer not to use Docker:

```bash
# Clone the repository
git clone https://github.com/open-webui/open-webui.git
cd open-webui

# Install backend dependencies
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env to set OLLAMA_API_BASE_URL=http://localhost:11434/api

# Start the backend
uvicorn main:app --host 0.0.0.0 --port 8080

# In another terminal, install and start the frontend
cd ../frontend
npm install
npm run dev
```

Access the interface at the URL provided by the frontend development server.

## Configuration Options

### Environment Variables

Open WebUI can be configured with various environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `OLLAMA_API_BASE_URL` | URL of Ollama API | `http://localhost:11434/api` |
| `PORT` | Port for the web interface | `8080` |
| `HOST` | Host binding for the interface | `0.0.0.0` |
| `DATA_DIR` | Directory for storing data | `/app/backend/data` |
| `ENABLE_SIGNUP` | Allow new users to register | `true` |
| `ENABLE_AUTH` | Enable authentication | `false` |
| `LOG_LEVEL` | Logging detail level | `error` |

For Docker deployments, pass these as environment variables:

```bash
docker run -d --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
  -e ENABLE_AUTH=true \
  -e LOG_LEVEL=info \
  -v open-webui-data:/app/backend/data \
  ghcr.io/open-webui/open-webui:latest
```

### Authentication

To enable multi-user authentication:

1. Set `ENABLE_AUTH=true` in your environment variables
2. Set `ENABLE_SIGNUP=true` to allow new user registration (can be disabled later)
3. Open the web interface and create your first admin user
4. Set `ENABLE_SIGNUP=false` to prevent further registrations if desired

### Persistent Storage

For persistent storage of conversations, settings, and users:

```bash
docker run -d --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
  -v ./open-webui-data:/app/backend/data \
  ghcr.io/open-webui/open-webui:latest
```

## Using Open WebUI

### Initial Setup

1. Open your browser and navigate to http://localhost:3000 (or your configured port)
2. If authentication is enabled, create an account or log in
3. In the sidebar, you should see available models from your Ollama instance
4. If no models appear, check that Ollama is running and accessible

### Basic Chat Interface

The Open WebUI interface includes:

- **Left sidebar**: Models, conversations, and settings
- **Main chat area**: Messages between you and the model
- **Input area**: Text field for sending prompts to the model
- **Model settings**: Configuration panel for adjusting model parameters

### Advanced Features

#### Custom Model Parameters

To customize model parameters for a specific conversation:

1. Click on the model name in the top bar of the chat
2. Adjust parameters:
   - **Temperature**: Controls randomness (0.0-2.0)
   - **Top P**: Nucleus sampling threshold (0.0-1.0)
   - **Maximum length**: Limits response length
   - **Context window**: Sets available context tokens
3. Save settings to apply them to the current conversation

#### RAG (Retrieval-Augmented Generation)

Enable RAG capabilities for improved responses with external knowledge:

1. In the sidebar, navigate to "RAG" section
2. Click "Upload files" to add documents (PDFs, text files, etc.)
3. Create a new collection and add your documents
4. When chatting, toggle the RAG feature to use your document collection
5. Ask questions related to your documents to see context-aware responses

#### Chat Templates

Create templates for common prompts:

1. Navigate to "Templates" in the sidebar
2. Click "New Template"
3. Define your template with placeholder variables
4. Save and use these templates in conversations

#### Vision Support

For models that support image input (like LLaVA):

1. Ensure you have a multimodal model like `llava` installed
2. In the chat interface, click the upload button (📎)
3. Select an image to upload
4. Ask questions about the image

## DevOps Team Setup

For teams using Ollama in DevOps workflows:

### Collaborative Setup

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
      - ENABLE_AUTH=true
      - ENABLE_SIGNUP=false
    depends_on:
      - ollama
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
      - caddy-config:/config
    depends_on:
      - open-webui

volumes:
  ollama-data:
  open-webui-data:
  caddy-data:
  caddy-config:
```

With a `Caddyfile`:

```
ollama.example.com {
    reverse_proxy open-webui:8080
    tls internal
}
```

### Custom DevOps Modelfile

Create a special Modelfile for your team:

```
# Modelfile - Save as ./modelfiles/DevOpsAssistant
FROM codellama:latest

# Configure parameters
PARAMETER temperature 0.2
PARAMETER top_p 0.9

# System prompt
SYSTEM You are an expert DevOps assistant specialized in infrastructure as code, 
CI/CD pipelines, cloud platforms, and Kubernetes. You provide practical solutions 
for DevOps challenges with secure, modern best practices.
You focus on AWS, Azure, and GCP platforms, helping with Terraform, CloudFormation,
Bicep, Docker, Kubernetes, GitHub Actions, and Azure DevOps.
```

Build the model:

```bash
docker exec -it ollama ollama create devops-assistant -f /modelfiles/DevOpsAssistant
```

## Security Considerations

When deploying Open WebUI:

1. **Authentication**: Always enable authentication in production
2. **Network access**: Limit access using a reverse proxy with TLS
3. **User management**: Control who has access to the interface
4. **Document handling**: Be aware that uploaded documents are stored in the data volume
5. **API security**: Protect the Ollama API endpoint from unauthorized access

### Securing with Nginx

Example `nginx.conf` for securing Open WebUI:

```nginx
server {
    listen 80;
    server_name ollama.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name ollama.example.com;

    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;

    # Basic authentication (optional additional layer)
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://open-webui:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Cannot connect to Ollama" error | Verify Ollama is running: `curl http://localhost:11434/api/tags` |
| Models not appearing | Ensure `OLLAMA_API_BASE_URL` is correctly set |
| File uploads failing | Check that the data directory is writable |
| Authentication issues | Clear browser cache or check user database |
| Slow performance | Adjust model parameters or upgrade hardware |

## Extending Open WebUI

### API Access

Open WebUI provides its own API that can be accessed at:

```
http://localhost:3000/api/docs
```

This Swagger UI allows for programmatic interaction with the interface.

### Custom Plugins

You can extend Open WebUI with custom plugins:

1. Clone the repository
2. Create a new directory in `backend/plugins/`
3. Implement the plugin interface
4. Add your plugin to the configuration

## Next Steps

After setting up Open WebUI:

1. [Customize models](models.md) for specific use cases
2. [Optimize GPU acceleration](gpu-setup.md) for better performance
3. [Implement DevOps workflows](devops-usage.md) using the web interface
4. Create team-specific templates and RAG collections

## Additional Resources

- [Open WebUI GitHub Repository](https://github.com/open-webui/open-webui)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [Docker Hub](https://hub.docker.com/r/openwebui/open-webui)