# Best Practices for Azure Implementation (DevOps & Cloud Architects)

## 1. Organize Resources with Management Groups, Subscriptions, and Resource Groups

- **Best Practice:** Use management groups for policy enforcement, separate subscriptions for environments (dev, test, prod), and resource groups for logical grouping.
- **Example:**

```sh
az account management-group create --name platform
az account management-group create --name prod --parent platform
az group create --name rg-app-prod --location westeurope
```

## 2. Infrastructure as Code (IaC)

- **Best Practice:** Use Terraform or Bicep for declarative, version-controlled infrastructure.
- **Terraform Example:**

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-app-prod"
  location = "westeurope"
}
```

- **Bicep Example:**

```bicep
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-app-prod'
  location: 'westeurope'
}
```

- **Common Pitfall:** Manual changes in the portal can cause drift. Always use IaC for changes.

## 3. Secure Identity and Access

- **Best Practice:** Use Azure AD for identity, enable MFA, and apply least-privilege RBAC.
- **Example:**

```sh
az ad group create --display-name "DevOps Team" --mail-nickname devops
az role assignment create --assignee <user-or-group-id> --role "Contributor" --resource-group rg-app-prod
```

- **Common Pitfall:** Assigning Owner role too broadly. Use custom roles for fine-grained access.

## 4. Secrets Management

- **Best Practice:** Store secrets in Azure Key Vault, never in code or pipelines.
- **Example:**

```sh
az keyvault create --name my-keyvault --resource-group rg-app-prod --location westeurope
az keyvault secret set --vault-name my-keyvault --name "DbPassword" --value "SuperSecret123"
```

## 5. Automate Deployments with CI/CD

- **Best Practice:** Use GitHub Actions or Azure Pipelines for automated builds, tests, and deployments.
- **GitHub Actions Example:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - run: az deployment group create --resource-group rg-app-prod --template-file main.bicep
```

- **Azure Pipelines Example:**

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'MyServiceConnection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az deployment group create --resource-group rg-app-prod --template-file main.bicep
```

## 6. Monitoring and Observability

- **Best Practice:** Enable Azure Monitor and Log Analytics for all resources. Set up alerts for critical metrics.
- **Example:**

```sh
az monitor log-analytics workspace create --resource-group rg-app-prod --workspace-name law-prod
az monitor diagnostic-settings create --resource-id <resource-id> --workspace law-prod --logs '[{"category": "AllLogs", "enabled": true}]'
```

## 7. Cost Management

- **Best Practice:** Use budgets and cost alerts. Tag resources for cost allocation.
- **Example:**

```sh
az consumption budget create --resource-group rg-app-prod --amount 1000 --time-grain monthly --name prod-budget
az tag create --resource-id <resource-id> --tags Environment=Prod Owner=DevOps
```

## 8. Common Pitfalls

- Not using IaC for all changes (leads to drift)
- Over-permissioned identities
- Ignoring monitoring and cost alerts
- Hardcoding secrets in code or pipelines

## References

- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

> **Joke:** Why did the Azure resource group break up with the VM? It needed more space!
