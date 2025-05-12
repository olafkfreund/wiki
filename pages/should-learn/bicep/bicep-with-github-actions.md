---
description: >-
  In this quick start, you use the GitHub Actions for Azure Resource Manager
  deployment to automate deploying a Bicep file to Azure.
---

# Bicep with GitHub Actions

Create a resource group for the deployment.

```powershell
az group create -n exampleRG -l westus
```plaintext

Create or use an existing service princprincipal

{% code overflow="wrap" %}
```bash
az ad sp create-for-rbac --name myApp --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/exampleRG --sdk-auth
```plaintext
{% endcode %}

Create secrets for your Azure credentials, resource group, and subscriptions.

1. In [GitHub](https://github.com/), navigate to your repository.
2. Select **Security > Secrets and variables > Actions > New repository secret**.
3. Paste the entire JSON output from the Azure CLI command into the secret's value field. Name the secret `AZURE_CREDENTIALS`.
4. Create another secret named `AZURE_RG`. Add the name of your resource group to the secret's value field (`exampleRG`).
5. Create another secret named `AZURE_SUBSCRIPTION`. Add your subscription ID to the secret's value field (example: `90fd3f9d-4c61-432d-99ba-1273f236afa2`).

### Create workflow <a href="#create-workflow" id="create-workflow"></a>

A workflow defines the steps to execute when triggered. It's a YAML (.yml) file in the **.github/workflows/** path of your repository. The workflow file extension can be either **.yml** or **.yaml**.

To create a workflow, take the following steps:

1. From your GitHub repository, select **Actions** from the top menu.
2. Select **New workflow**.
3. Select **set up a workflow yourself**.
4. Rename the workflow file if you prefer a different name other than **main.yml**. For example: **deployBicepFile.yml**.
5. Replace the content of the yml file with the following code:

```yaml
on: [push]
name: Azure ARM
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:

      # Checkout code
    - uses: actions/checkout@main

      # Log into Azure
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

      # Deploy Bicep file
    - name: deploy
      uses: azure/arm-deploy@v1
      with:
        subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
        resourceGroupName: ${{ secrets.AZURE_RG }}
        template: ./main.bicep
        parameters: 'storagePrefix=mystore storageSKU=Standard_LRS'
        failOnStdErr: false
```plaintext

5. Select **Start commit**.
6. Select **Commit directly to the main branch**.
7. Select **Commit new file** (or **Commit changes**).



### Check workflow status <a href="#check-workflow-status" id="check-workflow-status"></a>

1. Select the **Actions** tab. You'll see a **Create `deployStorageAccount.yml`** workflow listed. It takes 1-2 minutes to run the workflow.
2. Select the workflow to open it.
3. Select **Run ARM deploy** from the menu to verify the deployment.
