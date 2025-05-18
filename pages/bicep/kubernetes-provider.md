---
description: >-
  The Kubernetes provider allows you to create Kubernetes resources directly
  with Bicep. Bicep can deploy anything that can be deployed with the Kubernetes
  command-line client (kubectl) using the Kubernetes API.
---

# Kubernetes Provider for Bicep (2025)

The Kubernetes provider in Bicep lets you define and deploy Kubernetes resources directly alongside your Azure infrastructure. This enables unified, end-to-end IaC workflows for DevOps and SRE teams managing both cloud and Kubernetes environments.

---

## Why Use the Kubernetes Provider?

- **Unified IaC**: Manage Azure and Kubernetes resources in a single Bicep template
- **Automation**: Integrate with CI/CD (GitHub Actions, Azure Pipelines) for full-stack deployments
- **Security**: Use `@secure()` for sensitive kubeConfig values and integrate with Azure Key Vault
- **Modularity**: Separate infra and app layers with Bicep modules

---

## Enable the Extensibility Preview Feature

The Kubernetes provider is in preview. Enable it by adding a `bicepconfig.json` to your project root:

```json
{
  "experimentalFeaturesEnabled": {
    "extensibility": true
  }
}
```

---

## Basic Usage

### Import the Kubernetes Provider

```bicep
@secure()
param kubeConfig string

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
} as k8s
```

### Creating Kubernetes Resources

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

---

## Real-Life DevOps & SRE Examples

### 1. Deploy a Namespace, ConfigMap, and Deployment

```bicep
resource myNamespace 'core/v1' = {
  kind: 'Namespace'
  metadata: {
    name: 'devops-apps'
  }
}

import 'kubernetes@1.0.0' with {
  namespace: myNamespace.metadata.name
  kubeConfig: kubeConfig
} as k8s

resource myConfigMap 'core/v1' = {
  kind: 'ConfigMap'
  metadata: {
    name: 'app-config'
  }
  data: {
    'ENV': 'production'
    'LOG_LEVEL': 'info'
  }
}

resource myDeployment 'apps/v1' = {
  kind: 'Deployment'
  metadata: {
    name: 'nginx-app'
  }
  spec: {
    replicas: 2
    selector: {
      matchLabels: {
        app: 'nginx-app'
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'nginx-app'
        }
      }
      spec: {
        containers: [
          {
            name: 'nginx'
            image: 'nginx:1.25.0'
            envFrom: [
              {
                configMapRef: {
                  name: 'app-config'
                }
              }
            ]
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

### 2. Load YAML Manifests from File

```bicep
resource fromYaml 'core/v1' = {
  kind: 'List'
  apiVersion: 'v1'
  items: loadYamlContent('k8s-manifests.yaml')
}
```

---

## End-to-End Example: AKS Cluster with App Deployment

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

---

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

---

## Best Practices (2025)

- Use `@secure()` for kubeConfig and secrets
- Separate infra and app layers with Bicep modules
- Use parameter files for environment-specific values
- Validate with `az bicep build` and test with `az deployment group what-if`
- Use logical namespaces for multi-tenant clusters
- Store kubeConfig in Azure Key Vault for production

---

## Common Pitfalls

- Using admin kubeConfig in production (prefer service accounts)
- Not validating resource dependencies (use `dependsOn`)
- Overloading a single template with too many resources
- Not using YAML for complex or custom CRDs

---

## CI/CD Integration Example (GitHub Actions)

```yaml
- name: Deploy Infra and K8s Resources
  run: |
    az deployment group create \
      --resource-group myResourceGroup \
      --template-file main.bicep \
      --parameters kubeConfig="${{ secrets.KUBECONFIG }}"
```

---

## Azure & Bicep Jokes

> **Bicep Joke:** Why did the SRE use Bicep for Kubernetes? To flex on YAML!

> **Azure Joke:** Why did the pod love Azure? It always had a resource group to hang out in!

---

## References

- [Bicep Kubernetes Provider Docs](https://learn.microsoft.com/azure/azure-resource-manager/bicep/kubernetes-extensibility)
- [AKS Documentation](https://learn.microsoft.com/azure/aks/)
- [Bicep Official Docs](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

---

> **Search Tip:** Use keywords like `bicep kubernetes`, `aks`, `namespace`, `configmap`, or `ci/cd` to quickly find relevant examples and best practices.
