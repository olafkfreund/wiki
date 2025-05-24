# GCP Landing Zone: Real-World Guide for DevOps Engineers

A **Google Cloud Landing Zone** is a secure, scalable, and policy-driven GCP environment that provides a foundation for cloud adoption. It enables organizations to deploy workloads with governance, security, and compliance from day one, using best practices and automation.

---

## What is a GCP Landing Zone?

- A pre-configured GCP environment with hierarchical resource organization (folders, projects, billing accounts)
- Implements guardrails using IAM, Organization Policies, and centralized logging
- Automates project creation, baseline networking (VPCs), and security controls

**References:**

- [GCP Landing Zone Foundation](https://cloud.google.com/architecture/landing-zones)
- [Google Cloud Security Foundations Guide](https://cloud.google.com/architecture/security-foundations)

---

## Real-Life Use Cases

- **Enterprise Cloud Adoption:** Standardize environments for multiple teams or business units
- **Regulated Industries:** Enforce compliance (e.g., GDPR, HIPAA) with automated guardrails
- **Startups/Scale-ups:** Rapidly scale with secure, repeatable project structures

---

## Configuration Options

- **Resource Hierarchy:** Organization, folders, projects, billing accounts
- **Networking:** Shared VPCs, subnets, firewall rules, Private Google Access
- **Security:** IAM roles, Organization Policies, Cloud Audit Logs, Security Command Center
- **Automation:** Use Terraform, Deployment Manager, or gcloud CLI

---

## Example: GCP Landing Zone with Terraform

Below is a simplified example using Terraform to create a GCP organization folder, project, and baseline IAM policies.

```hcl
provider "google" {
  project = var.org_project
  region  = var.region
}

resource "google_folder" "engineering" {
  display_name = "Engineering"
  parent       = "organizations/${var.org_id}"
}

resource "google_project" "app" {
  name       = "app-project"
  project_id = var.project_id
  org_id     = var.org_id
  folder_id  = google_folder.engineering.id
}

resource "google_project_iam_member" "no_public_bucket" {
  project = google_project.app.project_id
  role    = "roles/storage.objectViewer"
  member  = "group:devs@example.com"
}

resource "google_organization_policy" "restrict_bucket_public_access" {
  org_id = var.org_id
  constraint = "constraints/storage.publicAccessPrevention"
  boolean_policy {
    enforced = true
  }
}
```

**Tip:** Use variables for organization IDs, project IDs, and regions for reusability.

---

## Example: Terraform Test with terraform-compliance

You can use [terraform-compliance](https://terraform-compliance.com/) to test your Terraform code for security and compliance. Example test to ensure public access to storage buckets is prevented:

```gherkin
Feature: Prevent Public Access to GCS Buckets
  Scenario: Ensure GCS buckets have public access prevention enabled
    Given I have google_storage_bucket defined
    Then it must contain public_access_prevention
    And its public_access_prevention must be "enforced"
```

---

## Notes for Linux, WSL, and NixOS Users

- **Linux:** Use the latest Terraform binary and Google Cloud SDK. Install via your package manager or [official releases](https://developer.hashicorp.com/terraform/downloads).
- **WSL:** Ensure your GCP credentials are accessible in your WSL home directory. Use `wsl --mount` for shared filesystems if needed.
- **NixOS:** Use [nixpkgs](https://search.nixos.org/packages) for reproducible installs:

  ```nix
  environment.systemPackages = with pkgs; [ terraform google-cloud-sdk ];
  ```

- Always use environment variables or [gcloud auth application-default login](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) for credentials—never hard-code secrets.

---

## Landing Zone Joke

> Why did the DevOps engineer refuse to deploy in an unprepared GCP project?
>
> Because there was no landing zone—he didn’t want to fall into the cloud!

---

For more advanced patterns, see the [GCP Security Foundations Guide](https://cloud.google.com/architecture/security-foundations) and [Terraform GCP modules](https://registry.terraform.io/namespaces/terraform-google-modules).
