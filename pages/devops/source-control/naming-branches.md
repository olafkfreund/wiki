# Branch Naming Conventions

When contributing to existing projects, look for and stick with the agreed branch naming convention. In open source projects this information is typically found in the contributing instructions, often in a file named `CONTRIBUTING.md`.

In the beginning of a new project the team agrees on the project conventions including the branch naming strategy.

## Common Branch Naming Patterns

### 1. Feature-based Convention

```plaintext
<type>/<issue-number>-<short-description>
```

Examples:
```
feature/271-add-more-cowbell
bugfix/389-fix-memory-leak
hotfix/422-critical-auth-issue
docs/129-update-readme
test/233-improve-test-coverage
refactor/156-optimize-queries
chore/111-update-dependencies
```

### 2. Owner-based Convention

```plaintext
<owner>/<type>/<issue-number>-<short-description>
```

Examples:
```
johndoe/feature/271-add-more-cowbell
janedoe/bugfix/389-fix-memory-leak
```

### 3. Release-based Convention

For teams working with release branches:

```plaintext
release/v<major>.<minor>.<patch>
release/v2.3.0
release/v2023.05
release/2023-Q2
```

### 4. Environment-based Convention

For GitOps workflows:

```plaintext
env/<environment-name>
env/production
env/staging
env/qa
```

## Multi-Cloud Development Considerations

When working across multiple cloud providers, you might want to include cloud provider information in branch names:

```plaintext
<type>/<provider>/<issue-number>-<description>
```

Examples:
```
feature/aws/345-lambda-integration
feature/azure/389-app-service-scaling
bugfix/gcp/417-gke-networking-issue
```

## Automation and Integration

### CI/CD Pipeline Integration

Well-structured branch names can trigger specific CI/CD workflows:

```yaml
# GitHub Actions example
name: Feature Branch CI

on:
  push:
    branches:
      - 'feature/**'
      - 'bugfix/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up environment
        run: echo "Setting up environment for ${{ github.ref }}"
```

### Automatic Work Item Linking

Branch names with issue numbers enable automatic linking in tools like Azure DevOps:

```yaml
# Azure Pipelines example
trigger:
  branches:
    include:
      - feature/*
      - bugfix/*
      - hotfix/*

pool:
  vmImage: 'ubuntu-latest'

steps:
- script: |
    # Extract work item ID from branch name
    BRANCH_NAME=$(Build.SourceBranch)
    WORK_ITEM_ID=$(echo $BRANCH_NAME | grep -oP '(\d+)-' | sed 's/-//')
    echo "##vso[task.setvariable variable=workItemId]$WORK_ITEM_ID"
  displayName: 'Extract work item ID'

- script: |
    echo "Associated with work item ID: $(workItemId)"
  displayName: 'Link Work Item'
```

## Branch Naming Best Practices

1. **Keep it simple** - Names should be intuitive and easy to remember
2. **Be consistent** - Once a convention is chosen, stick to it
3. **Use lowercase** - Avoid case sensitivity issues across systems
4. **Use hyphens** for word separation (not underscores or spaces)
5. **Keep it short** - Long branch names become unwieldy
6. **Include relevant information only** - Exclude redundant details

## Different Conventions for Different Development Models

### Trunk-Based Development

In trunk-based development, branches are short-lived and merged frequently:

```plaintext
feature/quick-description
```

or for one-day branches:

```plaintext
feature/2023-06-15-auth-refactor
```

### GitFlow

For GitFlow, branches follow a more structured naming convention:

```
feature/feature-name
release/v1.2.3
hotfix/v1.2.3.1
bugfix/issue-description
```

### GitHub Flow

With GitHub Flow's simplified approach:

```
feature/feature-name
fix/bug-fix-description
```

## Real-World Examples

### Enterprise SaaS Project

```
feature/ACME-1234-implement-sso
bugfix/ACME-1456-fix-pagination
hotfix/v2.5.1-critical-security-patch
release/v2.6.0
docs/ACME-1500-update-api-docs
```

### Infrastructure as Code Project

```
feature/aws/vpc-peering-support
feature/azure/vnet-gateway-configuration
bugfix/terraform/state-locking-issue
refactor/crossplane/simplify-resource-definitions
```

### Microservices Project

```
feature/user-service/add-password-reset
feature/payment-service/add-stripe-integration
bugfix/order-service/fix-race-condition
```

## Automated Branch Name Enforcement

Consider enforcing branch naming conventions through hooks or CI checks:

```bash
#!/bin/bash
# Git hook to verify branch naming convention
# Save as .git/hooks/pre-push and make executable

BRANCH_NAME=$(git symbolic-ref --short HEAD)
BRANCH_PATTERN="^(feature|bugfix|hotfix|release|docs|test|refactor|chore)\/[a-z0-9][a-z0-9-]*$"

if ! [[ $BRANCH_NAME =~ $BRANCH_PATTERN ]]; then
  echo "ERROR: Branch name '$BRANCH_NAME' does not match the required pattern."
  echo "Branch names should follow: <type>/<description> (e.g., feature/add-login)"
  exit 1
fi
```

The examples above are just that - examples. The team can choose to omit or add parts. Choosing a branch convention can depend on the development model (e.g. [trunk-based development](https://trunkbaseddevelopment.com/)), [versioning](https://microsoft.github.io/code-with-engineering-playbook/source-control/component-versioning/) model, tools used in managing source control, matter of taste etc. Focus on simplicity and reducing ambiguity; a good branch naming strategy allows the team to understand the purpose and ownership of each branch in the repository.
