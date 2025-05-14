# GCP Deployment Scenarios with Terraform

This guide provides practical deployment scenarios for Google Cloud Platform using Terraform, incorporating modern best practices and patterns for 2025.

## GKE Autopilot Cluster

Deploy a production-ready GKE Autopilot cluster with all recommended security features:

```hcl
module "gke_autopilot" {
  source = "./modules/gke-autopilot"

  project_id = var.project_id
  name       = "prod-cluster"
  region     = "europe-west4"
  
  network_config = {
    network_name    = module.vpc.network_name
    subnet_name     = module.vpc.subnet_names["gke"]
    master_ipv4_cidr_block = "172.16.0.0/28"
    enable_private_nodes   = true
    enable_private_endpoint = true
  }

  security_config = {
    enable_workload_identity  = true
    enable_binary_authorization = true
    enable_network_policy    = true
    enable_shielded_nodes   = true
  }

  maintenance_config = {
    maintenance_start_time = "02:00"
    maintenance_end_time   = "06:00"
    maintenance_recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
  }

  monitoring_config = {
    enable_managed_prometheus = true
    enable_system_metrics    = true
    enable_workload_metrics = true
  }

  addons_config = {
    http_load_balancing        = true
    horizontal_pod_autoscaling = true
    network_policy_config      = true
    gcp_filestore_csi_driver  = true
  }

  labels = merge(local.common_labels, {
    environment = "production"
    cluster_type = "autopilot"
  })
}

# Cloud SQL for applications
module "cloud_sql" {
  source = "./modules/cloud-sql"

  name           = "prod-db"
  database_version = "POSTGRES_14"
  region         = var.region

  settings = {
    tier              = "db-custom-8-32768"
    availability_type = "REGIONAL"
    
    backup_configuration = {
      enabled                        = true
      start_time                    = "02:00"
      point_in_time_recovery_enabled = true
      retention_period              = "7"
    }
    
    maintenance_window = {
      day          = 7
      hour         = 2
      update_track = "stable"
    }
    
    ip_configuration = {
      ipv4_enabled        = false
      private_network     = module.vpc.network_self_link
      require_ssl         = true
      allocated_ip_range  = module.vpc.psa_ranges["sql"].range_name
    }
  }

  deletion_protection = true
  
  database_flags = [
    {
      name  = "cloudsql.logical_decoding"
      value = "on"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]
}
```

## Cloud Run with Cloud Build Pipeline

Deploy a serverless application with automated CI/CD:

```hcl
# Cloud Run service with Cloud SQL and Secret Manager integration
module "cloud_run" {
  source = "./modules/cloud-run"

  service_name = "api-service"
  location     = var.region
  project_id   = var.project_id

  container_config = {
    image = "gcr.io/${var.project_id}/api-service:latest"
    
    resources = {
      limits = {
        cpu    = "2"
        memory = "2Gi"
      }
    }
    
    env_vars = {
      ENVIRONMENT = "production"
    }
    
    secrets = {
      DB_PASSWORD = {
        secret_name = "db-password"
        version     = "latest"
      }
    }
  }

  autoscaling_config = {
    min_instances = 1
    max_instances = 10
  }

  vpc_config = {
    connector_name = google_vpc_access_connector.connector.name
    egress         = "PRIVATE_RANGES_ONLY"
  }

  cloud_sql_connections = [
    module.cloud_sql.connection_name
  ]

  ingress_config = {
    ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  }
}

# Cloud Build CI/CD pipeline
module "cloud_build" {
  source = "./modules/cloud-build"

  project_id = var.project_id
  name       = "api-service-pipeline"
  
  github_config = {
    owner = "organization"
    repo  = "api-service"
    branch = "main"
  }

  substitutions = {
    _REGION = var.region
    _SERVICE_NAME = module.cloud_run.service_name
  }

  triggers = {
    push = {
      description = "Push to main branch"
      filename = "cloudbuild.yaml"
      included_files = ["src/**"]
      trigger_template = {
        branch_name = "main"
        repo_name   = "api-service"
      }
    }
  }
}
```

## VPC with Shared VPC Setup

Create a secure networking setup with Shared VPC:

```hcl
module "host_project" {
  source = "./modules/project"

  name            = "network-host"
  project_id      = "network-host-prod"
  billing_account = var.billing_account
  folder_id       = var.network_folder_id

  shared_vpc_host_config = {
    enabled = true
    service_project_ids = [
      module.service_project_1.project_id,
      module.service_project_2.project_id
    ]
  }
}

module "shared_vpc" {
  source = "./modules/vpc"
  
  project_id = module.host_project.project_id
  name       = "shared-vpc"
  
  subnets = [
    {
      name          = "subnet-01"
      ip_cidr_range = "10.10.10.0/24"
      region        = "us-central1"
      secondary_ip_ranges = {
        pods     = "172.16.0.0/20"
        services = "172.16.16.0/24"
      }
    },
    {
      name          = "subnet-02"
      ip_cidr_range = "10.10.20.0/24"
      region        = "us-central1"
      secondary_ip_ranges = {
        pods     = "172.16.32.0/20"
        services = "172.16.48.0/24"
      }
    }
  ]

  firewall_rules = {
    allow_internal = {
      name        = "allow-internal"
      description = "Allow internal traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["10.10.0.0/16"]
      
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
  }

  routes = {
    egress_internet = {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      next_hop_internet = true
    }
  }
}
```

## Cloud Storage with Lifecycle Management

Set up Cloud Storage buckets with intelligent lifecycle management:

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  names     = ["assets", "backups", "archives"]
  
  buckets = {
    assets = {
      location = "EU"
      storage_class = "STANDARD"
      
      versioning = {
        enabled = true
      }
      
      lifecycle_rules = [
        {
          action = {
            type = "SetStorageClass"
            storage_class = "NEARLINE"
          }
          condition = {
            age = 90
            matches_storage_class = ["STANDARD"]
          }
        }
      ]
      
      cors = [{
        origin          = ["https://example.com"]
        method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        response_header = ["*"]
        max_age_seconds = 3600
      }]
    }
    
    backups = {
      location = "EU"
      storage_class = "STANDARD"
      
      lifecycle_rules = [
        {
          action = {
            type = "SetStorageClass"
            storage_class = "COLDLINE"
          }
          condition = {
            age = 180
            matches_storage_class = ["STANDARD", "NEARLINE"]
          }
        },
        {
          action = {
            type = "Delete"
          }
          condition = {
            age = 365
          }
        }
      ]
    }
    
    archives = {
      location = "EU"
      storage_class = "ARCHIVE"
      
      retention_policy = {
        is_locked = true
        retention_period = 31536000 # 1 year
      }
    }
  }
}
```

## Pub/Sub with Cloud Functions

Create an event-driven architecture:

```hcl
module "pubsub" {
  source = "./modules/pubsub"

  project_id = var.project_id
  
  topics = {
    orders = {
      name = "orders"
      
      subscriptions = {
        process_order = {
          name = "process-order"
          ack_deadline_seconds = 20
          
          push_config = {
            push_endpoint = module.cloud_function_orders.trigger_url
            oidc_token = {
              service_account_email = google_service_account.pubsub_invoker.email
            }
          }
          
          retry_policy = {
            minimum_backoff = "10s"
            maximum_backoff = "600s"
          }
          
          dead_letter_policy = {
            dead_letter_topic = module.pubsub.topics["dead_letters"].id
            max_delivery_attempts = 5
          }
        }
      }
    }
  }
}

module "cloud_function_orders" {
  source = "./modules/cloud-function"

  project_id = var.project_id
  name       = "process-orders"
  location   = var.region
  
  runtime               = "nodejs18"
  entry_point          = "processOrder"
  source_directory     = "./functions/process-orders"
  
  environment_variables = {
    TOPIC_NAME = module.pubsub.topics["orders"].name
  }
  
  service_account_email = google_service_account.function_invoker.email
  
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  
  vpc_connector = {
    name = google_vpc_access_connector.connector.name
    egress_settings = "ALL_TRAFFIC"
  }
}
```

## Load Balancer with Cloud CDN

Deploy a global load balancer with CDN:

```hcl
module "global_lb" {
  source = "./modules/load-balancer"

  project_id = var.project_id
  name       = "global-lb"
  
  backend_services = {
    default = {
      protocol    = "HTTPS"
      port_name   = "http"
      timeout_sec = 30
      
      backend_groups = {
        group1 = {
          group = google_compute_instance_group_manager.group1.instance_group
          balancing_mode = "RATE"
          max_rate_per_instance = 100
        }
        group2 = {
          group = google_compute_instance_group_manager.group2.instance_group
          balancing_mode = "RATE"
          max_rate_per_instance = 100
        }
      }
      
      health_check = {
        check_interval_sec = 5
        timeout_sec       = 5
        healthy_threshold   = 2
        unhealthy_threshold = 10
        request_path      = "/health"
      }
      
      cdn_policy = {
        enabled = true
        cache_mode = "USE_ORIGIN_HEADERS"
        default_ttl = 3600
        client_ttl  = 3600
        max_ttl     = 86400
        
        negative_caching = true
        negative_caching_policy = {
          code = 404
          ttl  = 10
        }
        
        signed_url_cache_max_age_sec = 7200
      }
      
      security_policy = google_compute_security_policy.policy.self_link
    }
  }
  
  url_map = {
    default_service = "default"
    
    path_rules = [
      {
        paths   = ["/api/*"]
        service = "api"
      },
      {
        paths   = ["/static/*"]
        service = "static"
      }
    ]
  }
  
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.self_link
  ]
}
```

## Best Practices for GCP

### 1. Resource Organization

```hcl
module "project_factory" {
  source = "./modules/project-factory"

  for_each = {
    prod = {
      name = "production"
      services = ["compute", "container", "cloudsql"]
      folder_id = "folders/123456789"
    }
    staging = {
      name = "staging"
      services = ["compute", "container"]
      folder_id = "folders/987654321"
    }
  }

  billing_account = var.billing_account_id
  org_id         = var.organization_id
  
  name           = each.value.name
  project_id     = "${var.project_prefix}-${each.value.name}"
  folder_id      = each.value.folder_id
  
  activate_apis  = each.value.services
  
  labels = merge(local.common_labels, {
    environment = each.key
  })
}
```

### 2. IAM Best Practices

```hcl
module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
  
  custom_roles = {
    developer = {
      title = "Custom Developer Role"
      description = "Custom role for application developers"
      permissions = [
        "compute.instances.get",
        "container.clusters.get",
        "container.pods.list"
      ]
    }
  }
  
  service_accounts = {
    app = {
      account_id = "app-service"
      display_name = "Application Service Account"
      description = "Service account for application workloads"
      
      iam_roles = [
        "roles/cloudsql.client",
        "roles/secretmanager.secretAccessor"
      ]
    }
  }
  
  bindings = {
    developers = {
      role = "projects/${var.project_id}/roles/developer"
      members = [
        "group:developers@example.com"
      ]
    }
  }
}
```

### 3. Monitoring and Logging

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project_id = var.project_id
  
  notification_channels = {
    email = {
      display_name = "Email Notifications"
      type = "email"
      labels = {
        email_address = "alerts@example.com"
      }
    }
    slack = {
      display_name = "Slack Notifications"
      type = "slack"
      labels = {
        channel_name = "#alerts"
        auth_token   = data.google_secret_manager_secret_version.slack_token.secret_data
      }
    }
  }
  
  alert_policies = {
    high_cpu = {
      display_name = "High CPU Usage"
      documentation = "CPU usage is above 80% for more than 5 minutes"
      
      conditions = {
        cpu = {
          display_name = "CPU Usage > 80%"
          condition_threshold = {
            filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
            duration = "300s"
            comparison = "COMPARISON_GT"
            threshold_value = 0.8
          }
        }
      }
      
      notification_channels = ["email", "slack"]
      user_labels = local.monitoring_labels
    }
  }
  
  log_sinks = {
    storage = {
      name        = "storage-sink"
      destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
      filter      = "resource.type=\"gce_instance\""
      
      exclusions = {
        debug = {
          name        = "exclude-debug"
          filter      = "severity < ERROR"
          description = "Exclude debug and info logs"
        }
      }
    }
  }
}
```