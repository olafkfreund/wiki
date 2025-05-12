---
description: >-
  The Kubernetes provider allows you to create Kubernetes resources directly
  with Bicep. Bicep can deploy anything that can be deployed with the Kubernetes
  command-line client (kubectl) and a Kubernetes
---

# Kubernetes provider

### Enable the preview feature <a href="#enable-the-preview-feature" id="enable-the-preview-feature"></a>

This preview feature can be enabled by configuring the [bicepconfig.json](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config):thumbsup:

```json
{
  "experimentalFeaturesEnabled": {
    "extensibility": true
  }
}
```plaintext

The following sample imports the Kubernetes provider:

```bicep
@secure()
param kubeConfig string

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
} as k8s
```plaintext

Take this example:

{% code overflow="wrap" lineNumbers="true" %}
```bicep
@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
```plaintext
{% endcode %}

### Add the application definition: <a href="#add-the-application-definition" id="add-the-application-definition"></a>

1. Create a file named `azure-vote.yaml` in the same folder as `main.bicep` with the following YAML definition:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```plaintext

2. Open azure-vote.bicep and add the following line at the end of the file to output the load balancer public IP:

{% code overflow="wrap" %}
```bicep
output frontendIp string = coreService_azureVoteFront.status.loadBalancer.ingress[0].ip
```plaintext
{% endcode %}

3. Before the `output` statement in `main.bicep`, add the following Bicep to reference the newly created `azure-vote.bicep` module:

```bicep
module kubernetes './azure-vote.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
  }
}
```plaintext

4. At the bottom of `main.bicep`, add the following line to output the load balancer public IP:

```bicep
output lbPublicIp string = kubernetes.outputs.frontendIpi
```plaintext

### Deploy the Bicep file <a href="#deploy-the-bicep-file" id="deploy-the-bicep-file"></a>

Using CLI:

{% code overflow="wrap" lineNumbers="true" %}
```bash
az group create --name myResourceGroup --location eastus
az deployment group create --resource-group myResourceGroup --template-file main.bicep --parameters clusterName=<cluster-name> dnsPrefix=<dns-previs> linuxAdminUsername=<linux-admin-username> sshRSAPublicKey='<ssh-key>'er
```plaintext
{% endcode %}

Using Powershell:

{% code overflow="wrap" lineNumbers="true" %}
```powershell
New-AzResourceGroup -Name myResourceGroup -Location eastus
New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep -clusterName=<cluster-name> -dnsPrefix=<dns-prefix> -linuxAdminUsername=<linux-admin-username> -sshRSAPublicKey="<ssh-key>"
```plaintext
{% endcode %}
