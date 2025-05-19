---
description: Managed relational database services in Google Cloud Platform
---

# Google Cloud SQL

Google Cloud SQL is a fully managed relational database service that makes it easy to set up, maintain, manage, and administer your relational databases in the cloud. Cloud SQL offers MySQL, PostgreSQL, and SQL Server, removing the burden of database administration tasks like patching, backups, and replication.

## Key Features

- **Fully Managed**: Google handles infrastructure, backups, replication, and patching
- **High Availability**: Automatic failover between zones with synchronous replication
- **Automated Backups**: Point-in-time recovery with automated daily backups
- **Scaling**: Easy vertical scaling of compute and storage resources
- **Security**: IAM integration, data encryption at rest and in transit, network controls
- **Maintenance**: Automatic maintenance with configurable maintenance windows
- **Global Access**: Private services access allows secure access from anywhere
- **Database Engines**: MySQL, PostgreSQL, and SQL Server support
- **Connection Options**: Private IP, Public IP with SSL/TLS, Cloud SQL Auth Proxy

## Supported Database Engines

| Engine | Supported Versions | Use Cases |
|--------|-------------------|-----------|
| **MySQL** | 5.6, 5.7, 8.0 | Web applications, e-commerce platforms, content management systems |
| **PostgreSQL** | 9.6, 10, 11, 12, 13, 14, 15 | Geospatial applications, complex data types, ACID-compliant applications |
| **SQL Server** | 2017, 2019 | Enterprise applications, Windows-based workloads, .NET applications |

## Deployment with Terraform

### Basic MySQL Instance

```hcl
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-instance"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  
  settings {
    tier = "db-n1-standard-2"
    
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "02:00"
    }
    
    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true
      private_network = google_compute_network.private_network.id
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 2  # 2 AM
      update_track = "stable"
    }
  }
  
  deletion_protection = true  # Prevent accidental deletion
}

# Create database
resource "google_sql_database" "database" {
  name     = "application-db"
  instance = google_sql_database_instance.mysql_instance.name
}

# Create user
resource "google_sql_user" "users" {
  name     = "app-user"
  instance = google_sql_database_instance.mysql_instance.name
  password = "CHANGE-ME-PLEASE"  # Consider using Terraform secrets management
}
```

### PostgreSQL with High Availability

```hcl
resource "google_sql_database_instance" "postgres_ha_instance" {
  name             = "postgres-ha"
  database_version = "POSTGRES_14"
  region           = "us-central1"
  
  settings {
    tier              = "db-custom-4-15360"  # 4 vCPUs, 15GB RAM
    availability_type = "REGIONAL"  # Enables high availability
    
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "23:00"
      transaction_log_retention_days = 7
    }
    
    ip_configuration {
      ipv4_enabled    = false  # Disable public IP
      private_network = google_compute_network.private_network.id
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    database_flags {
      name  = "shared_buffers"
      value = "256MB"
    }
    
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
  }
  
  deletion_protection = true
}
```

### SQL Server with Read Replica

```hcl
resource "google_sql_database_instance" "sqlserver_primary" {
  name             = "sqlserver-primary"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = "us-central1"
  
  settings {
    tier              = "db-custom-4-15360"
    availability_type = "REGIONAL"
    
    backup_configuration {
      enabled            = true
      start_time         = "00:00"
      retention_settings {
        retained_backups = 14
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
    
    database_flags {
      name  = "cross db ownership chaining"
      value = "on"
    }
  }
  
  deletion_protection = true
}

resource "google_sql_database_instance" "sqlserver_replica" {
  name                 = "sqlserver-replica"
  database_version     = "SQLSERVER_2019_STANDARD"
  region               = "us-west1"  # Different region for disaster recovery
  master_instance_name = google_sql_database_instance.sqlserver_primary.name
  
  settings {
    tier              = "db-custom-4-15360"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }
  
  deletion_protection = true
}
```

## Connection Methods

### Using the Cloud SQL Auth Proxy

Cloud SQL Auth Proxy provides secure access to your Cloud SQL instances without having to whitelist IP addresses or configure SSL:

```bash
# Download the proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy_x86_64.linux -O cloud_sql_proxy
chmod +x cloud_sql_proxy

# Connect using the proxy with IAM authentication
./cloud_sql_proxy -instances=PROJECT_ID:REGION:INSTANCE_NAME=tcp:3306
```

#### Docker-based Cloud SQL Proxy

```yaml
# docker-compose.yml
version: '3'
services:
  cloud-sql-proxy:
    image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.0.0
    command:
      - "--credentials-file=/secrets/service-account.json"
      - "--address=0.0.0.0"
      - "--port=3306"
      - "PROJECT_ID:REGION:INSTANCE_NAME"
    volumes:
      - ./service-account.json:/secrets/service-account.json:ro
    ports:
      - "3306:3306"
  
  application:
    image: your-application-image
    environment:
      - DB_HOST=cloud-sql-proxy
      - DB_PORT=3306
      - DB_USER=app-user
      - DB_PASSWORD=your-password
    depends_on:
      - cloud-sql-proxy
```

### Direct Connection with Private IP

If your GCP resources are already in the same VPC, you can connect directly using Private IP:

```python
# Python example using SQLAlchemy
from sqlalchemy import create_engine

# Connect to MySQL
db_user = 'app-user'
db_pass = 'your-password'
db_name = 'application-db'
db_host = '10.x.x.x'  # Private IP of the Cloud SQL instance

engine = create_engine(f'mysql+pymysql://{db_user}:{db_pass}@{db_host}/{db_name}')
```

## High Availability and Disaster Recovery

### HA Configuration

```hcl
resource "google_sql_database_instance" "ha_instance" {
  name             = "ha-mysql"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  
  settings {
    tier              = "db-n1-standard-4"
    availability_type = "REGIONAL"  # Enables synchronous replication
    
    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true  # Enables point-in-time recovery
      start_time                     = "23:00"
      transaction_log_retention_days = 7
    }
  }
}
```

### Cross-Region Disaster Recovery

For disaster recovery across regions, set up cross-region read replicas:

```hcl
resource "google_sql_database_instance" "dr_replica" {
  name                 = "dr-replica"
  database_version     = "MYSQL_8_0"
  region               = "europe-west1"  # Different region
  master_instance_name = google_sql_database_instance.ha_instance.name
  
  settings {
    tier = "db-n1-standard-4"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }
}
```

## Security Best Practices

### 1. Private IP Configuration

```hcl
# First set up VPC peering for private connectivity
resource "google_compute_network" "private_network" {
  name                    = "private-network"
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Then create Cloud SQL instance with private IP only
resource "google_sql_database_instance" "private_instance" {
  name             = "private-mysql"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
  
  settings {
    tier = "db-n1-standard-2"
    
    ip_configuration {
      ipv4_enabled    = false  # Disable public IP
      private_network = google_compute_network.private_network.id
    }
    
    # Database flags for security hardening
    database_flags {
      name  = "local_infile"
      value = "off"
    }
    
    database_flags {
      name  = "skip_show_database"
      value = "on"
    }
  }
}
```

### 2. IAM Database Authentication

For PostgreSQL, you can enable IAM database authentication:

```hcl
resource "google_sql_database_instance" "postgres_iam_auth" {
  name             = "postgres-iam-auth"
  database_version = "POSTGRES_14"
  region           = "us-central1"
  
  settings {
    tier = "db-n1-standard-2"
    
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

# IAM User
resource "google_sql_user" "iam_user" {
  name     = "sqliam-user@project-id.iam"
  instance = google_sql_database_instance.postgres_iam_auth.name
  type     = "CLOUD_IAM_USER"
}

# IAM Service Account
resource "google_sql_user" "iam_service_account" {
  name     = "sqliam-sa@project-id.iam.gserviceaccount.com"
  instance = google_sql_database_instance.postgres_iam_auth.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
```

### 3. SSL/TLS Configuration

```hcl
resource "google_sql_database_instance" "ssl_instance" {
  # Basic instance configuration
  
  settings {
    # Other settings
    
    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true  # Force SSL connections
    }
  }
}

# Generate client certificates with gcloud (outside of Terraform)
# gcloud sql ssl client-certs create client-cert client-key.pem --instance=ssl-instance
```

## Monitoring and Maintenance

### Monitoring with Google Cloud Monitoring

```hcl
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "High CPU Alert"
  combiner     = "OR"
  conditions {
    display_name = "CPU Utilization > 80%"
    condition_threshold {
      filter          = "resource.type = \"cloudsql_database\" AND resource.labels.database_id = \"${google_sql_database_instance.mysql_instance.project}:${google_sql_database_instance.mysql_instance.name}\" AND metric.type = \"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "DB Admin Email"
  type         = "email"
  labels = {
    email_address = "db-admin@example.com"
  }
}
```

### Query Insights

Cloud SQL Query Insights helps identify problematic queries:

```hcl
resource "google_sql_database_instance" "instance_with_insights" {
  # Basic instance configuration
  
  settings {
    # Other settings
    
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
  }
}
```

### Maintenance Window Configuration

```hcl
resource "google_sql_database_instance" "maintenance_configured" {
  # Basic instance configuration
  
  settings {
    # Other settings
    
    maintenance_window {
      day          = 7   # Sunday
      hour         = 3   # 3 AM
      update_track = "stable"  # or "preview" for earlier updates
    }
  }
}
```

## Common Operational Tasks with gcloud CLI

### Create a Database Backup

```bash
# On-demand backup
gcloud sql backups create --instance=INSTANCE_NAME

# List backups
gcloud sql backups list --instance=INSTANCE_NAME
```

### Restore from a Backup

```bash
# Restore entire instance
gcloud sql instances restore INSTANCE_NAME \
  --backup-id=BACKUP_ID \
  --restore-instance=DESTINATION_INSTANCE_NAME

# Point-in-time recovery
gcloud sql instances restore INSTANCE_NAME \
  --restore-time="2023-05-20T15:00:00Z" \
  --restore-instance=DESTINATION_INSTANCE_NAME
```

### Import and Export Data

```bash
# Export to Cloud Storage
gcloud sql export sql INSTANCE_NAME \
  gs://BUCKET_NAME/FILENAME.sql \
  --database=DATABASE_NAME

# Import from Cloud Storage
gcloud sql import sql INSTANCE_NAME \
  gs://BUCKET_NAME/FILENAME.sql \
  --database=DATABASE_NAME
```

### Scaling Up/Down

```bash
# Vertical scaling
gcloud sql instances patch INSTANCE_NAME \
  --tier=db-custom-8-32768  # 8 CPUs, 32GB RAM

# Storage scaling
gcloud sql instances patch INSTANCE_NAME \
  --storage-size=100  # 100GB
```

## Integration with Kubernetes

### Using Kubernetes Secrets for Database Credentials

```yaml
# Create a Secret with database credentials
apiVersion: v1
kind: Secret
metadata:
  name: cloudsql-db-credentials
type: Opaque
data:
  username: YXBwLXVzZXI=  # base64 encoded 'app-user'
  password: c2VjcmV0LXBhc3N3b3Jk  # base64 encoded 'secret-password'
```

### Deployment with Cloud SQL Proxy Sidecar

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:latest
        env:
        - name: DB_HOST
          value: "127.0.0.1"
        - name: DB_PORT
          value: "3306"
        - name: DB_NAME
          value: "application-db"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: cloudsql-db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: cloudsql-db-credentials
              key: password
        
      - name: cloud-sql-proxy
        image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.0.0
        args:
          - "--credentials-file=/secrets/service-account.json"
          - "--address=0.0.0.0"
          - "--port=3306"
          - "PROJECT_ID:REGION:INSTANCE_NAME"
        volumeMounts:
          - name: cloudsql-instance-credentials
            mountPath: /secrets/
            readOnly: true
        
      volumes:
      - name: cloudsql-instance-credentials
        secret:
          secretName: cloudsql-instance-credentials
```

## Database Migration Service (DMS)

Cloud DMS helps migrate databases to Cloud SQL with minimal downtime:

```bash
# Create a migration job using gcloud
gcloud database-migration migration-jobs create my-migration \
  --source=my-source \
  --destination=my-destination \
  --region=us-central1

# Start the migration
gcloud database-migration migration-jobs start my-migration \
  --region=us-central1
```

## Best Practices for Cloud SQL

1. **Security First**:
   - Use private IP wherever possible
   - Implement least privilege IAM roles
   - Enable automatic backup
   - Configure SSL/TLS for all connections

2. **Performance Optimization**:
   - Size instances appropriately
   - Use database flags for workload optimization
   - Enable Query Insights to identify slow queries
   - Consider read replicas for read-heavy workloads

3. **Cost Management**:
   - Choose appropriate machine types
   - Use custom machine types for right-sizing
   - Enable automatic storage increases but set upper limits
   - Schedule maintenance during off-peak hours

4. **Operational Excellence**:
   - Implement monitoring and alerting
   - Configure appropriate maintenance windows
   - Use Terraform or other IaC tools for database provisioning
   - Document connection patterns for applications

5. **High Availability**:
   - Use regional instances for production workloads
   - Test failover procedures regularly
   - Implement cross-region replicas for disaster recovery
   - Use point-in-time recovery capabilities

## Common Pitfalls to Avoid

1. **Underestimating connection limits**:
   - Cloud SQL instances have connection limits based on the machine type
   - Implement connection pooling in applications

2. **Neglecting backup testing**:
   - Regularly test restore procedures to ensure backups are valid
   - Verify backup completeness with point-in-time tests

3. **Ignoring performance tuning**:
   - MySQL and PostgreSQL require different tuning approaches
   - Cloud SQL has specific limits that differ from self-managed databases

4. **Public IP exposure**:
   - Avoid exposing database instances to the internet
   - Use VPC Service Controls to restrict access

5. **Inadequate monitoring**:
   - Monitor both the Cloud SQL instance and query performance
   - Set up alerts for disk space, connection count, and CPU usage

## Further Reading

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud SQL Pricing](https://cloud.google.com/sql/pricing)
- [Cloud SQL IAM Authentication](https://cloud.google.com/sql/docs/mysql/authentication)
- [Cloud SQL High Availability](https://cloud.google.com/sql/docs/mysql/high-availability)
- [Database Migration Service](https://cloud.google.com/database-migration)