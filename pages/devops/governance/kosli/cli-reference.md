---
description: Complete Kosli CLI command reference with examples for DevOps change tracking
keywords: kosli, cli, commands, reference, api, devops
---

# Kosli CLI Reference

## Installation

```bash
# macOS/Linux
curl -sSL https://cli.kosli.com/install.sh | sh

# Windows
irm https://cli.kosli.com/install.ps1 | iex

# Verify
kosli version
```

## Authentication

```bash
# Set environment variables
export KOSLI_API_TOKEN="your-token"
export KOSLI_ORG="your-org"

# Or pass as flags
kosli --api-token="token" --org="org" <command>
```

## Flow Commands

### Create Flow

```bash
kosli create flow <name> \
  --description "Description" \
  --template artifact \
  --visibility public

# Example
kosli create flow payment-api \
  --description "Payment processing API" \
  --template artifact
```

### List Flows

```bash
kosli list flows
```

### Get Flow Details

```bash
kosli get flow <name>

# Example
kosli get flow payment-api
```

## Artifact Commands

### Report Artifact

```bash
kosli report artifact <name> \
  --artifact-type <type> \
  --flow <flow> \
  [--build-url <url>] \
  [--commit <sha>] \
  [--git-commit-info <ref>]

# Docker image
kosli report artifact myapp:v1.0.0 \
  --artifact-type docker \
  --flow payment-api \
  --build-url "https://github.com/org/repo/actions/runs/123" \
  --commit a3b5c7d \
  --git-commit-info HEAD

# File
kosli report artifact ./dist/app.jar \
  --artifact-type file \
  --flow payment-api \
  --commit a3b5c7d

# Directory
kosli report artifact ./dist/ \
  --artifact-type dir \
  --flow payment-api
```

### Get Artifact

```bash
kosli get artifact <name> --flow <flow>

# Example
kosli get artifact myapp:v1.0.0 --flow payment-api
```

## Evidence Commands

### Report Test Evidence

```bash
kosli report evidence test junit \
  --flow <flow> \
  --name <artifact> \
  --results-file <file>

# Example
kosli report evidence test junit \
  --flow payment-api \
  --name myapp:v1.0.0 \
  --results-file test-results.xml
```

### Report Generic Evidence

```bash
kosli report evidence generic \
  --flow <flow> \
  --name <artifact> \
  --evidence-type <type> \
  [--description "<text>"] \
  [--attachments <file1>,<file2>]

# Security scan
kosli report evidence generic \
  --flow payment-api \
  --name myapp:v1.0.0 \
  --evidence-type security-scan \
  --description "Trivy vulnerability scan" \
  --attachments trivy-scan.json

# Code review
kosli report evidence generic \
  --flow payment-api \
  --name myapp:v1.0.0 \
  --evidence-type code-review \
  --description "PR #123 approved by 2 reviewers" \
  --attachments pr-123.json
```

## Deployment Commands

### Report Deployment

```bash
kosli report deployment <environment> \
  --flow <flow> \
  --name <artifact>

# Example
kosli report deployment production \
  --flow payment-api \
  --name myapp:v1.0.0
```

## Snapshot Commands

### Snapshot Kubernetes

```bash
kosli snapshot k8s <environment> \
  --namespace <namespace> \
  [--kubeconfig <path>]

# Example
kosli snapshot k8s production \
  --namespace production

# Multiple namespaces
kosli snapshot k8s production \
  --namespace app1,app2,app3
```

### Snapshot Docker

```bash
kosli snapshot docker <environment>

# Example
kosli snapshot docker staging
```

## Environment Commands

### List Environments

```bash
kosli list environments
```

### Get Environment

```bash
kosli get environment <name>

# Example
kosli get environment production
```

## Common Options

### Global Flags

```
--api-token string    Kosli API token (or KOSLI_API_TOKEN env var)
--org string          Kosli organization (or KOSLI_ORG env var)
--flow string         Flow name (or KOSLI_FLOW env var)
--debug               Enable debug logging
--dry-run             Print commands without executing
--help                Show help
```

### Common Patterns

```bash
# Set defaults via environment
export KOSLI_API_TOKEN="..."
export KOSLI_ORG="my-org"
export KOSLI_FLOW="my-app"

# Then omit flags
kosli report artifact myapp:latest --artifact-type docker
kosli report deployment production --name myapp:latest

# Debug mode
kosli --debug report artifact ...

# Dry run
kosli --dry-run report artifact ...
```

## Quick Reference

| Task | Command |
|------|---------|
| Create flow | `kosli create flow <name>` |
| Report Docker image | `kosli report artifact <image> --artifact-type docker` |
| Report test results | `kosli report evidence test junit --results-file tests.xml` |
| Report security scan | `kosli report evidence generic --evidence-type security-scan` |
| Report deployment | `kosli report deployment <env> --name <artifact>` |
| Snapshot K8s | `kosli snapshot k8s <env> --namespace <ns>` |
| List flows | `kosli list flows` |
| Get artifact details | `kosli get artifact <name> --flow <flow>` |

## Examples

### Complete CI/CD Flow

```bash
#!/bin/bash
set -e

FLOW="payment-api"
VERSION="v1.2.3"
IMAGE="myapp:${VERSION}"

# 1. Build
docker build -t ${IMAGE} .

# 2. Report artifact
kosli report artifact ${IMAGE} \
  --artifact-type docker \
  --flow ${FLOW} \
  --commit $(git rev-parse HEAD)

# 3. Run tests
pytest --junitxml=test-results.xml

# 4. Report test evidence
kosli report evidence test junit \
  --flow ${FLOW} \
  --name ${IMAGE} \
  --results-file test-results.xml

# 5. Security scan
trivy image --format json -o scan.json ${IMAGE}

# 6. Report scan evidence
kosli report evidence generic \
  --flow ${FLOW} \
  --name ${IMAGE} \
  --evidence-type security-scan \
  --attachments scan.json

# 7. Deploy
kubectl set image deployment/myapp myapp=${IMAGE}

# 8. Report deployment
kosli report deployment production \
  --flow ${FLOW} \
  --name ${IMAGE}

# 9. Snapshot
kosli snapshot k8s production --namespace production

echo "✅ Deployment complete with full Kosli tracking"
```

## Next Steps

- [Best Practices](best-practices.md)
- [GitHub Actions Integration](github-actions.md)
- [GitLab CI Integration](gitlab-ci.md)
