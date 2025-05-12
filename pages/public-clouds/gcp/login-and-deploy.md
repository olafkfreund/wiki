---
description: Logging in and deploying to GCP from the command line in Linux
---

# Logging in and Deploying to GCP from the Command Line (Linux)

This guide explains how to authenticate to Google Cloud Platform (GCP) and deploy resources using both the gcloud CLI and Terraform on Linux. Real-life examples are provided for each method.

## 1. Authenticating to GCP with gcloud CLI

### Install gcloud CLI

```bash
# On Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg

# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update and install
sudo apt-get update && sudo apt-get install -y google-cloud-sdk
```

### Authenticate with your Google account

```bash
gcloud auth login
```
- This opens a browser window for authentication. If running headless, use:
```bash
gcloud auth login --no-launch-browser
```

### Set your default project and region

```bash
gcloud config set project <PROJECT_ID>
gcloud config set compute/region <REGION>
gcloud config set compute/zone <ZONE>
```

### Authenticate for Terraform (Application Default Credentials)

```bash
gcloud auth application-default login
```
- This command is required for Terraform to use your credentials.

## 2. Deploying Resources with gcloud CLI

### Example: Deploy a Compute Engine VM

```bash
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server,https-server
```

### Example: Deploy a GKE (Kubernetes) Cluster

```bash
gcloud container clusters create my-gke-cluster \
  --zone=us-central1-a \
  --num-nodes=2
```

## 3. Deploying Resources with Terraform

### Example: Deploy a Compute Engine VM

#### main.tf
```hcl
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "default" {
  name         = "tf-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
```

#### variables.tf
```hcl
variable "project" {}
variable "region" {}
variable "zone" {}
```

#### terraform.tfvars
```hcl
project = "your-gcp-project-id"
region  = "us-central1"
zone    = "us-central1-a"
```

#### Deploy with Terraform
```bash
terraform init
terraform plan
terraform apply
```

### Example: Deploy a GKE (Kubernetes) Cluster

#### main.tf
```hcl
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name     = "tf-gke-cluster"
  location = var.zone

  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
  }
}
```

#### variables.tf
```hcl
variable "project" {}
variable "region" {}
variable "zone" {}
```

#### terraform.tfvars
```hcl
project = "your-gcp-project-id"
region  = "us-central1"
zone    = "us-central1-a"
```

#### Deploy with Terraform
```bash
terraform init
terraform plan
terraform apply
```

## References
- [gcloud CLI Documentation](https://cloud.google.com/sdk/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
