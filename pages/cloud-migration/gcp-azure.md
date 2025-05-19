# Migrating from GCP to Azure: A Practical Guide for Cloud Architects and DevOps Engineers

Migrating from Google Cloud Platform (GCP) to Microsoft Azure requires careful planning, mapping of services, and process adaptation. This guide provides actionable steps, real-life examples, and best practices for a successful migration.

---

## Quick Comparison: GCP vs Azure Services

| GCP Service                | Azure Equivalent           | Notes                                    |
|----------------------------|---------------------------|------------------------------------------|
| Compute Engine             | Virtual Machines (VMs)    | VM types and images differ               |
| Cloud Storage              | Blob Storage              | APIs and access models vary              |
| Cloud IAM                  | Azure Active Directory    | RBAC and identity federation differ      |
| Cloud SQL                  | Azure SQL Database        | Migration tools available                |
| Cloud Functions            | Azure Functions           | Triggers and bindings differ             |
| Deployment Manager         | ARM Templates/Bicep       | Syntax and capabilities differ           |
| Stackdriver Monitoring     | Azure Monitor             | Metrics and logging integration varies   |
| VPC                        | Virtual Network (VNet)    | Subnet and peering models differ         |
| GKE (Kubernetes Engine)    | AKS (Azure Kubernetes)    | Cluster management differs               |
| Cloud DNS                  | Azure DNS                 | Record types and automation differ       |

> **Tip:** [Microsoft's GCP to Azure service mapping](https://learn.microsoft.com/en-us/azure/architecture/gcp-professional/services)

---

## Migration Checklist

- [ ] **Inventory GCP Resources**  
  Use gcloud CLI:  
  `gcloud asset search-all-resources --format=json > gcp-inventory.json`
- [ ] **Map GCP Services to Azure Equivalents**  
  Create a mapping table for all services in use.
- [ ] **Assess Application Dependencies**  
  Identify hardcoded endpoints, region-specific services, and OS dependencies.
- [ ] **Plan Identity and Access Migration**  
  Prepare to migrate Cloud IAM users/groups to Azure AD.
- [ ] **Network Planning**  
  Design Azure VNets to match or improve your GCP VPC topology.
- [ ] **Translate Infrastructure as Code**  
  Convert Deployment Manager templates to ARM/Bicep or Terraform.
- [ ] **Migrate Data**  
  Use AzCopy or Storage Transfer Service for storage migration.
- [ ] **Migrate Identity**  
  Set up Azure AD, and test user access.
- [ ] **Refactor Applications**  
  Update code/configs to use Azure SDKs and endpoints.
- [ ] **Test and Validate**  
  Use Azure Monitor and Application Insights for validation.
- [ ] **Update DNS**  
  Point domains to Azure endpoints (Azure DNS).
- [ ] **Monitor and Optimize**  
  Use Azure Cost Management and Azure Advisor.
- [ ] **Decommission GCP Resources**  
  Confirm all data is migrated and backups are complete before deleting.
- [ ] **Update Documentation**  
  Revise runbooks and architecture diagrams.

---

## Migration Steps (with Examples)

### 1. Infrastructure as Code (IaC) Translation

- **Example:** Convert Deployment Manager templates to Azure Bicep or ARM templates.
  - Use [dm-convert](https://github.com/GoogleCloudPlatform/deploymentmanager-samples/tree/master/tools/dm-convert) to export, then adapt to Azure.
  - Example Terraform snippet for Azure VM:

    ```hcl
    resource "azurerm_virtual_machine" "example" {
      name                  = "example-vm"
      resource_group_name   = azurerm_resource_group.example.name
      location              = azurerm_resource_group.example.location
      # ...
    }
    ```

### 2. Data Migration

- **Example:** Migrate Cloud Storage buckets to Azure Blob Storage using [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10):

  ```sh
  azcopy copy "https://storage.googleapis.com/<bucket>" "https://<account>.blob.core.windows.net/<container>" --recursive
  ```

### 3. Identity Migration

- **Example:** Sync GCP IAM users to Azure AD using [Azure AD Connect](https://learn.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-install-custom).

### 4. Application Refactoring

- Update code/configs to use Azure SDKs and endpoints.
- Replace GCP Cloud Functions triggers with Azure Function bindings.

### 5. Testing and Validation

- Use Azure Monitor and Application Insights for post-migration validation.

---

## Post-Migration Tasks

- **Update DNS:** Point domains to Azure endpoints (e.g., Azure DNS).
- **Monitor and Optimize:** Use Azure Cost Management and Azure Advisor.
- **Decommission GCP Resources:** Ensure all data is migrated and backups are complete before deleting.
- **Documentation:** Update runbooks and architecture diagrams.

---

## Best Practices & Common Pitfalls

- **Start with Non-Production Workloads:** Validate migration steps before moving critical systems.
- **Automate Everything:** Use Terraform/Ansible for repeatable deployments.
- **Watch for Service Limits:** Azure and GCP have different quotas.
- **Security Review:** Reassess security groups, NSGs, and IAM/RBAC policies.

---

## Cloud Hopping Humor

> Why did the engineer bring a suitcase to the GCP to Azure migration?
>
> Because they were ready for a change in the cloud forecast!

---

## References

- [GCP to Azure Service Comparison](https://learn.microsoft.com/en-us/azure/architecture/gcp-professional/services)
- [Azure Migration Center](https://azure.microsoft.com/en-us/migration/)
- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AzCopy Documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)
