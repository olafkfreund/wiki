---
description: >-
  Automate Azure deployments with Bicep and GitHub Actions. Latest best practices, real-world DevOps/SRE examples, and security tips for 2025.
---

# Bicep with GitHub Actions (2025)

Automate your Azure infrastructure deployments using Bicep and GitHub Actions. This guide covers modern DevOps/SRE best practices, secure authentication, and real-world workflow examples.

---

## Why Use GitHub Actions with Bicep?

- **CI/CD Automation**: Trigger deployments on code changes, PRs, or schedules
- **Security**: Use OIDC for passwordless authentication
- **Multi-Environment**: Deploy to dev, test, and prod with parameter files
- **Observability**: Integrate deployment status and logs into PRs

---

## Prerequisites

- Azure subscription
- GitHub repository
- Bicep files in your repo (e.g., `bicep/main.bicep`)
- Service principal or OIDC setup for authentication

---

## Initial Setup

### 1. Create a Resource Group

```bash
az group create -n exampleRG -l westus
```

### 2. Configure Authentication

#### Option A: Service Principal (legacy, less secure)

```bash
az ad sp create-for-rbac --name "GitHubActionsSP" --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/exampleRG \
  --sdk-auth
```

Store the output as the `AZURE_CREDENTIALS` secret in GitHub.

#### Option B: OIDC (recommended)

- Use federated credentials for passwordless, short-lived tokens. See [Microsoft Docs](https://learn.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux) for setup.

---

## Example: Basic Bicep Deployment Workflow

```yaml
name: Deploy Bicep Template
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    - name: Deploy Bicep
      uses: azure/arm-deploy@v1
      with:
        subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
        resourceGroupName: ${{ secrets.AZURE_RG }}
        template: ./bicep/main.bicep
        parameters: ./bicep/parameters/dev.parameters.json
```

---

## Example: Multi-Environment Deployment

```yaml
name: Multi-Env Bicep Deploy
on:
  push:
    branches: [ develop, main ]
jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Deploy to Dev
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.DEV_RESOURCE_GROUP }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters/dev.parameters.json
  deploy-prod:
    if: github.ref == 'refs/heads/main'
    needs: deploy-dev
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Deploy to Prod
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.PROD_RESOURCE_GROUP }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters/prod.parameters.json
```

---

## Example: Preview Changes with What-If

```yaml
- name: Preview Changes (What-If)
  uses: azure/arm-deploy@v1
  with:
    subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
    resourceGroupName: ${{ secrets.AZURE_RG }}
    template: ./bicep/main.bicep
    parameters: ./bicep/parameters.json
    deploymentMode: Validate
    additionalArguments: --what-if
```

---

## Security Best Practices

- Use OIDC for authentication (no secrets in repo)
- Assign least-privilege roles to service principals
- Mark sensitive parameters with `@secure()` in Bicep
- Store secrets in GitHub Secrets, not in code

---

## Monitoring & Troubleshooting

- Add deployment status comments to PRs using `actions/github-script`
- Upload deployment logs as artifacts for traceability
- Use `az deployment group show` to fetch outputs after deployment

---

## Bicep & Azure Jokes

> **Bicep Joke:** Why did the pipeline use Bicep? To flex on ARM templates!

> **Azure Joke:** Why did the engineer love Azure deployments? Because they always had a resourceful day!

---

## References

- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [ARM Deploy Action](https://github.com/Azure/arm-deploy)
- [OIDC Auth for GitHub Actions](https://learn.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux)
