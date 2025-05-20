# Authenticating Terraform with AWS

To deploy infrastructure on AWS using Terraform, you must authenticate Terraform to your AWS account. This guide covers real-life scenarios for local development, CI/CD pipelines, and multi-account setups, with best practices for security and automation.

---

## 1. Local Development: AWS CLI Credentials

The simplest way to authenticate is to use the AWS CLI. Configure your credentials with:

```bash
aws configure
```

This stores your credentials in `~/.aws/credentials` and region in `~/.aws/config`:

```ini
[default]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
region = eu-west-1
```

Terraform will automatically use these credentials.

**Best Practice:** Use named profiles for multiple accounts:

```ini
[dev]
aws_access_key_id = ...
aws_secret_access_key = ...
region = us-east-1

[prod]
aws_access_key_id = ...
aws_secret_access_key = ...
region = eu-west-1
```

Reference a profile in your provider block:

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

---

## 2. CI/CD Pipelines: Environment Variables

For automation (GitHub Actions, GitLab CI, Azure Pipelines), use environment variables for credentials:

```bash
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

**GitHub Actions Example:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_DEFAULT_REGION: us-east-1
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

**GitLab CI Example:**

```yaml
variables:
  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION: us-east-1

stages:
  - apply

apply:
  stage: apply
  image: hashicorp/terraform:1.7.5
  script:
    - terraform init
    - terraform apply -auto-approve
```

**Azure DevOps Example:**

```yaml
steps:
- script: |
    export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)
    export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
    terraform init
    terraform apply -auto-approve
  env:
    AWS_ACCESS_KEY_ID: $(AWS_ACCESS_KEY_ID)
    AWS_SECRET_ACCESS_KEY: $(AWS_SECRET_ACCESS_KEY)
```

---

## 3. Advanced: Assume Role for Multi-Account/MFA

For organizations using AWS Organizations or requiring MFA, use the `assume_role` block:

```hcl
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/terraform-deployer"
  }
}
```

**Best Practice:** Use short-lived credentials and roles for CI/CD, never long-lived root keys.

---

## 4. NixOS: Declarative AWS Credentials

Add credentials as environment variables in your NixOS configuration:

```nix
# configuration.nix
{
  environment.variables = {
    AWS_ACCESS_KEY_ID = "...";
    AWS_SECRET_ACCESS_KEY = "...";
    AWS_DEFAULT_REGION = "us-east-1";
  };
}
```

Or use [agenix](https://github.com/ryantm/agenix) for encrypted secrets.

---

## Best Practices
- Use IAM roles and short-lived credentials for automation (never root keys)
- Store secrets in a secure vault (GitHub/Azure/GitLab secrets, HashiCorp Vault, SSM Parameter Store)
- Use named profiles for multi-account setups
- Rotate credentials regularly
- Enable MFA for all users
- Use least privilege IAM policies

---

## References
- [Terraform AWS Provider Auth Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [Terraform in GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Terraform in GitLab CI/CD](https://docs.gitlab.com/ee/ci/examples/terraform.html)
- [Terraform in Azure DevOps](https://learn.microsoft.com/en-us/azure/developer/terraform/overview)

> **Tip:** For cloud-native, secure, and auditable deployments, always use roles and secret managers instead of hardcoded credentials.

---

```markdown
- [Authenticating Terraform with AWS](pages/terraform/aws/aws_auth_terraform.md)
```
