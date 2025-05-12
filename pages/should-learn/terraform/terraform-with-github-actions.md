# Terraform with GitHub Actions

here are some prior requirements you need to complete before we can get deploying Terraform using GitHub Actions.

* Storing the Terraform state file remotely
* Azure Service Principal
* Saving Service Principal credentials within GitHub Repository as secrets

To add this GitHub Action to your repository, within your GitHub Repo – select Actions -> Workflows -> New workflow

{% code overflow="wrap" lineNumbers="true" %}
```yaml
name: 'Terraform'
 
on:
  push:
    branches:
    - main
  pull_request:
 
jobs:
  terraform:
    name: 'Terraform'
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
    runs-on: ubuntu-latest
    environment: production
 
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
 
    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v2
 
    - name: 'Terraform Format'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'fmt'
        tf_actions_working_dir: "./terraform"
         
    - name: 'Terraform Init'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'init'
        tf_actions_working_dir: "./terraform"
 
    - name: 'Terraform Validate'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'validate'
        tf_actions_working_dir: "./terraform"
         
    - name: 'Terraform Plan'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'plan'
        tf_actions_working_dir: "./terraform"
 
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: "./terraform"
```plaintext
{% endcode %}

1. Within the GitHub repository to where you are going to be running the terraform from, select settings -> secrets
2. Add the 4 secrets from the output of script ran

* AZURE\_AD\_CLIENT\_ID – Will be the `clientId` value
* AZURE\_AD\_CLIENT\_SECRET – Will be the `clientSecret` value
* AZURE\_AD\_TENANT\_ID – Will be the `tenantId` value
* AZURE\_SUBSCRIPTION\_ID – Will be the `subscriptionId` value
* AZURE\_CREDENTIALS - Will be whole json output including {}

\
