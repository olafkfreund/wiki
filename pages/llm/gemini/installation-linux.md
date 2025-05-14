# Installing Gemini on Linux

This guide covers how to set up Google Gemini on Linux distributions for DevOps automation and cloud infrastructure management.

## Prerequisites

- Python 3.9 or higher
- pip (Python package manager)
- A Google Cloud account with Gemini API access
- Google Cloud CLI (optional, but recommended)

## Installation Steps

### 1. Set Up Python Environment

It's recommended to use a virtual environment:

```bash
# Create a virtual environment
python -m venv gemini-env

# Activate the environment
source gemini-env/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### 2. Install Google Gemini SDK

Install the official Python SDK:

```bash
pip install google-generativeai
```

For AI Studio integration:

```bash
pip install -U "google-cloud-aiplatform[stable]"
```

### 3. Configure Authentication

There are two main methods for authentication:

#### Option A: API Key (Simplest)

1. Visit [Google AI Studio](https://aistudio.google.com/) and create an API key
2. Store the key securely in your environment:

```bash
export GOOGLE_API_KEY="your-api-key-here"
```

To make this permanent, add to your `.bashrc` or `.zshrc`:

```bash
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

#### Option B: Service Account (For Production)

1. Create a service account in Google Cloud Console
2. Grant appropriate permissions (Vertex AI User or similar)
3. Download the service account key JSON file
4. Set the environment variable:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### 4. Verify Installation

Create a simple test script `test_gemini.py`:

```python
import google.generativeai as genai
import os

# Configure the API key
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Test the API with a simple prompt
model = genai.GenerativeModel('gemini-pro')
result = model.generate_content("Write a simple Terraform configuration for an AWS S3 bucket")

print(result.text)
```

Run the script:

```bash
python test_gemini.py
```

## Installing Additional Components

### NotebookML

For NotebookML integration:

```bash
pip install notebookml
pip install jupyter
```

### Gemini for CLI

For a command-line interface to Gemini:

```bash
pip install google-cloud-aiplatform[stable]
gcloud components install ai-platform
```

## Troubleshooting

### Common Issues

1. **API Key Not Found**: Ensure your environment variable is correctly set
   ```bash
   echo $GOOGLE_API_KEY
   # If empty, set it again
   ```

2. **Library Conflicts**: If you encounter dependency conflicts:
   ```bash
   pip install --upgrade google-generativeai --force-reinstall
   ```

3. **Quota Exceeded**: Check your quota usage in Google Cloud Console
   ```bash
   # For API-based usage
   gcloud ai operations list
   ```

4. **SSL Certificate Issues**: Update certificates:
   ```bash
   pip install --upgrade certifi
   ```

## System Integration

For DevOps workflows, you can install the Gemini CLI:

```bash
# Install the official Gemini CLI
pip install gemini-cli

# Verify installation
gemini --version
```

This tool allows you to use Gemini directly in shell scripts and automation workflows.