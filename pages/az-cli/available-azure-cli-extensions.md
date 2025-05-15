# Available Azure CLI Extensions (2025)

Azure CLI extensions add new features and commands to the base CLI, enabling you to manage preview services, integrate with DevOps tools, and automate advanced workflows.

## Discovering Extensions

List all available extensions:
```bash
az extension list-available --output table
```

Or search for a specific extension:
```bash
az extension list-available --query "[?contains(name, 'aks')]" --output table
```

Full list: [Azure CLI Extensions List (Official)](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-list)

## Installing Extensions

Install an extension (e.g., for AKS preview features):
```bash
az extension add --name aks-preview
```

Upgrade all installed extensions:
```bash
az extension update --all
```

Remove an extension:
```bash
az extension remove --name <extension-name>
```

## Real-Life Example: Using the ML Extension for Azure Machine Learning

```bash
az extension add --name ml
az ml workspace create --name my-ml-ws --resource-group my-rg
```

## Best Practices (2025)
- Regularly update extensions: `az extension update --all`
- Use extensions only from trusted sources (Microsoft or verified partners)
- Remove unused extensions to reduce CLI startup time
- Check compatibility after major CLI upgrades
- Use `--output json` for automation and scripting

## Common Extensions for DevOps Engineers
- `aks-preview` – Advanced AKS features
- `ml` – Azure Machine Learning
- `devops` – Azure DevOps integration
- `logic` – Logic Apps management
- `containerapp` – Azure Container Apps
- `bicep` – Native Bicep support

## Troubleshooting
- If you encounter issues, try removing and reinstalling the extension
- Check for extension-specific documentation and GitHub issues

## References
- [Azure CLI Extensions Documentation](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview)
- [List of Extensions](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-list)
