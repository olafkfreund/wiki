# Model Context Protocol (MCP) Server Setup

This guide explains how to set up and configure an MCP server optimized for infrastructure deployment and DevOps workflows.

## What is MCP?

The Model Context Protocol (MCP) server acts as a middleware between LLMs and your development environment, providing:
- Context-aware responses
- Code analysis capabilities
- Integration with development tools
- Infrastructure-as-Code validation
- Security scanning

## Server Setup

### Prerequisites
- Docker and Docker Compose
- 4GB RAM minimum
- Git
- Python 3.8+

### Basic Installation

1. Clone the MCP server repository:
```bash
git clone https://github.com/context-labs/mcp-server
cd mcp-server
```

2. Create configuration file (config.yaml):
```yaml
server:
  port: 3000
  host: "0.0.0.0"

models:
  - name: "claude-2"
    provider: "anthropic"
    config:
      api_key: ${ANTHROPIC_API_KEY}
  - name: "gpt-4"
    provider: "openai"
    config:
      api_key: ${OPENAI_API_KEY}

tools:
  - name: "terraform-validate"
    type: "shell"
    command: "terraform validate"
  - name: "terraform-plan"
    type: "shell"
    command: "terraform plan"
  - name: "aws-check"
    type: "shell"
    command: "aws sts get-caller-identity"
```

3. Start the server:
```bash
docker-compose up -d
```

## Infrastructure Tools Integration

### Terraform Integration

```yaml
tools:
  - name: "terraform-workflow"
    type: "composite"
    steps:
      - name: "validate"
        command: "terraform validate"
      - name: "security-scan"
        command: "tfsec ."
      - name: "plan"
        command: "terraform plan"
    
  - name: "terraform-docs"
    type: "shell"
    command: "terraform-docs markdown ."
```

### Cloud Provider Integration

```yaml
tools:
  - name: "aws-validate"
    type: "composite"
    steps:
      - name: "credentials-check"
        command: "aws sts get-caller-identity"
      - name: "policy-validation"
        command: "aws iam simulate-custom-policy"

  - name: "azure-validate"
    type: "composite"
    steps:
      - name: "login-check"
        command: "az account show"
      - name: "policy-check"
        command: "az policy state list"
```

## Security Configuration

### API Key Management
```yaml
security:
  key_rotation:
    enabled: true
    interval: "7d"
  
  auth:
    type: "jwt"
    secret: ${JWT_SECRET}
    
  rate_limiting:
    enabled: true
    requests_per_minute: 60
```

### Logging Configuration
```yaml
logging:
  level: "info"
  format: "json"
  outputs:
    - type: "file"
      path: "/var/log/mcp-server.log"
    - type: "cloudwatch"
      group: "mcp-logs"
      region: "us-west-2"
```

## Best Practices

1. **Resource Management**
   - Monitor memory usage
   - Implement rate limiting
   - Use connection pooling
   - Scale horizontally when needed

2. **Security**
   - Regular key rotation
   - JWT authentication
   - Request validation
   - Input sanitization

3. **Monitoring**
   ```yaml
   monitoring:
     prometheus:
       enabled: true
       port: 9090
     alerts:
       - name: "high_memory"
         threshold: "85%"
         action: "notify"
   ```

## Example Use Cases

### Infrastructure Validation
```python
from mcp_client import MCPClient

client = MCPClient("http://localhost:3000")
result = client.validate_infrastructure("""
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  acl    = "private"
}
""")
```

### Security Scanning
```python
scan_result = client.security_scan({
    "type": "terraform",
    "path": "./infrastructure",
    "checks": ["CKV_AWS_*"]
})
```

## Troubleshooting

1. **Connection Issues**
   - Check network configurations
   - Verify port mappings
   - Validate TLS certificates

2. **Performance Issues**
   - Monitor resource usage
   - Check logging levels
   - Analyze request patterns

3. **Tool Integration Issues**
   - Verify tool installations
   - Check PATH configurations
   - Validate permissions

## Resources

- [MCP Protocol Specification](https://github.com/context-labs/mcp-spec)
- [Infrastructure Validation Guide](https://docs.mcp-server.dev/guides/infrastructure)
- [Security Best Practices](https://docs.mcp-server.dev/security)