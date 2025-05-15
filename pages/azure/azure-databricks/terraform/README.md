# Azure Databricks Terraform Configuration

This guide provides best practices for using Terraform with Azure Databricks as of 2025. It includes authentication methods, cluster provisioning, notebook deployment, and job scheduling.

## Authentication Methods

Create a file named `auth.tf` with one of the following authentication methods.

### Option 1: Databricks CLI Profile Authentication (Recommended for Local Development)

```hcl
variable "databricks_connection_profile" {
  description = "The name of the Databricks connection profile to use."
  type        = string
  default     = "DEFAULT"
}

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.41.0"  # Always specify version constraints
    }
  }
  
  # Best practice: Define backend for state management
  backend "azurerm" {
    # Configure with backend.tfvars or environment variables
  }
}

provider "databricks" {
  profile = var.databricks_connection_profile
}

data "databricks_current_user" "me" {}
```

### Option 2: Environment Variable Authentication (Recommended for CI/CD)

```hcl
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.41.0"
    }
  }
  
  backend "azurerm" {}
}

# Environment variables required:
# DATABRICKS_HOST
# DATABRICKS_TOKEN or DATABRICKS_CLIENT_ID, DATABRICKS_CLIENT_SECRET, etc.
provider "databricks" {}

data "databricks_current_user" "me" {}
```

### Option 3: Azure CLI Authentication (Recommended for Azure DevOps)

```hcl
variable "databricks_host" {
  description = "The Azure Databricks workspace URL."
  type        = string
}

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.41.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
  }
  
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = var.databricks_host
  azure_client_id             = var.client_id         # Optional: For service principal
  azure_client_secret         = var.client_secret     # Optional: For service principal
  azure_tenant_id             = var.tenant_id         # Optional: For service principal
  azure_use_msi               = var.use_msi           # Optional: For managed identity
}

data "databricks_current_user" "me" {}
```

### Option 4: Azure Workload Identity Federation (Recommended for Production)

```hcl
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.41.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Uses workload identity when running in AKS with proper configuration
}

provider "databricks" {
  host = var.databricks_host
  azure_workspace_resource_id = var.workspace_id
  # Uses workload identity when properly configured
}

data "databricks_current_user" "me" {}
```

## Variable Files

Create `auth.auto.tfvars` to provide authentication variables:

```hcl
# For CLI profile authentication
databricks_connection_profile = "DEFAULT"

# For Azure CLI authentication
databricks_host = "https://<workspace-name>.azuredatabricks.net"
```

For production, consider using environment variables or a secret management solution instead of `.tfvars` files.

## Cluster Configuration

Create `cluster.tf` with the following content:

### Modern Cluster Configuration with Unity Catalog

```hcl
variable "cluster_name" {
  description = "A name for the cluster"
  type        = string
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity"
  type        = number
  default     = 20  # Shorter idle timeouts save costs
}

variable "cluster_num_workers" {
  description = "The number of workers"
  type        = number
}

variable "cluster_data_security_mode" {
  description = "Security mode for the cluster"
  type        = string
  validation {
    condition     = contains(["NONE", "SINGLE_USER", "USER_ISOLATION", "LEGACY_SINGLE_USER", "LEGACY_TABLE_ACL"], var.cluster_data_security_mode)
    error_message = "Must be a valid security mode"
  }
}

variable "spark_version" {
  description = "Databricks Runtime version"
  type        = string
  default     = null  # Use data source to find latest version
}

variable "spark_conf" {
  description = "Custom Spark configuration properties"
  type        = map(string)
  default     = {
    "spark.databricks.delta.preview.enabled" = "true"
    "spark.sql.adaptive.enabled" = "true"
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {
    "Environment" = "Development"
    "ManagedBy"   = "Terraform"
  }
}

# Find the smallest node type with local disk
data "databricks_node_type" "smallest" {
  local_disk  = true
  min_memory_gb = 8  # Minimum specs for performance
  category    = "General Purpose"
}

# Use the latest LTS runtime version
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  
  # Optionally filter for ML or Genomics runtime
  # ml = true
  # genomics = true
}

resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  node_type_id            = data.databricks_node_type.smallest.id
  spark_version           = coalesce(var.spark_version, data.databricks_spark_version.latest_lts.id)
  autotermination_minutes = var.cluster_autotermination_minutes
  num_workers             = var.cluster_num_workers
  data_security_mode      = var.cluster_data_security_mode
  
  spark_conf              = var.spark_conf
  
  # Best practice: Enable autoscaling for cost efficiency
  autoscale {
    min_workers = max(1, var.cluster_num_workers - 2)
    max_workers = var.cluster_num_workers
  }
  
  # Best practice: Use instance pools for faster startup
  instance_pool_id = var.instance_pool_id
  
  custom_tags = var.tags
  
  # Best practice: Implement init scripts for consistent configuration
  init_scripts {
    dbfs {
      destination = "dbfs:/databricks/scripts/cluster-init.sh"
    }
  }
  
  # Best practice: Enable Photon for better price/performance
  photon_enabled = true
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to these attributes after creation
      spark_conf["spark.databricks.cluster.profile"],
      spark_conf["spark.databricks.repl.allowedLanguages"],
    ]
  }
}

output "cluster_url" {
  value = databricks_cluster.this.url
}

output "cluster_id" {
  value = databricks_cluster.this.id
}
```

### All-Purpose Cluster Configuration

```hcl
variable "cluster_name" {
  description = "A name for the cluster"
  type        = string
  default     = "My Development Cluster"
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity"
  type        = number
  default     = 30
}

variable "cluster_num_workers" {
  description = "The number of workers"
  type        = number
  default     = 1
}

# Create the cluster with appropriate resources
data "databricks_node_type" "smallest" {
  local_disk  = true
  min_memory_gb = 8
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  node_type_id            = data.databricks_node_type.smallest.id
  spark_version           = data.databricks_spark_version.latest_lts.id
  autotermination_minutes = var.cluster_autotermination_minutes
  
  # Single-node cluster for development
  spark_conf = {
    "spark.master" = "local[*]"
    "spark.databricks.cluster.profile" = "singleNode"
  }
  
  # Use single node
  num_workers = 0
  
  custom_tags = {
    "ResourceClass" = "SingleNode"
    "Environment"   = "Development"
  }
}

output "cluster_url" {
  value = databricks_cluster.this.url
}
```

## Notebook Configuration

Create `notebook.tf` with the following content:

```hcl
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook"
  type        = string
  default     = "Terraform"
}

variable "notebook_filename" {
  description = "The notebook's filename"
  type        = string
}

variable "notebook_language" {
  description = "The language of the notebook"
  type        = string
  validation {
    condition     = contains(["PYTHON", "SCALA", "SQL", "R"], var.notebook_language)
    error_message = "Must be a valid notebook language (PYTHON, SCALA, SQL, R)"
  }
}

variable "notebook_format" {
  description = "The format of the notebook source"
  type        = string
  default     = "SOURCE"
  validation {
    condition     = contains(["SOURCE", "HTML", "JUPYTER"], var.notebook_format)
    error_message = "Must be a valid notebook format (SOURCE, HTML, JUPYTER)"
  }
}

resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename}"
  language = var.notebook_language
  format   = var.notebook_format
  source   = "./${var.notebook_filename}"
  
  # Optional: Define access control
  # access_control {
  #   group_name       = "data_scientists"
  #   permission_level = "CAN_EDIT"
  # }
}

output "notebook_url" {
 value = databricks_notebook.this.url
}
```

## Job Configuration

Create `job.tf` with the following content:

```hcl
variable "job_name" {
  description = "A name for the job"
  type        = string
  default     = "Terraform Managed Job"
}

variable "job_schedule" {
  description = "Cron schedule for the job"
  type        = string
  default     = "0 0 * * *"  # Daily at midnight
}

variable "job_timeout_seconds" {
  description = "Job timeout in seconds"
  type        = number
  default     = 3600  # 1 hour
}

resource "databricks_job" "this" {
  name = var.job_name
  
  # Best practice: Use job clusters instead of existing clusters
  job_cluster {
    job_cluster_key = "main_cluster"
    
    new_cluster {
      spark_version       = data.databricks_spark_version.latest_lts.id
      node_type_id        = data.databricks_node_type.smallest.id
      num_workers         = var.cluster_num_workers
      data_security_mode  = var.cluster_data_security_mode
      spark_conf          = var.spark_conf
      custom_tags         = var.tags
    }
  }
  
  # Run a notebook task
  task {
    task_key = "main_task"
    job_cluster_key = "main_cluster"
    
    notebook_task {
      notebook_path = databricks_notebook.this.path
      base_parameters = {
        env = "production"
      }
    }
    
    # Optional additional tasks
    # depends_on {
    #   task_key = "preparation_task"
    # }
  }
  
  # Optional: Schedule for recurring jobs
  schedule {
    quartz_cron_expression = var.job_schedule
    timezone_id = "UTC"
  }
  
  # Email notifications
  email_notifications {
    on_success = [data.databricks_current_user.me.user_name]
    on_failure = [data.databricks_current_user.me.user_name]
    on_start   = []  # Reduce notification noise
  }
  
  timeout_seconds = var.job_timeout_seconds
  max_retries     = 1
  
  git_source {
    url      = "https://github.com/my-org/my-repo"
    provider = "gitHub"
    branch   = "main"
  }
}

output "job_url" {
  value = databricks_job.this.url
}
```

## Terraform Deployment

Run the following commands to deploy your infrastructure:

```bash
# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply
```

## Best Practices (2025)

1. **Use Remote State Management**: Configure an Azure Storage backend for state files
2. **Implement CI/CD Pipelines**: Automate deployments with GitHub Actions or Azure DevOps
3. **Module Organization**: Split configurations into reusable modules
4. **Secret Management**: Use Azure Key Vault or GitHub Secrets instead of .tfvars files
5. **Version Constraints**: Always specify version constraints for providers
6. **Zero Downtime Deployments**: Use create_before_destroy and proper dependencies
7. **Cost Controls**: Implement auto-termination and auto-scaling for clusters
8. **Tagging Strategy**: Apply consistent tags for cost tracking and governance
9. **State Locking**: Enable state locking to prevent concurrent modifications
10. **Validation Rules**: Use input validation to prevent misconfigurations


