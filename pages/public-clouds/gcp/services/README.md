---
description: Overview of key GCP services and deployment methods
---

# GCP Services

This section contains detailed guides for deploying and managing common GCP services using both Terraform and the gcloud CLI on Linux environments.

## Container Services

- [Google Kubernetes Engine (GKE)](gke.md) - Managed Kubernetes service
- [Cloud Run](cloud-run.md) - Serverless containers
- [Artifact Registry](artifact-registry.md) - Container and artifact registry

## Compute Services

- [Compute Engine](compute-engine.md) - Virtual machines in the cloud
- [Cloud Functions](cloud-functions.md) - Serverless event-driven compute
- [App Engine](app-engine.md) - Platform as a Service (PaaS)

## Storage Services

- [Cloud Storage](cloud-storage.md) - Object storage service
- [Persistent Disk](persistent-disk.md) - Block storage for VMs
- [Filestore](filestore.md) - Managed file storage

## Database Services

- [Cloud SQL](cloud-sql.md) - Managed relational databases
- [Cloud Spanner](cloud-spanner.md) - Globally distributed SQL database
- [Firestore](firestore.md) - NoSQL document database
- [Bigtable](bigtable.md) - Wide-column NoSQL database
- [BigQuery](bigquery.md) - Serverless data warehouse

## Networking Services

- [VPC (Virtual Private Cloud)](vpc.md) - Isolated cloud resources
- [Cloud Load Balancing](cloud-load-balancing.md) - Global/regional load balancing
- [Cloud CDN](cloud-cdn.md) - Content delivery network
- [Cloud DNS](cloud-dns.md) - Managed DNS

## Each guide includes:

1. Service overview and key concepts
2. Terraform deployment examples
3. gcloud CLI deployment commands
4. Best practices
5. Common issues and troubleshooting

These guides are designed to help you deploy GCP resources programmatically using Infrastructure as Code (IaC) principles with Terraform or command-line automation with gcloud CLI.
