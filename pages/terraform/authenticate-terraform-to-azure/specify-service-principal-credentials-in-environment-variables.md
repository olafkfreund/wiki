---
description: >-
  Once you create a service principal, you can specify its credentials to
  Terraform via environment variables.
---

# Specify service principal credentials in environment variables

1.  Edit the `~/.bashrc` file by adding the following environment variables.

    BashCopy

    ```bash
    export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
    export ARM_TENANT_ID="<azure_subscription_tenant_id>"
    export ARM_CLIENT_ID="<service_principal_appid>"
    export ARM_CLIENT_SECRET="<service_principal_password>"
    ```plaintext
2.  To execute the `~/.bashrc` script, run `source ~/.bashrc` (or its abbreviated equivalent . `~/.bashrc`). You can also exit and reopen Cloud Shell for the script to run automatically.

    BashCopy

    ```bash
    . ~/.bashrc
    ```plaintext
3.  Once the environment variables have been set, you can verify their values as follows:

    BashCopy

    ```bash
    printenv | grep ^ARM*
    ```plaintext

Using PowerShell:

1.  To set the environment variables within a specific PowerShell session, use the following code. Replace the placeholders with the appropriate values for your environment.

    PowerShellCopy

    ```powershell
    $env:ARM_CLIENT_ID="<service_principal_app_id>"
    $env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
    $env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
    $env:ARM_CLIENT_SECRET="<service_principal_password>"
    ```plaintext
2.  Run the following PowerShell command to verify the Azure environment variables:

    PowerShellCopy

    ```powershell
    gci env:ARM_*
    ```plaintext
3. To set the environment variables for every PowerShell session, [create a PowerShell profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about\_profiles) and set the environment variables within your profile.
