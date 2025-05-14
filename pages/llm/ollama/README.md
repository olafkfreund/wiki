# Ollama: Run Large Language Models Locally

Ollama is an open-source framework that allows you to run large language models (LLMs) locally on your own hardware. It provides a simplified way to download, configure, and interact with various open-source LLMs without requiring complex setup or cloud resources.

## Overview

Ollama lets you:
- Run various open-source LLMs locally on your own hardware
- Utilize GPU acceleration when available (NVIDIA, AMD, or Intel)
- Create and customize model configurations
- Interact with models through a simple API
- Deploy models in containers
- Integrate LLMs into your DevOps workflows

## When to Use Ollama

Ollama is particularly useful when:

- **Privacy is a concern**: All data stays on your local machine
- **Internet connectivity is limited**: Models run offline after initial download
- **Cost is a factor**: No subscription or usage fees
- **Control is important**: Full control over model parameters and behavior
- **DevOps automation**: Including code review, documentation generation, and testing

## Key Features

- **Easy Setup**: Simple installation process across Linux, macOS, and Windows
- **Model Library**: Access to various models like Llama 2, Mistral, CodeLlama, and more
- **API Access**: RESTful API for integrating with custom applications
- **GPU Acceleration**: Support for NVIDIA CUDA, AMD ROCm, and Intel OneAPI
- **Docker Support**: Container-based deployment for consistent environments
- **Model Customization**: Create custom model configurations with Modelfiles

## Documentation Sections

Navigate through the following sections to learn more about Ollama:

1. [Installation Guide](installation.md) - Install Ollama on Linux, NixOS, or Docker
2. [Configuration](configuration.md) - Configure Ollama for optimal performance
3. [Models and Fine-tuning](models.md) - Details about available models and customization
4. [DevOps Usage Examples](devops-usage.md) - Real-world examples for DevOps engineers
5. [Docker Setup](docker-setup.md) - Running Ollama in Docker containers
6. [GPU Setup Guide](gpu-setup.md) - Configure GPU acceleration for NVIDIA, AMD, and Intel
7. [Open WebUI Integration](open-webui.md) - Adding a web interface to Ollama

## Quickstart

```bash
# Install Ollama (Linux)
curl -fsSL https://ollama.com/install.sh | sh

# Pull and run the Mistral model
ollama run mistral

# Start API server
ollama serve
```

For detailed instructions, please refer to the [Installation Guide](installation.md).