---
description: Fully managed NFS file servers for Google Cloud applications 
---

# Google Cloud Filestore

Google Cloud Filestore is a fully managed file storage service for applications running on Compute Engine VMs or Google Kubernetes Engine (GKE) clusters.

## Overview

Filestore provides network attached storage (NAS) with a traditional file system interface and shared file access using the NFSv3 protocol. It allows you to create fully managed NFS file servers on GCP to provide high-performance file storage for your applications.

## Key Features

- **Fully managed service**: Google handles all the infrastructure management, patching, and maintenance
- **High performance**: Low latency and high throughput for file operations
- **Scalability**: Choose service tiers based on performance and capacity needs
- **Snapshots**: Create point-in-time copies of your file shares for data protection
- **Integration**: Works seamlessly with Google Compute Engine and Google Kubernetes Engine

## Service Tiers

Filestore offers several service tiers to meet different performance, capacity, and availability needs:

| Tier | Capacity Range | Performance | Use Cases |
|------|----------------|-------------|-----------|
| Basic | 1-63.9 TB | Good | General purpose workloads |
| Zonal | 1-100 TB | High | High-performance computing |
| Regional | 1-100 TB | High with regional redundancy | Production workloads requiring higher availability |
| Enterprise | 1-10 PB | Highest | Large-scale enterprise workloads |

## Deployment with Terraform

Here's an example of provisioning a Filestore instance using Terraform:

```hcl
resource "google_filestore_instance" "instance" {
  name = "filestore-instance"
  tier = "BASIC_HDD"
  location = "us-central1-a"
  
  file_shares {
    name = "share1"
    capacity_gb = 1024  # 1 TB
  }
  
  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }
}
```

## Mounting a Filestore Share

### On Compute Engine

```bash
# Install NFS client
sudo apt-get update
sudo apt-get install nfs-common

# Create mount directory
sudo mkdir -p /mnt/filestore

# Mount the Filestore instance
sudo mount -o rw,intr <filestore-ip-address>:/share1 /mnt/filestore
```

### In Google Kubernetes Engine (GKE)

You can use the Filestore CSI driver to automatically provision and mount Filestore instances as PersistentVolumes.

Example PersistentVolumeClaim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: filestore-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Ti
  storageClassName: filestore-csi
```

## Best Practices

1. **Right-sizing**: Choose the appropriate tier and capacity for your workload requirements
2. **Network configuration**: Ensure proper network connectivity between your Filestore instance and clients
3. **Backup strategy**: Set up regular snapshots for data protection
4. **Performance tuning**: Configure appropriate NFS mount options based on your workload patterns
5. **Monitoring**: Use Cloud Monitoring to track performance metrics and set up alerts

## Common Use Cases

- **Content management systems**: Store and serve website assets
- **Development environments**: Shared code repositories and build environments
- **Data analytics**: Process large datasets using familiar file system interfaces
- **Media processing**: Store and process video and image files
- **Database backups**: Store database dumps and backups

## Pricing Considerations

- Filestore is billed based on provisioned capacity, not actual usage
- Different tiers have different pricing models
- Snapshots are billed based on the incremental storage they consume
- No ingress/egress charges within the same zone

## Limitations

- Currently only supports NFSv3 protocol
- Cannot resize an instance once created (need to create a new instance)
- Availability differs by tier (Basic and Zonal: single zone; Regional: multi-zone)

## Integration with DevOps Workflows

Filestore can be integrated into your DevOps workflow using:

1. **Infrastructure as Code**: Terraform, Deployment Manager
2. **Configuration Management**: Ansible playbooks to configure mounts
3. **CI/CD**: GitHub Actions or Cloud Build to deploy configurations

## Alternatives in GCP

- **Cloud Storage**: Object storage (not a file system)
- **Persistent Disk**: Block storage attached to specific VMs
- **Cloud SQL**: Managed relational database service
- **Cloud NetApp Volumes**: NetApp's high-performance file storage on GCP (third-party)