---
description: >-
  The Kubernetes provider allows you to create Kubernetes resources directly
  with Bicep. Bicep can deploy anything that can be deployed with the Kubernetes
  command-line client (kubectl) using the Kubernetes API.
---

# Kubernetes Provider for Bicep

The Kubernetes provider in Bicep allows you to define and deploy Kubernetes resources directly alongside your Azure infrastructure. This feature bridges the gap between infrastructure provisioning and application deployment, enabling a unified IaC workflow.

## Enable the Extensibility Preview Feature

The Kubernetes provider is currently available as a preview feature. To enable it, create a `bicepconfig.json` file in your project root with the following content:

```json
{
  "experimentalFeaturesEnabled": {
    "extensibility": true
  }
}
```

## Basic Usage

### Import the Kubernetes Provider

To use the Kubernetes provider, first import it in your Bicep file:

```bicep
@secure()
param kubeConfig string

// Import the Kubernetes provider
import 'kubernetes@1.0.0' with {
  namespace: 'default'  // Default namespace for resources
  kubeConfig: kubeConfig  // Kubernetes configuration
} as k8s
```

### Creating Kubernetes Resources

After importing the provider, you can create Kubernetes resources using the imported namespace:

```bicep
// Create a ConfigMap
resource myConfigMap 'core/v1' = {
  kind: 'ConfigMap'
  metadata: {
    name: 'my-config'
  }
  data: {
    'key1': 'value1'
    'key2': 'value2'
  }
}

// Create a Deployment
resource myDeployment 'apps/v1' = {
  kind: 'Deployment'
  metadata: {
    name: 'my-app'
  }
  spec: {
    replicas: 3
    selector: {
      matchLabels: {
        app: 'my-app'
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'my-app'
        }
      }
      spec: {
        containers: [
          {
            name: 'my-container'
            image: 'nginx:latest'
            ports: [
              {
                containerPort: 80
              }
            ]
          }
        ]
      }
    }
  }
}
```

## End-to-End Example: AKS Cluster with Application Deployment

This example demonstrates creating an AKS cluster and deploying an application to it in a single Bicep template.

### 1. Create the AKS Cluster (main.bicep)

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

// Reference the Kubernetes application deployment module
module kubernetes './azure-vote.bicep' = {
  name: 'kubernetes-app-deploy'
  params: {
    kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
output applicationIp string = kubernetes.outputs.frontendIp
```

### 2. Define the Application Resources (azure-vote.bicep)

```bicep
@secure()
param kubeConfig string

// Import the Kubernetes provider
import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
} as k8s

// Define Redis backend deployment
resource redisDeployment 'apps/v1' = {
  kind: 'Deployment'
  metadata: {
    name: 'azure-vote-back'
  }
  spec: {
    replicas: 1
    selector: {
      matchLabels: {
        app: 'azure-vote-back'
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'azure-vote-back'
        }
      }
      spec: {
        nodeSelector: {
          'kubernetes.io/os': 'linux'
        }
        containers: [
          {
            name: 'azure-vote-back'
            image: 'mcr.microsoft.com/oss/bitnami/redis:6.0.8'
            env: [
              {
                name: 'ALLOW_EMPTY_PASSWORD'
                value: 'yes'
              }
            ]
            resources: {
              requests: {
                cpu: '100m'
                memory: '128Mi'
              }
              limits: {
                cpu: '250m'
                memory: '256Mi'
              }
            }
            ports: [
              {
                containerPort: 6379
                name: 'redis'
              }
            ]
          }
        ]
      }
    }
  }
}

// Redis service
resource redisService 'core/v1' = {
  kind: 'Service'
  metadata: {
    name: 'azure-vote-back'
  }
  spec: {
    ports: [
      {
        port: 6379
      }
    ]
    selector: {
      app: 'azure-vote-back'
    }
  }
}

// Frontend deployment
resource frontendDeployment 'apps/v1' = {
  kind: 'Deployment'
  metadata: {
    name: 'azure-vote-front'
  }
  spec: {
    replicas: 1
    selector: {
      matchLabels: {
        app: 'azure-vote-front'
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'azure-vote-front'
        }
      }
      spec: {
        nodeSelector: {
          'kubernetes.io/os': 'linux'
        }
        containers: [
          {
            name: 'azure-vote-front'
            image: 'mcr.microsoft.com/azuredocs/azure-vote-front:v1'
            resources: {
              requests: {
                cpu: '100m'
                memory: '128Mi'
              }
              limits: {
                cpu: '250m'
                memory: '256Mi'
              }
            }
            ports: [
              {
                containerPort: 80
              }
            ]
            env: [
              {
                name: 'REDIS'
                value: 'azure-vote-back'
              }
            ]
          }
        ]
      }
    }
  }
}

// Frontend service with LoadBalancer to expose the application
resource frontendService 'core/v1' = {
  kind: 'Service'
  metadata: {
    name: 'azure-vote-front'
  }
  spec: {
    type: 'LoadBalancer'
    ports: [
      {
        port: 80
      }
    ]
    selector: {
      app: 'azure-vote-front'
    }
  }
}

// Output the frontend service IP address
output frontendIp string = frontendService.status.loadBalancer.ingress[0].ip
```

## Deployment Instructions

### Using Azure CLI

```bash
# Create a resource group
az group create --name myResourceGroup --location eastus

# Deploy the Bicep template
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters \
      clusterName=myAksCluster \
      dnsPrefix=myakscluster \
      linuxAdminUsername=azureuser \
      sshRSAPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

### Using PowerShell

```powershell
# Create a resource group
New-AzResourceGroup -Name myResourceGroup -Location eastus

# Deploy the Bicep template
New-AzResourceGroupDeployment `
  -ResourceGroupName myResourceGroup `
  -TemplateFile ./main.bicep `
  -clusterName myAksCluster `
  -dnsPrefix myakscluster `
  -linuxAdminUsername azureuser `
  -sshRSAPublicKey (Get-Content ~/.ssh/id_rsa.pub -Raw)
```

## Best Practices

1. **Secure kubeConfig Handling**
   - Always use the `@secure()` decorator for kubeConfig parameters
   - Consider using Azure Key Vault to store and retrieve kubeConfig values

2. **Resource Organization**
   - Separate infrastructure (AKS) and application (Kubernetes resources) into different Bicep modules
   - Use logical naming conventions for resources

3. **Namespace Management**
   - Use specific namespaces for different applications or environments
   - Create namespaces explicitly in your Bicep files

   ```bicep
   resource namespace 'core/v1' = {
     kind: 'Namespace'
     metadata: {
       name: 'my-application'
     }
   }
   
   // Then specify it when importing
   import 'kubernetes@1.0.0' with {
     namespace: namespace.metadata.name
     kubeConfig: kubeConfig
   } as k8s
   ```

4. **Configuration Management**
   - Use ConfigMaps and Secrets for application configuration
   - Consider parameter files for environment-specific values

5. **Resource Dependencies**
   - Use dependencies to ensure proper deployment order
   - For example, make sure services are created after their deployments

## Limitations and Considerations

- The Kubernetes provider is in preview and subject to change
- Complex Kubernetes objects might be easier to define using YAML and importing them
- For large-scale Kubernetes deployments, consider dedicated tools like Helm
- Using admin credentials in production environments is not recommended

## Alternative Approach: Using YAML Files

For complex Kubernetes manifests, you can use existing YAML files:

```bicep
@secure()
param kubeConfig string

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
} as k8s

resource fromYaml 'core/v1' = {
  kind: 'List'
  apiVersion: 'v1'
  items: loadYamlContent('kubernetes-manifests.yaml')
}
```

## Conclusion

The Kubernetes provider for Bicep enables DevOps teams to manage both Azure infrastructure and Kubernetes resources in a unified way, streamlining the deployment process and reducing the complexity of managing multiple toolchains.
