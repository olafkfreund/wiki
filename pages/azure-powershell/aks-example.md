---
description: >-
  Create and manage Azure Kubernetes Service (AKS) clusters using Azure PowerShell with advanced configuration options and best practices.
---

# Azure Kubernetes Service (AKS) with PowerShell

This guide demonstrates how to create, configure, and manage Azure Kubernetes Service (AKS) clusters using Azure PowerShell commands.

## Prerequisites

Before you begin, ensure you have:

```powershell
# Install required Azure PowerShell modules
Install-Module -Name Az -Repository PSGallery -Force
Install-Module -Name Az.Aks -Repository PSGallery -Force

# Log in to Azure
Connect-AzAccount

# Select subscription if you have multiple
Set-AzContext -SubscriptionId <subscription-id>
```

## Creating an AKS Cluster

### Basic Cluster Creation

```powershell
# Create resource group if it doesn't exist
New-AzResourceGroup -Name myResourceGroup -Location eastus

# Create a basic AKS cluster with 2 nodes
New-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -NodeCount 2 `
    -KubernetesVersion 1.26.6 `
    -GenerateSshKey `
    -Location eastus
```

### Advanced Cluster Creation

```powershell
# Create an AKS cluster with more advanced options
New-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAdvancedAKSCluster `
    -NodeCount 3 `
    -NodeVmSize "Standard_DS3_v2" `
    -KubernetesVersion 1.26.6 `
    -NetworkPlugin azure `
    -ServiceCidr "10.0.0.0/16" `
    -DnsServiceIp "10.0.0.10" `
    -DockerBridgeCidr "172.17.0.1/16" `
    -GenerateSshKey `
    -EnableRbac `
    -AcrNameToAttach myAcrRegistry `
    -EnableManagedIdentity `
    -Location eastus
```

### Create Cluster with Multiple Node Pools

```powershell
# First create a cluster with a system node pool
$cluster = New-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myMultiPoolCluster `
    -NodeCount 2 `
    -NodeVmSize "Standard_DS2_v2" `
    -KubernetesVersion 1.26.6 `
    -GenerateSshKey `
    -EnableRbac `
    -Location eastus

# Add a user node pool for workloads
New-AzAksNodePool `
    -ResourceGroupName myResourceGroup `
    -ClusterName myMultiPoolCluster `
    -Name userpool1 `
    -NodeCount 3 `
    -VmSize "Standard_DS3_v2" `
    -Mode User `
    -OsType Linux `
    -MaxPods 30
```

## Connecting to Your AKS Cluster

```powershell
# Install kubectl if not already installed
Install-AzAksKubectl

# Get credentials for the cluster
Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster -Admin

# Verify connection by listing nodes
kubectl get nodes

# Get cluster information
kubectl cluster-info
```

## Managing AKS Clusters

### Scaling Node Pools

```powershell
# Scale the default node pool
Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeCount 5

# Scale a specific node pool
Update-AzAksNodePool `
    -ResourceGroupName myResourceGroup `
    -ClusterName myMultiPoolCluster `
    -Name userpool1 `
    -NodeCount 5
```

### Upgrading an AKS Cluster

```powershell
# Get available Kubernetes versions
Get-AzAksVersion -Location eastus

# Upgrade cluster to a newer version
Set-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -KubernetesVersion 1.27.3
```

### Enabling Add-ons

```powershell
# Enable monitoring add-on
Set-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -EnableAzureMonitor

# Enable Azure Policy for Kubernetes
Set-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -EnableAzurePolicy
```

## Working with Deployments

After connecting to your cluster with `Import-AzAksCredential`, you can deploy applications:

```powershell
# Deploy a simple application
kubectl apply -f https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/all-in-one/guestbook-all-in-one.yaml

# Check deployment status
kubectl get deployments

# Access service details
kubectl get service frontend
```

## Integrating with Azure Container Registry (ACR)

```powershell
# Create an ACR if you don't have one
New-AzContainerRegistry `
    -ResourceGroupName myResourceGroup `
    -Name myAcrRegistry `
    -EnableAdminUser `
    -Sku Standard `
    -Location eastus

# Attach ACR to an existing AKS cluster
Set-AzAksCluster `
    -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -AcrNameToAttach myAcrRegistry
```

## Cleanup Resources

```powershell
# Delete an AKS cluster
Remove-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster

# Delete the resource group and all resources
Remove-AzResourceGroup -Name myResourceGroup -Force
```

## Best Practices for AKS with PowerShell

1. **Use PowerShell Scripts for Repeatability**
   - Store your cluster creation scripts in version control
   - Parameterize scripts for different environments (dev, test, prod)

2. **Security Recommendations**
   - Enable RBAC (`-EnableRbac`)
   - Use Azure AD integration for authentication
   - Implement network policies

3. **Node Pool Strategy**
   - Use system node pools for system services
   - Create dedicated user node pools for specific workload types
   - Consider using spot instances for cost optimization (`-EnableNodePublicIp`)

4. **Monitoring and Operations**
   - Enable Azure Monitor for containers
   - Set up alerts for resource utilization
   - Regularly upgrade to supported Kubernetes versions

5. **Resource Management**
   - Set resource quotas and limits for namespaces
   - Implement autoscaling for both clusters and deployments

## References

- [Azure PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/azure/)
- [AKS PowerShell Module Reference](https://docs.microsoft.com/en-us/powershell/module/az.aks/)
- [Azure PowerShell Samples Repository](https://github.com/Azure/azure-docs-powershell-samples)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
