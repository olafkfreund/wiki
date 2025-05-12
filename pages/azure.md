# Azure (Microsoft Azure) – 2025 Update

## Overview
Azure is Microsoft’s cloud platform, offering a wide range of services for compute, networking, storage, databases, AI, analytics, security, and more. It is known for strong enterprise integration, hybrid cloud capabilities, and a global presence.

## Core Services (2025)
| Service Category | Key Azure Services & Features |
|------------------|------------------------------|
| **Compute**      | Azure Kubernetes Service (AKS), Virtual Machines, Virtual Machine Scale Sets, Azure Virtual Desktop |
| **Networking**   | DDoS Protection, ExpressRoute, Private Link, Load Balancer, Virtual Network, VNet Peering |
| **Storage**      | Managed Disks, Premium Blobs/Files, Data Lake Storage Gen2, Blob SFTP/NFS support |
| **BCDR**         | Azure Site Recovery, Azure Backup |

## Security & Best Practices
- Use Microsoft Defender for Cloud for threat protection and security management.
- Implement Azure RBAC for least-privilege access.
- Store secrets in Azure Key Vault.
- Enable encryption for data at rest and in transit.
- Regularly rotate keys and credentials.
- Use Azure Policy for compliance and governance.
- Disable public network access for sensitive resources when possible.

## Landing Zones & Architecture
- Azure Landing Zones provide modular, scalable environments for workloads, with best practices for security, management, and governance.
- Use Infrastructure as Code (Bicep, ARM, Terraform) for repeatable deployments.
- Refactor landing zones as requirements evolve.

## DevOps & Automation
- Automate deployments with Azure DevOps, GitHub Actions, or other CI/CD tools.
- Monitor with Azure Monitor, Log Analytics, and Application Insights.

## References & Next Steps
- [Azure services with availability zones](https://learn.microsoft.com/en-us/azure/availability-zones-service-support)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)

