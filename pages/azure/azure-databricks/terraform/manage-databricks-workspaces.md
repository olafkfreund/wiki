# Manage Databricks Workspaces

This guide explains how to manage Azure Databricks workspaces using Terraform as of 2025, following the latest best practices.

## Provider Configuration

The following configuration blocks initialize the most common variables, [databricks_spark_version](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version), [databricks_node_type](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/node_type), and [databricks_current_user](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/current_user).

```hcl
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
  # Auth configuration can be provided via environment variables
  # or through the options below
  
  # Option 1: Use Azure CLI authentication
  # azure_use_msi = true
  
  # Option 2: Azure Workload Identity Federation (recommended for production)
  # azure_client_id      = var.client_id
  # azure_tenant_id      = var.tenant_id
  # azure_client_secret  = var.client_secret
}

data "databricks_current_user" "me" {}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true  # Using LTS versions is recommended for production
}

# Find appropriate node type based on requirements
data "databricks_node_type" "smallest" {
  local_disk    = true
  min_memory_gb = 8        # Setting minimum performance criteria
  category      = "General Purpose"
}
```

## Standard Functionality

These resources do not require administrative privileges. More documentation is available at the dedicated pages [databricks_secret_scope](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope), [databricks_token](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token), [databricks_secret](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret), [databricks_notebook](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/notebook), [databricks_job](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/job), [databricks_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster), [databricks_cluster_policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy), [databricks_instance_pool](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/instance_pool).

```hcl
# Create a secret scope with proper naming convention
resource "databricks_secret_scope" "this" {
  name        = "demo-${data.databricks_current_user.me.alphanumeric}"
  # Best practice: Use Azure Key Vault backed secret scope for production
  # backend_type = "AZURE_KEYVAULT"
  # azure_keyvault {
  #   resource_id = azurerm_key_vault.example.id
  #   dns_name    = azurerm_key_vault.example.vault_uri
  # }
}

# Best practice: Limit token lifetime and use descriptive comments
resource "databricks_token" "pat" {
  comment          = "Created by Terraform for ${var.environment} environment"
  lifetime_seconds = 2592000  # 30 days max, rotate regularly
}

resource "databricks_secret" "token" {
  string_value = databricks_token.pat.token_value
  scope        = databricks_secret_scope.this.name
  key          = "token"
}

# Use source control for notebooks in production
resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/Terraform"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
    # Best practice: Use secrets for sensitive information
    token = dbutils.secrets.get('${databricks_secret_scope.this.name}', '${databricks_secret.token.key}')
    print(f'This should be redacted: {token}')
    
    # Add proper error handling in production notebooks
    try:
      # Your code here
      print("Processing data...")
    except Exception as e:
      print(f"Error: {e}")
      raise
    EOT
  )
  
  # Best practice: Tag resources for better organization
  metadata_base64 = base64encode(jsonencode({
    "tags": ["managed-by-terraform", "environment:${var.environment}"]
  }))
}

# Best practice: Use job clusters instead of existing clusters for jobs
resource "databricks_job" "this" {
  name = "Terraform Demo (${data.databricks_current_user.me.alphanumeric})"
  
  job_cluster {
    job_cluster_key = "main-cluster"
    
    new_cluster {
      num_workers   = 1  # Use autoscaling for production workloads
      spark_version = data.databricks_spark_version.latest_lts.id
      node_type_id  = data.databricks_node_type.smallest.id
      
      # Best practice: Apply consistent tags
      custom_tags = {
        "Environment"     = var.environment
        "ManagedBy"       = "Terraform"
        "Department"      = var.department
        "CostCenter"      = var.cost_center
      }
      
      spark_conf = {
        # Enable Delta optimizations
        "spark.databricks.delta.optimizeWrite.enabled" = "true"
        "spark.databricks.delta.autoCompact.enabled"   = "true"
      }
      
      # Enable Photon for better performance
      photon_enabled = true
    }
  }

  task {
    task_key = "main"
    job_cluster_key = "main-cluster"
    
    notebook_task {
      notebook_path = databricks_notebook.this.path
      base_parameters = {
        "environment" = var.environment
      }
    }
    
    email_notifications {
      on_success = [data.databricks_current_user.me.user_name]
      on_failure = [data.databricks_current_user.me.user_name]
    }
  }

  # Schedule with proper timezone configuration
  schedule {
    quartz_cron_expression = "0 0 10 ? * MON-FRI"  # Weekdays at 10:00 AM
    timezone_id = "UTC"
  }
  
  # Define retry policy
  max_retries = 2
  retry_on_timeout = true
  
  # Set expectations and timeout for mission-critical jobs
  timeout_seconds = 3600  # 1 hour timeout
  
  # Best practice: Git source integration for CI/CD
  git_source {
    url      = "https://github.com/your-organization/your-repo"
    provider = "gitHub"
    branch   = "main"
  }
}

# Best practice: Use cluster policies to enforce standards
resource "databricks_cluster" "this" {
  cluster_name            = "Exploration (${data.databricks_current_user.me.alphanumeric})"
  spark_version           = data.databricks_spark_version.latest_lts.id
  instance_pool_id        = databricks_instance_pool.smallest_nodes.id
  policy_id               = databricks_cluster_policy.this.id
  autotermination_minutes = 20
  
  # Best practice: Enable autoscaling for cost efficiency
  autoscale {
    min_workers = 1
    max_workers = 10
  }
  
  # Enable Photon for better query performance
  photon_enabled = true
  
  # Use init scripts for consistent configuration
  init_scripts {
    dbfs {
      destination = "dbfs:/databricks/scripts/init-cluster.sh"
    }
  }
  
  custom_tags = {
    "Environment"     = var.environment
    "ManagedBy"       = "Terraform"
    "Department"      = var.department
    "CostCenter"      = var.cost_center
  }
}

# Best practice: Define standard cluster policies for governance and cost control
resource "databricks_cluster_policy" "this" {
  name = "Minimal (${data.databricks_current_user.me.alphanumeric})"
  definition = jsonencode({
    "dbus_per_hour": {
      "type": "range",
      "maxValue": 10
    },
    "autotermination_minutes": {
      "type": "fixed",
      "value": 20,
      "hidden": true
    },
    "spark_version": {
      "type": "allowlist",
      "values": [data.databricks_spark_version.latest_lts.id],
      "defaultValue": data.databricks_spark_version.latest_lts.id
    },
    "instance_pool_id": {
      "type": "fixed",
      "value": databricks_instance_pool.smallest_nodes.id,
      "hidden": false
    }
  })
}

# Best practice: Use instance pools for faster cluster startup times
resource "databricks_instance_pool" "smallest_nodes" {
  instance_pool_name = "Smallest Nodes (${data.databricks_current_user.me.alphanumeric})"
  min_idle_instances = 0
  max_capacity       = 30
  node_type_id       = data.databricks_node_type.smallest.id
  preloaded_spark_versions = [
    data.databricks_spark_version.latest_lts.id
  ]

  # Reduce idle time costs
  idle_instance_autotermination_minutes = 20
  
  # Apply consistent tags
  custom_tags = {
    "Environment" = var.environment
    "ManagedBy"   = "Terraform"
  }
  
  # Azure-specific settings for disk type and encryption
  azure_attributes {
    availability       = "SPOT_AZURE"  # Use Spot instances for cost savings
    spot_bid_max_price = 100           # Set maximum price as percentage
  }
}

output "notebook_url" {
  value = databricks_notebook.this.url
}

output "job_url" {
  value = databricks_job.this.url
}
```

## Workspace Security

Managing security requires administrative privileges. More documentation is available at the dedicated pages [databricks_secret_acl](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl), [databricks_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group), [databricks_user](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user), [databricks_group_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member), [databricks_permissions](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions).

```hcl
# Best practice: Use groups instead of individual permissions
resource "databricks_group" "spectators" {
  display_name = "Spectators (by ${data.databricks_current_user.me.alphanumeric})"
  
  # Optionally sync with Azure AD groups in production
  # external_id = "AAD-GROUP-ID"
}

# Best practice: Follow least privilege principle
resource "databricks_secret_acl" "spectators" {
  principal  = databricks_group.spectators.display_name
  scope      = databricks_secret_scope.this.name
  permission = "READ"
}

# Manage users systematically
resource "databricks_user" "dummy" {
  user_name    = "dummy+${data.databricks_current_user.me.alphanumeric}@example.com"
  display_name = "Dummy ${data.databricks_current_user.me.alphanumeric}"
  
  # For production sync with identity provider:
  # external_id = "AAD-USER-ID"
  
  # Best practice: Set expiration for service accounts
  # disable_as_user_deletion = true
}

# Assign users to groups rather than direct permissions
resource "databricks_group_member" "a" {
  group_id  = databricks_group.spectators.id
  member_id = databricks_user.dummy.id
}

# Set granular permissions based on role 
resource "databricks_permissions" "notebook" {
  notebook_path = databricks_notebook.this.id
  
  # Define access control for users
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "CAN_RUN"
  }
  
  # Define access control for groups
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_READ"
  }
}

# Configure job permissions
resource "databricks_permissions" "job" {
  job_id = databricks_job.this.id
  
  # Best practice: Limit ownership to specific users/groups
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "IS_OWNER"
  }
  
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_MANAGE_RUN"
  }
}

# Define cluster access permissions
resource "databricks_permissions" "cluster" {
  cluster_id = databricks_cluster.this.id
  
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "CAN_RESTART"
  }
  
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_ATTACH_TO"
  }
}

# Apply policy permissions
resource "databricks_permissions" "policy" {
  cluster_policy_id = databricks_cluster_policy.this.id
  
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_USE"
  }
}

# Configure instance pool permissions
resource "databricks_permissions" "pool" {
  instance_pool_id = databricks_instance_pool.smallest_nodes.id
  
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_ATTACH_TO"
  }
}

# Unity Catalog integration - 2025 best practice
resource "databricks_metastore" "this" {
  name = "primary-metastore"
  storage_root = "abfss://container@accountname.dfs.core.windows.net/metastore"
  # delta_sharing_scope = "INTERNAL_AND_EXTERNAL"
}

# Create a Unity Catalog catalog
resource "databricks_catalog" "sandbox" {
  metastore_id = databricks_metastore.this.id
  name         = "sandbox"
  comment      = "Sandbox catalog for development and testing"
  
  properties = {
    purpose = "development"
  }
}

# Manage fine-grained permissions
resource "databricks_grants" "sandbox" {
  catalog = databricks_catalog.sandbox.name
  
  grant {
    principal  = databricks_group.spectators.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA"]
  }
}
```

## Advanced Configuration

Use these configurations for network security and advanced workspace settings.

```hcl
# Get the current IP for IP access list configuration
data "http" "my_ip" {
  url = "https://ifconfig.me"
}

# Enable IP access lists
resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists": "true"
    
    # Enable improved security features
    "enableTokensConfig": "true"
    "maxTokenLifetimeDays": "30"
    "enableWorkspaceFilesystem": "false"  # Disable DBFS UI for security
    
    # Enable Unity Catalog for the workspace
    "enableUnifiedCatalog": "true"
  }
}

# Create IP access list for restricted access
resource "databricks_ip_access_list" "only_me" {
  label      = "only ${data.http.my_ip.body} is allowed to access workspace"
  list_type  = "ALLOW"
  ip_addresses = ["${data.http.my_ip.body}/32"]
  depends_on = [databricks_workspace_conf.this]
}

# Configure token usage permissions (2025 feature)
resource "databricks_token_usage" "service_principal" {
  application_id = var.service_principal_app_id
  comment        = "Service Principal used for CI/CD"
  permission     = "USER_API"
}

# Configure Private Link for secure connectivity
resource "databricks_mws_private_access_settings" "this" {
  private_access_settings_name = "Private-Link"
  region                       = var.region
  public_access_enabled        = false
}

# Configure automated PAT rotation using Azure Key Vault
resource "azurerm_key_vault_secret" "pat" {
  name         = "databricks-pat"
  value        = databricks_token.pat.token_value
  key_vault_id = azurerm_key_vault.example.id
  
  # Set expiration time
  expiration_date = timeadd(timestamp(), "720h")  # 30 days
}

# Configure audit logs export to Azure Log Analytics
resource "databricks_workspace_conf" "audit" {
  custom_config = {
    "enableAuditLogs": "true"
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "databricks-logs-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Export logs using Azure Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "databricks-diagnostics"
  target_resource_id         = var.databricks_workspace_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  
  enabled_log {
    category = "audit"
    
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
```

## Best Practices for Workspace Management (2025)

1. **Follow Least Privilege Principle**: Grant minimal permissions required for each role
2. **Use Instance Pools**: Reduce cluster start times and optimize costs
3. **Implement Cluster Policies**: Enforce governance and cost controls
4. **Enable Unity Catalog**: Manage data governance and security at the object level
5. **Leverage Azure DevOps or GitHub Actions**: Automate Terraform deployments
6. **Use Service Principals**: Avoid personal tokens for automation
7. **Implement Network Security**: Configure IP access lists and Private Link
8. **Monitor with Log Analytics**: Export audit logs for security monitoring
9. **Rotate Secrets Regularly**: Set up automated token rotation
10. **Use Spot Instances**: Reduce costs for non-production workloads
11. **Tag All Resources**: Improve cost tracking and resource organization
12. **Implement GitOps**: Source control all infrastructure and code

For production environments, consider deploying Databricks in an Azure landing zone with proper network isolation, automated CI/CD pipelines, and comprehensive monitoring.
