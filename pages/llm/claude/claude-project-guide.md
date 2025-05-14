# Creating a CLAUDE.md Project Guide

A well-structured CLAUDE.md file serves as the definitive guide for how Claude should interact with your codebase. This documentation helps Claude understand your project architecture, coding conventions, and desired interaction patterns.

## Purpose of CLAUDE.md

- Provides context about your project structure and architecture
- Establishes coding conventions and style guidelines
- Defines preferred interaction patterns with Claude
- Improves code generation accuracy and quality
- Creates consistent documentation for new team members

## CLAUDE.md Structure

A comprehensive CLAUDE.md should include these sections:

1. **Project Overview**
2. **Architecture**
3. **Code Style Guidelines**
4. **File Organization**
5. **Common Patterns**
6. **Testing Conventions**
7. **API Documentation**
8. **Examples**
9. **Known Limitations/Edge Cases**

## Template with Examples

Here's a template you can use as a starting point for your own CLAUDE.md file:

```markdown
# Project Guide for Claude

## Project Overview
[Project name] is a [brief description]. It's designed to [main purpose], primarily used by [target users].

**Tech Stack:**
- Frontend: [technologies]
- Backend: [technologies]
- Database: [technology]
- Infrastructure: [Cloud provider, hosting details]

## Architecture

### System Components
- **Component A**: Handles [responsibility]
- **Component B**: Manages [responsibility]
- **Component C**: Responsible for [responsibility]

### Data Flow
[Describe how data flows through your system]

## Code Style Guidelines

### General Principles
- [List key coding principles]

### Language-Specific Guidelines
- **TypeScript/JavaScript**: [conventions]
- **Python**: [conventions] 
- **Infrastructure as Code**: [conventions]

## File Organization

```
/src
  /components      # UI components
  /services        # Business logic
  /models          # Data models
  /utils           # Helper functions
/infrastructure    # IaC files
/tests             # Test files
/docs              # Documentation
```

## Common Patterns

### Pattern 1: [Name]
[Description and example of the pattern]

```typescript
// Example code demonstrating pattern
```

### Pattern 2: [Name]
[Description and example of the pattern]

```typescript
// Example code demonstrating pattern
```

## Testing Conventions

### Unit Tests
[Describe approach to unit testing]

```typescript
// Example unit test
```

### Integration Tests
[Describe approach to integration testing]

```typescript
// Example integration test
```

## API Documentation

### External APIs
[Document external APIs used]

### Internal APIs
[Document key internal APIs]

## Examples

### Example 1: [Name]
[Complete example with explanation]

### Example 2: [Name]
[Complete example with explanation]

## Known Limitations/Edge Cases
- [List known issues or limitations]
```

## Real-World Example

Here's a simplified example for a DevOps automation tool:

```markdown
# Project Guide for Claude

## Project Overview
DevOpsAutomator is a CLI tool that automates infrastructure provisioning and application deployment across multiple cloud providers. It's used by DevOps engineers and platform teams to streamline infrastructure management.

**Tech Stack:**
- Core: Python 3.10+
- Infrastructure: Terraform, AWS CDK
- Testing: pytest, moto
- CI/CD: GitHub Actions
- Supported Clouds: AWS, Azure, GCP

## Architecture

### System Components
- **Command Parser**: Processes CLI commands and arguments
- **Cloud Adapters**: Provides unified interface to different cloud providers
- **Resource Managers**: Handles specific resource types (VMs, networks, etc.)
- **State Manager**: Tracks deployed resources and their states
- **Template Engine**: Generates IaC scripts from templates

### Data Flow
1. User issues command via CLI
2. Command Parser validates input and routes to appropriate handler
3. Cloud Adapter translates generic operations to provider-specific API calls
4. State Manager records changes

## Code Style Guidelines

### General Principles
- Type hints for all functions
- Comprehensive docstrings in Google style
- Error handling with specific exceptions
- Dependency injection for testability

### Language-Specific Guidelines
- **Python**: PEP 8 compliant, black formatting
- **Terraform**: HashiCorp style, modules for reusable components
- **YAML**: 2-space indentation, comments for complex configurations

## File Organization

```
/src
  /cli            # Command-line interface
  /adapters       # Cloud provider adapters
  /resources      # Resource type implementations
  /state          # State management
  /templates      # IaC templates
/tests            # Test files
/docs             # Documentation
/examples         # Example configurations
```

## Common Patterns

### Pattern 1: Adapter Pattern
Used to provide a unified interface to different cloud providers.

```python
class CloudAdapter(ABC):
    @abstractmethod
    def create_instance(self, spec: InstanceSpec) -> Instance:
        pass
        
class AWSAdapter(CloudAdapter):
    def create_instance(self, spec: InstanceSpec) -> Instance:
        # AWS-specific implementation
        return ec2_instance
```

### Pattern 2: Command Pattern
Used to encapsulate requests as objects.

```python
class Command(ABC):
    @abstractmethod
    def execute(self) -> Result:
        pass

class CreateResourceCommand(Command):
    def __init__(self, adapter: CloudAdapter, spec: ResourceSpec):
        self.adapter = adapter
        self.spec = spec
        
    def execute(self) -> Result:
        return self.adapter.create_resource(self.spec)
```

## Testing Conventions

### Unit Tests
Each component should have comprehensive unit tests with mocked dependencies.

```python
def test_aws_adapter_create_instance():
    # Arrange
    mock_ec2 = Mock()
    adapter = AWSAdapter(mock_ec2)
    spec = InstanceSpec(...)
    
    # Act
    result = adapter.create_instance(spec)
    
    # Assert
    assert result.id is not None
    mock_ec2.run_instances.assert_called_once()
```

### Integration Tests
Tests that verify interactions between components use moto for AWS mocking.

```python
@mock_ec2
def test_create_instance_end_to_end():
    # Test creating an instance through the entire stack
    command = CreateInstanceCommand(...)
    result = command.execute()
    
    # Verify instance was created correctly
    assert result.status == "running"
```

## Known Limitations/Edge Cases
- GCP adapter doesn't support all resource types yet
- State management can get out of sync with actual cloud state
- Rate limiting isn't implemented for bulk operations
```

## Best Practices for CLAUDE.md

1. **Keep It Updated**: Review and update CLAUDE.md as your project evolves
2. **Be Specific**: Include concrete examples rather than abstract concepts
3. **Focus on Patterns**: Highlight recurring patterns and idioms unique to your codebase
4. **Include Context**: Explain the "why" behind architectural decisions
5. **Explain Trade-offs**: Document why certain approaches were chosen over alternatives
6. **Code Navigation**: Include file paths to help locate important components
7. **Version Control**: Keep CLAUDE.md in version control with the rest of your project

## CI/CD Integration

Integrate CLAUDE.md validation and updates into your CI/CD pipeline:

```yaml
# GitHub Actions workflow example
name: Validate CLAUDE.md

on:
  push:
    paths:
      - 'CLAUDE.md'
      - 'src/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check CLAUDE.md structure
        run: python .github/scripts/validate_claude_doc.py
        
      - name: Check code examples match actual code
        run: python .github/scripts/validate_code_examples.py
```

## Using CLAUDE.md with Claude

When working with Claude on your project, you can reference CLAUDE.md:

```
I'm working on the DevOpsAutomator project. Please refer to our CLAUDE.md file 
for project conventions. Based on that, I need help implementing a new resource 
type for Azure Container Instances following our existing patterns.
```

By maintaining a detailed CLAUDE.md, you create a single source of truth for both Claude and your team, ensuring consistent, high-quality code generation that follows your project's established patterns and practices.

## Additional Resources

- [Anthropic Claude Documentation](https://docs.anthropic.com/en/docs/claude-code/tutorials)
- [GitHub - Claude Project Templates](https://github.com/anthropics/claude-code-examples)