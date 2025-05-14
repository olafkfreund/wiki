# Azure Deployment Scenarios with Terraform

This guide provides practical deployment scenarios for Azure using Terraform, incorporating modern best practices and patterns.

## Landing Zone Deployment

A secure, scalable Azure landing zone implementation:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }
  backend "azurerm" {}
}

module "landing_zone" {
  source = "./modules/landing-zone"

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  location       = var.primary_location

  network_config = {
    hub_vnet_cidr         = "10.0.0.0/16"
    spoke_vnet_cidr       = "10.1.0.0/16"
    enable_vwan           = true
    enable_firewall       = true
    enable_bastion        = true
  }

  security_config = {
    enable_defender         = true
    enable_sentinel        = true
    enable_private_links   = true
    enable_policy         = true
  }

  governance_config = {
    resource_tags = local.common_tags
    enable_cost_management = true
    enable_resource_locks  = true
  }
}
```

## Multi-Region Active-Active Architecture

Deploy highly available services across multiple Azure regions:

```hcl
locals {
  regions = {
    primary = {
      location = "westeurope"
      cidr     = "10.1.0.0/16"
    }
    secondary = {
      location = "northeurope"
      cidr     = "10.2.0.0/16"
    }
  }
}

module "traffic_manager" {
  source = "./modules/traffic-manager"
  
  profile_name = "app-tm-profile"
  endpoints = [
    {
      name      = "primary"
      target    = module.primary_region.app_service_fqdn
      priority  = 1
    },
    {
      name      = "secondary"
      target    = module.secondary_region.app_service_fqdn
      priority  = 2
    }
  ]
}

module "primary_region" {
  source = "./modules/region"
  
  location = local.regions.primary.location
  vnet_cidr = local.regions.primary.cidr
  
  app_service_config = {
    sku             = "P1v3"
    zone_redundant  = true
    auto_scale      = true
  }
}

module "secondary_region" {
  source = "./modules/region"
  
  location = local.regions.secondary.location
  vnet_cidr = local.regions.secondary.cidr
  
  app_service_config = {
    sku             = "P1v3"
    zone_redundant  = true
    auto_scale      = true
  }
}
```

## Secure AKS Deployment

Deploy a production-ready AKS cluster with security best practices:

```hcl
module "aks_cluster" {
  source = "./modules/aks"

  cluster_name = "prod-aks"
  location     = var.location
  
  network_config = {
    vnet_cidr              = "10.0.0.0/16"
    pod_cidr               = "10.244.0.0/16"
    service_cidr          = "10.245.0.0/16"
    enable_network_policy = true
  }

  security_config = {
    enable_azure_policy    = true
    enable_pod_security   = true
    enable_workload_identity = true
    enable_defender       = true
  }

  node_pools = {
    system = {
      vm_size    = "Standard_D4s_v5"
      node_count = 3
      zones      = [1, 2, 3]
    }
    user = {
      vm_size    = "Standard_D8s_v5"
      node_count = 5
      zones      = [1, 2, 3]
    }
  }

  addons = {
    azure_policy                     = true
    azure_key_vault_secrets_provider = true
    open_service_mesh               = true
  }
}

# Private ACR with Managed Identity access
module "container_registry" {
  source = "./modules/acr"

  name                = "prodacr"
  sku                = "Premium"
  enable_private_link = true
  allowed_subnets    = [module.aks_cluster.subnet_id]
}

# Key Vault for secrets management
module "key_vault" {
  source = "./modules/key-vault"

  name                = "prod-kv"
  enable_private_link = true
  allowed_subnets    = [module.aks_cluster.subnet_id]
  
  access_policies = {
    aks = {
      object_id = module.aks_cluster.kubelet_identity_object_id
      key_permissions    = ["Get", "List"]
      secret_permissions = ["Get", "List"]
    }
  }
}
```

## Azure Front Door with Web Apps

Deploy globally distributed web applications:

```hcl
module "front_door" {
  source = "./modules/front-door"

  name = "global-web-app"
  
  frontend_endpoints = {
    default = {
      host_name = "app.example.com"
      waf_policy_id = module.waf_policy.id
    }
  }

  routing_rules = {
    default = {
      accepted_protocols = ["Https"]
      patterns_to_match = ["/*"]
      backend_pool_name = "app-backend"
    }
  }

  backend_pools = {
    app-backend = {
      backends = [
        {
          address = module.webapp_eu.default_site_hostname
          weight  = 100
          enabled = true
        },
        {
          address = module.webapp_us.default_site_hostname
          weight  = 100
          enabled = true
        }
      ]
      health_probe_settings = {
        protocol = "Https"
        path     = "/health"
      }
    }
  }
}

module "waf_policy" {
  source = "./modules/waf-policy"

  name     = "global-waf"
  mode     = "Prevention"
  
  managed_rules = {
    enable_core_ruleset = true
    enable_php_ruleset  = true
  }

  custom_rules = {
    rate_limiting = {
      priority = 1
      rule_type = "RateLimiting"
      match_conditions = {
        match_variables = [{
          variable_name = "RemoteAddr"
        }]
      }
      rate_limit_duration = "MINUTE"
      rate_limit_threshold = 100
    }
  }
}
```

## Azure Database Deployment

Deploy a highly available database with geo-replication:

```hcl
module "database" {
  source = "./modules/azure-sql"

  name                = "prod-sql"
  location           = var.primary_location
  dr_location        = var.secondary_location
  
  networking = {
    enable_private_endpoint = true
    allowed_subnets        = var.app_subnet_ids
  }

  high_availability = {
    enable_zone_redundancy = true
    enable_geo_replication = true
    failover_group_name   = "prod-sql-fog"
  }

  security = {
    enable_auditing      = true
    enable_threat_detection = true
    enable_data_encryption = true
  }

  performance = {
    sku_name            = "GP_Gen5_8"
    max_size_gb         = 256
    auto_pause_delay    = 60
    min_capacity       = 4
  }

  maintenance = {
    window_start_hour   = 2
    window_duration_hrs = 4
  }
}
```

## Best Practices for Azure Deployments

### 1. Resource Naming and Tagging

```hcl
locals {
  required_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.team_name
    CostCenter  = var.cost_center
    CreatedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "example" {
  name     = format("%s-%s-%s-rg", var.prefix, var.environment, var.purpose)
  location = var.location
  tags     = local.required_tags
}
```

### 2. Network Security

```hcl
module "network_security" {
  source = "./modules/network-security"

  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location

  network_watcher_enabled = true
  ddos_protection_enabled = true
  
  flow_logs_enabled = true
  flow_logs_retention = 30

  nsg_rules = {
    deny_all_inbound = {
      priority = 4096
      direction = "Inbound"
      access = "Deny"
      protocol = "*"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  }
}
```

### 3. Monitoring and Alerting

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location

  log_analytics_workspace = {
    sku                 = "PerGB2018"
    retention_in_days   = 30
  }

  action_groups = {
    critical = {
      short_name = "critical"
      email_receivers = [{
        name = "ops-team"
        email_address = "ops@example.com"
      }]
    }
  }

  metric_alerts = {
    high_cpu = {
      name = "high-cpu-usage"
      description = "Alert when CPU usage is high"
      metric_namespace = "Microsoft.Compute/virtualMachines"
      metric_name = "Percentage CPU"
      aggregation = "Average"
      operator = "GreaterThan"
      threshold = 90
      window_size = "PT5M"
      frequency = "PT1M"
      severity = 1
      action_group_id = module.monitoring.action_group_ids["critical"]
    }
  }
}
```

## CI/CD Pipeline Integration

### Azure DevOps Pipeline

```yaml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - terraform/**

variables:
  - group: terraform-variables

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Validate
  jobs:
  - job: ValidateAndPlan
    steps:
    - task: TerraformInstaller@1
      inputs:
        terraformVersion: 'latest'
    
    - task: TerraformTaskV4@4
      inputs:
        provider: 'azurerm'
        command: 'init'
        backendServiceArm: 'Azure-Service-Connection'
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'tfstate'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: '$(Environment).tfstate'
    
    - task: TerraformTaskV4@4
      inputs:
        provider: 'azurerm'
        command: 'plan'
        environmentServiceNameAzureRM: 'Azure-Service-Connection'

- stage: Apply
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: ApplyChanges
    steps:
    - task: TerraformTaskV4@4
      inputs:
        provider: 'azurerm'
        command: 'apply'
        environmentServiceNameAzureRM: 'Azure-Service-Connection'
        commandOptions: '-auto-approve'
```

## Testing and Validation

### Policy Testing

```hcl
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-resource-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require specified tags on resources"

  metadata = jsonencode({
    version  = "1.0.0"
    category = "Tags"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "tags['Environment']"
          exists = "false"
        },
        {
          field  = "tags['CostCenter']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_assignment" "require_tags" {
  name                 = "require-resource-tags"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Requires specified tags on all resources"
  display_name         = "Require Resource Tags"

  parameters = jsonencode({
    tagNames = {
      value = ["Environment", "CostCenter"]
    }
  })
}
```