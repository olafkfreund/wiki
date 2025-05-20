# Terraform with GitHub Actions

Automate your Terraform deployments using GitHub Actions for secure, repeatable, and cloud-agnostic workflows. This guide covers best practices for Azure, but the pattern applies to AWS and GCP as well.

---

## Prerequisites

- **Remote Terraform state** (e.g., Azure Storage Account, AWS S3, or GCP Cloud Storage)
- **Service Principal** (Azure) or equivalent credentials for AWS/GCP
- **Store credentials as GitHub Secrets** (never commit credentials to code)

---

## Step-by-Step: GitHub Actions Workflow for Terraform (Azure Example)

1. **Add the following workflow to `.github/workflows/terraform.yml` in your repo:**

```yaml
name: 'Terraform CI/CD'

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
    defaults:
      run:
        shell: bash
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Format
        run: terraform fmt -check
        working-directory: ./terraform
      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform
      - name: Terraform Validate
        run: terraform validate
        working-directory: ./terraform
      - name: Terraform Plan
        run: terraform plan
        working-directory: ./terraform
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
        working-directory: ./terraform
```

2. **Add GitHub Secrets** under your repository settings:
   - `AZURE_AD_CLIENT_ID` → `clientId` from your Service Principal
   - `AZURE_AD_CLIENT_SECRET` → `clientSecret`
   - `AZURE_AD_TENANT_ID` → `tenantId`
   - `AZURE_SUBSCRIPTION_ID` → `subscriptionId`
   - (Optional) `AZURE_CREDENTIALS` → full JSON output for some modules

---

## Best Practices

- Use remote state for collaboration and disaster recovery
- Store credentials only in GitHub Secrets or a secure vault
- Use separate Service Principals for dev, staging, and prod
- Rotate credentials regularly
- Use the latest stable GitHub Actions and Terraform versions

---

## References

- [Terraform GitHub Actions Docs](https://github.com/hashicorp/setup-terraform)
- [Terraform Azure Provider Auth](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [GitHub Actions: Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

> **Tip:** For AWS and GCP, use the respective provider environment variables and credentials in the same workflow pattern.

---

## Add to SUMMARY.md

```markdown
- [Terraform with GitHub Actions](pages/terraform/terraform-with-github-actions.md)
```
