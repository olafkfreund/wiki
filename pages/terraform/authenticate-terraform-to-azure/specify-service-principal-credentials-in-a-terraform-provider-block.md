---
description: >-
  The Azure provider block defines syntax that allows you to specify your Azure
  subscription's authentication information.
---

# Specify Service Principal Credentials in a Terraform Provider Block

To authenticate Terraform to Azure in a secure, automated, and cloud-agnostic way, use a Service Principal and reference its credentials in your provider block. This is the recommended approach for CI/CD pipelines and IaC workflows.

---

## Step-by-Step Example

1. **Store your Service Principal credentials securely** (e.g., as environment variables or in your CI/CD secret manager):
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`

2. **Reference these variables in your Terraform provider block:**

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
```

3. **Set the variables using environment variables or a `terraform.tfvars` file:**

```bash
export TF_VAR_subscription_id=$ARM_SUBSCRIPTION_ID
export TF_VAR_tenant_id=$ARM_TENANT_ID
export TF_VAR_client_id=$ARM_CLIENT_ID
export TF_VAR_client_secret=$ARM_CLIENT_SECRET
```

Or in `terraform.tfvars` (not recommended for production):
```hcl
subscription_id = "..."
tenant_id       = "..."
client_id       = "..."
client_secret   = "..."
```

---

## Real-Life DevOps Example: GitHub Actions

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

---

## Best Practices
- Never hardcode credentials in your Terraform code or repository
- Use environment variables or secret managers for sensitive values
- Rotate Service Principal credentials regularly
- Grant only the minimum RBAC permissions needed

---

## References
- [Terraform Azure Provider: Authenticating via Service Principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Azure CLI: az ad sp create-for-rbac](https://learn.microsoft.com/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac)

---

> **Tip:** For passwordless authentication in CI/CD, consider using OIDC with GitHub Actions or Azure Pipelines.

---

## Add to SUMMARY.md

```markdown
- [Specify Service Principal Credentials in a Terraform Provider Block](pages/terraform/authenticate-terraform-to-azure/specify-service-principal-credentials-in-a-terraform-provider-block.md)
```
