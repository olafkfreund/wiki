## Common Azure CLI Commands

Here are frequently used Azure CLI commands for DevOps workflows:

```bash
# Login to Azure
az login

# Set subscription context
az account set --subscription "Your Subscription Name"

# Create a resource group
az group create --name myResourceGroup --location eastus2

# List all resource groups
az group list --output table

# Get details about an AKS cluster
az aks show --resource-group myResourceGroup --name myAKSCluster
```