---
description: Deploying and managing Google Virtual Private Cloud (VPC) for networking
---

# VPC (Virtual Private Cloud)

Google Virtual Private Cloud (VPC) provides networking functionality for your Google Cloud resources and services. VPC offers global, scalable, and flexible networking for your Google Cloud workloads, enabling you to define your network topology with IP address ranges, subnets, routes, firewalls, and more.

## Key Features

- **Global Resource**: Single VPC can span multiple regions without requiring a VPN
- **Automatic Routing**: Built-in routing for subnet-to-subnet traffic
- **Private Google Access**: Access to Google services without public IPs
- **VPC Peering**: Connect VPCs across projects without a gateway
- **Shared VPC**: Share networks across multiple projects
- **VPC Network Peering**: Connect VPC networks in different projects or organizations
- **Cloud NAT**: Outbound connections for private instances
- **Hybrid Connectivity**: Connect to on-premises networks via Cloud VPN or Cloud Interconnect
- **IPv4 and IPv6 Support**: Dual-stack capabilities
- **Firewall Rules**: Granular L3/L4 traffic control
- **VPC Flow Logs**: Network monitoring and security analysis

## Deploying VPC Networks with Terraform

### Basic VPC with Custom Subnets

```hcl
# Create VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-vpc"
  auto_create_subnetworks = false  # Disable automatic subnet creation
  routing_mode            = "GLOBAL"  # Use global routing
  description             = "Custom VPC network with manually defined subnets"
}

# Create subnets in different regions
resource "google_compute_subnetwork" "us_central1_subnet" {
  name          = "us-central1-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  
  private_ip_google_access = true  # Enable private Google access
  
  # Enable flow logs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "europe_west1_subnet" {
  name          = "europe-west1-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
  
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "asia_east1_subnet" {
  name          = "asia-east1-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "asia-east1"
  network       = google_compute_network.vpc_network.id
  
  private_ip_google_access = true
}

# Create firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.vpc_network.id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
```

### VPC with Secondary IP Ranges for GKE

```hcl
resource "google_compute_network" "gke_vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/20" # Primary IP range for nodes
  region        = "us-central1"
  network       = google_compute_network.gke_vpc.id
  
  # Secondary IP ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/12" # Large block for pods
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.32.0.0/16" # Block for services
  }
  
  private_ip_google_access = true
}

# Allow GKE masters to reach nodes
resource "google_compute_firewall" "gke_master_to_nodes" {
  name    = "gke-master-to-nodes"
  network = google_compute_network.gke_vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }
  
  # This source range represents the GKE control plane
  source_ranges = ["172.16.0.0/28"]
  target_tags   = ["gke-node"]
}
```

### VPC with Cloud NAT and Private Instances

```hcl
# Create the VPC network
resource "google_compute_network" "private_vpc" {
  name                    = "private-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.private_vpc.id
  
  private_ip_google_access = true
}

# Create Cloud Router
resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = "us-central1"
  network = google_compute_network.private_vpc.id
}

# Create Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create a private instance (no external IP)
resource "google_compute_instance" "private_instance" {
  name         = "private-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = google_compute_network.private_vpc.id
    subnetwork = google_compute_subnetwork.private_subnet.id
    # No access_config block means no external IP
  }
  
  tags = ["private-vm"]
  
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y curl
    # Test egress connectivity via NAT
    curl -s https://api.ipify.org > /tmp/external-ip.txt
  EOT
}

# Create a jump host with public IP for access
resource "google_compute_instance" "jump_host" {
  name         = "jump-host"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = google_compute_network.private_vpc.id
    subnetwork = google_compute_subnetwork.private_subnet.id
    
    access_config {
      // Ephemeral public IP
    }
  }
  
  tags = ["ssh"]
}

# Firewall rule to allow SSH access to jump host
resource "google_compute_firewall" "allow_ssh_to_jump_host" {
  name    = "allow-ssh-to-jump-host"
  network = google_compute_network.private_vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Firewall rule to allow SSH from jump host to private instances
resource "google_compute_firewall" "allow_ssh_from_jump_host" {
  name    = "allow-ssh-from-jump-host"
  network = google_compute_network.private_vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_tags = ["ssh"]
  target_tags = ["private-vm"]
}
```

### Shared VPC Setup

```hcl
# Variables
variable "host_project_id" {
  description = "Project ID for the Shared VPC host project"
  type        = string
}

variable "service_project_ids" {
  description = "List of project IDs to attach as service projects"
  type        = list(string)
}

# Enable Shared VPC hosting in the host project
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# Attach service projects to the host
resource "google_compute_shared_vpc_service_project" "service" {
  count           = length(var.service_project_ids)
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project_ids[count.index]
}

# Create the shared VPC network
resource "google_compute_network" "shared_vpc" {
  name                    = "shared-vpc-network"
  project                 = var.host_project_id
  auto_create_subnetworks = false
}

# Create subnets in the shared VPC
resource "google_compute_subnetwork" "shared_subnet_1" {
  name          = "shared-subnet-1"
  project       = var.host_project_id
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.shared_vpc.id
  
  # IAM binding for specific service accounts
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
}

resource "google_compute_subnetwork" "shared_subnet_2" {
  name          = "shared-subnet-2"
  project       = var.host_project_id
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.shared_vpc.id
}

# Grant IAM permissions for service project admins to use the subnet
resource "google_compute_subnetwork_iam_binding" "subnet_users" {
  project    = var.host_project_id
  region     = google_compute_subnetwork.shared_subnet_1.region
  subnetwork = google_compute_subnetwork.shared_subnet_1.name
  role       = "roles/compute.networkUser"
  
  members = [
    "serviceAccount:service-${var.service_project_ids[0]}@compute-system.iam.gserviceaccount.com",
    "group:gcp-developers@example.com"
  ]
}

# Basic firewall rules for the shared VPC
resource "google_compute_firewall" "shared_vpc_internal" {
  name    = "shared-vpc-allow-internal"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = ["10.0.0.0/16"]
}
```

### VPC with Network Peering

```hcl
# Create two VPC networks for peering
resource "google_compute_network" "vpc_network_1" {
  name                    = "vpc-network-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_network_2" {
  name                    = "vpc-network-2"
  auto_create_subnetworks = false
}

# Create subnets in each VPC
resource "google_compute_subnetwork" "vpc1_subnet" {
  name          = "vpc1-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network_1.id
}

resource "google_compute_subnetwork" "vpc2_subnet" {
  name          = "vpc2-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network_2.id
}

# Create VPC peering between the two networks
resource "google_compute_network_peering" "peering1to2" {
  name         = "peering-1-to-2"
  network      = google_compute_network.vpc_network_1.id
  peer_network = google_compute_network.vpc_network_2.id
  
  # Optional: Export custom routes
  export_custom_routes = true
  # Optional: Export subnet routes with public IP
  export_subnet_routes_with_public_ip = true
}

resource "google_compute_network_peering" "peering2to1" {
  name         = "peering-2-to-1"
  network      = google_compute_network.vpc_network_2.id
  peer_network = google_compute_network.vpc_network_1.id
  
  export_custom_routes = true
  export_subnet_routes_with_public_ip = true
  
  # Ensure peerings are created in the correct order
  depends_on = [google_compute_network_peering.peering1to2]
}

# Create instances in each VPC to test connectivity
resource "google_compute_instance" "vm_vpc1" {
  name         = "vm-vpc1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = google_compute_network.vpc_network_1.id
    subnetwork = google_compute_subnetwork.vpc1_subnet.id
    
    access_config {
      // Ephemeral public IP
    }
  }
}

resource "google_compute_instance" "vm_vpc2" {
  name         = "vm-vpc2"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = google_compute_network.vpc_network_2.id
    subnetwork = google_compute_subnetwork.vpc2_subnet.id
    
    access_config {
      // Ephemeral public IP
    }
  }
}

# Firewall rules to allow internal communication
resource "google_compute_firewall" "allow_vpc1_internal" {
  name    = "allow-vpc1-internal"
  network = google_compute_network.vpc_network_1.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "allow_vpc2_internal" {
  name    = "allow-vpc2-internal"
  network = google_compute_network.vpc_network_2.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

## Managing VPC with gcloud CLI

### Creating Networks and Subnets

```bash
# Create a custom-mode VPC network
gcloud compute networks create my-custom-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=global \
    --description="Custom VPC network"

# Create subnets in different regions
gcloud compute networks subnets create us-central1-subnet \
    --network=my-custom-vpc \
    --region=us-central1 \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access

gcloud compute networks subnets create europe-subnet \
    --network=my-custom-vpc \
    --region=europe-west1 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access

# List networks
gcloud compute networks list

# Get details of a network
gcloud compute networks describe my-custom-vpc

# List subnets
gcloud compute networks subnets list --network=my-custom-vpc

# Enable flow logs for a subnet
gcloud compute networks subnets update us-central1-subnet \
    --region=us-central1 \
    --enable-flow-logs \
    --logging-aggregation-interval=interval-5-sec \
    --logging-flow-sampling=0.5 \
    --logging-metadata=include-all
```

### Working with Firewall Rules

```bash
# Create firewall rule to allow internal traffic
gcloud compute firewall-rules create allow-internal \
    --network=my-custom-vpc \
    --action=allow \
    --direction=ingress \
    --rules=tcp,udp,icmp \
    --source-ranges=10.0.0.0/16 \
    --description="Allow internal traffic"

# Create firewall rule to allow SSH from anywhere
gcloud compute firewall-rules create allow-ssh \
    --network=my-custom-vpc \
    --action=allow \
    --direction=ingress \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh \
    --description="Allow SSH from anywhere"

# List firewall rules for a specific network
gcloud compute firewall-rules list --filter="network:my-custom-vpc"

# Update a firewall rule
gcloud compute firewall-rules update allow-ssh \
    --source-ranges=35.235.240.0/20 \
    --description="Allow SSH from IAP only"

# Create a deny rule with high priority
gcloud compute firewall-rules create deny-all-egress \
    --network=my-custom-vpc \
    --action=deny \
    --direction=egress \
    --rules=all \
    --destination-ranges=0.0.0.0/0 \
    --priority=65000 \
    --description="Default deny all egress rule"
```

### Setting up Cloud NAT

```bash
# Create a Cloud Router
gcloud compute routers create nat-router \
    --network=my-custom-vpc \
    --region=us-central1

# Configure NAT on the router
gcloud compute routers nats create nat-config \
    --router=nat-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips \
    --enable-logging

# View NAT status
gcloud compute routers nats describe nat-config \
    --router=nat-router \
    --region=us-central1

# Update NAT configuration
gcloud compute routers nats update nat-config \
    --router=nat-router \
    --region=us-central1 \
    --nat-custom-subnet-ip-ranges=us-central1-subnet
```

### Setting up VPC Peering

```bash
# Create VPC networks
gcloud compute networks create vpc-network-1 --subnet-mode=custom
gcloud compute networks create vpc-network-2 --subnet-mode=custom

# Create subnets
gcloud compute networks subnets create vpc1-subnet \
    --network=vpc-network-1 \
    --region=us-central1 \
    --range=10.0.1.0/24

gcloud compute networks subnets create vpc2-subnet \
    --network=vpc-network-2 \
    --region=us-central1 \
    --range=10.0.2.0/24

# Create peering from VPC1 to VPC2
gcloud compute networks peerings create peer-vpc1-to-vpc2 \
    --network=vpc-network-1 \
    --peer-network=vpc-network-2 \
    --auto-create-routes \
    --export-custom-routes \
    --import-custom-routes

# Create peering from VPC2 to VPC1
gcloud compute networks peerings create peer-vpc2-to-vpc1 \
    --network=vpc-network-2 \
    --peer-network=vpc-network-1 \
    --auto-create-routes \
    --export-custom-routes \
    --import-custom-routes

# List peerings
gcloud compute networks peerings list --network=vpc-network-1

# Update peering to exchange subnet routes
gcloud compute networks peerings update peer-vpc1-to-vpc2 \
    --network=vpc-network-1 \
    --import-subnet-routes-with-public-ip \
    --export-subnet-routes-with-public-ip
```

### Managing Shared VPC

```bash
# Enable Shared VPC in host project
gcloud compute shared-vpc enable HOST_PROJECT_ID

# Associate service projects with the host project
gcloud compute shared-vpc associated-projects add SERVICE_PROJECT_ID_1 \
    --host-project=HOST_PROJECT_ID

gcloud compute shared-vpc associated-projects add SERVICE_PROJECT_ID_2 \
    --host-project=HOST_PROJECT_ID

# List associated service projects
gcloud compute shared-vpc associated-projects list \
    --host-project=HOST_PROJECT_ID

# Grant IAM permissions for a service account to use a subnet
gcloud compute networks subnets add-iam-policy-binding us-central1-subnet \
    --region=us-central1 \
    --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.networkUser" \
    --project=HOST_PROJECT_ID

# Remove a service project from Shared VPC
gcloud compute shared-vpc associated-projects remove SERVICE_PROJECT_ID_1 \
    --host-project=HOST_PROJECT_ID

# Disable Shared VPC hosting
gcloud compute shared-vpc disable HOST_PROJECT_ID
```

## Real-World Example: Enterprise Hub-and-Spoke Network Architecture

This example showcases a complete enterprise network architecture with hub-and-spoke design:

### Architecture Overview

1. Hub VPC for shared services and connectivity
2. Multiple spoke VPCs for application environments
3. VPC peering and custom routes
4. On-premises connectivity via VPN
5. Cloud NAT and Private Google Access
6. Hierarchical firewall policies

### Terraform Implementation

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

# Variables
variable "project_id" {
  description = "Project ID for deployment"
  type        = string
}

variable "region" {
  description = "Primary region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment_prefixes" {
  description = "Environment names for spoke networks"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "on_prem_cidr" {
  description = "On-premises CIDR range"
  type        = string
  default     = "192.168.0.0/16"
}

# Create a hub VPC
resource "google_compute_network" "hub_vpc" {
  name                    = "hub-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Hub VPC for centralized connectivity"
}

# Create subnets in the hub VPC
resource "google_compute_subnetwork" "hub_subnet" {
  name                     = "hub-subnet"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  network                  = google_compute_network.hub_vpc.id
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "hub_subnet_2" {
  name                     = "hub-subnet-2"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = "europe-west1"
  network                  = google_compute_network.hub_vpc.id
  private_ip_google_access = true
}

# Create spoke VPCs
resource "google_compute_network" "spoke_vpcs" {
  for_each                = toset(var.environment_prefixes)
  name                    = "${each.value}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Spoke VPC for ${each.value} environment"
}

# Create subnets in the spoke VPCs
resource "google_compute_subnetwork" "spoke_subnets_primary" {
  for_each                = toset(var.environment_prefixes)
  name                    = "${each.value}-primary-subnet"
  ip_cidr_range           = "10.${index(var.environment_prefixes, each.value) + 1}.0.0/24"
  region                  = var.region
  network                 = google_compute_network.spoke_vpcs[each.value].id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "spoke_subnets_secondary" {
  for_each                = toset(var.environment_prefixes)
  name                    = "${each.value}-secondary-subnet"
  ip_cidr_range           = "10.${index(var.environment_prefixes, each.value) + 1}.1.0/24"
  region                  = "europe-west1"
  network                 = google_compute_network.spoke_vpcs[each.value].id
  private_ip_google_access = true
}

# Create VPC peering from spoke to hub
resource "google_compute_network_peering" "spoke_to_hub_peering" {
  for_each                        = toset(var.environment_prefixes)
  name                            = "${each.value}-to-hub-peering"
  network                         = google_compute_network.spoke_vpcs[each.value].id
  peer_network                    = google_compute_network.hub_vpc.id
  export_custom_routes            = true
  import_custom_routes            = true
}

# Create VPC peering from hub to spoke
resource "google_compute_network_peering" "hub_to_spoke_peering" {
  for_each                        = toset(var.environment_prefixes)
  name                            = "hub-to-${each.value}-peering"
  network                         = google_compute_network.hub_vpc.id
  peer_network                    = google_compute_network.spoke_vpcs[each.value].id
  export_custom_routes            = true
  import_custom_routes            = true
  
  depends_on = [google_compute_network_peering.spoke_to_hub_peering]
}

# Create Cloud Router for VPN and NAT in hub VPC
resource "google_compute_router" "hub_router" {
  name    = "hub-router"
  region  = var.region
  network = google_compute_network.hub_vpc.id
  
  bgp {
    asn = 64514
  }
}

# Configure Cloud NAT for the hub VPC
resource "google_compute_router_nat" "hub_nat" {
  name                               = "hub-nat"
  router                             = google_compute_router.hub_router.name
  region                             = google_compute_router.hub_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create Cloud Routers for NAT in spoke VPCs
resource "google_compute_router" "spoke_routers" {
  for_each = toset(var.environment_prefixes)
  name     = "${each.value}-router"
  region   = var.region
  network  = google_compute_network.spoke_vpcs[each.value].id
  
  bgp {
    asn = 64515 + index(var.environment_prefixes, each.value)
  }
}

# Configure Cloud NAT for spoke VPCs
resource "google_compute_router_nat" "spoke_nats" {
  for_each                           = toset(var.environment_prefixes)
  name                               = "${each.value}-nat"
  router                             = google_compute_router.spoke_routers[each.value].name
  region                             = google_compute_router.spoke_routers[each.value].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create VPN gateway in hub VPC for on-premises connectivity
resource "google_compute_vpn_gateway" "hub_vpn_gateway" {
  name    = "hub-vpn-gateway"
  network = google_compute_network.hub_vpc.id
  region  = var.region
}

# Create external IP for VPN
resource "google_compute_address" "vpn_ip" {
  name   = "vpn-ip"
  region = var.region
}

# Create a VPN tunnel to on-premises (Note: on-prem side configuration not shown)
resource "google_compute_vpn_tunnel" "hub_vpn_tunnel" {
  name                  = "hub-to-onprem-tunnel"
  region                = var.region
  vpn_gateway           = google_compute_vpn_gateway.hub_vpn_gateway.id
  peer_ip               = "203.0.113.1" # Replace with actual on-prem VPN endpoint
  shared_secret         = "a-very-secure-secret"
  target_vpn_gateway    = google_compute_vpn_gateway.hub_vpn_gateway.id
  
  depends_on = [
    google_compute_address.vpn_ip
  ]
}

# Create routes for on-premises traffic
resource "google_compute_route" "route_to_onprem" {
  name             = "route-to-onprem"
  dest_range       = var.on_prem_cidr
  network          = google_compute_network.hub_vpc.id
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.hub_vpn_tunnel.id
  priority         = 1000
}

# Create firewall rules for hub VPC
resource "google_compute_firewall" "hub_allow_internal" {
  name    = "hub-allow-internal"
  network = google_compute_network.hub_vpc.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "hub_allow_iap_ssh" {
  name    = "hub-allow-iap-ssh"
  network = google_compute_network.hub_vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  # IAP IP ranges
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "hub_allow_onprem" {
  name    = "hub-allow-onprem"
  network = google_compute_network.hub_vpc.id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = [var.on_prem_cidr]
}

# Create firewall rules for spoke VPCs
resource "google_compute_firewall" "spoke_allow_internal" {
  for_each = toset(var.environment_prefixes)
  name     = "${each.value}-allow-internal"
  network  = google_compute_network.spoke_vpcs[each.value].id
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = [
    "10.${index(var.environment_prefixes, each.value) + 1}.0.0/16",
    "10.0.0.0/16" # Allow from hub
  ]
}

# Create Proxy-only subnet for internal load balancers in the hub
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.0.10.0/24"
  region        = var.region
  network       = google_compute_network.hub_vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Create a bastion host in the hub VPC
resource "google_compute_instance" "hub_bastion" {
  name         = "hub-bastion"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }
  
  network_interface {
    network    = google_compute_network.hub_vpc.id
    subnetwork = google_compute_subnetwork.hub_subnet.id
    
    # No external IP - will use IAP for SSH
  }
  
  tags = ["bastion", "ssh"]
  
  metadata = {
    enable-oslogin = "true"
  }
  
  service_account {
    scopes = ["cloud-platform"]
  }
}

# Create sample workload VMs in each spoke network
resource "google_compute_instance" "spoke_vms" {
  for_each     = toset(var.environment_prefixes)
  name         = "${each.value}-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }
  
  network_interface {
    network    = google_compute_network.spoke_vpcs[each.value].id
    subnetwork = google_compute_subnetwork.spoke_subnets_primary[each.value].id
    
    # No external IP
  }
  
  tags = ["${each.value}-vm"]
  
  metadata = {
    enable-oslogin = "true"
  }
  
  service_account {
    scopes = ["cloud-platform"]
  }
}

# Outputs
output "hub_vpc_name" {
  value = google_compute_network.hub_vpc.name
}

output "spoke_vpc_names" {
  value = { for prefix in var.environment_prefixes : prefix => google_compute_network.spoke_vpcs[prefix].name }
}

output "hub_subnet_ranges" {
  value = {
    primary   = google_compute_subnetwork.hub_subnet.ip_cidr_range
    secondary = google_compute_subnetwork.hub_subnet_2.ip_cidr_range
  }
}

output "spoke_subnet_ranges" {
  value = { for prefix in var.environment_prefixes : prefix => {
    primary   = google_compute_subnetwork.spoke_subnets_primary[prefix].ip_cidr_range
    secondary = google_compute_subnetwork.spoke_subnets_secondary[prefix].ip_cidr_range
  }}
}

output "vpn_gateway_ip" {
  value = google_compute_address.vpn_ip.address
}

output "bastion_name" {
  value = google_compute_instance.hub_bastion.name
}

output "iap_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.hub_bastion.name} --zone=${google_compute_instance.hub_bastion.zone} --tunnel-through-iap"
}
```

## Best Practices

1. **Network Design**
   - Use custom mode VPC and explicit subnet creation for better control
   - Choose non-overlapping CIDR ranges across your cloud and on-premises networks
   - Plan IP address allocation with future growth in mind
   - Use descriptive network and subnet names

2. **Security**
   - Implement a defense-in-depth approach with layered firewall rules
   - Use service accounts with minimum required permissions
   - Apply the principle of least privilege for firewall rules
   - Use Cloud Armor for edge protection when exposing services publicly
   - Enable VPC Flow Logs for network monitoring and forensics
   - Prefer IAP over public IP addresses for administration

3. **Connectivity**
   - Use VPC Peering for simple internal connectivity
   - Implement Cloud Router and NAT for egress from private instances
   - Choose appropriate hybrid connectivity options (VPN vs Interconnect)
   - Consider Network Connectivity Center for complex hybrid/multi-cloud setups
   - Test failover scenarios for critical network paths

4. **Performance**
   - Place resources in regions close to users
   - Use Global Load Balancing for worldwide deployments
   - Monitor network throughput and latency
   - Implement CDN for static content delivery
   - Optimize subnet sizes for anticipated workloads

5. **Operations**
   - Use infrastructure as code for all network configurations
   - Implement proper CIDR planning and documentation
   - Set up monitoring and alerts for network health
   - Create network diagrams and keep them updated
   - Develop runbooks for common network operations

## Common Issues and Troubleshooting

### Connectivity Issues
- Check firewall rules for both ingress and egress traffic
- Verify subnet routes and any custom routes
- Check VPC peering status and configuration
- Verify that service account has networking permissions
- Check for overlapping CIDR ranges causing routing issues

### VPC Peering Problems
- Remember peering is non-transitive (A→B→C doesn't mean A→C)
- Verify peering is established in both directions
- Check for CIDR range overlaps between networks
- Ensure both networks are in the same project or organization
- Verify custom routes are being exported/imported if needed

### Private Access and NAT Issues
- Confirm Private Google Access is enabled on subnets
- Check Cloud NAT configuration and allocation
- Verify NAT logs for errors or rate limiting
- Ensure instances don't have external IPs if using NAT
- Check egress firewall rules that might block NAT traffic

### VPN Connectivity Problems
- Verify VPN gateways and tunnels are up
- Check shared secret matches on both ends
- Verify BGP session status if using dynamic routing
- Validate firewall rules on both cloud and on-prem
- Check for overlapping IP ranges causing routing conflicts

## Further Reading

- [VPC Documentation](https://cloud.google.com/vpc/docs)
- [VPC Network Peering](https://cloud.google.com/vpc/docs/vpc-peering)
- [Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc)
- [Cloud NAT Overview](https://cloud.google.com/nat/docs/overview)
- [Network Design Patterns](https://cloud.google.com/architecture/best-practices-vpc-design)
- [Terraform Google VPC Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)