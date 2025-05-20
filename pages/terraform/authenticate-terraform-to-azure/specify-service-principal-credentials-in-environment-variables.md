---
description: >-
  Once you create a service principal, you can specify its credentials to
  Terraform via environment variables.
---

# Specify Service Principal Credentials in Environment Variables

To securely authenticate Terraform to Azure, export your Service Principal credentials as environment variables. This is the recommended approach for automation, CI/CD, and cross-platform workflows (Linux, macOS, WSL, PowerShell).

---

## Bash/Linux/WSL: Set Environment Variables

1. **Add the following to your `~/.bashrc` or `~/.zshrc`:**

    ```bash
    export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
    export ARM_TENANT_ID="<azure_subscription_tenant_id>"
    export ARM_CLIENT_ID="<service_principal_appid>"
    export ARM_CLIENT_SECRET="<service_principal_password>"
    ```

2. **Reload your shell configuration:**

    ```bash
    source ~/.bashrc
    # or for zsh
    source ~/.zshrc
    ```

3. **Verify the environment variables:**

    ```bash
    printenv | grep ^ARM
    ```

---

## PowerShell: Set Environment Variables

1. **Set variables for the current session:**

    ```powershell
    $env:ARM_CLIENT_ID="<service_principal_app_id>"
    $env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
    $env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
    $env:ARM_CLIENT_SECRET="<service_principal_password>"
    ```

2. **Verify the variables:**

    ```powershell
    Get-ChildItem env:ARM_*
    ```

3. **Persist variables for all sessions:**
    Add the export lines to your [PowerShell profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

---

## Real-Life DevOps Example: GitHub Actions

Store your Service Principal credentials as GitHub Actions secrets, then use them in your workflow:

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
- [PowerShell Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)

> **Tip:** For passwordless authentication in CI/CD, consider using OIDC with GitHub Actions or Azure Pipelines.

---

## Add to SUMMARY.md

```markdown
- [Specify Service Principal Credentials in Environment Variables](pages/terraform/authenticate-terraform-to-azure/specify-service-principal-credentials-in-environment-variables.md)
```
