# Service Principal for Terraform

To securely automate Terraform deployments in Azure, use a Service Principal with the minimum required permissions. This script creates a Service Principal with Contributor and User Access Administrator roles at the subscription scope—suitable for most DevOps CI/CD scenarios (e.g., GitHub Actions, Azure Pipelines).

---

## Bash Script: Create Service Principal for Terraform

```bash
#!/usr/bin/env bash
set -euo pipefail

# Set your Azure subscription context
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_NAME="firstContainerAppGitHubAction"

# Create the Service Principal with Contributor role
az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth \
  --output json

# Assign User Access Administrator role (optional, for RBAC management)
servicePrincipalAppId=$(az ad sp list --display-name "$SP_NAME" --query "[].appId" -o tsv)
az role assignment create \
  --assignee "$servicePrincipalAppId" \
  --role "User Access Administrator" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID"
```

**Output:**

```json
{
  "clientId": "XXXXXX",
  "clientSecret": "XXXXXX",
  "subscriptionId": "XXXXXX",
  "tenantId": "XXXXXX",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

---

## Usage in Terraform and CI/CD

- Store the output values (`clientId`, `clientSecret`, `subscriptionId`, `tenantId`) as environment variables or in your CI/CD secret manager (e.g., GitHub Actions, Azure DevOps).
- Reference these in your Terraform provider block:

```hcl
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

---

## Best Practices
- Use a unique Service Principal per environment (dev, staging, prod)
- Grant only the minimum permissions needed
- Rotate credentials regularly and never commit them to source control
- Store secrets in a secure vault (Azure Key Vault, GitHub/Azure DevOps secrets)

---

## References
- [Terraform Azure Provider: Service Principal Auth](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Azure CLI: az ad sp create-for-rbac](https://learn.microsoft.com/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac)
- [GitHub Actions: Azure Login](https://github.com/Azure/login)

> **Tip:** For passwordless authentication in CI/CD, consider using OIDC with GitHub Actions or Azure Pipelines.
