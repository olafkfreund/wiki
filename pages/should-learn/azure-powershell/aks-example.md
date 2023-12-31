---
description: >-
  Create an AKS cluster using New-AzAksCluster. The following example creates a
  cluster named myAKSCluster in the resource group named myResourceGroup.
---

# AKS example

{% code overflow="wrap" lineNumbers="true" %}
```powershell
New-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeCount 2 -GenerateSshKey -AcrNameToAttach <acrName>
```
{% endcode %}

```powershell
Install-AzAksKubectl
```

```powershell
Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
```

```powershell
kubectl get nodes
```

Example repo on GitHub: [https://github.com/Azure/azure-docs-powershell-samples](https://github.com/Azure/azure-docs-powershell-samples)
