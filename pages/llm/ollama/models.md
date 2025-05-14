# Ollama Models and Fine-tuning

This guide covers the available models in Ollama, how to use them, and techniques for customizing models to suit your specific requirements.

## Available Models

Ollama supports a variety of open-source LLMs. Here are some of the most commonly used models:

### General-Purpose Models

| Model | Size | Description | Command |
|-------|------|-------------|---------|
| Llama 2 | 7B to 70B | Meta's general-purpose model | `ollama pull llama2` |
| Mistral | 7B | High-quality open-source model | `ollama pull mistral` |
| Mixtral | 8x7B | Mixture-of-experts model | `ollama pull mixtral` |
| Phi-2 | 2.7B | Microsoft's compact model | `ollama pull phi` |
| Neural Chat | 7B | Optimized for chat | `ollama pull neural-chat` |
| Vicuna | 7B to 33B | Fine-tuned LLaMa model | `ollama pull vicuna` |

### Code-Specialized Models

| Model | Size | Description | Command |
|-------|------|-------------|---------|
| CodeLlama | 7B to 34B | Code-focused Llama variant | `ollama pull codellama` |
| WizardCoder | 7B to 34B | Fine-tuned for code tasks | `ollama pull wizardcoder` |
| DeepSeek Coder | 6.7B to 33B | Specialized for code | `ollama pull deepseek-coder` |

### Small/Efficient Models

| Model | Size | Description | Command |
|-------|------|-------------|---------|
| TinyLlama | 1.1B | Compact model for limited resources | `ollama pull tinyllama` |
| Gemma | 2B to 7B | Google's lightweight model | `ollama pull gemma` |
| Phi-2 | 2.7B | Efficient and compact | `ollama pull phi` |

### Multilingual Models

| Model | Description | Command |
|-------|-------------|---------|
| BLOOM | Multilingual capabilities | `ollama pull bloom` |
| Qwen | Chinese and English | `ollama pull qwen` |
| Japanese Stable LM | Japanese language | `ollama pull stablej` |

## Model Management

### Listing Models

```bash
# List all downloaded models
ollama list
```

### Pulling Models

```bash
# Pull a specific model version
ollama pull mistral:7b-v0.1
```

### Removing Models

```bash
# Remove a model
ollama rm mistral
```

## Model Parameters

Control model behavior with these parameters:

| Parameter | Description | Range |
|-----------|-------------|-------|
| `temperature` | Controls randomness | 0.0 - 2.0 |
| `top_p` | Nucleus sampling threshold | 0.0 - 1.0 |
| `top_k` | Limits vocabulary to top K tokens | 1 - 100+ |
| `context_length` | Maximum context window size | Model dependent |
| `seed` | Random seed for reproducibility | Any integer |

Example usage:

```bash
# Run a model with specific parameters
ollama run mistral --temperature 0.7 --top_p 0.9
```

## Customizing Models with Modelfiles

Ollama uses Modelfiles (similar to Dockerfiles) to create custom model configurations.

### Basic Modelfile Example

```
FROM mistral:latest
PARAMETER temperature 0.7
SYSTEM You are an expert DevOps engineer specializing in cloud infrastructure.
```

Save this in a file named `Modelfile` and create a custom model:

```bash
ollama create devops-assistant -f ./Modelfile
ollama run devops-assistant
```

### Advanced Modelfile Example

```
FROM codellama:latest
PARAMETER temperature 0.3
PARAMETER top_p 0.8
PARAMETER stop "```"
TEMPLATE """
<system>
You are a senior software developer specialized in infrastructure as code, container orchestration, and CI/CD pipelines.
</system>

<user>
{{.Prompt}}
</user>

<assistant>
"""
```

### Modelfile Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `FROM` | Base model | `FROM mistral:latest` |
| `PARAMETER` | Set inference parameter | `PARAMETER temperature 0.7` |
| `SYSTEM` | Set system message | `SYSTEM You are a helpful assistant` |
| `TEMPLATE` | Define chat template | `TEMPLATE <s>{{.System}}</s>{{.Prompt}}` |
| `ADAPTER` | Apply LoRA adapter | `ADAPTER ./adapter.bin` |
| `MESSAGE` | Add example conversation | `MESSAGE user "Hi"` |
| `PROMPT` | Default prompt | `PROMPT Answer in bullet points` |
| `LICENSE` | Specify model license | `LICENSE MIT` |

## Fine-tuning with Custom Data

While Ollama doesn't directly support fine-tuning, you can use pre-fine-tuned models and adapt them with Modelfiles.

### Using External Fine-tuned Models

1. Fine-tune a model using an external tool like [LLaMA Factory](https://github.com/hiyouga/LLaMA-Factory)
2. Convert the model to GGUF format
3. Import into Ollama:

```bash
# Import a fine-tuned model
ollama create custom-model -f Modelfile
```

With Modelfile:

```
FROM ./path/to/fine-tuned-model.gguf
PARAMETER temperature 0.7
```

### Behavior Fine-tuning with Examples

You can "soft fine-tune" model behavior by providing examples in the Modelfile:

```
FROM mistral:latest
SYSTEM You are a DevOps automation expert who explains complex concepts clearly.

# Include examples of desired behavior
MESSAGE user "How can I automate AWS infrastructure provisioning?"
MESSAGE assistant "For AWS infrastructure automation, I recommend these approaches:

1. **Terraform**: Infrastructure as Code (IaC) tool with declarative configuration
   - Maintains state of resources
   - Supports modules for reusability
   - Works with multiple cloud providers

2. **AWS CloudFormation**: Native AWS IaC service
   - JSON/YAML templates
   - Stack management with change sets
   - Deep integration with AWS services

3. **AWS CDK**: Define infrastructure using familiar programming languages
   - TypeScript, Python, Java support
   - Compiles to CloudFormation
   - Object-oriented approach

For most teams, Terraform offers the best balance of flexibility and functionality."
```

## Model Quantization

Ollama supports various quantization levels to balance performance and resource usage:

| Quantization | Size Impact | Performance | Command |
|--------------|-------------|------------|---------|
| Q4_K_M | 3-4GB (7B model) | Good | `ollama pull mistral:7b-q4_k_m` |
| Q5_K_M | 4-5GB (7B model) | Better | `ollama pull mistral:7b-q5_k_m` |
| Q8_0 | 7-8GB (7B model) | Best | `ollama pull mistral:7b-q8_0` |

For resource-constrained environments, use more aggressive quantization:

```bash
# Pull a highly quantized model
ollama pull tinyllama:1.1b-q4_0
```

## RAG (Retrieval-Augmented Generation)

Enhance models with external knowledge using RAG:

```bash
#!/bin/bash

# Simple RAG implementation with Ollama
MODEL="mistral:latest"
QUERY="What are the key components of a Kubernetes cluster?"
CONTEXT_FILE="kubernetes-docs.txt"

# Get context from a document
CONTEXT=$(grep -i "kubernetes components\|control plane\|node components" "$CONTEXT_FILE" | head -n 15)

# Create prompt with context
PROMPT="Based on the following information:\n\n$CONTEXT\n\nPlease answer: $QUERY"

# Send to Ollama
ollama run $MODEL --prompt "$PROMPT"
```

## Practical Model Selection Guide

| Use Case | Recommended Model | Why |
|----------|------------------|-----|
| General chat | `mistral:7b` | Good balance of size and capability |
| Code assistance | `codellama:7b` | Specialized for code understanding/generation |
| Resource-constrained | `tinyllama:1.1b` | Small memory footprint |
| Technical documentation | `neural-chat:7b` | Clear instruction following |
| Complex reasoning | `mixtral:8x7b` or `llama2:70b` | Sophisticated reasoning capabilities |

## DevOps-Specific Model Configuration

For DevOps-specific tasks, create a specialized model configuration:

```
# DevOps Assistant Modelfile
FROM codellama:latest
PARAMETER temperature 0.3
PARAMETER top_p 0.8
SYSTEM You are an expert in DevOps practices, cloud infrastructure, CI/CD pipelines, and infrastructure as code. You provide concise, accurate answers with practical examples when appropriate. You're familiar with AWS, Azure, GCP, Kubernetes, Docker, Terraform, Ansible, GitHub Actions, and other DevOps tools.

# Example prompt for debugging
PROMPT """
I'm encountering the following issue with my CI/CD pipeline or infrastructure:

{{.Input}}

Please help me by:
1. Identifying potential causes
2. Suggesting troubleshooting steps
3. Recommending a solution
4. Providing a brief example if applicable
"""
```

Create this model:

```bash
ollama create devops-assistant -f ./DevOps-Modelfile
```

## Next Steps

Now that you understand Ollama's models:

1. [Configure GPU acceleration](gpu-setup.md) to speed up model inferencing
2. [Set up Open WebUI](open-webui.md) for a graphical interface
3. [Explore DevOps usage examples](devops-usage.md) for practical applications