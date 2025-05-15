# Google Cloud Architecture Framework: Security

This guide provides actionable steps, real-life examples, and best practices for architecting and operating secure services on Google Cloud. It is designed for engineers seeking practical solutions for cloud security, compliance, and automation.

---

## 1. Shared Responsibility & Security Principles
- Google secures the infrastructure; you secure your workloads, data, and configurations ([Shared Responsibility Model](https://cloud.google.com/architecture/framework/security/shared-responsibility-shared-fate)).
- Apply defense in depth: use multiple layers (IAM, encryption, network, logging).

---

## 2. Identity & Access Management (IAM)
- Use least privilege: grant only required permissions.
- Prefer groups and custom roles over individual user permissions.
- **Example: Grant a custom role to a group using Terraform:**
  ```hcl
  resource "google_project_iam_member" "devops" {
    project = var.project_id
    role    = "roles/viewer"
    member  = "group:devops@example.com"
  }
  ```
- Enable 2-step verification and enforce strong authentication.

---

## 3. Data Protection & Encryption
- All data at rest is encrypted by default (Google-managed keys).
- For sensitive workloads, use Customer-Managed Encryption Keys (CMEK) with Cloud KMS.
- **Example: Encrypt a storage bucket with CMEK:**
  ```hcl
  resource "google_storage_bucket" "secure" {
    name          = "my-secure-bucket"
    encryption {
      default_kms_key_name = google_kms_crypto_key.mykey.id
    }
  }
  ```
- Use VPC Service Controls to restrict data exfiltration.

---

## 4. Network Security
- Use VPCs and subnets to segment workloads.
- Restrict ingress/egress with firewall rules.
- Enable Private Google Access for internal workloads.
- **Example: Create a firewall rule to allow only SSH from a trusted IP:**
  ```hcl
  resource "google_compute_firewall" "ssh" {
    name    = "allow-ssh"
    network = google_compute_network.vpc.name
    allow {
      protocol = "tcp"
      ports    = ["22"]
    }
    source_ranges = ["203.0.113.0/24"]
  }
  ```
- Use Cloud Armor for DDoS and WAF protection.

---

## 5. Compute & Container Security
- Use Shielded VMs and enable OS Login for secure access.
- Regularly patch and update images (use Container Analysis for vulnerability scanning).
- **Example: Enable Binary Authorization for GKE:**
  ```hcl
  resource "google_container_cluster" "secure" {
    enable_binary_authorization = true
  }
  ```
- Use Workload Identity for secure service-to-service authentication.

---

## 6. Logging, Monitoring & Detection
- Enable Cloud Audit Logs for all services.
- Use Cloud Logging and Cloud Monitoring for real-time visibility.
- Set up alerting policies for suspicious activity.
- Integrate with Security Command Center for threat detection.

---

## 7. Compliance & Governance
- Use Organization Policy Service to enforce guardrails (e.g., restrict resource locations).
- Automate policy checks with Forseti or Config Validator.
- Document compliance requirements and map controls to Google Cloud features.

---

## 8. Real-Life Example: Secure GKE Deployment
1. Use Terraform to provision a private GKE cluster with Workload Identity.
2. Enable Binary Authorization and Cloud Armor.
3. Store secrets in Secret Manager and mount via Workload Identity.
4. Monitor with Cloud Operations Suite and set up alerting for pod failures.
5. Enforce network policies to restrict pod-to-pod communication.

---

## Best Practices
- Automate security controls with Terraform or Deployment Manager.
- Use IAM Conditions for context-aware access.
- Regularly review IAM policies and audit logs.
- Test incident response with simulated attacks (use Google Cloud's Security Health Analytics).
- Use LLMs (Copilot, Claude) to generate policy templates or analyze logs.

## Common Pitfalls
- Overly permissive IAM roles (avoid using Owner/Editor roles)
- Not enabling audit logging for all resources
- Exposing services to the public internet unintentionally
- Manual changes outside of IaC

---

## References
- [Google Cloud Security Overview](https://cloud.google.com/security/overview/whitepaper)
- [Google Cloud Security Foundations Blueprint](https://cloud.google.com/architecture/security-foundations)
- [Google Cloud IAM Docs](https://cloud.google.com/iam/docs)
- [Google Cloud KMS Docs](https://cloud.google.com/kms/docs)
- [Google Cloud VPC Docs](https://cloud.google.com/vpc/docs)
- [Google Cloud Security Command Center](https://cloud.google.com/security-command-center)
- [Google Cloud Compliance](https://cloud.google.com/security/compliance)
