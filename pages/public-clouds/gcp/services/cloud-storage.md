---
description: Deploying and managing Google Cloud Storage for object storage
---

# Cloud Storage

Google Cloud Storage is a globally unified, scalable, and highly durable object storage service for storing and accessing any amount of data. It provides industry-leading availability, performance, security, and management features.

## Key Features

- **Global Accessibility**: Access data from anywhere in the world
- **Scalability**: Store and retrieve any amount of data at any time
- **Durability**: 11 9's (99.999999999%) durability for stored objects
- **Storage Classes**: Standard, Nearline, Coldline, and Archive storage tiers
- **Object Versioning**: Maintain history and recover from accidental deletions
- **Object Lifecycle Management**: Automatically transition and delete objects
- **Strong Consistency**: Read-after-write and list consistency
- **Customer-Managed Encryption Keys (CMEK)**: Control encryption keys
- **Object Hold and Retention Policies**: Enforce compliance requirements
- **VPC Service Controls**: Add security perimeter around sensitive data

## Cloud Storage Classes

| Storage Class | Purpose | Minimum Storage Duration | Typical Use Cases |
|---------------|---------|------------------------|-------------------|
| Standard | High-performance, frequent access | None | Website content, active data, mobile apps |
| Nearline | Low-frequency access | 30 days | Data accessed less than once a month |
| Coldline | Very low-frequency access | 90 days | Data accessed less than once a quarter |
| Archive | Data archiving, online backup | 365 days | Long-term archive, disaster recovery |

## Deploying Cloud Storage with Terraform

### Basic Bucket Creation

```hcl
resource "google_storage_bucket" "static_assets" {
  name          = "my-static-assets-bucket"
  location      = "US"
  storage_class = "STANDARD"
  
  labels = {
    environment = "production"
    department  = "engineering"
  }
  
  # Enable versioning for recovery
  versioning {
    enabled = true
  }
  
  # Use uniform bucket-level access (recommended)
  uniform_bucket_level_access = true
  
  # Public access prevention (recommended security setting)
  public_access_prevention = "enforced"
}

# Grant access to a service account
resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_storage_bucket.static_assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:my-service-account@my-project.iam.gserviceaccount.com"
}
```

### Advanced Configuration with Lifecycle Policies

```hcl
resource "google_storage_bucket" "data_lake" {
  name          = "my-datalake-bucket"
  location      = "US-CENTRAL1"
  storage_class = "STANDARD"
  
  # Enable versioning
  versioning {
    enabled = true
  }
  
  # Enable object lifecycle management
  lifecycle_rule {
    condition {
      age = 30  # days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90  # days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 365  # days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }
  
  # Delete old non-current versions
  lifecycle_rule {
    condition {
      age = 30  # days
      with_state = "ARCHIVED"  # non-current versions
    }
    action {
      type = "Delete"
    }
  }
  
  # Use Customer-Managed Encryption Key (CMEK)
  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_key.id
  }
  
  # Other security settings
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"
}

# Create KMS key for CMEK
resource "google_kms_key_ring" "storage_keyring" {
  name     = "storage-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "bucket_key" {
  name     = "bucket-key"
  key_ring = google_kms_key_ring.storage_keyring.id
}

# Grant Cloud Storage service account access to use KMS key
data "google_storage_project_service_account" "gcs_account" {}

resource "google_kms_crypto_key_iam_binding" "crypto_key_binding" {
  crypto_key_id = google_kms_crypto_key.bucket_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}
```

### Static Website Hosting Configuration

```hcl
resource "google_storage_bucket" "website" {
  name          = "my-static-website-bucket"
  location      = "US"
  storage_class = "STANDARD"
  
  # Enable website serving
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  
  # Set CORS configuration
  cors {
    origin          = ["https://example.com"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["Content-Type", "Access-Control-Allow-Origin"]
    max_age_seconds = 3600
  }
  
  # Force bucket to serve content via HTTPS
  force_destroy = true
}

# Make objects publicly readable
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Upload index page
resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  bucket = google_storage_bucket.website.name
  source = "./website/index.html"
  
  # Set content type
  content_type = "text/html"
}

# Upload 404 page
resource "google_storage_bucket_object" "not_found" {
  name   = "404.html"
  bucket = google_storage_bucket.website.name
  source = "./website/404.html"
  
  content_type = "text/html"
}
```

## Managing Cloud Storage with gsutil

### Basic Bucket Commands

```bash
# Create a bucket
gsutil mb -l us-central1 gs://my-bucket

# List buckets
gsutil ls

# List objects in a bucket
gsutil ls gs://my-bucket/

# Get bucket information
gsutil ls -L gs://my-bucket

# Enable bucket versioning
gsutil versioning set on gs://my-bucket

# Set default storage class
gsutil defstorageclass set NEARLINE gs://my-bucket
```

### Object Operations

```bash
# Upload file(s)
gsutil cp file.txt gs://my-bucket/

# Upload directory
gsutil cp -r ./local-dir gs://my-bucket/dir/

# Upload with specific content type
gsutil -h "Content-Type:text/html" cp index.html gs://my-bucket/

# Download file(s)
gsutil cp gs://my-bucket/file.txt ./

# Download directory
gsutil cp -r gs://my-bucket/dir/ ./local-dir/

# Move/Rename objects
gsutil mv gs://my-bucket/old-name.txt gs://my-bucket/new-name.txt

# Delete object
gsutil rm gs://my-bucket/file.txt

# Delete all objects in a bucket
gsutil rm gs://my-bucket/**

# Delete bucket and all its contents
gsutil rm -r gs://my-bucket
```

### Access Control

```bash
# Make object public
gsutil acl ch -u AllUsers:R gs://my-bucket/file.txt

# Set bucket-level IAM policy
gsutil iam ch serviceAccount:my-service@my-project.iam.gserviceaccount.com:objectViewer gs://my-bucket

# Get IAM policy
gsutil iam get gs://my-bucket

# Set uniform bucket-level access (recommended)
gsutil uniformbucketlevelaccess set on gs://my-bucket

# Disable public access
gsutil pap set enforced gs://my-bucket
```

### Lifecycle Management

```bash
# Create a lifecycle policy JSON file
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "NEARLINE"
        },
        "condition": {
          "age": 30,
          "matchesStorageClass": ["STANDARD"]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "age": 365
        }
      }
    ]
  }
}
EOF

# Apply lifecycle policy to bucket
gsutil lifecycle set lifecycle.json gs://my-bucket

# View current lifecycle policy
gsutil lifecycle get gs://my-bucket
```

## Real-World Example: Multi-Region Data Lake Architecture

This example demonstrates a complete data lake architecture using Cloud Storage:

### Architecture Overview

1. Landing Zone: Raw data ingestion bucket
2. Processing Zone: Data transformation and staging
3. Curated Zone: Processed, high-quality data
4. Archive Zone: Long-term, cold storage

### Terraform Implementation

```hcl
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Create VPC with private access
resource "google_compute_network" "data_lake_network" {
  name                    = "data-lake-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "data_lake_subnet" {
  name          = "data-lake-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.data_lake_network.id
  
  # Enable Google Private Access
  private_ip_google_access = true
}

# Create VPC Service Controls perimeter
resource "google_access_context_manager_service_perimeter" "data_perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.data_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.data_policy.name}/servicePerimeters/data_lake_perimeter"
  title  = "Data Lake Perimeter"
  
  status {
    resources = ["projects/${var.project_id}"]
    restricted_services = ["storage.googleapis.com"]
    
    ingress_policies {
      ingress_from {
        identities = [
          "serviceAccount:${google_service_account.data_processor.email}",
        ]
      }
      ingress_to {
        resources = ["*"]
        operations {
          service_name = "storage.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }
  }
}

resource "google_access_context_manager_access_policy" "data_policy" {
  parent = "organizations/${var.organization_id}"
  title  = "Data Lake Access Policy"
}

# Service Account for data processing
resource "google_service_account" "data_processor" {
  account_id   = "data-processor"
  display_name = "Data Lake Processing Service Account"
}

# KMS for encryption
resource "google_kms_key_ring" "data_lake_keyring" {
  name     = "data-lake-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "data_lake_key" {
  name     = "data-lake-key"
  key_ring = google_kms_key_ring.data_lake_keyring.id
  
  # Rotation settings
  rotation_period = "7776000s" # 90 days
  
  # Protect against destruction
  lifecycle {
    prevent_destroy = true
  }
}

# Grant KMS access to service account
resource "google_kms_crypto_key_iam_binding" "data_lake_key_binding" {
  crypto_key_id = google_kms_crypto_key.data_lake_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}

data "google_storage_project_service_account" "gcs_account" {}

# Create buckets for the data lake zones
resource "google_storage_bucket" "landing_zone" {
  name          = "${var.project_id}-landing-zone"
  location      = "US"
  storage_class = "STANDARD"
  
  # Security settings
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  
  # Set CMEK encryption
  encryption {
    default_kms_key_name = google_kms_crypto_key.data_lake_key.id
  }
  
  # Lifecycle policies
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
  
  # Ensure data is kept for compliance even if deleted in Terraform
  lifecycle {
    prevent_destroy = true
  }
  
  # Logging configuration
  logging {
    log_bucket        = google_storage_bucket.logs.name
    log_object_prefix = "landing-zone"
  }
}

resource "google_storage_bucket" "processing_zone" {
  name          = "${var.project_id}-processing-zone"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  
  encryption {
    default_kms_key_name = google_kms_crypto_key.data_lake_key.id
  }
  
  # Transition to Nearline after 30 days
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  # Delete after 60 days
  lifecycle_rule {
    condition {
      age = 60
    }
    action {
      type = "Delete"
    }
  }
  
  logging {
    log_bucket        = google_storage_bucket.logs.name
    log_object_prefix = "processing-zone"
  }
}

resource "google_storage_bucket" "curated_zone" {
  name          = "${var.project_id}-curated-zone"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  
  # Enable versioning for data protection
  versioning {
    enabled = true
  }
  
  encryption {
    default_kms_key_name = google_kms_crypto_key.data_lake_key.id
  }
  
  # Lifecycle management
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  # Delete non-current versions after 30 days
  lifecycle_rule {
    condition {
      age        = 30
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }
  
  logging {
    log_bucket        = google_storage_bucket.logs.name
    log_object_prefix = "curated-zone"
  }
}

resource "google_storage_bucket" "archive_zone" {
  name          = "${var.project_id}-archive-zone"
  location      = "US"
  storage_class = "ARCHIVE"
  
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  
  # Enable object holds for compliance
  retention_policy {
    retention_period = 31536000 # 1 year in seconds
  }
  
  encryption {
    default_kms_key_name = google_kms_crypto_key.data_lake_key.id
  }
  
  logging {
    log_bucket        = google_storage_bucket.logs.name
    log_object_prefix = "archive-zone"
  }
}

# Create bucket for access logs
resource "google_storage_bucket" "logs" {
  name          = "${var.project_id}-access-logs"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  
  # Set lifecycle for logs
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# IAM permissions for the buckets
resource "google_storage_bucket_iam_binding" "landing_zone_writer" {
  bucket = google_storage_bucket.landing_zone.name
  role   = "roles/storage.objectCreator"
  
  members = [
    "serviceAccount:${google_service_account.data_ingestion.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "processing_zone_reader" {
  bucket = google_storage_bucket.landing_zone.name
  role   = "roles/storage.objectViewer"
  
  members = [
    "serviceAccount:${google_service_account.data_processor.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "processing_zone_writer" {
  bucket = google_storage_bucket.processing_zone.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.data_processor.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "curated_zone_writer" {
  bucket = google_storage_bucket.curated_zone.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.data_processor.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "curated_zone_viewer" {
  bucket = google_storage_bucket.curated_zone.name
  role   = "roles/storage.objectViewer"
  
  members = [
    "serviceAccount:${google_service_account.data_analyst.email}",
    "group:data-analysts@example.com",
  ]
}

resource "google_storage_bucket_iam_binding" "archive_zone_writer" {
  bucket = google_storage_bucket.archive_zone.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.data_processor.email}",
  ]
}

# Additional service accounts
resource "google_service_account" "data_ingestion" {
  account_id   = "data-ingestion"
  display_name = "Data Ingestion Service Account"
}

resource "google_service_account" "data_analyst" {
  account_id   = "data-analyst"
  display_name = "Data Analyst Service Account"
}

# Notification configuration for new file arrivals
resource "google_storage_notification" "landing_zone_notification" {
  bucket         = google_storage_bucket.landing_zone.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.landing_zone_notifications.id
  event_types    = ["OBJECT_FINALIZE"]
}

resource "google_pubsub_topic" "landing_zone_notifications" {
  name = "landing-zone-notifications"
}

resource "google_pubsub_topic_iam_binding" "landing_zone_publisher" {
  topic   = google_pubsub_topic.landing_zone_notifications.name
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}
```

### Data Lifecycle Automation Script

```python
# data_lifecycle.py
from google.cloud import storage
import datetime
import logging

def move_processed_data(event, context):
    """Cloud Function triggered by Pub/Sub to move processed data"""
    # Get bucket and file details
    bucket_name = event['attributes']['bucketId']
    object_name = event['attributes']['objectId']
    
    if not object_name.endswith('.processed'):
        return
        
    # Initialize storage client
    storage_client = storage.Client()
    
    # Set source and destination buckets
    source_bucket = storage_client.bucket(bucket_name)
    processed_blob = source_bucket.blob(object_name)
    
    # Determine target bucket based on data type
    object_metadata = processed_blob.metadata
    data_type = object_metadata.get('data_type', 'unknown')
    
    if data_type == 'report':
        dest_bucket_name = f"{bucket_name.split('-')[0]}-curated-zone"
        dest_path = f"reports/{datetime.datetime.now().strftime('%Y/%m/%d')}/{object_name.replace('.processed', '')}"
    elif data_type == 'archive':
        dest_bucket_name = f"{bucket_name.split('-')[0]}-archive-zone"
        dest_path = f"{datetime.datetime.now().strftime('%Y/%m')}/{object_name.replace('.processed', '')}"
    else:
        dest_bucket_name = f"{bucket_name.split('-')[0]}-curated-zone"
        dest_path = f"other/{object_name.replace('.processed', '')}"

    # Copy to destination
    dest_bucket = storage_client.bucket(dest_bucket_name)
    source_blob = source_bucket.blob(object_name)
    
    # Copy with metadata
    dest_blob = source_bucket.copy_blob(
        source_blob, dest_bucket, dest_path
    )
    
    # Delete original after successful copy
    source_blob.delete()
    
    logging.info(f"Moved {object_name} to {dest_bucket_name}/{dest_path}")
```

## Best Practices

1. **Bucket Naming and Organization**
   - Choose globally unique, DNS-compliant names
   - Use consistent naming conventions
   - Organize objects with clear prefix hierarchy
   - Consider regional requirements for data storage

2. **Security**
   - Enable uniform bucket-level access
   - Use VPC Service Controls for sensitive data
   - Apply appropriate IAM roles with least privilege
   - Enforce public access prevention
   - Use CMEK for regulated data
   - Enable object holds for compliance

3. **Cost Optimization**
   - Choose appropriate storage classes for data access patterns
   - Implement lifecycle policies for automatic transitions
   - Use composite objects for small files
   - Monitor usage with Cloud Monitoring
   - Consider requester pays for shared datasets

4. **Performance**
   - Store frequently accessed data in regions close to users
   - Use parallel composite uploads for large files
   - Avoid small, frequent operations
   - Use signed URLs for temporary access
   - Implement connection pooling in applications

5. **Data Management**
   - Enable object versioning for critical data
   - Configure access logs for audit trails
   - Use object metadata for classification
   - Set up notifications for bucket events
   - Implement retention policies for compliance

## Common Issues and Troubleshooting

### Access Denied Errors
- Verify IAM permissions and roles
- Check for VPC Service Controls blocking access
- Ensure service accounts have proper permissions
- Validate CMEK access for encrypted buckets
- Check organization policies for restrictions

### Performance Issues
- Review network configuration for private Google access
- Ensure proper region selection for proximity to users
- Monitor request rates and throttling
- Check object naming patterns for hotspots
- Optimize upload/download processes

### Cost Management
- Review storage distribution across classes
- Check lifecycle policies for effectiveness
- Monitor large, unnecessary object versions
- Watch for unexpected egress charges
- Verify requester-pays configuration

### Data Management
- Validate versioning is working as expected
- Check retention policy effectiveness
- Monitor object holds and legal holds
- Verify notification configurations
- Ensure backups are properly configured

## Further Reading

- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Terraform Google Cloud Storage Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
- [Cloud Storage Best Practices](https://cloud.google.com/storage/docs/best-practices)
- [Cloud Storage Security](https://cloud.google.com/storage/docs/security-best-practices)
- [Data Lifecycle Management](https://cloud.google.com/storage/docs/lifecycle)