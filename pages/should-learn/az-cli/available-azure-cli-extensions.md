# Available Azure CLI Extensions

Azure CLI extensions add extra functionality to the base CLI, supporting new Azure services and preview features. Extensions are updated frequently, so always check the latest list.

## List All Available Extensions

```bash
az extension list-available --output table
```

Or view the full list online: [Azure CLI Extensions List](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-list)

## Install an Extension

```bash
az extension add --name <extension-name>
```

**Example:** Install the `aks-preview` extension for advanced AKS features:

```bash
az extension add --name aks-preview
```

## Real-Life Example: Use an Extension in Automation

In a GitHub Actions workflow to deploy Azure Container Apps (requires the `containerapp` extension):

```yaml
- name: Install Azure CLI extension
  run: az extension add --name containerapp
- name: Deploy Container App
  run: az containerapp create --name myapp --resource-group devops-rg --image myacr.azurecr.io/app:latest
```

## Best Practices

- **Keep extensions up to date:**

  ```bash
  az extension update --name <extension-name>
  ```

- **Remove unused extensions:**

  ```bash
  az extension remove --name <extension-name>
  ```

- **Check for compatibility issues** after major Azure CLI upgrades.

## Common Pitfalls

- Some extensions are in preview and may change or be deprecated.
- Extensions may require specific Azure CLI versions—check compatibility before upgrading.

## References

- [Official Azure CLI Extensions Documentation](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview)
- [List of All Extensions](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-list)

---

> **Azure Joke:**
> Why did the Azure CLI extension go to therapy? Because it couldn't handle all the new features without a little support!
