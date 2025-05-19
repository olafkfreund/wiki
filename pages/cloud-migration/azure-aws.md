# Migrating from Azure to AWS: A Practical Guide for Cloud Architects and DevOps Engineers

Migrating from Azure to AWS requires careful planning, understanding service equivalencies, and adapting your infrastructure and processes. This guide provides step-by-step instructions, real-life examples, and best practices for a successful migration.

---

## Quick Comparison: Azure vs AWS Services

| Azure Service                | AWS Equivalent           | Notes                                    |
|-----------------------------|-------------------------|------------------------------------------|
| Virtual Machines (VMs)       | EC2                    | VM types and images differ               |
| Blob Storage                 | S3                     | APIs and access models vary              |
| Azure Active Directory       | IAM                    | RBAC and identity federation differ      |
| Azure SQL Database           | RDS                    | Migration tools available                |
| Azure Functions              | Lambda                 | Triggers and bindings differ             |
| ARM Templates/Bicep          | CloudFormation         | Syntax and capabilities differ           |
| Azure Monitor                | CloudWatch             | Metrics and logging integration varies   |
| Virtual Network (VNet)       | VPC                    | Subnet and peering models differ         |
| AKS (Azure Kubernetes)       | EKS                    | Cluster management differs               |
| Azure DNS                    | Route 53               | Record types and automation differ       |

> **Tip:** [AWS Service Comparison Table](https://aws.amazon.com/azure/)

---

## Pre-Migration Checklist

1. **Inventory Your Azure Resources**
   - Use Azure CLI or Azure Resource Graph to export resources:

     ```sh
     az resource list --output json > azure-inventory.json
     ```

2. **Map Services to AWS Equivalents**
   - Document each Azure service and its AWS counterpart.
3. **Assess Application Dependencies**
   - Identify hardcoded endpoints, region-specific services, and OS dependencies.
4. **Plan Identity and Access Migration**
   - Prepare to migrate Azure AD users/groups to AWS IAM or federate with AWS SSO.
5. **Network Planning**
   - Design AWS VPCs to match (or improve) your Azure VNet topology.

---

## Migration Checklist

- [ ] **Inventory Azure Resources**  
  Use Azure CLI:  
  `az resource list --output json > azure-inventory.json`
- [ ] **Map Azure Services to AWS Equivalents**  
  Create a mapping table for all services in use.
- [ ] **Assess Application Dependencies**  
  Identify hardcoded endpoints, region-specific services, and OS dependencies.
- [ ] **Plan Identity and Access Migration**  
  Prepare to migrate Azure AD users/groups to AWS IAM or federate with AWS SSO.
- [ ] **Network Planning**  
  Design AWS VPCs to match or improve your Azure VNet topology.
- [ ] **Translate Infrastructure as Code**  
  Convert ARM/Bicep templates to CloudFormation or Terraform.
- [ ] **Migrate Data**  
  Use AWS CLI S3 sync or AWS DataSync for storage migration.
- [ ] **Migrate Identity**  
  Set up AWS SSO or IAM, and test user access.
- [ ] **Refactor Applications**  
  Update code/configs to use AWS SDKs and endpoints.
- [ ] **Test and Validate**  
  Use CloudWatch and X-Ray for validation.
- [ ] **Update DNS**  
  Point domains to AWS endpoints (Route 53).
- [ ] **Monitor and Optimize**  
  Use AWS Cost Explorer and Trusted Advisor.
- [ ] **Decommission Azure Resources**  
  Confirm all data is migrated and backups are complete before deleting.
- [ ] **Update Documentation**  
  Revise runbooks and architecture diagrams.

---

## Migration Steps (with Examples)

### 1. Infrastructure as Code (IaC) Translation

- **Example:** Convert ARM/Bicep templates to AWS CloudFormation or Terraform.
  - Use [Azure Resource Manager Template Converter](https://github.com/awslabs/aws-cloudformation-templates/tree/master/aws/solutions/ARM2CFN) or manually map resources.
  - Example Terraform snippet for AWS EC2:

    ```hcl
    resource "aws_instance" "example" {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
      # ...
    }
    ```

### 2. Data Migration

- **Example:** Migrate Azure Blob Storage to S3 using [AWS CLI S3 sync](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html):

  ```sh
  aws s3 sync "https://<account>.blob.core.windows.net/<container>" s3://mybucket --recursive
  ```

### 3. Identity Migration

- **Example:** Sync Azure AD users to AWS IAM using [AWS SSO](https://docs.aws.amazon.com/singlesignon/latest/userguide/azure-ad-idp.html) or SAML federation.

### 4. Application Refactoring

- Update code/configs to use AWS SDKs and endpoints.
- Replace Azure Function triggers with Lambda event sources.

### 5. Testing and Validation

- Use CloudWatch and X-Ray for post-migration validation.

---

## Post-Migration Tasks

- **Update DNS:** Point domains to AWS endpoints (e.g., Route 53).
- **Monitor and Optimize:** Use AWS Cost Explorer and Trusted Advisor.
- **Decommission Azure Resources:** Ensure all data is migrated and backups are complete before deleting.
- **Documentation:** Update runbooks and architecture diagrams.

---

## Best Practices & Common Pitfalls

- **Start with Non-Production Workloads:** Validate migration steps before moving critical systems.
- **Automate Everything:** Use Terraform/Ansible for repeatable deployments.
- **Watch for Service Limits:** AWS and Azure have different quotas.
- **Security Review:** Reassess security groups, NACLs, and IAM/RBAC policies.

---

## Cloud Hopping Humor

> Why did the cloud architect take a compass on their Azure to AWS migration?
>
> To make sure they didn’t get lost in the clouds!

---

## References

- [AWS Service Comparison Table](https://aws.amazon.com/azure/)
- [AWS Migration Hub](https://aws.amazon.com/migration-hub/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI S3 Sync](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html)
