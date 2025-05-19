---
description: Deploying and managing Google Cloud Functions for serverless computing
---

# Cloud Functions

Google Cloud Functions is a lightweight, event-based, asynchronous compute solution that allows you to create small, single-purpose functions that respond to cloud events without the need to manage a server or a runtime environment.

## Key Features

- **Serverless**: No infrastructure management required
- **Event-Driven**: Triggered by Cloud events (Pub/Sub, Storage, Firestore, etc.)
- **Scalable**: Automatically scales based on load
- **Pay-per-Use**: Only pay for compute time consumed
- **Multiple Runtimes**: Support for Node.js, Python, Go, Java, .NET, Ruby, and PHP
- **Integrated Security**: IAM integration, VPC Service Controls
- **Monitoring and Logging**: Native integration with Cloud Monitoring and Logging
- **Multiple Generations**: Both 1st and 2nd generation runtimes

## Cloud Functions Generations

| Feature | Cloud Functions (1st gen) | Cloud Functions (2nd gen) |
|---------|---------------------------|--------------------------|
| Max Execution Time | 9 minutes | 60 minutes |
| Concurrency | Per-instance | Per-function, up to 1,000 |
| Minimum Instance Count | 0 | Configurable (0-100) |
| Maximum Instance Count | 3,000 | 1,000 |
| Memory | 128MB - 8GB | 256MB - 32GB |
| CPU | 0.17 - 2 vCPU | 0.5 - 8 vCPU |
| VPC Connectivity | Yes | Yes |
| Buildpacks Support | No | Yes |
| Cold Start Optimization | Limited | Advanced |

## Deploying Cloud Functions with Terraform

### Basic HTTP Function (1st gen)

```hcl
resource "google_cloudfunctions_function" "hello_world" {
  name        = "hello-world-function"
  description = "Hello World HTTP Function"
  runtime     = "nodejs16"
  
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger_http          = true
  entry_point           = "helloWorld"
  
  environment_variables = {
    ENVIRONMENT = "production"
  }
  
  # Make publicly accessible
  ingress_settings = "ALLOW_ALL"
}

# Allow unauthenticated access
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.hello_world.project
  region         = google_cloudfunctions_function.hello_world.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_storage_bucket" "function_bucket" {
  name     = "hello-world-function-bucket"
  location = "US"
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./function-source.zip"
}
```

### Advanced Pub/Sub Function (2nd gen)

```hcl
resource "google_cloudfunctions2_function" "pubsub_function" {
  name        = "pubsub-processing-function"
  location    = "us-central1"
  description = "Process messages from Pub/Sub"
  
  build_config {
    runtime     = "python310"
    entry_point = "process_message"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_code.name
      }
    }
  }
  
  service_config {
    max_instance_count = 100
    min_instance_count = 0
    available_memory   = "512M"
    timeout_seconds    = 60
    environment_variables = {
      TOPIC_NAME = google_pubsub_topic.function_topic.name
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
  }
  
  event_trigger {
    trigger_region        = "us-central1"
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.function_topic.id
    service_account_email = google_service_account.function_sa.email
    retry_policy          = "RETRY_POLICY_RETRY"
  }
}

# Create a service account for the function
resource "google_service_account" "function_sa" {
  account_id   = "pubsub-function-sa"
  display_name = "Service Account for Pub/Sub Function"
}

# Grant necessary roles
resource "google_project_iam_member" "function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Create a Pub/Sub topic
resource "google_pubsub_topic" "function_topic" {
  name = "function-trigger-topic"
}

# Storage for function code
resource "google_storage_bucket" "function_bucket" {
  name     = "pubsub-function-source"
  location = "US"
}

resource "google_storage_bucket_object" "function_code" {
  name   = "function-code.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./function-code.zip"
}
```

### Security Hardened Function with VPC Connector

```hcl
resource "google_cloudfunctions2_function" "secure_function" {
  name        = "secure-internal-function"
  location    = "us-central1"
  description = "Security-hardened internal function with VPC access"
  
  build_config {
    runtime     = "nodejs16"
    entry_point = "processSecureRequest"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.secure_function_code.name
      }
    }
    # Enable BuildPacks for container customization
    docker_repository = "projects/${var.project_id}/locations/us-central1/repositories/my-repository"
  }
  
  service_config {
    max_instance_count = 50
    min_instance_count = 1
    available_memory   = "1G"
    available_cpu      = "1"
    timeout_seconds    = 300
    
    # Connect to VPC
    vpc_connector                 = google_vpc_access_connector.connector.id
    vpc_connector_egress_settings = "ALL_TRAFFIC"
    
    # Security settings
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    
    # Use CMEK for encryption
    service_account_email = google_service_account.secure_function_sa.email
    
    # Secret environment variable
    secret_environment_variables {
      key        = "API_KEY"
      project_id = var.project_id
      secret     = google_secret_manager_secret.api_key.secret_id
      version    = "latest"
    }
    
    # Protect against traffic spikes
    max_instance_request_concurrency = 10
  }
  
  # HTTP trigger with IAM auth
  depends_on = [
    google_secret_manager_secret_version.api_key_version,
    google_secret_manager_secret_iam_member.secret_accessor,
  ]
}

# Create VPC connector
resource "google_vpc_access_connector" "connector" {
  name          = "vpc-connector"
  region        = "us-central1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.network.name
}

# Create VPC network
resource "google_compute_network" "network" {
  name                    = "function-network"
  auto_create_subnetworks = false
}

# Create subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "function-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.network.id
}

# Create service account
resource "google_service_account" "secure_function_sa" {
  account_id   = "secure-function-sa"
  display_name = "Secure Function Service Account"
}

# Grant minimal permissions
resource "google_project_iam_member" "secure_function_permissions" {
  for_each = toset([
    "roles/cloudfunctions.invoker",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])
  
  role    = each.key
  member  = "serviceAccount:${google_service_account.secure_function_sa.email}"
  project = var.project_id
}

# Create secret for API key
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"
  
  replication {
    auto {}
  }
}

# Add a version to the secret
resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = "your-api-key-value"
}

# Allow function service account to access the secret
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.secure_function_sa.email}"
}
```

## Managing Cloud Functions with gcloud CLI

### Deploying Function (1st gen)

```bash
# Create a simple HTTP function
gcloud functions deploy hello-world \
  --runtime nodejs16 \
  --trigger-http \
  --entry-point helloWorld \
  --source ./function-code/ \
  --allow-unauthenticated

# Deploy Pub/Sub triggered function
gcloud functions deploy process-messages \
  --runtime python39 \
  --trigger-topic my-topic \
  --entry-point process_message \
  --source ./function-code/ \
  --memory 512MB \
  --timeout 120s

# Deploy a function with environment variables
gcloud functions deploy db-processor \
  --runtime go116 \
  --trigger-http \
  --entry-point ProcessRequest \
  --source ./go-function/ \
  --set-env-vars DB_HOST=10.0.0.1,DB_NAME=mydb,ENV=production
```

### Deploying Function (2nd gen)

```bash
# Deploy HTTP function with 2nd gen features
gcloud functions deploy hello-world-v2 \
  --gen2 \
  --runtime nodejs16 \
  --trigger-http \
  --entry-point helloWorld \
  --source ./function-code/ \
  --min-instances 1 \
  --max-instances 10 \
  --memory 512MB \
  --cpu 1 \
  --concurrency 20 \
  --allow-unauthenticated

# Deploy with VPC connector
gcloud functions deploy vpc-function \
  --gen2 \
  --runtime python39 \
  --trigger-http \
  --entry-point handle_request \
  --source ./function-code/ \
  --vpc-connector projects/my-project/locations/us-central1/connectors/my-connector \
  --egress-settings all-traffic
```

### Managing Functions

```bash
# List functions
gcloud functions list

# Get function details
gcloud functions describe my-function

# View function logs
gcloud functions logs read my-function

# Delete a function
gcloud functions delete my-function

# Add IAM policy binding
gcloud functions add-iam-policy-binding my-function \
  --member="user:user@example.com" \
  --role="roles/cloudfunctions.invoker"
```

## Real-World Example: Serverless Image Processing Pipeline

This example demonstrates a complete serverless image processing pipeline using Cloud Functions:

### Architecture Overview

1. User uploads image to Cloud Storage
2. First function is triggered to validate and extract metadata
3. Valid images trigger a Pub/Sub message
4. Second function performs image processing (resize, optimize)
5. Processed images are stored in an output bucket
6. Metadata is saved to Firestore

### Terraform Implementation

```hcl
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Create Storage Buckets
resource "google_storage_bucket" "input_bucket" {
  name          = "${var.project_id}-image-input"
  location      = "US"
  storage_class = "STANDARD"
  
  # Delete files after processing (7 days)
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
  
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "output_bucket" {
  name          = "${var.project_id}-image-output"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  
  cors {
    origin          = ["https://example.com"]
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

# Create function source bucket
resource "google_storage_bucket" "function_code" {
  name          = "${var.project_id}-function-code"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
}

# Upload source code for validation function
resource "google_storage_bucket_object" "validation_function_code" {
  name   = "validation-function-${data.archive_file.validation_function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_code.name
  source = data.archive_file.validation_function_zip.output_path
}

# Upload source code for processing function
resource "google_storage_bucket_object" "processing_function_code" {
  name   = "processing-function-${data.archive_file.processing_function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_code.name
  source = data.archive_file.processing_function_zip.output_path
}

# Zip the function code
data "archive_file" "validation_function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function-code/validation"
  output_path = "/tmp/validation-function.zip"
}

data "archive_file" "processing_function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function-code/processing"
  output_path = "/tmp/processing-function.zip"
}

# Create Pub/Sub topic
resource "google_pubsub_topic" "image_processing_topic" {
  name = "image-processing"
}

# Create service account for functions
resource "google_service_account" "function_service_account" {
  account_id   = "image-processing-sa"
  display_name = "Image Processing Function Service Account"
}

# Grant permissions to service account
resource "google_project_iam_member" "function_permissions" {
  for_each = toset([
    "roles/storage.objectViewer", 
    "roles/storage.objectCreator", 
    "roles/pubsub.publisher", 
    "roles/pubsub.subscriber", 
    "roles/firestore.documentUser"
  ])
  
  role   = each.key
  member = "serviceAccount:${google_service_account.function_service_account.email}"
}

# Deploy validation function (1st gen - simplicity for metadata extraction)
resource "google_cloudfunctions_function" "image_validation_function" {
  name        = "image-validation"
  description = "Validates uploaded images and extracts metadata"
  runtime     = "nodejs16"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_code.name
  source_archive_object = google_storage_bucket_object.validation_function_code.name
  entry_point           = "validateImage"
  service_account_email = google_service_account.function_service_account.email
  
  # Trigger on new files in the input bucket
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.input_bucket.name
  }
  
  environment_variables = {
    TOPIC_NAME   = google_pubsub_topic.image_processing_topic.name
    PROJECT_ID   = var.project_id
    MIN_WIDTH    = "200"
    MIN_HEIGHT   = "200"
    ALLOWED_TYPES = "image/jpeg,image/png,image/webp"
  }
}

# Deploy processing function (2nd gen - more power for image manipulation)
resource "google_cloudfunctions2_function" "image_processing_function" {
  name        = "image-processing"
  description = "Processes images based on configuration"
  location    = "us-central1"
  
  build_config {
    runtime     = "nodejs16"
    entry_point = "processImage"
    source {
      storage_source {
        bucket = google_storage_bucket.function_code.name
        object = google_storage_bucket_object.processing_function_code.name
      }
    }
  }
  
  service_config {
    max_instance_count    = 10
    min_instance_count    = 1
    available_memory      = "1024M"
    available_cpu         = "1"
    timeout_seconds       = 300
    service_account_email = google_service_account.function_service_account.email
    
    environment_variables = {
      INPUT_BUCKET  = google_storage_bucket.input_bucket.name
      OUTPUT_BUCKET = google_storage_bucket.output_bucket.name
      SIZES         = "thumbnail=150x150,small=300x300,medium=800x600"
    }
    
    # Processing can handle multiple concurrent requests
    max_instance_request_concurrency = 5
  }
  
  event_trigger {
    trigger_region = "us-central1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.image_processing_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

# Enable Firestore API
resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
  
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Configure Firestore
resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = "(default)"
  location_id = "nam5"
  type        = "FIRESTORE_NATIVE"
  
  depends_on = [google_project_service.firestore]
}
```

### Node.js Validation Function

```javascript
// validation-function/index.js
const { Storage } = require('@google-cloud/storage');
const { PubSub } = require('@google-cloud/pubsub');
const { Firestore } = require('@google-cloud/firestore');
const sharp = require('sharp');

const storage = new Storage();
const pubsub = new PubSub();
const firestore = new Firestore();

// Environment variables
const topicName = process.env.TOPIC_NAME;
const projectId = process.env.PROJECT_ID;
const minWidth = parseInt(process.env.MIN_WIDTH || '200');
const minHeight = parseInt(process.env.MIN_HEIGHT || '200');
const allowedTypes = (process.env.ALLOWED_TYPES || 'image/jpeg,image/png').split(',');

exports.validateImage = async (file, context) => {
  // Skip if this is a deletion event
  if (!file.contentType) return;
  
  // Check if file is an image
  if (!allowedTypes.includes(file.contentType)) {
    console.log(`File ${file.name} has invalid content type: ${file.contentType}`);
    await logRejection(file, 'invalid_type');
    return;
  }
  
  try {
    // Download the file
    const bucket = storage.bucket(file.bucket);
    const tempFilePath = `/tmp/${file.name.split('/').pop()}`;
    
    await bucket.file(file.name).download({ destination: tempFilePath });
    
    // Get metadata with Sharp
    const metadata = await sharp(tempFilePath).metadata();
    
    // Validate dimensions
    if (metadata.width < minWidth || metadata.height < minHeight) {
      console.log(`Image ${file.name} dimensions too small: ${metadata.width}x${metadata.height}`);
      await logRejection(file, 'dimensions_too_small');
      return;
    }
    
    // Store metadata in Firestore
    const imageDoc = {
      fileName: file.name,
      contentType: file.contentType,
      size: file.size,
      md5Hash: file.md5Hash,
      width: metadata.width,
      height: metadata.height,
      format: metadata.format,
      createdAt: context.timestamp,
      status: 'validated',
      outputVersions: []
    };
    
    await firestore.collection('images').doc(file.name.replace(/[\/\.]/g, '_')).set(imageDoc);
    
    // Publish message to trigger processing
    const topic = pubsub.topic(topicName);
    const messageData = {
      fileName: file.name,
      bucket: file.bucket,
      contentType: file.contentType,
      metadata: {
        width: metadata.width,
        height: metadata.height,
        format: metadata.format
      }
    };
    
    await topic.publish(Buffer.from(JSON.stringify(messageData)));
    console.log(`Published message for ${file.name}`);
    
  } catch (error) {
    console.error(`Error processing ${file.name}:`, error);
    await logRejection(file, 'processing_error');
  }
};

async function logRejection(file, reason) {
  await firestore.collection('rejected_images').doc(file.name.replace(/[\/\.]/g, '_')).set({
    fileName: file.name,
    contentType: file.contentType,
    size: file.size,
    reason: reason,
    timestamp: new Date()
  });
}
```

### Node.js Processing Function

```javascript
// processing-function/index.js
const { Storage } = require('@google-cloud/storage');
const { Firestore } = require('@google-cloud/firestore');
const sharp = require('sharp');
const path = require('path');
const os = require('os');
const fs = require('fs').promises;

const storage = new Storage();
const firestore = new Firestore();

// Environment variables
const inputBucket = process.env.INPUT_BUCKET;
const outputBucket = process.env.OUTPUT_BUCKET;
const sizeConfigs = parseSizeConfigs(process.env.SIZES || 'thumbnail=150x150');

/**
 * Process an image when a message is published to Pub/Sub
 */
exports.processImage = async (message, context) => {
  // Decode the Pub/Sub message
  const data = message.data 
    ? JSON.parse(Buffer.from(message.data, 'base64').toString())
    : {};
    
  const { fileName, bucket, contentType, metadata } = data;
  
  if (!fileName || !bucket || !contentType) {
    console.error('Missing required message data');
    return;
  }
  
  const tempLocalPath = path.join(os.tmpdir(), path.basename(fileName));
  const outputPaths = [];
  
  try {
    // Download the original file
    await storage.bucket(bucket).file(fileName).download({ destination: tempLocalPath });
    console.log(`Downloaded ${fileName} to ${tempLocalPath}`);
    
    // Process each configured size
    for (const [sizeName, dimensions] of Object.entries(sizeConfigs)) {
      const outputFileName = generateOutputFileName(fileName, sizeName);
      const tempOutputPath = path.join(os.tmpdir(), outputFileName);
      
      // Resize the image
      await sharp(tempLocalPath)
        .resize({
          width: dimensions.width,
          height: dimensions.height,
          fit: sharp.fit.cover,
          position: sharp.strategy.attention
        })
        .toFile(tempOutputPath);
      
      // Upload the resized image
      await storage.bucket(outputBucket).upload(tempOutputPath, {
        destination: outputFileName,
        metadata: {
          contentType,
          metadata: {
            originalImage: fileName,
            sizeName,
            width: dimensions.width.toString(),
            height: dimensions.height.toString()
          }
        }
      });
      
      // Clean up temp file
      await fs.unlink(tempOutputPath);
      
      // Record the output version
      outputPaths.push({
        sizeName,
        path: outputFileName,
        width: dimensions.width,
        height: dimensions.height,
        bucket: outputBucket
      });
    }
    
    // Optimize the original and upload as "full" size
    const optimizedPath = path.join(os.tmpdir(), `optimized-${path.basename(fileName)}`);
    await sharp(tempLocalPath)
      .withMetadata()
      .jpeg({ quality: 85 })
      .toFile(optimizedPath);
    
    await storage.bucket(outputBucket).upload(optimizedPath, {
      destination: `full/${path.basename(fileName)}`,
      metadata: {
        contentType,
        metadata: {
          originalImage: fileName,
          sizeName: 'full',
          optimized: 'true'
        }
      }
    });
    
    // Add full size to outputs
    outputPaths.push({
      sizeName: 'full',
      path: `full/${path.basename(fileName)}`,
      width: metadata.width,
      height: metadata.height,
      bucket: outputBucket
    });
    
    // Update metadata in Firestore
    await firestore.collection('images')
      .doc(fileName.replace(/[\/\.]/g, '_'))
      .update({
        status: 'processed',
        processedAt: new Date(),
        outputVersions: outputPaths
      });
    
    console.log(`Successfully processed ${fileName} into ${outputPaths.length} sizes`);
    
    // Clean up the temp file
    await fs.unlink(tempLocalPath);
    await fs.unlink(optimizedPath);
    
  } catch (error) {
    console.error(`Error processing image ${fileName}:`, error);
    
    // Update Firestore with error
    await firestore.collection('images')
      .doc(fileName.replace(/[\/\.]/g, '_'))
      .update({
        status: 'error',
        errorMessage: error.message,
        errorAt: new Date()
      });
  }
};

/**
 * Parse size configurations from environment variable
 * Format: "name=widthxheight,name2=widthxheight"
 */
function parseSizeConfigs(sizesString) {
  const configs = {};
  
  sizesString.split(',').forEach(sizeConfig => {
    const [name, dimensions] = sizeConfig.trim().split('=');
    
    if (name && dimensions) {
      const [width, height] = dimensions.split('x').map(Number);
      
      if (width && height) {
        configs[name] = { width, height };
      }
    }
  });
  
  return configs;
}

/**
 * Generate output file name based on original and size name
 */
function generateOutputFileName(originalName, sizeName) {
  const ext = path.extname(originalName);
  const baseName = path.basename(originalName, ext);
  return `${sizeName}/${baseName}-${sizeName}${ext}`;
}
```

## Best Practices

1. **Function Design**
   - Keep functions small and focused on a single task
   - Separate business logic from function handler
   - Use environment variables for configuration
   - Implement proper error handling and retry logic
   - Design for idempotency to handle duplicate events

2. **Performance Optimization**
   - Use global variables efficiently (initialize outside handler)
   - Optimize cold starts with minimum instances (2nd gen)
   - Consider connection pooling for database access
   - Use appropriate memory allocation for function workload
   - Leverage concurrent execution where appropriate

3. **Security**
   - Apply least privilege principle to function service accounts
   - Store secrets in Secret Manager, not environment variables
   - Use VPC Service Controls for sensitive workloads
   - Consider using Container-based deployments for custom dependencies
   - Enable IAM authentication for HTTP functions

4. **Monitoring and Observability**
   - Implement structured logging with appropriate severity levels
   - Set up Cloud Monitoring alerts for errors and latency
   - Use custom metrics for business-specific data points
   - Implement distributed tracing for complex workflows
   - Configure uptime checks for critical HTTP functions

5. **Cost Optimization**
   - Right-size memory allocation based on function needs
   - Set appropriate function timeout limits
   - Use minimum instances only when cold starts are problematic
   - Avoid unnecessary network egress
   - Monitor execution time and optimize long-running functions

## Common Issues and Troubleshooting

### Cold Start Latency
- Use minimum instances for critical functions (2nd gen)
- Optimize function size by removing unnecessary dependencies
- Consider splitting large functions into smaller ones
- Use lightweight languages (Go, Node.js) for time-sensitive functions
- Keep connection initialization outside the function handler

### Memory Issues
- Monitor memory usage in Cloud Monitoring
- Increase memory allocation if functions are hitting limits
- Watch for memory leaks in long-running functions
- Be careful with large in-memory data structures
- Consider streaming approaches for large file processing

### Timeout Issues
- Break long-running tasks into smaller functions
- Use Pub/Sub or Task queues for background processing
- Implement proper cancellation handling
- Consider Cloud Run for longer-running processes
- Use 2nd generation functions for workloads requiring up to 60 minutes

### Networking Issues
- Use VPC connector for accessing internal resources
- Check egress settings for functions needing external access
- Monitor network latency in Cloud Monitoring
- Consider regional deployment to minimize latency
- Check for connection limits when accessing databases

## Further Reading

- [Cloud Functions Documentation](https://cloud.google.com/functions/docs)
- [Cloud Functions 2nd Gen Overview](https://cloud.google.com/functions/docs/2nd-gen/overview)
- [Terraform Google Cloud Functions Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function)
- [Terraform Google Cloud Functions 2nd Gen Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function)
- [Serverless Architectural Patterns](https://cloud.google.com/architecture/serverless-design-patterns)