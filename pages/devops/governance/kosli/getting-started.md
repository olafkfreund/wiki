---
description: Get started with Kosli for automated DevOps change tracking and compliance evidence collection
keywords: kosli, getting started, setup, installation, cli, devops, compliance
---

# Getting Started with Kosli

## Overview

This guide walks you through setting up Kosli for your first project. By the end, you'll have Kosli tracking your deployments and collecting compliance evidence automatically.

## Prerequisites

- A Kosli account (sign up at [kosli.com](https://www.kosli.com/))
- A CI/CD pipeline (GitHub Actions, GitLab CI, Azure DevOps, or similar)
- Docker or Kubernetes deployment
- Command-line access

## Step 1: Create Kosli Account

1. Visit [https://app.kosli.com/signup](https://app.kosli.com/signup)
2. Sign up with your email or GitHub/GitLab account
3. Create your organization
4. Note your **Organization name** (you'll need this later)

## Step 2: Generate API Token

1. Log in to Kosli web app
2. Navigate to **Settings > API Tokens**
3. Click **Create New Token**
4. Name it (e.g., "CI/CD Pipeline")
5. Copy the token - **you won't see it again**

**Security Note**: Store this token securely in your CI/CD secrets, never commit it to code.

## Step 3: Install Kosli CLI

### Local Installation (for testing)

**macOS/Linux**:
```bash
curl -sSL https://cli.kosli.com/install.sh | sh
```

**Windows**:
```powershell
irm https://cli.kosli.com/install.ps1 | iex
```

**Verify Installation**:
```bash
kosli version
# Output: kosli version x.x.x
```

### CI/CD Installation

You don't need to install locally for CI/CD—use platform-specific actions:

- **GitHub Actions**: [`kosli-dev/setup-cli-action`](https://github.com/marketplace/actions/setup-kosli-cli)
- **GitLab CI**: Install in pipeline using curl
- **Azure DevOps**: Install in pipeline script

## Step 4: Configure Environment

Set up your environment variables:

```bash
# Required
export KOSLI_API_TOKEN="your-api-token-here"
export KOSLI_ORG="your-organization-name"

# Optional (can be set per command)
export KOSLI_FLOW="your-flow-name"  # e.g., "microservices-api"
```

**Verify Authentication**:
```bash
kosli version
# If authenticated correctly, you'll see version info
```

## Step 5: Create Your First Flow

A **Flow** in Kosli represents a software delivery pipeline (e.g., one per application or microservice).

```bash
# Create a flow
kosli create flow microservices-api \
  --description "Microservices API application" \
  --template artifact \
  --visibility public

# List your flows
kosli list flows
```

**Flow Templates**:
- `artifact`: For Docker images, binaries, packages
- `generic`: For custom workflows

## Step 6: Report Your First Artifact

When you build software (Docker image, binary, etc.), report it to Kosli:

```bash
# Build your Docker image
docker build -t myapp:v1.0.0 .

# Report to Kosli
kosli report artifact myapp:v1.0.0 \
  --artifact-type docker \
  --flow microservices-api \
  --build-url "https://github.com/myorg/myapp/actions/runs/12345" \
  --commit $(git rev-parse HEAD) \
  --git-commit-info HEAD
```

**What This Does**:
- Creates cryptographic fingerprint of the Docker image
- Links it to the Git commit
- Records build URL for traceability
- Stores in Kosli for tracking

## Step 7: Report Evidence

Report evidence that required processes occurred:

### Test Results

```bash
# After running tests
pytest --junitxml=test-results.xml

# Report test evidence to Kosli
kosli report evidence test junit \
  --flow microservices-api \
  --name myapp:v1.0.0 \
  --results-file test-results.xml
```

### Security Scan

```bash
# Run security scan
trivy image --format json -o scan.json myapp:v1.0.0

# Report scan evidence to Kosli
kosli report evidence generic \
  --flow microservices-api \
  --name myapp:v1.0.0 \
  --evidence-type security-scan \
  --description "Trivy security scan" \
  --attachments scan.json
```

### Code Review (Pull Request)

```bash
# Report PR approval as evidence
kosli report evidence generic \
  --flow microservices-api \
  --name myapp:v1.0.0 \
  --evidence-type pull-request \
  --description "PR #123 approved by 2 reviewers" \
  --attachments pr-123.json
```

## Step 8: Report Deployment

When you deploy to an environment, report it to Kosli:

```bash
# Deploy to Kubernetes
kubectl set image deployment/myapp myapp=myapp:v1.0.0

# Report deployment to Kosli
kosli report deployment production \
  --flow microservices-api \
  --name myapp:v1.0.0 \
  --environment production
```

**What This Does**:
- Records when artifact was deployed
- Tracks which environment
- Links to all collected evidence
- Enables compliance verification

## Step 9: Snapshot Environment

Kosli can snapshot your runtime environment to verify what's actually running:

### Kubernetes

```bash
# Snapshot Kubernetes namespace
kosli snapshot k8s production \
  --namespace production
```

### Docker

```bash
# Snapshot Docker containers
kosli snapshot docker production
```

**What This Does**:
- Captures what's actually running in the environment
- Compares against expected deployments
- Detects drift (unexpected changes)
- Alerts on discrepancies

## Step 10: View in Kosli Web App

1. Log in to [https://app.kosli.com](https://app.kosli.com)
2. Navigate to your flow: **microservices-api**
3. See your artifact with:
   - Build information
   - Test evidence
   - Security scan results
   - Deployment history
   - Compliance status

## Complete Example: End-to-End

Here's a complete example in a CI/CD pipeline:

```bash
#!/bin/bash
set -e

# Step 1: Build
echo "Building Docker image..."
docker build -t myapp:${VERSION} .

# Step 2: Report Artifact
echo "Reporting artifact to Kosli..."
kosli report artifact myapp:${VERSION} \
  --artifact-type docker \
  --flow microservices-api \
  --build-url "${CI_PIPELINE_URL}" \
  --commit "${GIT_COMMIT}" \
  --git-commit-info HEAD

# Step 3: Run Tests
echo "Running tests..."
pytest --junitxml=test-results.xml

# Step 4: Report Test Evidence
echo "Reporting test results to Kosli..."
kosli report evidence test junit \
  --flow microservices-api \
  --name myapp:${VERSION} \
  --results-file test-results.xml

# Step 5: Security Scan
echo "Running security scan..."
trivy image --format json -o trivy-scan.json myapp:${VERSION}

# Step 6: Report Scan Evidence
echo "Reporting security scan to Kosli..."
kosli report evidence generic \
  --flow microservices-api \
  --name myapp:${VERSION} \
  --evidence-type security-scan \
  --attachments trivy-scan.json

# Step 7: Push Image
echo "Pushing image to registry..."
docker push myapp:${VERSION}

# Step 8: Deploy
echo "Deploying to production..."
kubectl set image deployment/myapp myapp=myapp:${VERSION}

# Step 9: Report Deployment
echo "Reporting deployment to Kosli..."
kosli report deployment production \
  --flow microservices-api \
  --name myapp:${VERSION} \
  --environment production

# Step 10: Snapshot Environment
echo "Snapshotting production environment..."
kosli snapshot k8s production \
  --namespace production

echo "✅ Deployment complete with full Kosli tracking!"
```

## Understanding Kosli Concepts

### Flow

A **Flow** represents your software delivery pipeline. Create one flow per application/microservice.

**Example Flows**:
- `payment-api` - Payment processing microservice
- `web-frontend` - Web application frontend
- `data-pipeline` - Data processing pipeline

### Artifact

An **Artifact** is a deployable unit (Docker image, binary, package).

**Artifact Types**:
- `docker` - Docker images
- `file` - Files, binaries, JARs
- `dir` - Directories

### Evidence

**Evidence** is proof that required processes occurred (tests, scans, reviews).

**Evidence Types**:
- `junit-test` - JUnit test results
- `generic` - Custom evidence (scans, approvals, etc.)
- `pull-request` - Code review approvals

### Environment

An **Environment** is where artifacts run (production, staging, etc.).

**Example Environments**:
- `production` - Production Kubernetes cluster
- `staging` - Staging environment
- `dev` - Development environment

### Trail

A **Trail** is the complete history of an artifact from build to production, including all evidence and deployments.

## Common Commands Quick Reference

```bash
# Create flow
kosli create flow <name> --description "..." --template artifact

# Report artifact
kosli report artifact <name> --artifact-type docker --flow <flow>

# Report test evidence
kosli report evidence test junit --flow <flow> --name <artifact> --results-file test.xml

# Report generic evidence
kosli report evidence generic --flow <flow> --name <artifact> --evidence-type <type> --attachments file.json

# Report deployment
kosli report deployment <environment> --flow <flow> --name <artifact>

# Snapshot environment
kosli snapshot k8s <environment> --namespace <namespace>

# List flows
kosli list flows

# Get artifact details
kosli get artifact <name> --flow <flow>

# Get flow history
kosli get flow <flow>
```

## Troubleshooting

### Authentication Issues

**Problem**: `Error: authentication failed`

**Solution**:
```bash
# Verify token is set
echo $KOSLI_API_TOKEN

# Verify organization
echo $KOSLI_ORG

# Test authentication
kosli version
```

### Artifact Not Found

**Problem**: `Error: artifact not found`

**Solution**:
- Ensure you reported the artifact first
- Verify artifact name matches exactly
- Check flow name is correct
- Docker images: ensure tag is included

### Fingerprint Mismatch

**Problem**: `Error: fingerprint mismatch`

**Solution**:
- Artifact changed after reporting
- Ensure you're deploying the exact artifact you reported
- Check Docker image wasn't rebuilt with same tag

## Next Steps

Now that you understand the basics:

1. **Integrate with CI/CD**:
   - [GitHub Actions Integration](github-actions.md)
   - [GitLab CI Integration](gitlab-ci.md)
   - [Azure DevOps Integration](azure-devops.md)

2. **Explore CLI**:
   - [Complete CLI Reference](cli-reference.md)

3. **Learn Best Practices**:
   - [Kosli Best Practices](best-practices.md)

4. **Advanced Features**:
   - Policy as Code
   - Custom evidence types
   - Compliance reports
   - Drift detection

## Additional Resources

- [Kosli Documentation](https://docs.kosli.com/)
- [Kosli CLI Repository](https://github.com/kosli-dev/cli)
- [Kosli Blog](https://www.kosli.com/blog/)
- [Example Projects](https://github.com/kosli-dev/examples)
