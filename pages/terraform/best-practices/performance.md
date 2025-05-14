# Terraform Performance Best Practices

A guide to optimizing Terraform performance and resource management.

## State Management Optimization

### Large State File Handling

1. **Split States**
   - Break monolithic states into smaller functional units
   - Use separate states for different components/environments
   - Implement state sharing through data sources

2. **Reduce State Size**
   ```hcl
   terraform {
     required_providers {
       aws = {
         source = "hashicorp/aws"
         version = "~> 4.0"
       }
     }
     # Optimize state operations
     backend "s3" {
       skip_metadata_api_check = true
       skip_region_validation = true
     }
   }
   ```

## Plan and Apply Optimization

### Targeted Operations
```bash
# Target specific resources
terraform plan -target=module.vpc
terraform apply -target=aws_instance.web_server

# Parallel operations
terraform apply -parallel=true -parallelism=20
```

### Resource Dependencies

```hcl
# Explicit dependencies
resource "aws_instance" "web" {
  depends_on = [aws_vpc.main]
}

# Implicit dependencies through references
resource "aws_instance" "web" {
  subnet_id = aws_subnet.main.id  # Implicit dependency
}
```

## Module Performance

### Module Design

1. **Minimize Module Complexity**
   ```hcl
   # Good: Focused module
   module "vpc" {
     source = "./modules/vpc"
     cidr_block = var.vpc_cidr
   }

   # Separate module for subnets
   module "subnets" {
     source = "./modules/subnets"
     vpc_id = module.vpc.vpc_id
   }
   ```

2. **Use Data Sources Efficiently**
   ```hcl
   # Cache data source results in locals
   locals {
     availability_zones = data.aws_availability_zones.available.names
   }
   ```

## Resource Creation Optimization

### Parallel Resource Creation

1. **Remove Unnecessary Dependencies**
   ```hcl
   # Instead of this
   resource "aws_instance" "web" {
     depends_on = [aws_vpc.main, aws_subnet.main, aws_security_group.web]
   }

   # Use this
   resource "aws_instance" "web" {
     subnet_id = aws_subnet.main.id  # Only necessary dependency
     vpc_security_group_ids = [aws_security_group.web.id]
   }
   ```

2. **Batch Resource Creation**
   ```hcl
   # Use count or for_each for batch operations
   resource "aws_instance" "web" {
     count = var.instance_count
     ami   = var.ami_id
     instance_type = var.instance_type
   }
   ```

## Provider Configuration

### Provider Optimization

```hcl
provider "aws" {
  # Reduce API calls
  skip_get_ec2_platforms = true
  skip_metadata_api_check = true
  skip_region_validation = true
  
  # Configure retries
  max_retries = 5
}
```

## Data Loading

### Efficient Data Sources

```hcl
# Use specific data source queries
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Cache repeated lookups
locals {
  ami_id = data.aws_ami.ubuntu.id
}
```

## Variable Management

### Optimize Variable Usage

```hcl
# Use maps for lookups instead of multiple conditionals
locals {
  instance_types = {
    dev  = "t3.micro"
    test = "t3.small"
    prod = "t3.medium"
  }
  
  selected_instance_type = local.instance_types[var.environment]
}
```

## Testing and Validation

### Performance Testing

1. **Benchmark Commands**
   ```bash
   time terraform plan
   time terraform apply -auto-approve
   ```

2. **Profile Terraform Operations**
   ```bash
   TF_LOG=trace terraform plan
   ```

## Memory Management

### Memory Optimization

1. **Workspace Cleanup**
   ```bash
   # Regular cleanup
   rm -rf .terraform/providers
   terraform init -upgrade
   ```

2. **Provider Plugin Caching**
   ```bash
   # Enable plugin caching
   export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
   ```

## Performance Monitoring

### Monitoring Strategies

1. **Execution Time Tracking**
   - Monitor plan/apply duration
   - Track state file size growth
   - Monitor API rate limits

2. **Resource Creation Time**
   ```hcl
   locals {
    start_time = timestamp()
   }

   output "execution_time" {
     value = format("Execution time: %s", formatdate("DD/MM/YYYY hh:mm:ss", local.start_time))
   }
   ```

## Best Practices Checklist

- [ ] State files optimally sized and split
- [ ] Unnecessary dependencies removed
- [ ] Provider configurations optimized
- [ ] Data source usage optimized
- [ ] Resource creation parallelized where possible
- [ ] Variables efficiently structured
- [ ] Regular performance monitoring implemented
- [ ] Plugin caching configured
- [ ] Regular cleanup procedures established
- [ ] Performance metrics tracked