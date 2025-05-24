# GitHub Actions for DevOps Automation

GitHub Actions enables engineers to automate build, test, and deployment workflows directly from their repositories. It supports a wide range of DevOps use cases, including CI/CD, infrastructure provisioning, and integration with major cloud providers.

> **Tip:** Browse the [GitHub Actions Marketplace](https://github.com/marketplace?type=actions) for reusable actions for AWS, Azure, GCP, and more.

## Example 1: Deploy ASP.NET Core to Azure Web App

This workflow builds and deploys an ASP.NET Core app to Azure Web App on every push to `main`:

```yaml
name: ASP.NET Core CI/CD with Azure

on:
  push:
    branches: [ main ]

env:
  AZURE_WEBAPP_NAME: myapp
  AZURE_WEBAPP_PACKAGE_PATH: './bin/Release/netcoreapp3.1/publish'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET Core
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '3.1.x'
      - name: Build and publish
        run: dotnet build --configuration Release --output ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
      - name: Deploy to Azure Web App
        uses: Azure/webapps-deploy@v2
        with:
          app-name: ${{ env.AZURE_WEBAPP_NAME }}
          package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
```

**How it works:**
- Checks out code, sets up .NET, builds, and publishes the app.
- Deploys to Azure Web App using the official action.

## Example 2: Deploy Azure Infrastructure with ARM Templates

This workflow provisions Azure resources using an ARM template:

```yaml
name: Azure Infrastructure Deployment

on:
  push:
    branches: [ main ]

env:
  AZURE_RG: 'my-resource-group'
  AZURE_LOCATION: 'westeurope'
  AZURE_TEMPLATE_FILE: './template.json'
  AZURE_PARAMETER_FILE: './parameters.json'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Validate ARM Template
        uses: azure/arm-validate-action@v1
        with:
          templateFile: ${{ env.AZURE_TEMPLATE_FILE }}
          parametersFile: ${{ env.AZURE_PARAMETER_FILE }}
      - name: Create Resource Group
        run: az group create --name ${{ env.AZURE_RG }} --location ${{ env.AZURE_LOCATION }}
      - name: Deploy ARM Template
        uses: azure/arm-deploy@v1
        with:
          templateFile: ${{ env.AZURE_TEMPLATE_FILE }}
          parametersFile: ${{ env.AZURE_PARAMETER_FILE }}
          resourceGroupName: ${{ env.AZURE_RG }}
```

**How it works:**
- Logs in to Azure using a service principal stored in `AZURE_CREDENTIALS` secret ([setup guide](https://github.com/Azure/login#configure-a-service-principal-with-a-secret)).
- Validates and deploys the ARM template to a resource group.

## Best Practices

- Use [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches) to enforce code review and CI checks.
- Store secrets in [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) and never hard-code credentials.
- Integrate [Dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically) for automated dependency updates.
- Use [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) for safe, staged deployments.
- Reference the [GitHub Actions Marketplace](https://github.com/marketplace?type=actions) for reusable actions.

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Actions for GitHub](https://github.com/Azure/actions)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

> **Pro Tip:** For multi-cloud or hybrid workflows, combine GitHub Actions with Terraform, Ansible, or Kubernetes actions for end-to-end automation.
