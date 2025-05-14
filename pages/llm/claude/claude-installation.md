# Claude Installation Guide

This guide provides step-by-step instructions for installing and configuring Claude in both Linux and Windows Subsystem for Linux (WSL) environments.

## Linux Installation

### Prerequisites
- Python 3.8 or higher
- pip package manager
- git

### Steps

1. Create a virtual environment:
```bash
python3 -m venv claude-env
source claude-env/bin/activate
```

2. Install Claude CLI:
```bash
pip install anthropic
```

3. Set up your API key:
```bash
export ANTHROPIC_API_KEY='your-api-key'
```

4. Add to your ~/.bashrc or ~/.zshrc for persistence:
```bash
echo 'export ANTHROPIC_API_KEY="your-api-key"' >> ~/.bashrc
source ~/.bashrc
```

## WSL Installation

### Prerequisites
- WSL2 installed and configured
- Ubuntu or Debian-based distribution
- Python 3.8 or higher

### Steps

1. Update WSL system:
```bash
wsl -d Ubuntu
sudo apt update && sudo apt upgrade -y
```

2. Install Python dependencies:
```bash
sudo apt install python3-pip python3-venv -y
```

3. Follow the same steps as Linux installation above.

## Claude Desktop Application

For a graphical interface to Claude:

1. Install Node.js dependencies:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
```

2. Clone and build the desktop application:
```bash
git clone https://github.com/anthropics/claude-desktop
cd claude-desktop
npm install
npm run build
```

3. Start the application:
```bash
npm start
```

## Role Configuration and Project Initialization

### Setting Up Project Roles

Claude can be configured with different roles for various project contexts. Here's how to set up roles:

1. Create a claude-config.json in your project root:
```json
{
  "roles": {
    "code_reviewer": {
      "description": "Reviews code for best practices and security issues",
      "temperature": 0.7,
      "max_tokens": 1024
    },
    "documentation_writer": {
      "description": "Generates and updates technical documentation",
      "temperature": 0.3,
      "max_tokens": 2048
    },
    "architect": {
      "description": "Provides architectural guidance and system design",
      "temperature": 0.4,
      "max_tokens": 1500
    }
  }
}
```

2. Initialize Claude with a specific role:
```python
import anthropic
import json

def initialize_claude_with_role(role_name):
    with open('claude-config.json', 'r') as f:
        config = json.load(f)
    
    if role_name not in config['roles']:
        raise ValueError(f"Role {role_name} not found in configuration")
    
    role_config = config['roles'][role_name]
    
    return anthropic.Client(
        api_key=os.getenv("ANTHROPIC_API_KEY"),
        default_parameters={
            'temperature': role_config['temperature'],
            'max_tokens_to_sample': role_config['max_tokens']
        }
    )
```

### Initializing Claude for Existing Projects

To initialize Claude for an existing codebase:

1. Create a project context file:
```python
def create_project_context():
    context = {
        'project_structure': [],
        'dependencies': {},
        'configuration': {}
    }
    
    # Scan project structure
    for root, dirs, files in os.walk('.'):
        if '.git' in dirs:
            dirs.remove('.git')
        context['project_structure'].extend(
            os.path.join(root, file) for file in files
        )
    
    # Parse dependency files
    if os.path.exists('requirements.txt'):
        with open('requirements.txt', 'r') as f:
            context['dependencies']['python'] = f.read()
    
    if os.path.exists('package.json'):
        with open('package.json', 'r') as f:
            context['dependencies']['node'] = json.load(f)
    
    return context
```

2. Initialize Claude with project context:
```python
def initialize_claude_for_project():
    context = create_project_context()
    claude = anthropic.Client(api_key=os.getenv("ANTHROPIC_API_KEY"))
    
    # Initialize system message with project context
    system_message = f"""Project Context:
    - Structure: {len(context['project_structure'])} files
    - Dependencies: {', '.join(context['dependencies'].keys())}
    - Configuration: {context['configuration']}
    """
    
    return claude, system_message
```

3. Usage example:
```python
# Initialize Claude as a code reviewer for your project
claude = initialize_claude_with_role('code_reviewer')
claude, context = initialize_claude_for_project()

# Now you can use Claude with project awareness
response = claude.messages.create(
    model="claude-3-opus-20240229",
    system=context,
    messages=[{
        "role": "user",
        "content": "Review the code in src/main.py for security issues"
    }]
)
```

### Best Practices for Role Configuration

1. **Role Separation**
   - Keep roles focused and specific
   - Define clear boundaries between roles
   - Use appropriate temperature settings for each role

2. **Context Management**
   - Regularly update project context
   - Keep system messages concise but informative
   - Include relevant project-specific guidelines

3. **Version Control**
   - Track role configurations in version control
   - Document role changes and their purposes
   - Use environment variables for sensitive settings

## Best Practices

1. **API Key Security**
   - Never commit API keys to version control
   - Use environment variables or secure key management
   - Rotate keys periodically

2. **Virtual Environment**
   - Always use virtual environments for isolation
   - Keep dependencies updated
   - Use requirements.txt for project dependencies

3. **Error Handling**
   ```python
   try:
       import anthropic
       claude = anthropic.Client(api_key=os.getenv("ANTHROPIC_API_KEY"))
   except Exception as e:
       logging.error(f"Failed to initialize Claude: {e}")
   ```

## Troubleshooting

Common issues and solutions:

1. **API Key Issues**
   - Verify key is correctly set in environment
   - Check key permissions and quotas
   - Ensure no whitespace in key string

2. **Installation Errors**
   - Update pip: `pip install --upgrade pip`
   - Check Python version compatibility
   - Verify system dependencies

3. **WSL-Specific Issues**
   - Enable WSL2: `wsl --set-version Ubuntu`
   - Check WSL integration in VS Code
   - Verify network connectivity

## Resources

- [Official Claude Documentation](https://docs.anthropic.com)
- [Claude API Reference](https://docs.anthropic.com/claude/reference)
- [WSL Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)