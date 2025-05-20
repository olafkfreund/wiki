# Terraform in GitLab CI/CD Pipelines

GitLab CI/CD is a robust automation platform for deploying infrastructure with Terraform across AWS, Azure, and GCP. It offers tight integration with GitLab repositories, built-in secret management, and flexible runners. Below are real-life scenarios, best practices, and a comparison with GitHub Actions and Azure DevOps Pipelines.

---

## Why Use GitLab CI/CD for Terraform?
- **Integrated experience:** Native with GitLab repos, merge requests, and issues.
- **Secret management:** Built-in CI/CD variables and Vault integration.
- **Flexible runners:** Use shared, group, or self-hosted runners (Linux, NixOS, Docker, etc.).
- **Multi-cloud:** Supports AWS, Azure, GCP, and hybrid deployments.
- **Pipeline as Code:** YAML-based, versioned, and auditable.

---

## Real-Life Scenarios

### 1. Deploying to AWS with GitLab CI/CD

```yaml
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: "terraform"

validate:
  stage: validate
  image: hashicorp/terraform:1.7.5
  script:
    - cd $TF_ROOT
    - terraform init -input=false
    - terraform validate

plan:
  stage: plan
  image: hashicorp/terraform:1.7.5
  script:
    - cd $TF_ROOT
    - terraform init -input=false
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - $TF_ROOT/tfplan

apply:
  stage: apply
  image: hashicorp/terraform:1.7.5
  script:
    - cd $TF_ROOT
    - terraform apply -auto-approve tfplan
  when: manual
  only:
    - main
  environment:
    name: production
  dependencies:
    - plan
```

**When to use:**
- Teams using GitLab for code, issues, and CI/CD
- AWS, Azure, or GCP deployments with GitLab-managed secrets

---

### 2. Multi-Cloud Deployments with Secure Variables

Store cloud credentials as [GitLab CI/CD variables](https://docs.gitlab.com/ee/ci/variables/):
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`
- `GOOGLE_CREDENTIALS` (JSON)

Reference them in your pipeline:

```yaml
before_script:
  - export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
  - export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
  - export ARM_CLIENT_ID="$ARM_CLIENT_ID"
  - export ARM_CLIENT_SECRET="$ARM_CLIENT_SECRET"
  - export ARM_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID"
  - export ARM_TENANT_ID="$ARM_TENANT_ID"
  - export GOOGLE_CREDENTIALS="$GOOGLE_CREDENTIALS"
```

**When to use:**
- Centralized, secure multi-cloud deployments from a single pipeline

---

### 3. NixOS-based Runners for Reproducible IaC

Use a NixOS self-hosted runner to ensure consistent Terraform, provider, and tool versions:

```nix
# shell.nix for runner
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [ terraform tflint awscli azure-cli google-cloud-sdk ];
}
```

Register the runner with this shell for reproducible builds.

**When to use:**
- Teams needing strict reproducibility and custom toolchains

---

## Best Practices for Security and Deployments
- Store all secrets as masked/protected CI/CD variables—never in code.
- Use separate variables and pipelines for dev, staging, and prod.
- Use remote state (S3, Azure Storage, GCP Storage) with state locking.
- Pin Terraform and provider versions in your pipeline and code.
- Use `terraform validate`, `tflint`, and `checkov` in the pipeline.
- Require manual approval for production applies.
- Use merge request pipelines for plan/apply previews.

---

## GitLab CI/CD vs GitHub Actions vs Azure DevOps Pipelines

| Feature                | GitLab CI/CD           | GitHub Actions         | Azure DevOps Pipelines |
|------------------------|------------------------|------------------------|-----------------------|
| **Best for**           | Self-hosted, DevSecOps | Open source, GitHub    | Enterprise, Azure     |
| **Secret Management**  | CI/CD Variables, Vault | GitHub Secrets         | Key Vault, Library    |
| **RBAC**               | Flexible, project/group| Basic (org/repo)       | Native, granular      |
| **Multi-cloud**        | Yes                    | Yes                    | Yes                   |
| **Pipeline as Code**   | YAML                   | YAML                   | YAML                  |
| **Marketplace**        | Registry               | Actions Marketplace    | Extensions            |
| **Audit/Compliance**   | Strong                 | Moderate               | Strong                |
| **Integration**        | GitLab, self-hosted    | GitHub, open ecosystem | Azure, MSFT stack     |

**Summary:**
- **GitLab CI/CD:** Best for self-hosted, advanced runners, and integrated DevSecOps.
- **GitHub Actions:** Best for open source, GitHub-native, fast setup, good for multi-cloud.
- **Azure DevOps Pipelines:** Best for enterprise Azure, strong RBAC, Key Vault, and compliance.

---

## References
- [GitLab Terraform CI/CD Example](https://docs.gitlab.com/ee/ci/examples/terraform.html)
- [GitLab CI/CD Variables](https://docs.gitlab.com/ee/ci/variables/)
- [Terraform Security Scanning (Checkov)](https://www.checkov.io/)
- [Terraform in GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Terraform in Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/developer/terraform/overview)

> **Tip:** Use GitLab CI/CD for secure, reproducible, and auditable Terraform deployments—especially if you need custom runners, DevSecOps, or self-hosted control.

---

```markdown
- [Terraform in GitLab CI/CD Pipelines](pages/terraform/cicd/gitlab-ci.md)