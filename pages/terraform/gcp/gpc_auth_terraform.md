# Authenticating Terraform with GCP

To deploy infrastructure on Google Cloud Platform (GCP) using Terraform, you must authenticate Terraform to your GCP project. This guide covers real-life scenarios for local development, CI/CD pipelines, and multi-project setups, with best practices for security and automation.

---

## 1. Local Development: gcloud CLI & Application Default Credentials

The recommended way to authenticate locally is to use the Google Cloud SDK (`gcloud`).

```bash
gcloud auth application-default login
```

This command creates an Application Default Credentials (ADC) file at `~/.config/gcloud/application_default_credentials.json`.

**Provider block example:**

```hcl
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
```

Terraform will automatically use ADC if no credentials are specified.

**Best Practice:** Use named configurations for multiple projects:

```bash
gcloud config configurations create dev
# Set project, region, etc.
gcloud config set project my-dev-project
gcloud config set compute/region us-central1
gcloud config configurations activate dev
```

---

## 2. Service Account Key File (for CI/CD and Automation)

For automation (GitHub Actions, GitLab CI, Azure Pipelines), use a GCP Service Account with the required IAM roles. Download its JSON key and store it securely (never commit to code).

**Set the environment variable:**

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

**Provider block example:**

```hcl
provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project
  region      = var.gcp_region
}
```

**GitHub Actions Example:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      GOOGLE_APPLICATION_CREDENTIALS: ${{ secrets.GCP_CREDENTIALS }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - name: Write GCP credentials
        run: echo "$GOOGLE_APPLICATION_CREDENTIALS" > /tmp/account.json
      - run: export GOOGLE_APPLICATION_CREDENTIALS=/tmp/account.json && terraform init
      - run: export GOOGLE_APPLICATION_CREDENTIALS=/tmp/account.json && terraform apply -auto-approve
```

**GitLab CI Example:**

```yaml
variables:
  GOOGLE_APPLICATION_CREDENTIALS: /tmp/account.json

before_script:
  - echo "$GCP_CREDENTIALS" > /tmp/account.json

stages:
  - apply

apply:
  stage: apply
  image: hashicorp/terraform:1.7.5
  script:
    - terraform init
    - terraform apply -auto-approve
```

---

## 3. Workload Identity Federation (OIDC for CI/CD)

For passwordless, keyless authentication in CI/CD, use [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation). This is the most secure and recommended approach for production pipelines.

- Configure a Workload Identity Pool and Provider in GCP.
- Grant the pool access to the required GCP resources.
- Use OIDC tokens from GitHub Actions, GitLab, or Azure DevOps to authenticate.

**GitHub Actions Example:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider'
          service_account: 'terraform-ci@my-project.iam.gserviceaccount.com'
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

---

## 4. NixOS: Declarative GCP Credentials

Add credentials as environment variables in your NixOS configuration:

```nix
# configuration.nix
{
  environment.variables = {
    GOOGLE_APPLICATION_CREDENTIALS = "/etc/nixos/gcp-service-account.json";
  };
}
```

Or use [agenix](https://github.com/ryantm/agenix) for encrypted secrets.

---

## Best Practices

- Use Workload Identity Federation (OIDC) for CI/CD pipelines (no static keys)
- Store service account keys in secret managers (never in code)
- Grant least privilege IAM roles to service accounts
- Rotate and audit service account keys regularly
- Use named gcloud configurations for multi-project workflows
- Never use user credentials in automation

---

## References

- [Terraform GCP Provider Auth Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference)
- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Terraform in GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Terraform in GitLab CI/CD](https://docs.gitlab.com/ee/ci/examples/terraform.html)
- [Terraform in Azure DevOps](https://learn.microsoft.com/en-us/azure/developer/terraform/overview)

> **Tip:** For secure, auditable, and cloud-native deployments, prefer OIDC-based authentication for CI/CD and never commit service account keys to your repository.

---

```markdown
- [Authenticating Terraform with GCP](pages/terraform/gcp/gpc_auth_terraform.md)
```
