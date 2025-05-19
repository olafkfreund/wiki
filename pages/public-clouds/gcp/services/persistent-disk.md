---
description: Block storage solutions for virtual machines in Google Cloud Platform
---

# Persistent Disk

Google Cloud Persistent Disk provides reliable, high-performance block storage for virtual machine instances running on Google Cloud Platform. It offers a range of storage options optimized for different workloads, from standard hard disk drives (HDD) to solid-state drives (SSD) and even extreme performance options.

## Key Features

- **Durability**: Built-in redundancy ensures data reliability
- **Automatic Encryption**: All data is automatically encrypted at rest
- **Flexible Sizing**: Easily scale from 10GB to 64TB per disk
- **Snapshot Support**: Create point-in-time backups of your disks
- **Multiple Performance Tiers**: Standard (HDD), Balanced (SSD), Performance (SSD), and Extreme (SSD)
- **Multi-writer Mode**: Allows multiple VMs to read/write to a single disk simultaneously
- **Regional Persistence**: Option for synchronous replication across zones

## Disk Types

| Type | Use Case | Performance | Price Point |
|------|----------|------------|-------------|
| **Standard (pd-standard)** | Batch processing, non-critical workloads | 0.3-0.8 IOPS/GB | Lowest |
| **Balanced (pd-balanced)** | General purpose workloads | Up to 6,000 read IOPS, 9,000 write IOPS | Medium |
| **SSD (pd-ssd)** | I/O-intensive applications, databases | Up to 15,000 read IOPS, 15,000 write IOPS | High |
| **Extreme (pd-extreme)** | High-performance databases, analytics | Up to 120,000 read IOPS, 120,000 write IOPS | Highest |
| **Hyperdisk Balanced** | Consistent performance mid-tier workloads | Provisioned performance | Medium-high |
| **Hyperdisk Extreme** | Ultra-high performance workloads | Provisioned performance up to 350,000 IOPS | Premium |

## Creating and Managing Persistent Disks

### Using gcloud CLI

#### Create a new Persistent Disk

```bash
# Create a standard persistent disk
gcloud compute disks create my-disk \
    --project=my-project \
    --type=pd-standard \
    --size=500GB \
    --zone=us-central1-a

# Create an SSD persistent disk
gcloud compute disks create high-perf-disk \
    --project=my-project \
    --type=pd-ssd \
    --size=1TB \
    --zone=us-central1-a

# Create a regional persistent disk (replicated across zones)
gcloud compute disks create ha-disk \
    --project=my-project \
    --type=pd-balanced \
    --size=2TB \
    --region=us-central1 \
    --replica-zones=us-central1-a,us-central1-b
```

#### Attach a disk to a VM

```bash
# Attach an existing disk to a VM
gcloud compute instances attach-disk my-instance \
    --project=my-project \
    --disk=my-disk \
    --zone=us-central1-a

# Attach disk and mark as read-only
gcloud compute instances attach-disk my-instance \
    --project=my-project \
    --disk=my-disk \
    --mode=ro \
    --zone=us-central1-a
```

#### Format and mount a disk on Linux VM

```bash
# Connect to your instance
gcloud compute ssh my-instance --zone=us-central1-a

# Check available disks
sudo lsblk

# Format the disk (if new)
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb

# Create a mount point
sudo mkdir -p /mnt/disks/my-disk

# Mount the disk
sudo mount -o discard,defaults /dev/sdb /mnt/disks/my-disk

# Set proper permissions
sudo chmod a+w /mnt/disks/my-disk

# Configure automatic mounting on reboot
echo UUID=$(sudo blkid -s UUID -o value /dev/sdb) /mnt/disks/my-disk ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
```

#### Create a snapshot

```bash
# Create a snapshot of a disk
gcloud compute snapshots create my-snapshot \
    --project=my-project \
    --source-disk=my-disk \
    --source-disk-zone=us-central1-a \
    --description="Backup of my-disk on $(date)"
```

#### Create a disk from a snapshot

```bash
# Create a new disk from a snapshot
gcloud compute disks create restored-disk \
    --project=my-project \
    --size=500GB \
    --source-snapshot=my-snapshot \
    --type=pd-balanced \
    --zone=us-central1-a
```

#### Resize a disk

```bash
# Resize a disk to a larger size (resizing to smaller is not supported)
gcloud compute disks resize my-disk \
    --project=my-project \
    --size=2TB \
    --zone=us-central1-a
```

### Using Terraform

#### Create a boot disk and data disk for a VM

```hcl
resource "google_compute_disk" "data_disk" {
  name  = "data-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size  = 200
  
  # Optional: provisioned throughput for Hyperdisk
  # provisioned_iops = 5000
  
  # Optional: create from snapshot or image
  # snapshot = "snapshot-name"
  # image = "image-name"
  
  # Enable CMEK encryption (optional)
  # disk_encryption_key {
  #   kms_key_self_link = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
  # }

  labels = {
    environment = "dev"
    team        = "devops"
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-instance"
  machine_type = "e2-standard-4"
  zone         = "us-central1-a"

  # Boot disk
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 100
      type  = "pd-balanced"
    }
  }

  # Attach the data disk
  attached_disk {
    source      = google_compute_disk.data_disk.id
    device_name = "data-disk"
    mode        = "READ_WRITE"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Format and mount the data disk
    sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-data-disk
    sudo mkdir -p /mnt/disks/data
    sudo mount -o discard,defaults /dev/disk/by-id/google-data-disk /mnt/disks/data
    sudo chmod 777 /mnt/disks/data
    echo UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/google-data-disk) /mnt/disks/data ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
  EOT
}
```

#### Create a regional persistent disk with Terraform

```hcl
resource "google_compute_region_disk" "ha_disk" {
  name          = "ha-disk"
  type          = "pd-balanced"
  region        = "us-central1"
  size          = 500
  replica_zones = ["us-central1-a", "us-central1-b"]

  labels = {
    environment = "production"
  }
}
```

#### Managing disk snapshots with Terraform

```hcl
resource "google_compute_disk" "default" {
  name  = "prod-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size  = 500
}

resource "google_compute_snapshot" "snapshot" {
  name        = "prod-disk-snapshot"
  source_disk = google_compute_disk.default.name
  zone        = "us-central1-a"
  
  snapshot_encryption_key {
    raw_key = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
  }

  # Use snapshot schedule policy (optional)
  # source_snapshot_schedule_policy = google_compute_resource_policy.snapshot_schedule.id
}

# Optional: Create a schedule policy for automated snapshots
resource "google_compute_resource_policy" "snapshot_schedule" {
  name   = "daily-snapshot-policy"
  region = "us-central1"
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
    
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    
    snapshot_properties {
      labels = {
        automated = "true"
      }
      
      storage_locations = ["us"]
    }
  }
}

# Apply the snapshot schedule to the disk
resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name = google_compute_resource_policy.snapshot_schedule.name
  disk = google_compute_disk.default.name
  zone = "us-central1-a"
}
```

## Performance Optimization

### Best Practices for Disk Performance

1. **Choose the right disk type** for your workload:
   - Standard PD: Batch jobs, cost-effective storage
   - Balanced PD: General purpose workloads
   - SSD PD: Database systems, I/O intensive applications
   - Extreme PD or Hyperdisk: High-performance databases, analytics

2. **Stripe multiple disks** for higher performance:
   ```bash
   # Example: Create a striped volume with mdadm on Linux
   sudo apt-get update
   sudo apt-get install mdadm
   
   # Create striped array from two disks
   sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
   
   # Format the striped volume
   sudo mkfs.ext4 -F /dev/md0
   
   # Mount the striped volume
   sudo mkdir -p /mnt/striped-disk
   sudo mount /dev/md0 /mnt/striped-disk
   ```

3. **Enable write caching** on your file system:
   ```bash
   # Mount with write caching enabled (removes 'discard' option)
   sudo mount -o defaults /dev/sdb /mnt/disks/my-disk
   ```

4. **Use appropriate file systems**:
   - ext4: Good general-purpose file system with solid performance
   - XFS: Better for large files and high-performance workloads

5. **Tune I/O scheduler** for your workload:
   ```bash
   # Check current scheduler
   cat /sys/block/sdb/queue/scheduler
   
   # Change scheduler (example: to 'none' for SSD)
   echo none | sudo tee /sys/block/sdb/queue/scheduler
   ```

## Backup Strategies

### Snapshot-Based Backup

```bash
# Create a snapshot schedule
gcloud compute resource-policies create snapshot-schedule daily-backup \
    --project=my-project \
    --region=us-central1 \
    --max-retention-days=14 \
    --start-time=04:00 \
    --daily-schedule

# Apply the schedule to a disk
gcloud compute disks add-resource-policies my-disk \
    --project=my-project \
    --zone=us-central1-a \
    --resource-policies=daily-backup
```

### Database Backup Best Practices

For databases, consider:

1. **Consistent snapshots**:
   - Freeze the filesystem or use database-specific tools to quiesce writes
   - For MySQL:
     ```sql
     FLUSH TABLES WITH READ LOCK;
     -- Take snapshot
     UNLOCK TABLES;
     ```
   
2. **Scheduled backups with custom scripts**:
   ```bash
   #!/bin/bash
   # Example for PostgreSQL
   pg_dump my_database | gzip > /backup/my_database_$(date +%Y%m%d).sql.gz
   gsutil cp /backup/my_database_$(date +%Y%m%d).sql.gz gs://my-backup-bucket/
   ```

## Disaster Recovery with Persistent Disk

### Zone-to-Zone Recovery (using regional disks)

```hcl
# Terraform example for regional disk with failover capability
resource "google_compute_region_disk" "regional_disk" {
  name                      = "regional-disk"
  type                      = "pd-balanced"
  region                    = "us-central1"
  size                      = 500
  replica_zones             = ["us-central1-a", "us-central1-b"]
  physical_block_size_bytes = 4096
}

# Instance in primary zone
resource "google_compute_instance" "primary_instance" {
  name         = "primary-instance"
  machine_type = "e2-standard-4"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }
}

# Disk attachment
resource "google_compute_disk_attachment" "primary_attachment" {
  disk     = google_compute_region_disk.regional_disk.id
  instance = google_compute_instance.primary_instance.id
  zone     = "us-central1-a"
  
  # Use this to ensure proper detachment during failover
  force_detach = true
}
```

### Cross-Region Recovery (using snapshots)

```bash
# Create a snapshot schedule that stores snapshots in multiple regions
gcloud compute resource-policies create snapshot-schedule multi-region-daily \
    --project=my-project \
    --region=us-central1 \
    --max-retention-days=30 \
    --start-time=03:00 \
    --daily-schedule \
    --storage-location=us

# Apply to disk
gcloud compute disks add-resource-policies my-disk \
    --project=my-project \
    --zone=us-central1-a \
    --resource-policies=multi-region-daily

# In case of disaster, restore in a different region
gcloud compute disks create recovery-disk \
    --project=my-project \
    --source-snapshot=my-latest-snapshot \
    --zone=us-west1-b
```

## Multi-Writer Shared Disks

Persistent Disk supports multi-writer mode, allowing multiple VMs to concurrently access the same disk. This is useful for clustered applications like GFS, OCFS2, or other distributed file systems.

```bash
# Create a multi-writer disk
gcloud compute disks create shared-disk \
    --project=my-project \
    --type=pd-ssd \
    --size=1TB \
    --multi-writer \
    --zone=us-central1-a

# Attach to first instance
gcloud compute instances attach-disk instance-1 \
    --disk=shared-disk \
    --zone=us-central1-a

# Attach to second instance
gcloud compute instances attach-disk instance-2 \
    --disk=shared-disk \
    --zone=us-central1-a
```

### Using multi-writer disks with a cluster file system

```bash
# On both VMs: Install OCFS2 (example of a cluster file system)
sudo apt-get update
sudo apt-get install -y ocfs2-tools

# Configure OCFS2 cluster
# [Create configuration files, initialize the cluster]

# Format the shared disk with OCFS2
sudo mkfs.ocfs2 -L "shared" /dev/sdb

# Mount on both VMs
sudo mkdir -p /mnt/shared
sudo mount -t ocfs2 /dev/sdb /mnt/shared
```

## Security and Compliance

### Customer-Supplied Encryption Keys (CSEK)

```bash
# Generate a key
KEY=$(openssl rand -base64 32)

# Create a disk with a customer-supplied encryption key
gcloud compute disks create encrypted-disk \
    --project=my-project \
    --zone=us-central1-a \
    --size=100GB \
    --csek-key-file <(echo "{\"key\":\"$KEY\",\"key-type\":\"raw\"}")

# Attach the disk (requires the same key)
gcloud compute instances attach-disk my-instance \
    --project=my-project \
    --disk=encrypted-disk \
    --zone=us-central1-a \
    --csek-key-file <(echo "{\"key\":\"$KEY\",\"key-type\":\"raw\"}")
```

### Customer-Managed Encryption Keys (CMEK)

```bash
# First, create a key ring and key in Cloud KMS
gcloud kms keyrings create my-keyring \
    --project=my-project \
    --location=us-central1

gcloud kms keys create my-key \
    --project=my-project \
    --location=us-central1 \
    --keyring=my-keyring \
    --purpose=encryption

# Create a disk with a customer-managed encryption key
gcloud compute disks create cmek-disk \
    --project=my-project \
    --zone=us-central1-a \
    --size=100GB \
    --kms-key=projects/my-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key
```

## Cost Optimization

### Rightsizing Persistent Disks

1. **Monitor utilization** with Cloud Monitoring:
   ```bash
   # Install the monitoring agent on your VM
   curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
   sudo bash add-monitoring-agent-repo.sh
   sudo apt-get update
   sudo apt-get install -y stackdriver-agent
   sudo service stackdriver-agent start
   ```

2. **Use custom metrics** to track disk usage patterns:
   ```bash
   # Example: Report disk usage to Cloud Monitoring
   DISK_USAGE=$(df -h | grep /dev/sdb | awk '{print $5}' | sed 's/%//')
   gcloud logging write disk-metrics "Disk usage: ${DISK_USAGE}%" --payload-type=json
   ```

3. **Create a disk sizing policy**:
   - Start with smaller disks and increase as needed
   - Consider performance requirements (larger disks offer higher performance)
   - Use disk snapshots to preserve data when resizing

### Disk Type Selection

For cost-effective disk usage:

1. **Use pd-standard** for infrequently accessed data
2. **Use pd-balanced** for good performance at a reasonable cost
3. **Use pd-ssd** only for high-performance workloads
4. **Use snapshot lifecycle policies** to automatically delete old snapshots

## Monitoring and Troubleshooting

### Set Up Monitoring

```terraform
resource "google_monitoring_alert_policy" "disk_usage_alert" {
  display_name = "Disk Usage Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Disk Usage > 90%"
    
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/disk/percent_used\" resource.type=\"gce_instance\" metric.label.device_name=\"sdb\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 90
      
      trigger {
        count = 1
      }
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }
  
  notification_channels = [
    google_monitoring_notification_channel.email.name
  ]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "DevOps Team Email"
  type         = "email"
  
  labels = {
    email_address = "devops@example.com"
  }
}
```

### Common Troubleshooting Scenarios

#### Disk Performance Issues

```bash
# Check current I/O stats
sudo iostat -xz 1

# Check if disk is properly attached
lsblk

# Test write performance
dd if=/dev/zero of=/mnt/disks/my-disk/test bs=1M count=1000 oflag=direct

# Test read performance
dd if=/mnt/disks/my-disk/test of=/dev/null bs=1M count=1000

# Identify processes using the disk
sudo iotop
```

#### Disk Full Issues

```bash
# Check disk usage
df -h

# Find large files
sudo find /mnt/disks/my-disk -type f -size +100M -exec ls -lh {} \;

# Find directories with most usage
sudo du -h --max-depth=2 /mnt/disks/my-disk | sort -hr | head -10
```

#### Disk Attachment Problems

```bash
# Check if disk is visible to system
sudo lsblk

# Look for attachment errors
journalctl -xeu google-disk-attach

# Try to manually mount
sudo mount -o discard,defaults /dev/sdb /mnt/disks/my-disk

# Check dmesg for disk errors
dmesg | grep -i sdb
```

## Further Reading

- [Google Cloud Persistent Disk Documentation](https://cloud.google.com/compute/docs/disks)
- [Optimizing Persistent Disk Performance](https://cloud.google.com/compute/docs/disks/optimizing-pd-performance)
- [Using Snapshots](https://cloud.google.com/compute/docs/disks/create-snapshots)
- [Working with Regional Persistent Disks](https://cloud.google.com/compute/docs/disks/regional-persistent-disk)