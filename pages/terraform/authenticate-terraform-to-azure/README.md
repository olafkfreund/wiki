---
description: >-
  To use Terraform commands against your Azure subscription, you must first
  authenticate Terraform to that subscription. This article covers common
  DevOps scenarios for authenticating to Azure securely and reproducibly.
---

# Authenticate Terraform to Azure

To use Terraform with Azure, you must authenticate Terraform to your Azure subscription. The recommended approach for automation and CI/CD is to use a Service Principal with RBAC. Below are step-by-step instructions for both Bash (Azure CLI) and PowerShell workflows, with real-life DevOps tips.

---

## Bash (Azure CLI): Create a Service Principal for Terraform

1. **Sign in to Azure:**

   ```bash
   az login
   ```

2. **(If using Git Bash on Windows)** set the environment variable to avoid path conversion issues:

   ```bash
   export MSYS_NO_PATHCONV=1
   ```

   > *Tip:* Add this to your `~/.bashrc` for persistent use.

3. **Create a Service Principal with Contributor role:**

   ```bash
   az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>
   ```

   - Replace `<service_principal_name>` and `<subscription_id>` as needed.
   - The output will include `appId`, `password`, and `tenant`—**store these securely** (e.g., Azure Key Vault, GitHub Actions secrets).

   > **Best Practice:** Never commit credentials to source control. Use environment variables or secret managers in CI/CD.

4. **Configure Terraform to use the Service Principal:**
   Add these variables to your environment or your CI/CD pipeline:

   ```bash
   export ARM_CLIENT_ID="<appId>"
   export ARM_CLIENT_SECRET="<password>"
   export ARM_SUBSCRIPTION_ID="<subscription_id>"
   export ARM_TENANT_ID="<tenant>"
   ```

   Or use a [Terraform provider block](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference):

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

## PowerShell: Create a Service Principal for Terraform

1. **Open a PowerShell prompt and sign in:**

   ```powershell
   Connect-AzAccount
   ```

2. **Check your current subscription:**

   ```powershell
   Get-AzContext
   ```

3. **List all available subscriptions:**

   ```powershell
   Get-AzSubscription
   ```

4. **Set the active subscription (if needed):**

   ```powershell
   Set-AzContext -Subscription "<subscription_id_or_subscription_name>"
   ```

5. **Create a Service Principal with Contributor role:**

   ```powershell
   $sp = New-AzADServicePrincipal -DisplayName <service_principal_name> -Role "Contributor"
   $appId = $sp.AppId
   $password = $sp.PasswordCredentials.SecretText
   $tenantId = (Get-AzContext).Tenant.Id
   ```

   - Store `$appId`, `$password`, and `$tenantId` securely for use in Terraform.

---

## Real-Life DevOps Example: GitHub Actions with Azure

Store your Service Principal credentials as GitHub Actions secrets, then use them in your workflow:

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

---

## Best Practices

- Use a dedicated Service Principal per environment (dev, staging, prod)
- Grant only the minimum RBAC permissions needed
- Store credentials in a secure secret manager (Azure Key Vault, GitHub/Azure DevOps secrets)
- Rotate Service Principal credentials regularly
- Never commit credentials to source control

---

## References

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Azure CLI: az ad sp create-for-rbac](https://learn.microsoft.com/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac)
- [Azure PowerShell: New-AzADServicePrincipal](https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azadserviceprincipal)
- [GitHub Actions: Azure Login](https://github.com/Azure/login)

> **Tip:** For fully automated pipelines, use Terraform Cloud or GitHub Actions with OIDC for passwordless authentication to Azure.
