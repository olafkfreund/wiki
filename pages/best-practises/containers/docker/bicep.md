# Bicep: Deploying Docker Containers on Azure

This guide demonstrates how to use Bicep to deploy Docker containers to Azure Container Instances (ACI). It includes best practices, step-by-step deployment, troubleshooting, and common pitfalls for engineers working with Azure, Docker, and Infrastructure as Code.

---

## Best Practices for Bicep & Docker
- Use parameterization for image, CPU, memory, and ports to support multiple environments.
- Always use specific image tags (avoid `latest`) for reproducibility.
- Store secrets (e.g., registry credentials) in Azure Key Vault and reference them securely.
- Use resource group and location parameters for portability.
- Validate Bicep files before deployment:
  ```sh
  az bicep build --file main.bicep
  az deployment group validate --resource-group <rg> --template-file main.bicep
  ```
- Use outputs to retrieve container IPs or other runtime info for automation.

---

## Step-by-Step: Deploy a Docker Container with Bicep
1. **Create a Resource Group:**
   ```sh
   az group create --name exampleRG --location eastus
   ```
2. **Deploy the Bicep Template:**
   ```sh
   az deployment group create --resource-group exampleRG --template-file main.bicep
   ```
3. **Check Deployment Output:**
   - The output will include the public IP address of your container.
4. **List Resources:**
   ```sh
   az resource list --resource-group exampleRG
   ```
5. **View Container Logs:**
   ```sh
   az container logs --resource-group exampleRG --name acilinuxpublicipcontainergroup
   ```

---

## Real-Life Example: Parameterized Bicep for CI/CD
- Integrate Bicep deployment in GitHub Actions or Azure Pipelines for automated container rollouts.
- Example GitHub Actions step:
  ```yaml
  - name: Deploy to Azure
    uses: azure/arm-deploy@v1
    with:
      resourceGroupName: exampleRG
      template: main.bicep
      parameters: image=myrepo/myapp:1.2.3
  ```

---

## Common Pitfalls
- Using `latest` image tag (can cause unexpected updates)
- Not exposing required ports or using wrong protocol
- Insufficient CPU/memory for container workload
- Forgetting to set restart policy (may cause containers to stop unexpectedly)
- Not checking logs for failed deployments

---

## References
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Deploy containers with Bicep](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-bicep)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/container)

---

{% code overflow="wrap" %}
```bicep
@description('Name for the container group')
param name string = 'acilinuxpublicipcontainergroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
```plaintext
{% endcode %}

```bash
az group create --name exampleRG --location eastus
az deployment group create --resource-group exampleRG --template-file main.bicep
```plaintext

```bash
az resource list --resource-group exampleRG
```plaintext

{% code overflow="wrap" %}
```bash
az container logs --resource-group exampleRG --name acilinuxpublicipcontainergroup
```plaintext
{% endcode %}
