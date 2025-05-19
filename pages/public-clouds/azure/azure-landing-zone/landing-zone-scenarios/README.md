# Landing Zone scenarios

## What is an Azure Landing Zone?

An Azure Landing Zone is a pre-configured, scalable, and secure cloud environment that provides a foundation for workloads and applications. It implements best practices for governance, security, networking, and resource organization, enabling rapid and compliant cloud adoption.

## Azure Landing Zone Best Practices for 2025

### 1. Modular, Scalable Design

- Use modular templates (Terraform modules, Bicep modules) for networking, identity, security, and management.
- Example (Terraform):

```hcl
module "network" {
  source = "Azure/network/azurerm"
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}
```

### 2. Infrastructure as Code (IaC) First

- Deploy all landing zone resources using IaC (Terraform, Bicep) for repeatability and auditability.
- Example (Bicep):

```bicep
module policy 'policy.bicep' = {
  name: 'policy'
  params: {
    policyName: 'enforce-tagging'
  }
}
```

### 3. Security and Compliance by Default

- Enforce security baselines (Azure Policy, Defender for Cloud, RBAC, Key Vault integration).
- Example (Azure CLI):

```sh
az policy assignment create --policy "audit-vm-managed-disks-encryption" --scope /subscriptions/<sub-id>
```

### 4. Automated Identity and Access Management

- Integrate Azure AD, enable conditional access, and automate RBAC assignments.
- Example:

```sh
az ad group create --display-name "CloudOps" --mail-nickname cloudops
az role assignment create --assignee <group-id> --role "Contributor" --scope /subscriptions/<sub-id>
```

### 5. Centralized Logging, Monitoring, and Cost Management

- Deploy Log Analytics, Azure Monitor, and set up budgets and cost alerts.
- Example:

```sh
az monitor log-analytics workspace create --resource-group rg-landingzone --workspace-name law-landingzone
az consumption budget create --resource-group rg-landingzone --amount 5000 --time-grain monthly --name lz-budget
```

### 6. Automation and CI/CD

- Use GitHub Actions, Azure Pipelines, or Terraform Cloud for automated deployments and policy enforcement.
- Example (GitHub Actions):

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - run: az deployment sub create --location westeurope --template-file main.bicep
```

### 7. LLM and AI Integration

- Integrate Large Language Models (LLMs) for automated documentation, policy generation, and compliance checks.
- Example: Use Azure OpenAI Service to generate policy documentation or automate code reviews.

### 8. Tagging and Naming Standards

- Enforce organization-wide tagging and naming conventions for all resources.
- Example:

```hcl
resource "azurerm_resource_group" "main" {
  name = "rg-landingzone-prod-weu"
  tags = {
    Environment = "prod"
    Owner       = "cloudops"
  }
}
```

## Common Pitfalls

- Manual resource creation (leads to drift and compliance issues)
- Inconsistent security and policy enforcement
- Lack of cost controls and monitoring
- Not updating landing zone modules for new Azure features

## References

- [Microsoft Cloud Adoption Framework: Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Enterprise-Scale Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/)
- [Terraform Azure Landing Zones](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale)

> **Joke:** Why did the landing zone never get lost? Because it always followed best practices!
