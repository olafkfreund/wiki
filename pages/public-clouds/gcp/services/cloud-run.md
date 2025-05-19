---
description: Deploying and managing Google Cloud Run for containerized applications
---

# Cloud Run

Google Cloud Run is a fully managed compute platform that allows you to run stateless containers directly on top of Google's scalable infrastructure. It abstracts away infrastructure management so you can focus on developing applications in the language of your choice.

## Key Features

- **Fully managed**: No infrastructure to provision or manage
- **Serverless**: Pay only for the resources you use
- **Scale to zero**: No charges when your service isn't running
- **Autoscaling**: Automatically scales based on traffic
- **Multiple languages**: Supports any language using a Docker container
- **Custom domains**: Connect your own domain names
- **Private services**: Restrict access to authorized users or internal services
- **Traffic splitting**: Gradually roll out new versions with percentage-based traffic splitting
- **VPC connectivity**: Connect to VPC resources
- **Cloud SQL connection**: Direct connection to Cloud SQL databases
- **Concurrency**: Process multiple requests per container instance
- **WebSockets**: Support for WebSockets and HTTP/2

## Deploying Cloud Run with Terraform

### Basic Service Deployment

```hcl
# Create a service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
}

# Grant permissions to the service account
resource "google_project_iam_member" "cloud_run_permissions" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Deploy the Cloud Run service
resource "google_cloud_run_service" "service" {
  name     = "my-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/my-image:latest"
        
        # Resource limits
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        # Environment variables
        env {
          name  = "ENV_VAR_NAME"
          value = "env_var_value"
        }
        
        # Secret environment variables
        env {
          name = "SECRET_ENV_VAR"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.my_secret.secret_id
              key  = "latest"
            }
          }
        }
        
        # Container ports
        ports {
          container_port = 8080
        }
      }
      
      # Service account
      service_account_name = google_service_account.cloud_run_sa.email
      
      # Concurrency settings
      container_concurrency = 80
      
      # Timeout
      timeout_seconds = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "100"
        "autoscaling.knative.dev/minScale" = "1"
        "run.googleapis.com/client-name"   = "terraform"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  # Auto-generate revision name
  autogenerate_revision_name = true
}

# Allow public access to the service
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.service.location
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Create a secret for the service
resource "google_secret_manager_secret" "my_secret" {
  secret_id = "my-service-secret"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "my_secret_version" {
  secret      = google_secret_manager_secret.my_secret.id
  secret_data = "my-secret-value"
}

# Grant access to secret
resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.my_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Output the service URL
output "service_url" {
  value = google_cloud_run_service.service.status[0].url
}
```

### Cloud Run Service with VPC Access

```hcl
# Create a VPC
resource "google_compute_network" "vpc" {
  name                    = "cloudrun-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "cloudrun-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Create a VPC connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  name          = "vpc-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
}

# Deploy Cloud Run service with VPC connector
resource "google_cloud_run_service" "vpc_service" {
  name     = "vpc-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/my-vpc-app:latest"
        
        # Environment variables
        env {
          name  = "INTERNAL_SERVICE_URL"
          value = "http://internal-service.private.run:8080"
        }
      }
      
      # Service account
      service_account_name = google_service_account.cloud_run_sa.email
    }
    
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }
}
```

### Cloud Run Service with Traffic Splitting

```hcl
# Deploy Cloud Run service with multiple revisions
resource "google_cloud_run_service" "multi_revision_service" {
  name     = "multi-revision-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/my-image:v2"
      }
    }
    
    metadata {
      name = "multi-revision-service-green"
      annotations = {
        "run.googleapis.com/client-name" = "terraform"
      }
    }
  }
  
  # Traffic splitting between revisions
  traffic {
    percent       = 80
    revision_name = "multi-revision-service-green"
  }
  
  traffic {
    percent       = 20
    revision_name = "multi-revision-service-blue"
    # This revision needs to exist before applying this configuration
  }
}
```

### Cloud Run with Custom Domain Mapping

```hcl
# Create a Cloud Run service
resource "google_cloud_run_service" "website" {
  name     = "website"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/website:latest"
      }
    }
  }
}

# Create a domain mapping
resource "google_cloud_run_domain_mapping" "domain_mapping" {
  location = var.region
  name     = "example.com"
  
  metadata {
    namespace = var.project_id
  }
  
  spec {
    route_name = google_cloud_run_service.website.name
  }
}

# Output the resource records that should be added to DNS
output "dns_records" {
  value = [for record in google_cloud_run_domain_mapping.domain_mapping.status[0].resource_records : {
    name  = record.name
    type  = record.type
    rrdatas = record.rrdatas
  }]
}
```

## Deploying Cloud Run with gcloud CLI

### Building and Deploying a Container

```bash
# Navigate to your app directory
cd ~/my-app

# Create a Dockerfile
cat > Dockerfile << EOF
FROM node:16-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD [ "node", "index.js" ]
EOF

# Build and push the container image
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/my-app:v1

# Deploy to Cloud Run
gcloud run deploy my-app \
  --image gcr.io/$(gcloud config get-value project)/my-app:v1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Updating an Existing Service

```bash
# Deploy a new revision
gcloud run deploy my-app \
  --image gcr.io/$(gcloud config get-value project)/my-app:v2 \
  --platform managed \
  --region us-central1
  
# Split traffic between revisions
gcloud run services update-traffic my-app \
  --platform managed \
  --region us-central1 \
  --to-revisions my-app-00001-abc=80,my-app-00002-def=20
```

### Creating a Private Service

```bash
# Deploy a private Cloud Run service
gcloud run deploy private-service \
  --image gcr.io/$(gcloud config get-value project)/private-service:v1 \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated
  
# Grant access to a specific user
gcloud run services add-iam-policy-binding private-service \
  --platform managed \
  --region us-central1 \
  --member="user:user@example.com" \
  --role="roles/run.invoker"

# Grant access to another service account
gcloud run services add-iam-policy-binding private-service \
  --platform managed \
  --region us-central1 \
  --member="serviceAccount:my-sa@$(gcloud config get-value project).iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

### Configure VPC Connector

```bash
# Create a VPC connector
gcloud compute networks vpc-access connectors create my-connector \
  --network default \
  --region us-central1 \
  --range 10.8.0.0/28

# Deploy with VPC connector
gcloud run deploy vpc-app \
  --image gcr.io/$(gcloud config get-value project)/vpc-app:v1 \
  --platform managed \
  --region us-central1 \
  --vpc-connector my-connector \
  --vpc-egress private-ranges-only
```

### Configure Environment Variables and Secrets

```bash
# Create a secret in Secret Manager
echo -n "my-secret-value" | gcloud secrets create my-secret \
  --replication-policy="automatic" \
  --data-file=-

# Grant access to the secret
gcloud secrets add-iam-policy-binding my-secret \
  --member="serviceAccount:$(gcloud iam service-accounts list --filter="EMAIL:cloud-run-sa*" --format="value(EMAIL)")" \
  --role="roles/secretmanager.secretAccessor"

# Deploy with environment variables and secret
gcloud run deploy env-app \
  --image gcr.io/$(gcloud config get-value project)/env-app:v1 \
  --platform managed \
  --region us-central1 \
  --set-env-vars "KEY1=VALUE1,KEY2=VALUE2" \
  --update-secrets="SECRET1=my-secret:latest"
```

## Real-World Example: Microservices Application

This example demonstrates a complete microservices architecture using Cloud Run:

### Step 1: Infrastructure Setup with Terraform

```hcl
# Set up the infrastructure for a microservices application
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create VPC for services
resource "google_compute_network" "vpc" {
  name                    = "microservices-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "microservices-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Create a VPC connector
resource "google_vpc_access_connector" "connector" {
  name          = "microservices-vpc-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
}

# Create Cloud SQL instance for databases
resource "google_sql_database_instance" "postgres" {
  name             = "microservices-postgres"
  database_version = "POSTGRES_13"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      
      authorized_networks {
        name  = "office"
        value = var.office_ip_range
      }
    }
    
    backup_configuration {
      enabled            = true
      start_time         = "02:00"
      binary_log_enabled = false
    }
  }
  
  deletion_protection = true
}

# Create databases for each service
resource "google_sql_database" "auth_db" {
  name     = "auth-service-db"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_database" "product_db" {
  name     = "product-service-db"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_database" "order_db" {
  name     = "order-service-db"
  instance = google_sql_database_instance.postgres.name
}

# Create database users
resource "random_password" "auth_db_password" {
  length  = 16
  special = true
}

resource "random_password" "product_db_password" {
  length  = 16
  special = true
}

resource "random_password" "order_db_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "auth_db_user" {
  name     = "auth-service"
  instance = google_sql_database_instance.postgres.name
  password = random_password.auth_db_password.result
}

resource "google_sql_user" "product_db_user" {
  name     = "product-service"
  instance = google_sql_database_instance.postgres.name
  password = random_password.product_db_password.result
}

resource "google_sql_user" "order_db_user" {
  name     = "order-service"
  instance = google_sql_database_instance.postgres.name
  password = random_password.order_db_password.result
}

# Create Redis instance for caching
resource "google_redis_instance" "cache" {
  name           = "microservices-cache"
  tier           = "BASIC"
  memory_size_gb = 1
  
  region                  = var.region
  authorized_network      = google_compute_network.vpc.id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  redis_version           = "REDIS_6_X"
  display_name            = "Microservices Cache"
  reserved_ip_range       = "10.9.0.0/28"
  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 2
        minutes = 0
      }
    }
  }
}

# Store database credentials in Secret Manager
resource "google_secret_manager_secret" "auth_db_secret" {
  secret_id = "auth-db-credentials"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "auth_db_secret_version" {
  secret = google_secret_manager_secret.auth_db_secret.id
  
  secret_data = jsonencode({
    username = google_sql_user.auth_db_user.name
    password = google_sql_user.auth_db_user.password
    database = google_sql_database.auth_db.name
    instance = google_sql_database_instance.postgres.connection_name
  })
}

resource "google_secret_manager_secret" "product_db_secret" {
  secret_id = "product-db-credentials"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "product_db_secret_version" {
  secret = google_secret_manager_secret.product_db_secret.id
  
  secret_data = jsonencode({
    username = google_sql_user.product_db_user.name
    password = google_sql_user.product_db_user.password
    database = google_sql_database.product_db.name
    instance = google_sql_database_instance.postgres.connection_name
  })
}

resource "google_secret_manager_secret" "order_db_secret" {
  secret_id = "order-db-credentials"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "order_db_secret_version" {
  secret = google_secret_manager_secret.order_db_secret.id
  
  secret_data = jsonencode({
    username = google_sql_user.order_db_user.name
    password = google_sql_user.order_db_user.password
    database = google_sql_database.order_db.name
    instance = google_sql_database_instance.postgres.connection_name
  })
}

# Create JWT secret for authentication
resource "random_password" "jwt_secret" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "jwt-secret"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "jwt_secret_version" {
  secret = google_secret_manager_secret.jwt_secret.id
  
  secret_data = random_password.jwt_secret.result
}

# Create service accounts for each service
resource "google_service_account" "auth_service_sa" {
  account_id   = "auth-service-sa"
  display_name = "Authentication Service"
}

resource "google_service_account" "product_service_sa" {
  account_id   = "product-service-sa"
  display_name = "Product Service"
}

resource "google_service_account" "order_service_sa" {
  account_id   = "order-service-sa"
  display_name = "Order Service"
}

resource "google_service_account" "frontend_sa" {
  account_id   = "frontend-sa"
  display_name = "Frontend Application"
}

# Grant permissions to service accounts
resource "google_project_iam_member" "auth_service_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/cloudsql.client"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.auth_service_sa.email}"
}

resource "google_project_iam_member" "product_service_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/cloudsql.client"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.product_service_sa.email}"
}

resource "google_project_iam_member" "order_service_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/cloudsql.client",
    "roles/pubsub.publisher"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.order_service_sa.email}"
}

resource "google_project_iam_member" "frontend_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/cloudtrace.agent"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.frontend_sa.email}"
}

# Grant access to secrets
resource "google_secret_manager_secret_iam_member" "auth_db_secret_access" {
  secret_id = google_secret_manager_secret.auth_db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.auth_service_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "product_db_secret_access" {
  secret_id = google_secret_manager_secret.product_db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.product_service_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "order_db_secret_access" {
  secret_id = google_secret_manager_secret.order_db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.order_service_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "jwt_secret_access" {
  secret_id = google_secret_manager_secret.jwt_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.auth_service_sa.email}"
}

# Create Pub/Sub topic for order events
resource "google_pubsub_topic" "order_events" {
  name = "order-events"
}

# Deploy the Authentication Service
resource "google_cloud_run_service" "auth_service" {
  name     = "auth-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/auth-service:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        
        env {
          name = "DB_CREDENTIALS"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.auth_db_secret.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name = "JWT_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.jwt_secret.secret_id
              key  = "latest"
            }
          }
        }
      }
      
      service_account_name = google_service_account.auth_service_sa.email
      
      # Add Cloud SQL proxy
      containers {
        image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0"
        args = [
          "--structured-logs",
          "--port=5432",
          "${google_sql_database_instance.postgres.connection_name}"
        ]
      }
    }
    
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.postgres.connection_name
        "autoscaling.knative.dev/minScale"        = "1"
        "autoscaling.knative.dev/maxScale"        = "10"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Deploy Product Service
resource "google_cloud_run_service" "product_service" {
  name     = "product-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/product-service:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        
        env {
          name = "DB_CREDENTIALS"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.product_db_secret.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name  = "REDIS_HOST"
          value = google_redis_instance.cache.host
        }
        
        env {
          name  = "REDIS_PORT"
          value = google_redis_instance.cache.port
        }
      }
      
      service_account_name = google_service_account.product_service_sa.email
      
      # Add Cloud SQL proxy
      containers {
        image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0"
        args = [
          "--structured-logs",
          "--port=5432",
          "${google_sql_database_instance.postgres.connection_name}"
        ]
      }
    }
    
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.postgres.connection_name
        "autoscaling.knative.dev/minScale"        = "1"
        "autoscaling.knative.dev/maxScale"        = "10"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Deploy Order Service
resource "google_cloud_run_service" "order_service" {
  name     = "order-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/order-service:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        
        env {
          name = "DB_CREDENTIALS"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.order_db_secret.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name  = "PRODUCT_SERVICE_URL"
          value = google_cloud_run_service.product_service.status[0].url
        }
        
        env {
          name  = "PUBSUB_TOPIC"
          value = google_pubsub_topic.order_events.id
        }
      }
      
      service_account_name = google_service_account.order_service_sa.email
      
      # Add Cloud SQL proxy
      containers {
        image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0"
        args = [
          "--structured-logs",
          "--port=5432",
          "${google_sql_database_instance.postgres.connection_name}"
        ]
      }
    }
    
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.postgres.connection_name
        "autoscaling.knative.dev/minScale"        = "1"
        "autoscaling.knative.dev/maxScale"        = "10"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Deploy Frontend Application
resource "google_cloud_run_service" "frontend" {
  name     = "frontend"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/frontend:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        
        env {
          name  = "AUTH_SERVICE_URL"
          value = google_cloud_run_service.auth_service.status[0].url
        }
        
        env {
          name  = "PRODUCT_SERVICE_URL"
          value = google_cloud_run_service.product_service.status[0].url
        }
        
        env {
          name  = "ORDER_SERVICE_URL"
          value = google_cloud_run_service.order_service.status[0].url
        }
      }
      
      service_account_name = google_service_account.frontend_sa.email
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Make the frontend public
resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_service.frontend.location
  service  = google_cloud_run_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Set up service-to-service authentication
resource "google_cloud_run_service_iam_member" "product_service_auth" {
  location = google_cloud_run_service.product_service.location
  service  = google_cloud_run_service.product_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.order_service_sa.email}"
}

resource "google_cloud_run_service_iam_member" "auth_service_frontend_auth" {
  location = google_cloud_run_service.auth_service.location
  service  = google_cloud_run_service.auth_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

resource "google_cloud_run_service_iam_member" "product_service_frontend_auth" {
  location = google_cloud_run_service.product_service.location
  service  = google_cloud_run_service.product_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

resource "google_cloud_run_service_iam_member" "order_service_frontend_auth" {
  location = google_cloud_run_service.order_service.location
  service  = google_cloud_run_service.order_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

# Output service URLs
output "frontend_url" {
  value = google_cloud_run_service.frontend.status[0].url
}

output "auth_service_url" {
  value = google_cloud_run_service.auth_service.status[0].url
}

output "product_service_url" {
  value = google_cloud_run_service.product_service.status[0].url
}

output "order_service_url" {
  value = google_cloud_run_service.order_service.status[0].url
}
```

### Step 2: Example Authentication Service Code

```javascript
// auth-service/server.js
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');
const app = express();
const port = process.env.PORT || 8080;

// Parse credentials from Secret Manager
const dbCredentials = JSON.parse(process.env.DB_CREDENTIALS || '{}');
const jwtSecret = process.env.JWT_SECRET || 'default-secret';

// Set up database connection
const pool = new Pool({
  host: 'localhost', // Cloud SQL Proxy sidecar
  port: 5432,
  user: dbCredentials.username,
  password: dbCredentials.password,
  database: dbCredentials.database,
});

app.use(express.json());

// Middleware for logging and tracing
app.use((req, res, next) => {
  const traceHeader = req.header('X-Cloud-Trace-Context');
  console.log(`Request received: ${req.method} ${req.path} - Trace: ${traceHeader || 'none'}`);
  next();
});

// Initialize database tables if needed
async function initializeDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Database tables initialized');
  } catch (error) {
    console.error('Error initializing database:', error);
  }
}

// Initialize the database when the service starts
initializeDatabase();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// User registration
app.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    // Validate input
    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Check if user already exists
    const existingUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (existingUser.rows.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }
    
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create the user
    const result = await pool.query(
      'INSERT INTO users (email, password, name) VALUES ($1, $2, $3) RETURNING id, email, name, created_at',
      [email, hashedPassword, name]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error in /register:', error);
    res.status(500).json({ error: 'An error occurred during registration' });
  }
});

// User login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      return res.status(400).json({ error: 'Missing email or password' });
    }
    
    // Find the user
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    const user = result.rows[0];
    
    // Verify the password
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    // Generate a JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      jwtSecret,
      { expiresIn: '24h' }
    );
    
    res.json({
      userId: user.id,
      email: user.email,
      name: user.name,
      token
    });
  } catch (error) {
    console.error('Error in /login:', error);
    res.status(500).json({ error: 'An error occurred during login' });
  }
});

// Verify token endpoint for other services
app.post('/verify', (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    jwt.verify(token, jwtSecret, (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: 'Invalid or expired token' });
      }
      
      res.json({ valid: true, user: decoded });
    });
  } catch (error) {
    console.error('Error in /verify:', error);
    res.status(500).json({ error: 'An error occurred during token verification' });
  }
});

// Get user profile
app.get('/profile/:id', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    jwt.verify(token, jwtSecret, async (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: 'Invalid or expired token' });
      }
      
      const userId = req.params.id;
      
      // Check if the user is requesting their own profile
      if (decoded.userId != userId) {
        return res.status(403).json({ error: 'Access denied' });
      }
      
      const result = await pool.query(
        'SELECT id, email, name, created_at FROM users WHERE id = $1',
        [userId]
      );
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      res.json(result.rows[0]);
    });
  } catch (error) {
    console.error('Error in /profile:', error);
    res.status(500).json({ error: 'An error occurred while fetching the profile' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Auth service listening on port ${port}`);
});
```

### Step 3: Example Product Service Code

```javascript
// product-service/server.js
const express = require('express');
const { Pool } = require('pg');
const Redis = require('ioredis');
const app = express();
const port = process.env.PORT || 8080;

// Parse credentials from Secret Manager
const dbCredentials = JSON.parse(process.env.DB_CREDENTIALS || '{}');

// Set up database connection
const pool = new Pool({
  host: 'localhost', // Cloud SQL Proxy sidecar
  port: 5432,
  user: dbCredentials.username,
  password: dbCredentials.password,
  database: dbCredentials.database,
});

// Set up Redis connection
const redisClient = new Redis({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
});

app.use(express.json());

// Middleware for logging and tracing
app.use((req, res, next) => {
  const traceHeader = req.header('X-Cloud-Trace-Context');
  console.log(`Request received: ${req.method} ${req.path} - Trace: ${traceHeader || 'none'}`);
  next();
});

// Initialize database tables if needed
async function initializeDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        category_id INTEGER REFERENCES categories(id),
        price DECIMAL(10, 2) NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    console.log('Product database tables initialized');
    
    // Add some sample data if tables are empty
    const categoryCount = await pool.query('SELECT COUNT(*) FROM categories');
    
    if (parseInt(categoryCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO categories (name, description) VALUES
        ('Electronics', 'Electronic gadgets and devices'),
        ('Books', 'Physical and digital books'),
        ('Clothing', 'Apparel and accessories')
      `);
      
      await pool.query(`
        INSERT INTO products (name, description, category_id, price, stock, image_url) VALUES
        ('Smartphone', 'Latest smartphone with advanced features', 1, 599.99, 50, 'https://example.com/smartphone.jpg'),
        ('Laptop', 'Powerful laptop for professionals', 1, 1299.99, 25, 'https://example.com/laptop.jpg'),
        ('Headphones', 'Noise-cancelling wireless headphones', 1, 199.99, 100, 'https://example.com/headphones.jpg'),
        ('Programming Book', 'Learn to code with this comprehensive guide', 2, 49.99, 30, 'https://example.com/programming-book.jpg'),
        ('T-Shirt', 'Comfortable cotton t-shirt', 3, 19.99, 200, 'https://example.com/tshirt.jpg')
      `);
      
      console.log('Added sample product data');
    }
  } catch (error) {
    console.error('Error initializing database:', error);
  }
}

// Initialize the database when the service starts
initializeDatabase();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Get all products with caching
app.get('/products', async (req, res) => {
  try {
    const cacheKey = 'products:all';
    
    // Try to get from cache first
    const cachedProducts = await redisClient.get(cacheKey);
    
    if (cachedProducts) {
      console.log('Cache hit for all products');
      return res.json(JSON.parse(cachedProducts));
    }
    
    console.log('Cache miss for all products, querying database');
    
    // Query database if not in cache
    const result = await pool.query(`
      SELECT p.*, c.name as category_name 
      FROM products p 
      JOIN categories c ON p.category_id = c.id
      ORDER BY p.name
    `);
    
    // Store in cache for 5 minutes
    await redisClient.set(cacheKey, JSON.stringify(result.rows), 'EX', 300);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Error fetching products' });
  }
});

// Get a single product by ID with caching
app.get('/products/:id', async (req, res) => {
  try {
    const productId = req.params.id;
    const cacheKey = `product:${productId}`;
    
    // Try to get from cache first
    const cachedProduct = await redisClient.get(cacheKey);
    
    if (cachedProduct) {
      console.log(`Cache hit for product ${productId}`);
      return res.json(JSON.parse(cachedProduct));
    }
    
    console.log(`Cache miss for product ${productId}, querying database`);
    
    // Query database if not in cache
    const result = await pool.query(`
      SELECT p.*, c.name as category_name 
      FROM products p 
      JOIN categories c ON p.category_id = c.id 
      WHERE p.id = $1
    `, [productId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    // Store in cache for 5 minutes
    await redisClient.set(cacheKey, JSON.stringify(result.rows[0]), 'EX', 300);
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error(`Error fetching product ${req.params.id}:`, error);
    res.status(500).json({ error: 'Error fetching product' });
  }
});

// Get products by category with caching
app.get('/categories/:id/products', async (req, res) => {
  try {
    const categoryId = req.params.id;
    const cacheKey = `category:${categoryId}:products`;
    
    // Try to get from cache first
    const cachedProducts = await redisClient.get(cacheKey);
    
    if (cachedProducts) {
      console.log(`Cache hit for category ${categoryId} products`);
      return res.json(JSON.parse(cachedProducts));
    }
    
    console.log(`Cache miss for category ${categoryId} products, querying database`);
    
    // Query database if not in cache
    const result = await pool.query(`
      SELECT p.*, c.name as category_name 
      FROM products p 
      JOIN categories c ON p.category_id = c.id 
      WHERE c.id = $1
      ORDER BY p.name
    `, [categoryId]);
    
    // Store in cache for 5 minutes
    await redisClient.set(cacheKey, JSON.stringify(result.rows), 'EX', 300);
    
    res.json(result.rows);
  } catch (error) {
    console.error(`Error fetching products for category ${req.params.id}:`, error);
    res.status(500).json({ error: 'Error fetching products' });
  }
});

// Check product stock
app.get('/products/:id/stock', async (req, res) => {
  try {
    const productId = req.params.id;
    
    const result = await pool.query(
      'SELECT id, name, stock FROM products WHERE id = $1',
      [productId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error(`Error checking stock for product ${req.params.id}:`, error);
    res.status(500).json({ error: 'Error checking product stock' });
  }
});

// Update product stock (for internal service use)
app.post('/products/:id/stock', async (req, res) => {
  try {
    const productId = req.params.id;
    const { quantity } = req.body;
    
    if (quantity === undefined) {
      return res.status(400).json({ error: 'Quantity is required' });
    }
    
    // Begin transaction
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      // Check current stock
      const stockResult = await client.query(
        'SELECT stock FROM products WHERE id = $1 FOR UPDATE',
        [productId]
      );
      
      if (stockResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Product not found' });
      }
      
      const currentStock = stockResult.rows[0].stock;
      const newStock = currentStock - quantity;
      
      if (newStock < 0) {
        await client.query('ROLLBACK');
        return res.status(400).json({ 
          error: 'Insufficient stock', 
          requested: quantity, 
          available: currentStock 
        });
      }
      
      // Update the stock
      await client.query(
        'UPDATE products SET stock = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
        [newStock, productId]
      );
      
      await client.query('COMMIT');
      
      // Invalidate cache
      await redisClient.del(`product:${productId}`);
      
      res.json({ 
        productId: parseInt(productId), 
        previousStock: currentStock, 
        newStock, 
        deducted: quantity 
      });
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error(`Error updating stock for product ${req.params.id}:`, error);
    res.status(500).json({ error: 'Error updating product stock' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Product service listening on port ${port}`);
});
```

### Step 4: Example of Frontend Integration

```javascript
// frontend/src/api/services.js
import axios from 'axios';

// Service URLs from environment variables
const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL;
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL;
const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL;

// Create axios instances for each service
export const authApi = axios.create({
  baseURL: AUTH_SERVICE_URL,
});

export const productApi = axios.create({
  baseURL: PRODUCT_SERVICE_URL,
});

export const orderApi = axios.create({
  baseURL: ORDER_SERVICE_URL,
});

// Add authentication interceptor
const addAuthToken = (config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
};

// Add interceptors to APIs that need authentication
productApi.interceptors.request.use(addAuthToken);
orderApi.interceptors.request.use(addAuthToken);

// Auth service methods
export const authService = {
  login: async (email, password) => {
    const response = await authApi.post('/login', { email, password });
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data));
    }
    return response.data;
  },
  
  register: async (userData) => {
    return await authApi.post('/register', userData);
  },
  
  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
  
  getProfile: async (userId) => {
    return await authApi.get(`/profile/${userId}`);
  }
};

// Product service methods
export const productService = {
  getAllProducts: async () => {
    return await productApi.get('/products');
  },
  
  getProduct: async (id) => {
    return await productApi.get(`/products/${id}`);
  },
  
  getProductsByCategory: async (categoryId) => {
    return await productApi.get(`/categories/${categoryId}/products`);
  }
};

// Order service methods
export const orderService = {
  createOrder: async (orderData) => {
    return await orderApi.post('/orders', orderData);
  },
  
  getOrders: async () => {
    return await orderApi.get('/orders');
  },
  
  getOrder: async (id) => {
    return await orderApi.get(`/orders/${id}`);
  }
};
```

## Best Practices

1. **Container Design**
   - Use distroless or minimal base images
   - Follow the single responsibility principle
   - Optimize Dockerfile for layer caching
   - Implement proper health checks
   - Handle graceful shutdowns (SIGTERM)
   - Keep container images small

2. **Performance Optimization**
   - Configure appropriate memory and CPU limits
   - Minimize container startup time
   - Implement connection pooling for databases
   - Use caching when appropriate
   - Scale container instances based on actual load
   - Use concurrency settings effectively

3. **Security**
   - Use dedicated service accounts with minimal permissions
   - Store secrets in Secret Manager
   - Enable binary authorization if needed
   - Implement proper authentication and authorization
   - Scan container images for vulnerabilities
   - Follow the principle of least privilege

4. **Cost Optimization**
   - Use CPU throttling for background services
   - Scale to zero when possible
   - Use min instances only for critical services
   - Monitor and set budget alerts
   - Optimize container image size
   - Use instance concurrency to handle multiple requests

5. **Networking and Connectivity**
   - Use VPC Service Controls for additional security
   - Use VPC connectors for private services
   - Implement proper service-to-service authentication
   - Configure appropriate connection timeouts
   - Implement retry logic for network failures
   - Use Cloud CDN for static content

## Common Issues and Troubleshooting

### Container Startup Problems
- Check container logs in Cloud Logging
- Verify correct environment variables
- Ensure the container listens on the correct port (defaults to 8080)
- Check for permissions issues with service accounts
- Review memory and CPU limits

### Connection Issues
- Verify VPC connector configuration
- Check firewall rules
- Ensure IAM permissions are set correctly
- Verify service accounts have appropriate permissions
- Check Cloud SQL connection settings

### Performance Problems
- Review concurrency settings
- Check for memory leaks
- Monitor CPU and memory usage
- Verify database connection pooling
- Look for slow external API calls
- Implement proper caching

### Deployment Failures
- Check for errors in Cloud Build logs
- Verify container can be pulled from registry
- Ensure build process completes successfully
- Review resource quota limitations
- Check for syntax errors in configuration

## Further Reading

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run vs Cloud Functions](https://cloud.google.com/blog/products/serverless/when-to-use-cloud-functions-vs-cloud-run)
- [Terraform Google Cloud Run Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service)
- [Best Practices for Cloud Run](https://cloud.google.com/run/docs/best-practices)
- [Cloud Run Samples](https://github.com/GoogleCloudPlatform/cloud-run-samples)