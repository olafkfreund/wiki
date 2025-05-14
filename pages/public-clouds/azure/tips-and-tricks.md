# Azure DevOps Engineering Tips & Tricks

## 🔑 Authentication & Security

### Azure AD Authentication
```bash
# Switch between multiple accounts
az account list --output table
az account set --subscription "Subscription-Name"

# Create service principal with certificate
az ad sp create-for-rbac --name "SP-Name" \
    --role "Contributor" \
    --scopes "/subscriptions/{SubID}" \
    --create-cert
```

### Security Automation
```bash
# Find resources without required tags
az resource list --query "[?tags==null]"

# List resources with public access
az network public-ip list --query "[].{Name:name,IP:ipAddress,Status:provisioningState}"
```

## 🚀 Infrastructure Optimization

### Cost Management
```bash
# List unused disks
az disk list --query "[?diskState=='Unattached']"

# Find unassociated public IPs
az network public-ip list --query "[?ipConfiguration==null]"
```

### Resource Management
- Use Azure Policy for governance
- Implement proper tagging strategy
- Regular cleanup of unused resources

## 💾 Data Management

### Storage Account Best Practices
```bash
# Enable blob soft delete
az storage account blob-service-properties update \
    --account-name mystorageaccount \
    --enable-delete-retention \
    --delete-retention-days 7

# Configure lifecycle management
az storage account management-policy create \
    --account-name mystorageaccount \
    --policy @policy.json
```

## 🔍 Monitoring & Alerting

### Azure Monitor Insights
```bash
# Create custom metric alerts
az monitor metrics alert create \
    --name "High-CPU-Alert" \
    --resource-group myResourceGroup \
    --condition "avg Percentage CPU > 90" \
    --window-size 5m \
    --evaluation-frequency 1m
```

### Application Insights
- Use custom dimensions for better filtering
- Implement proper sampling
- Set up availability tests

## 🛠 Infrastructure as Code

### ARM/Bicep Tips
```bash
# Test Bicep deployments
az deployment group what-if \
    --resource-group myResourceGroup \
    --template-file main.bicep

# Convert ARM to Bicep
az bicep decompile --file template.json
```

### Terraform Integration
```hcl
# Use Azure provider with managed identity
provider "azurerm" {
  features {}
  use_msi = true
}
```

## 🚦 Network Management

### Virtual Network Analysis
```bash
# Enable NSG flow logs
az network watcher flow-log create \
    --resource-group myResourceGroup \
    --name myFlowLog \
    --location westeurope \
    --nsg myNSG \
    --storage-account myStorageAccount

# Analyze effective routes
az network nic show-effective-route-table \
    --resource-group myResourceGroup \
    --name myNIC
```

## 🤖 Automation & DevOps

### Azure DevOps Automation
```yaml
# Use dynamic variables in pipelines
variables:
  - name: BuildConfiguration
    ${{ if eq(variables['Build.SourceBranchName'], 'main') }}:
      value: 'Release'
    ${{ if ne(variables['Build.SourceBranchName'], 'main') }}:
      value: 'Debug'
```

### Logic Apps Workflow
```bash
# Deploy Logic App workflow
az logicapp deployment create \
    --resource-group myResourceGroup \
    --name myLogicApp \
    --template-file workflow.json
```

## 🔒 Security Best Practices

### Key Vault Management
- Use managed identities
- Implement proper access policies
- Enable soft-delete and purge protection

### Network Security
```bash
# Enable DDoS protection
az network ddos-protection create \
    --resource-group myResourceGroup \
    --name myDDoSProtection \
    --location westeurope

# Configure private endpoints
az network private-endpoint create \
    --name myPrivateEndpoint \
    --resource-group myResourceGroup \
    --vnet-name myVNet \
    --subnet mySubnet \
    --private-connection-resource-id $storageAccountId \
    --group-id blob \
    --connection-name myConnection
```

## 💰 Cost Optimization Techniques

### Resource Scheduling
```bash
# Auto-shutdown VMs
az vm auto-shutdown -g myResourceGroup -n myVM \
    --time 2200 --email "admin@example.com"
```

### Cost Analysis
```bash
# Get cost by resource group
az consumption usage list \
    --start-date 2025-01-01 \
    --end-date 2025-05-14 \
    --query "[?contains(instanceId, 'resourceGroups')].{Cost:pretaxCost}"
```

## 🔄 Disaster Recovery

### Azure Site Recovery
```bash
# Enable replication
az site-recovery protection enable \
    --resource-group myResourceGroup \
    --vault-name myVault \
    --vm myVM \
    --target-zone "2"
```

### Backup Strategies
- Use Azure Backup for VMs
- Implement cross-region backup copies
- Regular restore testing

## 📊 Performance Optimization

### VM Performance
```bash
# Enable disk caching
az vm update -g myResourceGroup -n myVM \
    --set storageProfile.osDisk.cacheSettings.readWrite=true

# Monitor VM metrics
az monitor metrics list \
    --resource myVM \
    --metric "Percentage CPU" \
    --interval 5m
```

## Hidden Gems

1. Use Managed Identities wherever possible
2. Implement Azure Policy as Code
3. Use Azure Front Door for global applications
4. Leverage Event Grid for event-driven architectures
5. Use Azure Advisor API for optimization recommendations

## DevOps Best Practices

1. **Infrastructure as Code**
   - Version control all templates
   - Use nested templates for reusability
   - Implement proper state management

2. **Monitoring & Alerting**
   - Set up comprehensive dashboards
   - Use Action Groups for notifications
   - Implement proper log analytics

3. **Security**
   - Regular security assessments
   - Use Microsoft Defender for Cloud
   - Implement Just-In-Time VM access

4. **Cost Management**
   - Regular cost analysis
   - Implement auto-scaling
   - Use cost allocation tags

5. **Automation**
   - Use Azure Automation for routine tasks
   - Implement proper RBAC
   - Set up CI/CD pipelines