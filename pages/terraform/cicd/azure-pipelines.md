# Terraform in Azure DevOps Pipelines

Azure DevOps Pipelines is a powerful CI/CD platform for automating infrastructure deployments with Terraform across Azure, AWS, and GCP. It provides deep integration with Azure, robust security controls, and flexible pipeline authoring. Below are real-life scenarios, best practices, and a comparison with GitHub Actions and GitLab CI/CD.

---

## Why Use Azure DevOps Pipelines for Terraform?

- **Enterprise integration:** Native support for Azure RBAC, Key Vault, and Service Connections.
- **Pipeline as Code:** YAML pipelines for versioned, auditable automation.
- **Multi-cloud:** Supports AWS, Azure, GCP, and hybrid deployments.
- **Security:** Fine-grained permissions, secret management, and audit trails.
- **Scalability:** Hosted and self-hosted agents for large teams and complex workflows.

---

## Real-Life Scenarios

### 1. Deploying Azure Infrastructure with Service Principal

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include: [ main ]

pool:
  vmImage: 'ubuntu-latest'

variables:
  TF_VERSION: '1.7.5'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.x'
- task: TerraformInstaller@1
  inputs:
    terraformVersion: '$(TF_VERSION)'
- task: AzureCLI@2
  inputs:
    azureSubscription: 'MyServiceConnection' # Service connection in Azure DevOps
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az --version
      terraform --version
      terraform init
      terraform plan -out=tfplan
      terraform apply -auto-approve tfplan
    workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
  env:
    ARM_CLIENT_ID: $(servicePrincipalId)
    ARM_CLIENT_SECRET: $(servicePrincipalKey)
    ARM_SUBSCRIPTION_ID: $(subscriptionId)
    ARM_TENANT_ID: $(tenantId)
```

**When to use:**

- Enterprise Azure environments needing RBAC, Key Vault, and audit integration
- Teams with existing Azure DevOps adoption

---

### 2. Multi-Cloud Deployments (AWS, GCP)

Use Azure DevOps to deploy to AWS or GCP by storing credentials in Azure Key Vault or pipeline secrets.

```yaml
steps:
- task: TerraformInstaller@1
  inputs:
    terraformVersion: '1.7.5'
- script: |
    export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)
    export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
    terraform init
    terraform plan
    terraform apply -auto-approve
  env:
    AWS_ACCESS_KEY_ID: $(awsAccessKeyId)
    AWS_SECRET_ACCESS_KEY: $(awsSecretAccessKey)
```

**When to use:**

- Centralized DevOps for multi-cloud (Azure, AWS, GCP) from a single platform

---

### 3. Secure Secret Management with Azure Key Vault

```yaml
steps:
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'MyServiceConnection'
    KeyVaultName: 'my-keyvault'
    SecretsFilter: 'terraform-sp-client-id,terraform-sp-client-secret'
- script: |
    export ARM_CLIENT_ID=$(terraform-sp-client-id)
    export ARM_CLIENT_SECRET=$(terraform-sp-client-secret)
    terraform init
    terraform apply -auto-approve
```

**When to use:**

- Enforce secret rotation and centralized credential management

---

## Best Practices for Security and Deployments

- Use Service Connections and Key Vault for all secrets—never store credentials in code or variables.
- Use separate pipelines and Service Principals for dev, staging, and prod.
- Enable RBAC and audit logging for all pipeline actions.
- Use remote state (Azure Storage, AWS S3, GCP Storage) with state locking.
- Pin Terraform and provider versions for reproducibility.
- Use pipeline approvals and manual gates for production deployments.
- Scan Terraform code with TFLint, Checkov, or tfsec in the pipeline.

---

## Azure DevOps vs GitHub Actions vs GitLab CI/CD

| Feature                | Azure DevOps Pipelines | GitHub Actions         | GitLab CI/CD           |
|------------------------|-----------------------|------------------------|------------------------|
| **Best for**           | Enterprise, Azure     | Open source, GitHub    | Self-hosted, GitLab    |
| **Secret Management**  | Key Vault, Library    | GitHub Secrets         | GitLab CI/CD Secrets   |
| **RBAC**               | Native, granular      | Basic (org/repo)       | Flexible, project/group|
| **Multi-cloud**        | Yes                   | Yes                    | Yes                    |
| **Pipeline as Code**   | YAML                  | YAML                   | YAML                   |
| **Marketplace**        | Extensions            | Actions Marketplace    | GitLab Registry        |
| **Audit/Compliance**   | Strong                | Moderate               | Strong                 |
| **Integration**        | Azure, MSFT stack     | GitHub, open ecosystem | GitLab, self-hosted    |

**Summary:**

- **Azure DevOps Pipelines:** Best for enterprise Azure, strong RBAC, Key Vault, and compliance.
- **GitHub Actions:** Best for open source, GitHub-native, fast setup, good for multi-cloud.
- **GitLab CI/CD:** Best for self-hosted, advanced runners, and integrated DevSecOps.

---

## References

- [Terraform in Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/developer/terraform/overview)
- [Terraform Azure DevOps Extension](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
- [Azure Key Vault Integration](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/key-vault)
- [Terraform Security Scanning (Checkov)](https://www.checkov.io/)
- [Terraform in GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Terraform in GitLab CI/CD](https://docs.gitlab.com/ee/ci/examples/terraform.html)

> **Tip:** For cloud-agnostic, secure, and auditable IaC, use Azure DevOps Pipelines with Service Principals, Key Vault, and remote state. For open source or hybrid teams, consider GitHub Actions or GitLab CI/CD.

---

```markdown
- [Terraform in Azure DevOps Pipelines](pages/terraform/cicd/azure-pipelines.md)
```
