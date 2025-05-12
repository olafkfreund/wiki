# Static Code testing

### Linting

Linting is the process of checking source code for syntax and style errors.

* **Terraform fmt**: This is a built-in Terraform command that should be the first port of call. The command formats your Terraform code based on a set of standard formatting rules.
* [**tflint**](https://github.com/terraform-linters/tflint): This is a popular open-source tool that checks for syntax errors, best practices, and code style consistency. Once installed, simply run it using the command:

```hcl
tflint /path/to/terraform/code
```plaintext

* **Checkov**: This is an open-source static analysis tool for Terraform that checks for security and compliance issues in your Terraform code. Install it using the python package manager _pip_ and run it using the command below:

```hcl
pip install checkov
checkov -d /path/to/terraform/code
```plaintext

Checkov will identify security issues and provides recommendations for how to fix the issue, along with the location of the relevant code, such as publically accessible storage accounts.

* [**Terrascan**](https://github.com/tenable/terrascan): This open-source tool performs static code analysis to identify security vulnerabilities and compliance violations in Terraform code. Example output is shown below for a publically accessible storage account:

```hcl
=== [azure_storage_account] ===
Rules:
Risky network access configuration for storage account
Rule ID: AWS_3_2
Description: A storage account with unrestricted network access configuration may result in unauthorized access to the account and its data.
Severity: CRITICAL
Tags: [network,storage]
Status: FAILED
Resource:
```plaintext

Check out the list of [other popular tools used in Terraform-managed deployments](https://spacelift.io/blog/terraform-tools).

### Compliance Testing

[**terraform-compliance**](https://terraform-compliance.com/) enables you to write a set of conditions in [YAML files](https://spacelift.io/blog/yaml) that must be met and test your code against them.

It can easily be installed using pip and run using the command shown below:

```hcl
pip install terraform-compliance
terraform-compliance -p /path/to/policy/file.yaml -f /path/to/terraform/code
```plaintext

For example, the YAML file below specifies that Azure Storage Account should not be publicly accessible:

```hcl
controls:
  - name: azure-storage-not-publicly-accessible
    description: Azure Storage Account should not be publicly accessible
    rules:
      - azure_storage_account:
          public_access_allowed: False
```plaintext

### Drift Testing

Terraform will natively [test for drift](https://spacelift.io/blog/terraform-drift-detection) between your code and the real infrastructure when `terraform plan` is run. Terraform will compare the current state of your infrastructure to the state saved in the state file.

If there are any differences, Terraform will display an execution plan that shows how to update your infrastructure to match your configuration.

You can also make use of [`driftctl`](https://driftctl.com/) which is a free open-source tool that can report on infrastructure drift. Example output from the tool is shown below:

```hcl
Found 11 resource(s) – 73% coverage
– 8 managed by terraform
– 2 not managed by terraform
– 1 found in terraform state but missing on the cloud provider
```plaintext

Periodic monitoring of the IaC-managed infrastructure to proactively check for drifts is a challenge.
