---
description: Terraform configuration guide for multiple cloud providers including AWS, Azure, and GCP
keywords: terraform, configuration, AWS, Azure, GCP, IaC, infrastructure as code
---

# Terraform Configuration

This section covers Terraform configuration across multiple cloud providers. Terraform uses the HashiCorp Configuration Language (HCL) to declaratively describe your infrastructure.

## Provider Configuration

{% tabs %}
{% tab title="Azure" %}
{% code lang="hcl" %}
```hcl

# Azure Provider configuration
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id"
  tenant_id       = "your-tenant-id"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
  
  tags = {
    environment = "dev"
  }
}

```
{% endcode %}plaintext

For more details on Azure specific configurations, see the [Azure section](azure/README.md).
{% endtab %}

{% tab title="AWS" %}
{% code lang="hcl" %}
```hcl

# AWS Provider configuration
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "example-vpc"
    Environment = "dev"
  }
}

```
{% endcode %}plaintext

For more details on AWS specific configurations, see the [AWS section](aws.md).
{% endtab %}

{% tab title="GCP" %}
{% code lang="hcl" %}
```hcl

# GCP Provider configuration
provider "google" {
  credentials = file("account.json")
  project     = "your-project-id"
  region      = "us-central1"
}

# Create a GCP network
resource "google_compute_network" "example" {
  name                    = "example-network"
  auto_create_subnetworks = false
}

```
{% endcode %}plaintext

For more details on GCP specific configurations, see the [GCP section](gcp.md).
{% endtab %}
{% endtabs %}

## Backend Configuration

Your Terraform state can be stored in various backends. Choose the one that best fits your workflow:

{% tabs %}
{% tab title="Azure Storage" %}
{% code lang="hcl" %}
```hcl

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstate00123"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

```
{% endcode %}plaintext
{% endtab %}

{% tab title="S3" %}
{% code lang="hcl" %}
```hcl

terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

```
{% endcode %}plaintext
{% endtab %}

{% tab title="GCS" %}
{% code lang="hcl" %}
```hcl

terraform {
  backend "gcs" {
    bucket = "tf-state-prod"
    prefix = "terraform/state"
  }
}

```
{% endcode %}plaintext
{% endtab %}
{% endtabs %}

## Current Terraform Version

This documentation assumes Terraform version {{ book.terraformVersion }} or higher.

