# Terraform-docs

Terraform-docs is a utility for generating documentation from Terraform modules in various output formats.

## Installation

### Using Homebrew
```bash
brew install terraform-docs
```

### Using Go
```bash
go install github.com/terraform-docs/terraform-docs@latest
```

### Docker
```bash
docker pull quay.io/terraform-docs/terraform-docs:latest
```

## Usage

### Basic Command
```bash
terraform-docs markdown table /path/to/module
```

### Configuration File
Create `.terraform-docs.yml` in your module directory:

```yaml
formatter: "markdown table"

sections:
  show:
    - requirements
    - providers
    - inputs
    - outputs

output:
  file: "README.md"
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
```

## Integration with Git Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/sh
terraform-docs markdown table --output-file README.md ./module/
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Generate terraform docs
on:
  - pull_request

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.ref }}

    - name: Render terraform docs
      uses: terraform-docs/gh-actions@v1.0.0
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```

### Azure DevOps Pipeline
```yaml
steps:
- script: |
    curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz
    tar -xzf terraform-docs.tar.gz
    chmod +x terraform-docs
    ./terraform-docs markdown table . > README.md
  displayName: 'Generate Module Documentation'
```

## Output Formats

1. Markdown Table (default)
```bash
terraform-docs markdown table /path/to/module
```

2. Markdown Document
```bash
terraform-docs markdown document /path/to/module
```

3. JSON
```bash
terraform-docs json /path/to/module
```

4. YAML
```bash
terraform-docs yaml /path/to/module
```

## Best Practices

1. **Documentation Comments**
   ```hcl
   variable "instance_type" {
     description = "The type of EC2 instance to launch"
     type        = string
     default     = "t3.micro"
   }
   ```

2. **Required vs Optional**
   ```hcl
   variable "environment" {
     description = "(Required) The environment this resource belongs to"
     type        = string
   }

   variable "tags" {
     description = "(Optional) Additional tags for the resource"
     type        = map(string)
     default     = {}
   }
   ```

3. **Examples in Description**
   ```hcl
   variable "allowed_ports" {
     description = "List of allowed ports. Example: [80, 443]"
     type        = list(number)
     default     = [80, 443]
   }
   ```

## Common Issues and Solutions

1. **Missing Documentation**
   - Ensure all variables and outputs have descriptions
   - Use meaningful names for resources
   - Include examples where appropriate

2. **Version Conflicts**
   - Keep terraform-docs updated
   - Pin version in CI/CD pipelines
   - Check compatibility with Terraform version

3. **Output Formatting**
   - Use consistent formatting
   - Follow team conventions
   - Include all necessary sections

## Checklist

- [ ] All variables have descriptions
- [ ] All outputs have descriptions
- [ ] Required vs optional is clearly marked
- [ ] Examples are included where helpful
- [ ] Documentation is generated automatically
- [ ] CI/CD integration is configured
- [ ] Git hooks are set up (if needed)
- [ ] Version is pinned in automation
