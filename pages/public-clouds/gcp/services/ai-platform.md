---
description: Guide for deploying and managing Google's AI Platform services
---

# AI Platform

Google AI Platform (formerly known as Vertex AI) is a machine learning platform that allows developers and data scientists to train and deploy ML models. This guide focuses on practical deployment scenarios using Terraform and gcloud CLI.

## Key Concepts

- **Custom Models**: Train and deploy your own ML models using custom training
- **AutoML**: Automated machine learning with minimal expertise required
- **Pipelines**: ML workflow orchestration
- **Model Registry**: Version control, lineage tracking, and metadata management for models
- **Endpoints**: Deploy models for online prediction
- **Feature Store**: Store, share and serve ML features
- **Managed Notebooks**: Jupyter notebook environments for ML development

## Deploying AI Platform Resources with Terraform

### Example: Setting up an AI Platform Notebook Instance

```hcl
resource "google_project_service" "notebooks_api" {
  service = "notebooks.googleapis.com"
  disable_on_destroy = false
}

resource "google_notebooks_instance" "ml_instance" {
  name = "ml-notebook-instance"
  location = "us-central1-a"
  machine_type = "n1-standard-4"
  
  vm_image {
    project = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }
  
  install_gpu_driver = false
  boot_disk_type = "PD_SSD"
  boot_disk_size_gb = 100
  
  no_public_ip = true
  no_proxy_access = false
  
  network = "default"
  subnet = "default"
  
  depends_on = [google_project_service.notebooks_api]
}
```

### Example: Creating a Model Endpoint with Terraform

```hcl
resource "google_project_service" "aiplatform_api" {
  service = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_vertex_ai_endpoint" "prediction_endpoint" {
  display_name = "sample-prediction-endpoint"
  location     = "us-central1"
  
  depends_on = [google_project_service.aiplatform_api]
}

resource "google_vertex_ai_model" "sample_model" {
  display_name = "sample-model"
  metadata {
    artifact_uri = "gs://${google_storage_bucket.model_bucket.name}/model"
    container_spec {
      image_uri = "us-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-8:latest"
    }
  }
  region = "us-central1"
  depends_on = [google_project_service.aiplatform_api]
}

resource "google_vertex_ai_model_deployment" "default" {
  endpoint = google_vertex_ai_endpoint.prediction_endpoint.id
  model = google_vertex_ai_model.sample_model.id
  display_name = "sample-deployment"
  
  dedicated_resources {
    machine_type = "n1-standard-2"
    min_replica_count = 1
    max_replica_count = 2
  }
  
  depends_on = [
    google_vertex_ai_model.sample_model,
    google_vertex_ai_endpoint.prediction_endpoint
  ]
}

resource "google_storage_bucket" "model_bucket" {
  name          = "model-artifacts-${random_id.bucket_suffix.hex}"
  location      = "US"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
```

## Deploying AI Platform Resources with gcloud CLI

### Creating a Notebook Instance

```bash
# Enable the Notebooks API
gcloud services enable notebooks.googleapis.com

# Create a Notebook instance
gcloud notebooks instances create ml-notebook \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf-latest-cpu \
  --machine-type=n1-standard-4 \
  --location=us-central1-a \
  --boot-disk-size=100GiB \
  --no-public-ip
```

### Training a Custom Model

```bash
# Create a custom training job
gcloud ai custom-jobs create \
  --region=us-central1 \
  --display-name=my-training-job \
  --python-package-uris=gs://my-bucket/trainer.tar.gz \
  --python-module=trainer.task \
  --container-image-uri=gcr.io/cloud-aiplatform/training/tf-cpu.2-2:latest \
  --replica-count=1 \
  --machine-type=n1-standard-4
```

### Deploying a Model

```bash
# Upload model to Model Registry
gcloud ai models upload \
  --region=us-central1 \
  --display-name=my-model \
  --container-image-uri=us-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-8:latest \
  --artifact-uri=gs://my-bucket/model/

# Create an endpoint
gcloud ai endpoints create \
  --region=us-central1 \
  --display-name=my-endpoint

# Deploy model to the endpoint
gcloud ai endpoints deploy-model my-endpoint \
  --region=us-central1 \
  --model=my-model \
  --display-name=my-deployment \
  --machine-type=n1-standard-2 \
  --min-replica-count=1 \
  --max-replica-count=2 \
  --traffic-split=0=100
```

## Best Practices

1. **Cost Management**:
   - Use preemptible VMs for non-critical training jobs
   - Scale endpoints based on traffic patterns
   - Delete unused resources promptly

2. **Security**:
   - Use VPC Service Controls to restrict data access
   - Apply IAM roles with least privilege
   - Enable audit logging for AI Platform operations

3. **Performance Optimization**:
   - Select appropriate machine types for your workloads
   - Use GPU/TPU accelerators for deep learning tasks
   - Implement batch prediction for high-throughput, non-realtime needs

4. **MLOps**:
   - Implement CI/CD pipelines for model training and deployment
   - Use Vertex AI Pipelines for end-to-end ML workflows
   - Implement model monitoring for detecting drift and ensuring quality

## Common Issues and Troubleshooting

### Model Deployment Failures
- Check container compatibility with the selected machine type
- Ensure model artifacts are properly structured
- Verify IAM permissions for service accounts

### Performance Issues
- Monitor endpoint metrics for CPU/memory usage
- Check for bottlenecks in preprocessing steps
- Consider using AutoScaling policies

### Cost Overruns
- Set budget alerts for AI Platform resources
- Review usage regularly to identify idle resources
- Use spot/preemptible instances for training when possible

## Real-World Example: Sentiment Analysis Pipeline

This example demonstrates a complete end-to-end ML pipeline for sentiment analysis:

```hcl
# Terraform for sentiment analysis pipeline

# 1. Create Cloud Storage bucket for data and artifacts
resource "google_storage_bucket" "ml_bucket" {
  name          = "sentiment-analysis-${var.project_id}"
  location      = "US"
  force_destroy = true
}

# 2. Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "aiplatform.googleapis.com",
    "notebooks.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  
  service = each.key
  disable_on_destroy = false
}

# 3. Create Notebook for development
resource "google_notebooks_instance" "sentiment_notebook" {
  name = "sentiment-notebook"
  location = "us-central1-a"
  machine_type = "n1-standard-4"
  
  vm_image {
    project = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }
  
  depends_on = [google_project_service.required_apis]
}

# 4. Create AI Platform Endpoint
resource "google_vertex_ai_endpoint" "sentiment_endpoint" {
  display_name = "sentiment-analysis-endpoint"
  location     = "us-central1"
  
  depends_on = [google_project_service.required_apis]
}

# 5. Create Cloud Build trigger for CI/CD
resource "google_cloudbuild_trigger" "ml_pipeline_trigger" {
  name = "ml-pipeline-trigger"
  location = "global"
  
  github {
    owner = "owner-name"
    name  = "repo-name"
    push {
      branch = "main"
    }
  }
  
  build {
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "ai", "custom-jobs", "create",
        "--region=us-central1",
        "--display-name=sentiment-training-job",
        "--python-package-uris=gs://${google_storage_bucket.ml_bucket.name}/trainer.tar.gz",
        "--python-module=trainer.task"
      ]
    }
  }
  
  depends_on = [google_project_service.required_apis]
}
```

## Further Reading

- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [Terraform Google Provider AI Platform Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vertex_ai_endpoint)
- [ML Infrastructure Best Practices](https://cloud.google.com/architecture/ml-on-gcp-best-practices)