# Repository Templates and Examples

## Project README Template
```markdown
# Project Name

Brief project description and purpose.

## Quick Start
\`\`\`bash
make setup
make test
make run
\`\`\`

## Architecture
[Link to architecture diagram]

## Development
- Prerequisites
- Local setup
- Testing
- Deployment

## Infrastructure
- Cloud resources
- Environment variables
- Deployment pipeline

## Security
- Access management
- Security scanning
- Compliance checks

## Operations
- Monitoring
- Alerting
- Incident response
```

## Pull Request Template
```markdown
## Description
What does this PR do?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance tests

## Security
- [ ] Security impact assessed
- [ ] Secrets scanned
- [ ] Dependencies updated

## Compliance
- [ ] Regulatory requirements met
- [ ] Documentation updated
- [ ] ADRs created/updated
```

## Architecture Decision Record (ADR) Template
```markdown
# Title

## Status
Proposed/Accepted/Deprecated/Superseded

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?

## Compliance Impact
Any regulatory or security implications?
```

## Runbook Template
```markdown
# Operation Name

## Overview
Brief description of this operation

## Prerequisites
- Required access
- Required tools
- Required knowledge

## Steps
1. Step one
   - Details
   - Commands
2. Step two
   - Details
   - Commands

## Verification
How to verify success

## Rollback
Steps to undo changes

## Monitoring
What to monitor during operation
```

## Environment Configuration Template
```yaml
# .env.template
APP_NAME=servicename
ENVIRONMENT=development
LOG_LEVEL=info

# Cloud Provider
CLOUD_REGION=
CLOUD_PROJECT=

# Security
SECRET_ROTATION_DAYS=30
COMPLIANCE_LEVEL=

# Monitoring
METRICS_ENDPOINT=
TRACING_ENABLED=true
```

## Infrastructure Documentation Template
```markdown
# Infrastructure Overview

## Resources
- VPC/VNET configuration
- Kubernetes clusters
- Databases
- Storage
- CDN/Caching

## Security
- Network policies
- IAM configurations
- Encryption settings

## Costs
- Resource quotas
- Cost optimization
- Budget alerts

## Disaster Recovery
- Backup strategy
- Recovery procedures
- Failover configuration
```

## Local Development Setup
```bash
#!/bin/bash
# setup.sh

# Install dependencies
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Set up development tools
npm install -g commitizen
pre-commit install

# Configure git hooks
git config core.hooksPath .githooks

# Set up environment
cp .env.template .env

echo "Development environment setup complete"
```