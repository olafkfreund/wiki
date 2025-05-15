---
description: >-
  In this quick start, you use the GitHub Actions for Azure Resource Manager
  deployment to automate deploying a Bicep file to Azure.
---

# Bicep with GitHub Actions

This guide explains how to set up GitHub Actions for automated deployment of Bicep templates to Azure, covering basic setup, advanced workflows, and security best practices.

## Prerequisites

- An Azure subscription
- A GitHub repository
- Basic knowledge of Bicep (Azure's Infrastructure as Code language)
- Azure CLI installed (for initial setup)

## Initial Setup

### Create a resource group

First, create a resource group for your deployment:

```bash
az group create -n exampleRG -l westus
```

### Create a service principal

Create a service principal with contributor access to your resource group:

```bash
az ad sp create-for-rbac --name "GitHubActionsSP" --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/exampleRG \
  --sdk-auth
```

This command outputs JSON credentials that look similar to:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Configure GitHub Secrets

Store your Azure credentials and configuration as GitHub secrets:

1. In your GitHub repository, go to **Settings > Secrets and variables > Actions > New repository secret**
2. Create the following secrets:

   - `AZURE_CREDENTIALS`: Paste the entire JSON output from the service principal creation
   - `AZURE_RG`: Your resource group name (e.g., `exampleRG`)
   - `AZURE_SUBSCRIPTION`: Your subscription ID

## Basic Workflow

Create a GitHub Actions workflow file at `.github/workflows/deploy-bicep.yml`:

```yaml
name: Deploy Bicep Template

on:
  push:
    branches: [ main ]
    paths:
      - 'bicep/**'
      - '.github/workflows/deploy-bicep.yml'
  workflow_dispatch: # Allows manual triggering

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      # Checkout code
      - uses: actions/checkout@v3

      # Log into Azure
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      # Deploy Bicep file
      - name: Deploy Bicep template
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./bicep/main.bicep
          parameters: 'storagePrefix=mystore storageSKU=Standard_LRS'
          failOnStdErr: false
```

## Advanced Workflow Examples

### Multiple Environment Deployment

This example deploys to development and production environments based on branch:

```yaml
name: Multi-Environment Bicep Deploy

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Bicep CLI
        run: |
          curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
          chmod +x ./bicep
          sudo mv ./bicep /usr/local/bin/bicep
      
      - name: Validate Bicep files
        run: |
          bicep build ./bicep/main.bicep --stdout > /dev/null
  
  deploy-dev:
    needs: validate
    if: github.ref == 'refs/heads/develop' || github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v3
      
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Deploy to Development
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.DEV_RESOURCE_GROUP }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters/dev.parameters.json
          deploymentName: 'github-${{ github.run_number }}-dev'

  deploy-prod:
    needs: [validate, deploy-dev]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production # Requires approval in GitHub
    steps:
      - uses: actions/checkout@v3
      
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Deploy to Production
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.PROD_RESOURCE_GROUP }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters/prod.parameters.json
          deploymentName: 'github-${{ github.run_number }}-prod'
```

### Preview Changes with What-If

This workflow validates and previews changes before deployment:

```yaml
name: Bicep Preview and Deploy

on:
  push:
    branches: [ main ]
    paths:
      - 'bicep/**'
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Preview Changes (What-If)
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters.json
          deploymentMode: Validate
          additionalArguments: --what-if
      
      - name: Deploy Bicep (PR Comment)
        if: github.event_name == 'pull_request'
        uses: azure/arm-deploy@v1
        with:
          scope: resourcegroup
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters.json
          deploymentName: 'pr-${{ github.event.pull_request.number }}'
          additionalArguments: --what-if
  
  deploy:
    needs: preview
    if: github.event_name != 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Deploy Bicep
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters.json
          deploymentName: 'github-${{ github.run_number }}'
```

## Security Best Practices

### 1. Minimize Service Principal Permissions

Instead of using the Contributor role at the resource group level, consider using custom roles with just the permissions needed:

```bash
# Create a custom role definition file (custom-role.json)
{
  "Name": "Bicep Deployer",
  "Description": "Can deploy resources from Bicep files",
  "Actions": [
    "Microsoft.Resources/deployments/*",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ],
  "AssignableScopes": [
    "/subscriptions/{subscription-id}/resourceGroups/exampleRG"
  ]
}

# Create the custom role
az role definition create --role-definition custom-role.json

# Assign the custom role to your service principal
az role assignment create --assignee {service-principal-id} \
  --role "Bicep Deployer" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/exampleRG"
```

### 2. Use OpenID Connect (OIDC) Instead of Secrets

OIDC provides a more secure way to authenticate GitHub Actions with Azure without storing long-lived credentials:

```yaml
name: Secure Bicep Deployment with OIDC

on:
  push:
    branches: [ main ]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Azure login with OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION }}
      
      - name: Deploy Bicep
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./bicep/main.bicep
          parameters: ./bicep/parameters.json
```

To set up OIDC authentication:

1. Create a federated credential in Azure AD:

```bash
# Create an app registration first
appId=$(az ad app create --display-name "GitHub-Actions-OIDC" --query appId -o tsv)
objectId=$(az ad app show --id $appId --query id -o tsv)

# Create a service principal
spId=$(az ad sp create --id $appId --query id -o tsv)

# Assign role
az role assignment create \
  --role Contributor \
  --assignee $spId \
  --scope "/subscriptions/{subscription-id}/resourceGroups/exampleRG"

# Create federated credential
az ad app federated-credential create \
  --id $objectId \
  --parameters "{\"name\":\"github-federated\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:your-org/your-repo:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Save these values as GitHub secrets
echo "AZURE_CLIENT_ID: $appId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId -o tsv)"
echo "AZURE_SUBSCRIPTION: $(az account show --query id -o tsv)"
```

### 3. Secure Parameters Handling

Store sensitive parameters in GitHub secrets and pass them securely:

```yaml
- name: Deploy with Secure Parameters
  uses: azure/arm-deploy@v1
  with:
    subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
    resourceGroupName: ${{ secrets.AZURE_RG }}
    template: ./bicep/main.bicep
    parameters: >
      storagePrefix=mystore 
      storageSKU=Standard_LRS 
      adminPassword=${{ secrets.ADMIN_PASSWORD }}
```

In your Bicep file, mark sensitive parameters accordingly:

```bicep
@secure()
param adminPassword string
```

## Monitoring and Troubleshooting

### Add Deployment Status Comments to PRs

```yaml
- name: Comment PR with Deployment Status
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v6
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      const output = `#### Bicep Deployment Preview 🚀
      Validation: ✅ Passed
      
      <details><summary>Show What-If Results</summary>
      
      \`\`\`
      ${{ steps.whatif.outputs.stdout }}
      \`\`\`
      </details>`;
      
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: output
      })
```

### Track Deployment History

```yaml
- name: Save Deployment History
  if: success()
  run: |
    echo "Deployment completed at $(date)" >> deployments.log
    echo "Run ID: ${{ github.run_id }}" >> deployments.log
    echo "Commit: ${{ github.sha }}" >> deployments.log
    echo "Template: ./bicep/main.bicep" >> deployments.log
    echo "-------------------------------------------" >> deployments.log
    
- name: Upload Deployment History
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: deployment-history
    path: deployments.log
```

## Example Repository Structure

```
├── .github/
│   └── workflows/
│       └── deploy-bicep.yml
├── bicep/
│   ├── main.bicep
│   ├── modules/
│   │   ├── storage.bicep
│   │   └── networking.bicep
│   └── parameters/
│       ├── dev.parameters.json
│       └── prod.parameters.json
└── README.md
```

## Conclusion

Using GitHub Actions with Bicep provides a powerful way to automate your infrastructure deployment to Azure. By implementing proper security practices and leveraging advanced workflow configurations, you can create reliable, secure CI/CD pipelines for your infrastructure code.

For more information, refer to the official documentation:
- [Azure Bicep documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [Azure ARM Deploy Action](https://github.com/Azure/arm-deploy)
