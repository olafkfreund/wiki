---
description: Deploying and managing Google Cloud DNS for domain and DNS hosting
---

# Cloud DNS

Google Cloud DNS is a high-performance, resilient, global Domain Name System (DNS) service that publishes your domain names to the global DNS in a cost-effective way. Cloud DNS translates requests for domain names like "www.example.com" into IP addresses like "192.0.2.1".

## Key Features

- **Global Anycast**: Global network of anycast name servers for low-latency DNS resolution
- **High Availability**: 100% uptime SLA with automatic failover
- **Scalability**: Handle millions of DNS queries
- **Security**: DNSSEC support for zone signing and validation
- **Public and Private Zones**: Support for both public internet domains and private VPC DNS
- **Managed Service**: No need to provision or manage DNS servers
- **Cloud Integration**: Works with other GCP services for automatic DNS record management
- **Programmatic Management**: Full API, gcloud, and Terraform support
- **Logging**: Query logging for auditing and analytics
- **Flexible Pricing**: Pay only for hosted zones and queries

## Deploying Cloud DNS with Terraform

### Basic Public Zone Configuration

```hcl
resource "google_dns_managed_zone" "example_zone" {
  name        = "example-zone"
  dns_name    = "example.com."
  description = "Example public DNS zone"
  
  # Default visibility is "public"
  
  labels = {
    environment = "production"
  }
}

# Create an A record
resource "google_dns_record_set" "a_record" {
  name         = "www.example.com."
  managed_zone = google_dns_managed_zone.example_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["203.0.113.1"]
}

# Create a CNAME record
resource "google_dns_record_set" "cname_record" {
  name         = "mail.example.com."
  managed_zone = google_dns_managed_zone.example_zone.name
  type         = "CNAME"
  ttl          = 300
  
  rrdatas = ["ghs.googlehosted.com."]
}

# Create MX records for email
resource "google_dns_record_set" "mx_record" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.example_zone.name
  type         = "MX"
  ttl          = 3600
  
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com."
  ]
}

# Create TXT records for verification and SPF
resource "google_dns_record_set" "txt_record" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.example_zone.name
  type         = "TXT"
  ttl          = 3600
  
  rrdatas = [
    "\"v=spf1 include:_spf.google.com ~all\"",
    "\"google-site-verification=abcdefghijklmnopqrstuvwxyz\""
  ]
}

# Output the name servers
output "name_servers" {
  description = "Cloud DNS name servers for this zone"
  value       = google_dns_managed_zone.example_zone.name_servers
}
```

### Private DNS Zone Configuration

```hcl
# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

# Create a private DNS zone
resource "google_dns_managed_zone" "private_zone" {
  name        = "private-example-zone"
  dns_name    = "internal.example."
  description = "Private DNS zone for internal services"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

# Create A records for internal services
resource "google_dns_record_set" "api_record" {
  name         = "api.internal.example."
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.0.10"]
}

resource "google_dns_record_set" "db_record" {
  name         = "db.internal.example."
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.0.20"]
}

# Service discovery via SRV records
resource "google_dns_record_set" "service_discovery" {
  name         = "_grpc._tcp.internal.example."
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "SRV"
  ttl          = 300
  
  rrdatas = [
    "0 1 8080 service-a.internal.example.",
    "0 1 8080 service-b.internal.example."
  ]
}
```

### DNSSEC Configuration 

```hcl
resource "google_dns_managed_zone" "secure_zone" {
  name        = "secure-example-zone"
  dns_name    = "secure.example."
  description = "Secure DNS zone with DNSSEC enabled"
  
  dnssec_config {
    state = "on"
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "zoneSigning"
    }
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
    }
  }
}

# Output DNSSEC information
output "dnssec_info" {
  description = "DNSSEC DS record information"
  value       = google_dns_managed_zone.secure_zone.dnssec_config
}
```

### Cloud DNS Peering Configuration

```hcl
# Create two VPC networks to demonstrate DNS peering
resource "google_compute_network" "network_a" {
  name                    = "network-a"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_b" {
  name                    = "network-b" 
  auto_create_subnetworks = false
}

# Create subnets
resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.network_a.id
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-b"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.network_b.id
}

# DNS zone for network A
resource "google_dns_managed_zone" "network_a_dns" {
  name        = "network-a-dns"
  dns_name    = "services-a.internal."
  description = "DNS zone for Network A services"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.network_a.id
    }
  }
}

# DNS zone for network B
resource "google_dns_managed_zone" "network_b_dns" {
  name        = "network-b-dns"
  dns_name    = "services-b.internal."
  description = "DNS zone for Network B services"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.network_b.id
    }
  }
}

# Create DNS peering from network A to network B
resource "google_dns_managed_zone" "peering_zone_a_to_b" {
  name        = "peering-a-to-b"
  dns_name    = "services-b.internal."
  description = "DNS peering zone from Network A to Network B"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.network_a.id
    }
  }
  
  peering_config {
    target_network {
      network_url = google_compute_network.network_b.id
    }
  }
}

# Create DNS peering from network B to network A
resource "google_dns_managed_zone" "peering_zone_b_to_a" {
  name        = "peering-b-to-a"
  dns_name    = "services-a.internal."
  description = "DNS peering zone from Network B to Network A"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.network_b.id
    }
  }
  
  peering_config {
    target_network {
      network_url = google_compute_network.network_a.id
    }
  }
}

# Add some example records
resource "google_dns_record_set" "service_a" {
  name         = "app.services-a.internal."
  managed_zone = google_dns_managed_zone.network_a_dns.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.1.10"]
}

resource "google_dns_record_set" "service_b" {
  name         = "db.services-b.internal."
  managed_zone = google_dns_managed_zone.network_b_dns.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.2.20"]
}
```

## Managing Cloud DNS with gcloud CLI

### Creating and Managing DNS Zones

```bash
# Create a public DNS zone
gcloud dns managed-zones create example-zone \
  --description="Example public zone" \
  --dns-name="example.com." \
  --labels="environment=prod"

# Create a private DNS zone
gcloud dns managed-zones create private-zone \
  --description="Example private zone" \
  --dns-name="internal.example." \
  --visibility=private \
  --networks=my-vpc-network

# List managed zones
gcloud dns managed-zones list

# Describe a specific zone
gcloud dns managed-zones describe example-zone
```

### Managing DNS Records

```bash
# Add an A record
gcloud dns record-sets transaction start --zone=example-zone

gcloud dns record-sets transaction add "203.0.113.1" \
  --name="www.example.com." \
  --ttl=300 \
  --type=A \
  --zone=example-zone

gcloud dns record-sets transaction execute --zone=example-zone

# Add multiple records in one transaction
gcloud dns record-sets transaction start --zone=example-zone

gcloud dns record-sets transaction add "10.0.0.1" "10.0.0.2" \
  --name="api.example.com." \
  --ttl=300 \
  --type=A \
  --zone=example-zone

gcloud dns record-sets transaction add "mail.example.com." \
  --name="alias.example.com." \
  --ttl=300 \
  --type=CNAME \
  --zone=example-zone

gcloud dns record-sets transaction execute --zone=example-zone

# Update an existing record
gcloud dns record-sets transaction start --zone=example-zone

gcloud dns record-sets transaction remove "203.0.113.1" \
  --name="www.example.com." \
  --ttl=300 \
  --type=A \
  --zone=example-zone

gcloud dns record-sets transaction add "203.0.113.2" \
  --name="www.example.com." \
  --ttl=300 \
  --type=A \
  --zone=example-zone

gcloud dns record-sets transaction execute --zone=example-zone

# List all records in a zone
gcloud dns record-sets list --zone=example-zone

# Delete a record
gcloud dns record-sets transaction start --zone=example-zone

gcloud dns record-sets transaction remove "mail.example.com." \
  --name="alias.example.com." \
  --ttl=300 \
  --type=CNAME \
  --zone=example-zone

gcloud dns record-sets transaction execute --zone=example-zone
```

### Configuring DNSSEC

```bash
# Enable DNSSEC for a zone
gcloud dns managed-zones update example-zone \
  --dnssec-state=on

# View DNSSEC configuration
gcloud dns managed-zones describe example-zone \
  --format="json(dnssecConfig)"

# Get DS record information (to provide to your domain registrar)
gcloud dns dns-keys list --zone=example-zone
```

### Managing DNS Policies

```bash
# Create a DNS policy with specific forwarders
gcloud dns policies create custom-forwarding-policy \
  --description="Custom DNS forwarding policy" \
  --networks=my-vpc-network \
  --alternative-name-servers=192.168.1.1,192.168.1.2 \
  --enable-logging

# List DNS policies
gcloud dns policies list

# Update a DNS policy
gcloud dns policies update custom-forwarding-policy \
  --enable-logging

# Delete a DNS policy
gcloud dns policies delete custom-forwarding-policy
```

## Real-World Example: Multi-VPC DNS Architecture

This example demonstrates a complete multi-VPC DNS setup with private zones, forwarding, and DNS peering:

### Architecture Overview

1. Hub & Spoke VPC network architecture
2. Central DNS management in Hub VPC
3. DNS forwarding for on-premises integration
4. DNS peering to shared services
5. Service Discovery support

### Terraform Implementation

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default region"
  type        = string
  default     = "us-central1"
}

variable "on_prem_dns" {
  description = "On-premises DNS server IPs"
  type        = list(string)
  default     = ["192.168.1.10", "192.168.1.11"]
}

# Create the Hub VPC
resource "google_compute_network" "hub_vpc" {
  name                    = "hub-vpc"
  auto_create_subnetworks = false
  description             = "Hub VPC for centralized services"
}

resource "google_compute_subnetwork" "hub_subnet" {
  name          = "hub-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.hub_vpc.id
}

# Create Spoke VPCs
resource "google_compute_network" "spoke_vpc_1" {
  name                    = "spoke-vpc-1"
  auto_create_subnetworks = false
  description             = "Spoke VPC 1 for application workloads"
}

resource "google_compute_subnetwork" "spoke_subnet_1" {
  name          = "spoke-subnet-1"
  ip_cidr_range = "10.1.0.0/24"
  region        = var.region
  network       = google_compute_network.spoke_vpc_1.id
}

resource "google_compute_network" "spoke_vpc_2" {
  name                    = "spoke-vpc-2"
  auto_create_subnetworks = false
  description             = "Spoke VPC 2 for database workloads"
}

resource "google_compute_subnetwork" "spoke_subnet_2" {
  name          = "spoke-subnet-2"
  ip_cidr_range = "10.2.0.0/24"
  region        = var.region
  network       = google_compute_network.spoke_vpc_2.id
}

# Create VPC peering between Hub and Spokes
resource "google_compute_network_peering" "hub_to_spoke1" {
  name         = "hub-to-spoke1"
  network      = google_compute_network.hub_vpc.id
  peer_network = google_compute_network.spoke_vpc_1.id
  
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "spoke1_to_hub" {
  name         = "spoke1-to-hub"
  network      = google_compute_network.spoke_vpc_1.id
  peer_network = google_compute_network.hub_vpc.id
  
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "hub_to_spoke2" {
  name         = "hub-to-spoke2"
  network      = google_compute_network.hub_vpc.id
  peer_network = google_compute_network.spoke_vpc_2.id
  
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "spoke2_to_hub" {
  name         = "spoke2-to-hub"
  network      = google_compute_network.spoke_vpc_2.id
  peer_network = google_compute_network.hub_vpc.id
  
  export_custom_routes = true
  import_custom_routes = true
}

# Create DNS zones
# 1. Main private zone in Hub VPC
resource "google_dns_managed_zone" "internal_corp" {
  name        = "internal-corp"
  dns_name    = "corp.internal."
  description = "Main corporate private DNS zone"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# 2. DNS zones for the spoke VPCs
resource "google_dns_managed_zone" "apps_zone" {
  name        = "apps-zone"
  dns_name    = "apps.corp.internal."
  description = "Private DNS zone for applications"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc_1.id
    }
  }
}

resource "google_dns_managed_zone" "db_zone" {
  name        = "db-zone"
  dns_name    = "db.corp.internal."
  description = "Private DNS zone for databases"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc_2.id
    }
  }
}

# 3. DNS peering from Hub to Spokes
resource "google_dns_managed_zone" "hub_to_apps_peer" {
  name        = "hub-to-apps-peer"
  dns_name    = "apps.corp.internal."
  description = "DNS peering from Hub to Applications"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
  
  peering_config {
    target_network {
      network_url = google_compute_network.spoke_vpc_1.id
    }
  }
}

resource "google_dns_managed_zone" "hub_to_db_peer" {
  name        = "hub-to-db-peer"
  dns_name    = "db.corp.internal."
  description = "DNS peering from Hub to Databases"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
  
  peering_config {
    target_network {
      network_url = google_compute_network.spoke_vpc_2.id
    }
  }
}

# 4. DNS zone for on-prem domain
resource "google_dns_managed_zone" "onprem_zone" {
  name        = "onprem-zone"
  dns_name    = "onprem.example."
  description = "Zone for on-premises domain"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
  
  forwarding_config {
    target_name_servers {
      ipv4_address = var.on_prem_dns[0]
    }
    target_name_servers {
      ipv4_address = var.on_prem_dns[1]
    }
  }
}

# Create DNS policy for outbound server policy
resource "google_dns_policy" "dns_forwarding_policy" {
  name = "dns-forwarding-policy"
  
  networks {
    network_url = google_compute_network.hub_vpc.id
  }
  
  enable_inbound = false
  
  alternative_name_server_config {
    target_name_servers {
      ipv4_address = var.on_prem_dns[0]
    }
    target_name_servers {
      ipv4_address = var.on_prem_dns[1]
    }
  }
}

# Create DNS records for services

# 1. Common services in the hub VPC
resource "google_dns_record_set" "hub_services" {
  name         = "services.corp.internal."
  managed_zone = google_dns_managed_zone.internal_corp.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.0.10"]
}

resource "google_dns_record_set" "hub_proxy" {
  name         = "proxy.corp.internal."
  managed_zone = google_dns_managed_zone.internal_corp.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.0.0.20"]
}

# 2. Application services in spoke VPC 1
resource "google_dns_record_set" "app_frontend" {
  name         = "frontend.apps.corp.internal."
  managed_zone = google_dns_managed_zone.apps_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.1.0.10"]
}

resource "google_dns_record_set" "app_backend" {
  name         = "backend.apps.corp.internal."
  managed_zone = google_dns_managed_zone.apps_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.1.0.20"]
}

# 3. Database services in spoke VPC 2
resource "google_dns_record_set" "db_primary" {
  name         = "primary.db.corp.internal."
  managed_zone = google_dns_managed_zone.db_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.2.0.10"]
}

resource "google_dns_record_set" "db_replica" {
  name         = "replica.db.corp.internal."
  managed_zone = google_dns_managed_zone.db_zone.name
  type         = "A"
  ttl          = 300
  
  rrdatas = ["10.2.0.11"]
}

# 4. Service discovery using SRV records
resource "google_dns_record_set" "service_discovery" {
  name         = "_http._tcp.services.corp.internal."
  managed_zone = google_dns_managed_zone.internal_corp.name
  type         = "SRV"
  ttl          = 300
  
  rrdatas = [
    "0 1 8080 frontend.apps.corp.internal.",
    "0 1 8080 backend.apps.corp.internal."
  ]
}

# Output the name servers and information
output "dns_zones" {
  value = {
    internal_corp = google_dns_managed_zone.internal_corp.dns_name
    apps_zone     = google_dns_managed_zone.apps_zone.dns_name
    db_zone       = google_dns_managed_zone.db_zone.dns_name
    onprem_zone   = google_dns_managed_zone.onprem_zone.dns_name
  }
}

output "app_services" {
  value = {
    frontend = google_dns_record_set.app_frontend.name
    backend  = google_dns_record_set.app_backend.name
  }
}

output "db_services" {
  value = {
    primary = google_dns_record_set.db_primary.name
    replica = google_dns_record_set.db_replica.name
  }
}
```

### Testing DNS Resolution Script

```bash
#!/bin/bash
# test-dns-resolution.sh - Tests DNS resolution across the network architecture

# Base variables
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region 2>/dev/null || echo "us-central1")
BASE_CMD="gcloud compute ssh"

# Test from each VPC
test_resolution() {
    local vm=$1
    local zone=$2
    
    echo "==== Testing DNS Resolution from $vm in $zone ===="
    
    # Define domains to test
    local domains=(
        "services.corp.internal"
        "proxy.corp.internal"
        "frontend.apps.corp.internal"
        "backend.apps.corp.internal"
        "primary.db.corp.internal"
        "replica.db.corp.internal"
        "onprem-server.onprem.example"
    )
    
    for domain in "${domains[@]}"; do
        echo "Resolving $domain..."
        $BASE_CMD $vm --zone $zone --command "nslookup $domain" -- -q
        echo ""
    done
    
    # Test service discovery
    echo "Testing service discovery SRV record:"
    $BASE_CMD $vm --zone $zone --command "nslookup -type=SRV _http._tcp.services.corp.internal" -- -q
    echo ""
}

# Create test VMs if they don't exist
echo "Checking for test VMs..."

# Hub VM
if ! gcloud compute instances describe hub-test-vm --zone $REGION-a &>/dev/null; then
    echo "Creating hub-test-vm..."
    gcloud compute instances create hub-test-vm \
        --zone=$REGION-a \
        --machine-type=e2-micro \
        --subnet=hub-subnet \
        --image-family=debian-11 \
        --image-project=debian-cloud
fi

# Spoke1 VM
if ! gcloud compute instances describe spoke1-test-vm --zone $REGION-a &>/dev/null; then
    echo "Creating spoke1-test-vm..."
    gcloud compute instances create spoke1-test-vm \
        --zone=$REGION-a \
        --machine-type=e2-micro \
        --subnet=spoke-subnet-1 \
        --image-family=debian-11 \
        --image-project=debian-cloud
fi

# Spoke2 VM
if ! gcloud compute instances describe spoke2-test-vm --zone $REGION-a &>/dev/null; then
    echo "Creating spoke2-test-vm..."
    gcloud compute instances create spoke2-test-vm \
        --zone=$REGION-a \
        --machine-type=e2-micro \
        --subnet=spoke-subnet-2 \
        --image-family=debian-11 \
        --image-project=debian-cloud
fi

# Run tests
test_resolution "hub-test-vm" "$REGION-a"
test_resolution "spoke1-test-vm" "$REGION-a"
test_resolution "spoke2-test-vm" "$REGION-a"

echo "DNS resolution testing complete."
```

## Best Practices

1. **Zone Design**
   - Use descriptive zone names that reflect their purpose
   - Follow a consistent naming convention
   - Keep zone structure flat when possible
   - Consider separate zones for different environments

2. **Performance and Reliability**
   - Set appropriate TTL values (lower for frequently changing records)
   - Avoid excessive DNS lookups in application code
   - Use multi-region deployments for public-facing services
   - Implement DNS monitoring and alerting

3. **Security**
   - Enable DNSSEC for public zones
   - Implement strict policies for DNS zone access
   - Limit who can modify DNS records
   - Use private zones for internal services
   - Enable logging for audit purposes

4. **Operational Excellence**
   - Use Infrastructure as Code for all DNS configurations
   - Document DNS architecture and record management processes
   - Implement automated testing for DNS resolution
   - Create runbooks for common DNS operations

5. **Cost Optimization**
   - Clean up unused DNS zones and records
   - Monitor query volumes for unexpected spikes
   - Consolidate zones where appropriate
   - Use Cloud DNS Policies efficiently

## Common Issues and Troubleshooting

### Resolution Issues
- Verify VPC network attachments for private zones
- Check that DNS peering is correctly configured
- Ensure proper IAM permissions for DNS management
- Test resolution from different VPC networks
- Check for conflicting or overlapping DNS zones

### Propagation Delays
- Allow sufficient time for DNS changes to propagate
- Check if TTL values are set appropriately
- Use DNS monitoring tools to verify propagation
- Consider reducing TTL before planned changes
- Test from multiple global regions

### DNSSEC Problems
- Ensure correct DS records are published at the parent zone
- Verify DNSSEC key signing key (KSK) and zone signing key (ZSK)
- Check for DNSSEC validation errors in logs
- Test DNSSEC validation with online tools
- Allow time for DNSSEC changes to propagate

### Integration with On-Premises DNS
- Verify DNS forwarding configuration
- Check firewall rules for DNS traffic (port 53)
- Test DNS resolution in both directions
- Configure conditional forwarding on on-premises DNS servers
- Check for subnet overlaps causing routing issues

## Further Reading

- [Cloud DNS Documentation](https://cloud.google.com/dns/docs)
- [Cloud DNS Best Practices](https://cloud.google.com/dns/docs/best-practices)
- [DNSSEC in Cloud DNS](https://cloud.google.com/dns/docs/dnssec)
- [Private DNS Zones](https://cloud.google.com/dns/docs/zones/manage-private-zones)
- [Terraform Google Cloud DNS Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)