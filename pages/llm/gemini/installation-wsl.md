# Installing Gemini on WSL2

This guide covers setting up Google Gemini on Windows Subsystem for Linux (WSL2), providing a Linux environment on Windows systems for DevOps professionals.

## Prerequisites

- Windows 10 version 2004+ or Windows 11
- WSL2 installed and configured
- A Linux distribution installed via WSL (Ubuntu recommended)
- Python 3.9+ installed on your WSL distribution
- A Google Cloud account with Gemini API access

## Installation Steps

### 1. Prepare Your WSL Environment

First, ensure your WSL environment is up-to-date:

```bash
# Open your WSL terminal
wsl

# Update your Linux distribution
sudo apt update && sudo apt upgrade -y

# Install Python dependencies
sudo apt install -y python3-pip python3-venv python3-dev build-essential
```

### 2. Create a Python Virtual Environment

```bash
# Navigate to your home directory or preferred project directory
cd ~

# Create a directory for your Gemini projects
mkdir -p gemini-projects && cd gemini-projects

# Create a virtual environment
python3 -m venv gemini-env

# Activate the environment
source gemini-env/bin/activate
```

### 3. Install Google Generative AI SDK

```bash
# Upgrade pip
pip install --upgrade pip

# Install the Gemini Python SDK
pip install google-generativeai

# For more advanced features with Vertex AI
pip install -U "google-cloud-aiplatform[stable]"
```

### 4. Configure Authentication

#### Using API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey) in your Windows browser
2. Create and copy your API key
3. In your WSL terminal, add to your environment:

```bash
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

#### Using Service Account (Production)

```bash
# Download your service account key to your Windows filesystem
# For example to C:\Users\YourName\Documents\service-account.json

# Create directory for credentials in WSL
mkdir -p ~/.config/gcloud

# Copy the file to your WSL filesystem
cp /mnt/c/Users/YourName/Documents/service-account.json ~/.config/gcloud/

# Set the environment variable
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/service-account.json"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Install Google Cloud CLI (Optional but Recommended)

```bash
# Download and install the Google Cloud CLI
curl https://sdk.cloud.google.com | bash

# Restart your shell
exec -l $SHELL

# Initialize gcloud
gcloud init

# Install AI Platform components
gcloud components install ai-platform
```

### 6. Verify Installation

Create a test file:

```bash
cat > test_gemini.py << 'EOF'
import google.generativeai as genai
import os

# Configure the API key
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Test the API
model = genai.GenerativeModel('gemini-pro')
result = model.generate_content("Create a brief explanation of what WSL2 is for DevOps engineers")

print(result.text)
EOF

# Run the test
python test_gemini.py
```

## WSL-Specific Considerations

### Filesystem Performance

For best performance when working with large projects:

```bash
# Store projects in the Linux filesystem, not Windows
mkdir -p ~/gemini-projects

# Avoid working from /mnt/c/ when possible for performance-sensitive tasks
```

### GPU Acceleration for ML Workloads

WSL2 supports GPU acceleration, which can improve performance for large ML operations:

1. Install the latest NVIDIA CUDA drivers on Windows
2. Install CUDA support in your WSL distribution:

```bash
sudo apt install -y nvidia-cuda-toolkit
```

3. Verify GPU access from WSL:

```bash
nvidia-smi
```

### Windows/WSL Integration

You can integrate Gemini with both Windows and Linux tools:

```bash
# Create a Windows alias for your Gemini environment (add to Windows PowerShell profile)
function gemini-wsl { wsl -d Ubuntu -u your-username "cd ~/gemini-projects && source gemini-env/bin/activate && python3 $args" }
```

## Troubleshooting WSL-Specific Issues

1. **Network Connectivity Issues**:
   ```bash
   # If you encounter network issues, edit /etc/resolv.conf
   sudo nano /etc/resolv.conf
   # Add or modify: nameserver 8.8.8.8
   ```

2. **File Permission Problems**:
   ```bash
   # Fix permissions for key files
   chmod 600 ~/.config/gcloud/service-account.json
   ```

3. **WSL Memory Limitations**:
   Create a `.wslconfig` file in your Windows user directory:
   ```
   [wsl2]
   memory=8GB
   processors=4
   ```