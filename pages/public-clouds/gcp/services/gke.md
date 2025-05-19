---
description: Deploying and managing Google Kubernetes Engine (GKE) clusters
---

# Google Kubernetes Engine (GKE)

Google Kubernetes Engine (GKE) is Google Cloud's managed Kubernetes service that provides a secure, production-ready environment for deploying containerized applications. This guide focuses on practical deployment scenarios using Terraform and gcloud CLI.

## Key Features

- **Autopilot**: Fully managed Kubernetes experience with hands-off operations
- **Standard**: More control over cluster configuration and node management
- **GKE Enterprise**: Advanced multi-cluster management and governance features
- **Auto-scaling**: Automatic scaling of node pools based on workload demand
- **Auto-upgrade**: Automated Kubernetes version upgrades
- **Multi-zone/region**: Deploy across zones/regions for high availability
- **VPC-native networking**: Uses alias IP ranges for pod networking
- **Container-Optimized OS**: Secure by default OS for GKE nodes
- **Workload Identity**: Secure access to Google Cloud services from pods

## Deploying GKE with Terraform

### Standard Cluster Deployment

```hcl
resource "google_container_cluster" "primary" {
  name               = "my-gke-cluster"
  location           = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count = 1
  
  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Network configuration
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  # IP allocation policy for VPC-native
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  
  # Release channel for auto-upgrades
  release_channel {
    channel = "REGULAR"
  }
  
  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2022-01-01T00:00:00Z"
      end_time   = "2022-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 3
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    
    # Google recommends custom service accounts with minimal permissions
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Enable workload identity on node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    labels = {
      env = "production"
    }
    
    tags = ["gke-node", "production"]
  }
}

resource "google_service_account" "gke_sa" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ])
  
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
  project = var.project_id
}

resource "google_compute_network" "vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/16"
  }
}
```

### Autopilot Cluster Deployment

```hcl
resource "google_container_cluster" "autopilot" {
  name     = "autopilot-cluster"
  location = "us-central1"
  
  # Enable Autopilot mode
  enable_autopilot = true
  
  # Network configuration
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  # IP allocation policy for VPC-native
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
  
  # Release channel (required for Autopilot)
  release_channel {
    channel = "REGULAR"
  }
  
  # Workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
```

## Deploying GKE with gcloud CLI

### Creating a Standard Cluster

```bash
# Create VPC
gcloud compute networks create gke-vpc --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create gke-subnet \
  --network=gke-vpc \
  --region=us-central1 \
  --range=10.10.0.0/16 \
  --secondary-range=pods=10.20.0.0/16,services=10.30.0.0/16

# Create service account
gcloud iam service-accounts create gke-sa --display-name="GKE Service Account"

# Assign roles
for role in roles/logging.logWriter roles/monitoring.metricWriter roles/monitoring.viewer roles/artifactregistry.reader
do
  gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
    --member="serviceAccount:gke-sa@$(gcloud config get-value project).iam.gserviceaccount.com" \
    --role="${role}"
done

# Create GKE cluster
gcloud container clusters create my-gke-cluster \
  --zone=us-central1-a \
  --network=gke-vpc \
  --subnetwork=gke-subnet \
  --cluster-secondary-range-name=pods \
  --services-secondary-range-name=services \
  --enable-ip-alias \
  --enable-private-nodes \
  --master-ipv4-cidr=172.16.0.0/28 \
  --enable-master-global-access \
  --no-enable-basic-auth \
  --release-channel=regular \
  --workload-pool=$(gcloud config get-value project).svc.id.goog \
  --no-issue-client-certificate \
  --num-nodes=1 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10 \
  --machine-type=e2-standard-4 \
  --disk-size=100 \
  --disk-type=pd-standard \
  --service-account=gke-sa@$(gcloud config get-value project).iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --metadata=disable-legacy-endpoints=true \
  --tags=gke-node,production \
  --node-labels=env=production \
  --enable-autoupgrade \
  --enable-autorepair
```

### Creating an Autopilot Cluster

```bash
# Create VPC and subnet (same as above)

# Create Autopilot cluster
gcloud container clusters create-auto autopilot-cluster \
  --region=us-central1 \
  --network=gke-vpc \
  --subnetwork=gke-subnet \
  --cluster-secondary-range-name=pods \
  --services-secondary-range-name=services \
  --enable-master-global-access \
  --release-channel=regular \
  --workload-pool=$(gcloud config get-value project).svc.id.goog
```

## Real-World Example: Deploying a Microservice Application

This example demonstrates deploying a complete microservices application to GKE:

### Step 1: Create GKE infrastructure with Terraform

```hcl
# main.tf - GKE Infrastructure

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "microservices-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "microservices-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "192.168.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "172.16.0.0/16"
  }
}

# NAT Router and Gateway for private clusters
resource "google_compute_router" "router" {
  name    = "microservices-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "microservices-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Service Account
resource "google_service_account" "gke_sa" {
  account_id   = "microservices-gke-sa"
  display_name = "Microservices GKE Service Account"
}

# IAM roles for the Service Account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ])
  
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
  project = var.project_id
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "microservices-cluster"
  location = var.region
  
  # We create a separate node pool below
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.32/28"
  }
  
  # Enable Binary Authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
  
  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Release channel
  release_channel {
    channel = "REGULAR"
  }
}

# Node Pools
resource "google_container_node_pool" "general" {
  name       = "general"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    labels = {
      role = "general"
    }
    
    taint = []
  }
}

# Create a dedicated node pool for database workloads
resource "google_container_node_pool" "database" {
  name       = "database"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  node_config {
    machine_type = "e2-highmem-4"
    disk_size_gb = 200
    disk_type    = "pd-ssd"
    
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    labels = {
      role = "database"
    }
    
    taint {
      key    = "workloadType"
      value  = "database"
      effect = "NO_SCHEDULE"
    }
  }
}

# Artifact Registry (for storing container images)
resource "google_artifact_registry_repository" "repo" {
  provider = google-beta
  
  location      = var.region
  repository_id = "microservices"
  format        = "DOCKER"
  
  # Encryption using CMEK (Customer-Managed Encryption Keys)
  kms_key_name = google_kms_crypto_key.artifact_key.id
}

# KMS Key for encrypting Artifact Registry
resource "google_kms_key_ring" "keyring" {
  name     = "microservices-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "artifact_key" {
  name     = "artifact-key"
  key_ring = google_kms_key_ring.keyring.id
}
```

### Step 2: Create Kubernetes manifests for the application

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: microservices
  labels:
    istio-injection: enabled

---
# frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: microservices
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: us-central1-docker.pkg.dev/PROJECT_ID/microservices/frontend:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /readiness
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      serviceAccountName: frontend-sa

---
# frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: microservices
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP

---
# backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: microservices
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: backend-api
        image: us-central1-docker.pkg.dev/PROJECT_ID/microservices/backend:latest
        ports:
        - containerPort: 8081
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db_host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
      serviceAccountName: backend-sa
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - backend-api
              topologyKey: "kubernetes.io/hostname"

---
# database.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: microservices
spec:
  serviceName: database
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: database
        image: us-central1-docker.pkg.dev/PROJECT_ID/microservices/postgres:13
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: POSTGRES_DB
          value: app
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
      nodeSelector:
        role: database
      tolerations:
      - key: workloadType
        operator: Equal
        value: database
        effect: NoSchedule
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "premium-rwo"
      resources:
        requests:
          storage: 100Gi

---
# ingress.yaml (using Ingress-NGINX controller)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: microservices
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-api
            port:
              number: 80
```

### Step 3: Create Deployment Pipeline (Cloud Build)

```yaml
# cloudbuild.yaml
steps:
# Build the container images
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/frontend:${_VERSION}', './frontend']

- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/backend:${_VERSION}', './backend']

# Push the container images to Artifact Registry
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/frontend:${_VERSION}']

- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/backend:${_VERSION}']

# Deploy to GKE
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'apply'
  - '-f'
  - 'kubernetes/namespace.yaml'
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=microservices-cluster'

# Create secrets
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'create'
  - 'secret'
  - 'generic'
  - 'db-credentials'
  - '--namespace=microservices'
  - '--from-literal=username=admin'
  - '--from-literal=password=${_DB_PASSWORD}'
  - '--dry-run=client'
  - '-o'
  - 'yaml'
  - '|'
  - 'kubectl'
  - 'apply'
  - '-f'
  - '-'
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=microservices-cluster'

# Update kubernetes manifests with the new image version
- name: 'gcr.io/cloud-builders/sed'
  args:
  - '-i'
  - 's|us-central1-docker.pkg.dev/PROJECT_ID/microservices/frontend:latest|us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/frontend:${_VERSION}|g'
  - 'kubernetes/frontend.yaml'

- name: 'gcr.io/cloud-builders/sed'
  args:
  - '-i'
  - 's|us-central1-docker.pkg.dev/PROJECT_ID/microservices/backend:latest|us-central1-docker.pkg.dev/${PROJECT_ID}/microservices/backend:${_VERSION}|g'
  - 'kubernetes/backend.yaml'

# Apply the Kubernetes manifests
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'apply'
  - '-f'
  - 'kubernetes/.'
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=microservices-cluster'

substitutions:
  _VERSION: '1.0.0'
  _DB_PASSWORD: 'changeme'  # Should be set via Cloud Build triggers or Secret Manager

options:
  dynamic_substitutions: true
```

## Best Practices

1. **Security**
   - Use private clusters with no public endpoint
   - Implement Workload Identity for pod-level access to Google Cloud resources
   - Apply the principle of least privilege for service accounts
   - Enable Binary Authorization for secure supply chain
   - Keep nodes and master updated with release channels

2. **Reliability**
   - Deploy across multiple zones/regions for high availability
   - Use Pod Disruption Budgets to ensure availability during maintenance
   - Implement proper health checks and readiness/liveness probes
   - Set appropriate resource requests and limits
   - Use node auto-provisioning to handle fluctuating workloads

3. **Cost Optimization**
   - Use Autopilot for hands-off management and optimized costs
   - Leverage Spot VMs for batch or fault-tolerant workloads
   - Set up cluster autoscaler to scale nodes based on demand
   - Use horizontal pod autoscaling (HPA) based on CPU/memory/custom metrics
   - Implement PodNodeSelector to ensure pods run on appropriate nodes

4. **Monitoring and Logging**
   - Enable Cloud Monitoring and Logging during cluster creation
   - Set up custom dashboards for cluster and application metrics
   - Create log-based alerts for critical issues
   - Use Cloud Trace and Profiler for application performance monitoring
   - Implement distributed tracing using OpenTelemetry

## Common Issues and Troubleshooting

### Networking Issues
- Ensure pod CIDR ranges don't overlap with VPC subnets
- Check firewall rules for master-to-node and node-to-node communication
- Verify kube-proxy is running correctly for service networking
- Use Network Policy to control pod-to-pod traffic

### Performance Problems
- Review pod resource settings (requests/limits)
- Check for node resource exhaustion (CPU, memory)
- Look for noisy neighbor issues on shared nodes
- Monitor network throughput and latency

### Deployment Failures
- Verify service account permissions
- Check image pull errors (registry access, image existence)
- Examine pod events with `kubectl describe pod`
- Review logs with `kubectl logs` or Cloud Logging

### Scaling Issues
- Ensure cluster autoscaler is properly configured
- Check if pods have appropriate resource requests
- Verify node resource availability
- Look for pod affinity/anti-affinity conflicts

## Further Reading

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GKE Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [GKE Multi-Cluster Architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/multi-cluster-architecture)