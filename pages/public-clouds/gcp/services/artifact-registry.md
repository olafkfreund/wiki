---
description: Deploying and managing Google Artifact Registry for container images and packages
---

# Artifact Registry

Google Artifact Registry is a universal package manager that lets you store and manage container images and language packages (such as Maven and npm). It's an evolution of Container Registry, offering better management and security features.

## Key Features

- **Multi-format support**: Container images, language packages (Maven, npm, Python, etc.)
- **Regional storage**: Store artifacts close to your deployments
- **VPC Service Controls**: Restrict access to your artifacts
- **Integration with IAM**: Fine-grained access control
- **Container Analysis**: Vulnerability scanning
- **CMEK support**: Customer-managed encryption keys
- **Artifact dependencies**: View artifact dependencies
- **Binary Authorization**: Enforce security policies

## Deploying Artifact Registry with Terraform

### Basic Repository Creation

```hcl
resource "google_artifact_registry_repository" "my_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "my-repo"
  description   = "Docker repository for my applications"
  format        = "DOCKER"
}

# IAM policy for the repository
resource "google_artifact_registry_repository_iam_member" "repo_access" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.my_repo.location
  repository = google_artifact_registry_repository.my_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.service_account.email}"
}

# Service account that needs access
resource "google_service_account" "service_account" {
  account_id   = "artifact-user"
  display_name = "Artifact Registry User"
}
```

### Advanced Repository with CMEK

```hcl
# Create a KMS keyring and key
resource "google_kms_key_ring" "keyring" {
  name     = "artifact-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "key" {
  name     = "artifact-key"
  key_ring = google_kms_key_ring.keyring.id
}

# Grant service account access to use the key
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  
  members = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
  ]
}

# Create repository with CMEK
resource "google_artifact_registry_repository" "secure_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "secure-repo"
  description   = "Secure Docker repository with CMEK"
  format        = "DOCKER"
  
  kms_key_name = google_kms_crypto_key.key.id
  
  # Wait for KMS permissions to propagate
  depends_on = [google_kms_crypto_key_iam_binding.crypto_key]
}

# Get project information
data "google_project" "project" {}
```

### Multiple Format Repository Configuration

```hcl
# Create repositories for different artifact types
resource "google_artifact_registry_repository" "docker_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "docker-repo"
  description   = "Docker container repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "maven_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "maven-repo"
  description   = "Maven package repository"
  format        = "MAVEN"
  
  maven_config {
    version_policy = "RELEASE"
    allow_snapshot_overwrites = true
  }
}

resource "google_artifact_registry_repository" "npm_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "npm-repo"
  description   = "NPM package repository"
  format        = "NPM"
}

resource "google_artifact_registry_repository" "python_repo" {
  provider = google-beta
  
  location      = "us-central1"
  repository_id = "python-repo"
  description   = "Python package repository"
  format        = "PYTHON"
}
```

## Managing Artifact Registry with gcloud CLI

### Creating Repositories

```bash
# Create a Docker repository
gcloud artifacts repositories create docker-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker container repository"

# Create a Maven repository
gcloud artifacts repositories create maven-repo \
  --repository-format=maven \
  --location=us-central1 \
  --description="Maven package repository"

# Create an NPM repository
gcloud artifacts repositories create npm-repo \
  --repository-format=npm \
  --location=us-central1 \
  --description="NPM package repository"

# Create a Python repository
gcloud artifacts repositories create python-repo \
  --repository-format=python \
  --location=us-central1 \
  --description="Python package repository"
```

### Managing Access

```bash
# Grant read access to a service account
gcloud artifacts repositories add-iam-policy-binding docker-repo \
  --location=us-central1 \
  --member=serviceAccount:my-sa@my-project.iam.gserviceaccount.com \
  --role=roles/artifactregistry.reader

# Grant write access to a specific user
gcloud artifacts repositories add-iam-policy-binding docker-repo \
  --location=us-central1 \
  --member=user:user@example.com \
  --role=roles/artifactregistry.writer

# Grant admin access to a group
gcloud artifacts repositories add-iam-policy-binding docker-repo \
  --location=us-central1 \
  --member=group:devops@example.com \
  --role=roles/artifactregistry.admin
```

### Working with Docker Images

```bash
# Configure Docker to use Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Tag an image for Artifact Registry
docker tag my-image:latest us-central1-docker.pkg.dev/my-project/docker-repo/my-image:latest

# Push an image
docker push us-central1-docker.pkg.dev/my-project/docker-repo/my-image:latest

# Pull an image
docker pull us-central1-docker.pkg.dev/my-project/docker-repo/my-image:latest

# List images in a repository
gcloud artifacts docker images list us-central1-docker.pkg.dev/my-project/docker-repo

# Delete an image
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/my-project/docker-repo/my-image:latest
```

### Working with Maven Packages

```bash
# Configure Maven settings.xml
cat > ~/.m2/settings.xml << EOF
<settings>
  <servers>
    <server>
      <id>artifact-registry</id>
      <configuration>
        <httpConfiguration>
          <get>
            <usePreemptive>true</usePreemptive>
          </get>
        </httpConfiguration>
      </configuration>
    </server>
  </servers>
</settings>
EOF

# Set up Maven authentication
gcloud auth application-default login

# Add repository to pom.xml
cat << EOF
<repositories>
  <repository>
    <id>artifact-registry</id>
    <url>artifactregistry://us-central1-maven.pkg.dev/my-project/maven-repo</url>
    <releases>
      <enabled>true</enabled>
    </releases>
    <snapshots>
      <enabled>true</enabled>
    </snapshots>
  </repository>
</repositories>
<distributionManagement>
  <repository>
    <id>artifact-registry</id>
    <url>artifactregistry://us-central1-maven.pkg.dev/my-project/maven-repo</url>
  </repository>
</distributionManagement>
EOF

# Deploy a package
mvn deploy
```

### Working with NPM Packages

```bash
# Configure NPM
npm config set registry https://us-central1-npm.pkg.dev/my-project/npm-repo/

# Set up NPM authentication
gcloud auth application-default login
npm config set //us-central1-npm.pkg.dev/my-project/npm-repo/:_authToken "$(gcloud auth print-access-token)"

# Publish a package
npm publish

# Install a package
npm install @my-scope/my-package
```

## Real-World Example: CI/CD Pipeline with Artifact Registry

This example demonstrates a complete CI/CD pipeline using Artifact Registry:

### Step 1: Infrastructure Setup with Terraform

```hcl
# Set up repositories for different environments
resource "google_artifact_registry_repository" "dev_repo" {
  provider = google-beta
  
  location      = var.region
  repository_id = "dev-images"
  description   = "Development container images"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "prod_repo" {
  provider = google-beta
  
  location      = var.region
  repository_id = "prod-images"
  description   = "Production container images"
  format        = "DOCKER"
  
  # Enable vulnerability scanning
  docker_config {
    immutable_tags = true
  }
}

# Create service accounts for CI/CD
resource "google_service_account" "ci_account" {
  account_id   = "ci-service-account"
  display_name = "CI Pipeline Service Account"
}

resource "google_service_account" "cd_account" {
  account_id   = "cd-service-account"
  display_name = "CD Pipeline Service Account"
}

# Grant permissions to CI account (for building and pushing images)
resource "google_artifact_registry_repository_iam_member" "ci_dev_writer" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.dev_repo.location
  repository = google_artifact_registry_repository.dev_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ci_account.email}"
}

resource "google_artifact_registry_repository_iam_member" "ci_prod_writer" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.prod_repo.location
  repository = google_artifact_registry_repository.prod_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ci_account.email}"
}

# Grant permissions to CD account (for pulling images)
resource "google_artifact_registry_repository_iam_member" "cd_dev_reader" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.dev_repo.location
  repository = google_artifact_registry_repository.dev_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.cd_account.email}"
}

resource "google_artifact_registry_repository_iam_member" "cd_prod_reader" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.prod_repo.location
  repository = google_artifact_registry_repository.prod_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.cd_account.email}"
}

# Set up Cloud Build trigger for CI
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "build-and-push-image"
  description = "Build and push container image on commit"
  
  github {
    owner = "myorg"
    name  = "myrepo"
    push {
      branch = "^main$"
    }
  }
  
  substitutions = {
    _REGION = var.region
    _PROJECT_ID = var.project_id
  }
  
  filename = "cloudbuild.yaml"
  
  service_account = google_service_account.ci_account.id
}
```

### Step 2: Cloud Build Configuration (cloudbuild.yaml)

```yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA', '.']

  # Push the container image to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA']

  # Tag as latest
  - name: 'gcr.io/cloud-builders/docker'
    args: ['tag', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:latest']

  # Push latest tag
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:latest']

  # Run vulnerability scanning
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'artifacts'
      - 'docker'
      - 'images'
      - 'scan'
      - '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA'
      - '--format=json'
      - '--verbosity=info'
    id: 'Scan-Image'

  # Analyze scan results
  - name: 'gcr.io/cloud-builders/gcloud'
    script: |
      #!/bin/bash
      SCAN_RESULT=$(gcloud artifacts docker images list-vulnerabilities ${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA --format="value(vulnerability.effectiveSeverity)")
      if echo "$SCAN_RESULT" | grep -q "CRITICAL"; then
        echo "Critical vulnerabilities found. Failing build."
        exit 1
      else
        echo "No critical vulnerabilities found."
      fi
    id: 'Analyze-Scan'

  # Deploy to dev environment
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args:
      - 'run'
      - '--filename=k8s/dev/'
      - '--location=${_REGION}'
      - '--cluster=dev-cluster'
      - '--image=${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA'

# Store image in Artifact Registry
images:
  - '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:$COMMIT_SHA'
  - '${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:latest'

options:
  machineType: 'E2_HIGHCPU_8'
  dynamicSubstitutions: true
```

### Step 3: Promotion to Production (promotion.yaml)

```yaml
steps:
  # Copy from dev to prod repository with promoted tag
  - name: 'gcr.io/cloud-builders/docker'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        gcloud auth configure-docker ${_REGION}-docker.pkg.dev && \
        docker pull ${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:${_VERSION} && \
        docker tag ${_REGION}-docker.pkg.dev/${PROJECT_ID}/dev-images/myapp:${_VERSION} ${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:${_VERSION} && \
        docker push ${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:${_VERSION}

  # Tag as latest in production
  - name: 'gcr.io/cloud-builders/docker'
    args: ['tag', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:${_VERSION}', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:latest']

  # Push latest tag
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:latest']

  # Deploy to production
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args:
      - 'run'
      - '--filename=k8s/prod/'
      - '--location=${_REGION}'
      - '--cluster=prod-cluster'
      - '--image=${_REGION}-docker.pkg.dev/${PROJECT_ID}/prod-images/myapp:${_VERSION}'

substitutions:
  _VERSION: 'v1.0.0'  # This is overridden when the build is triggered

options:
  dynamicSubstitutions: true
  machineType: 'E2_HIGHCPU_8'
```

## Best Practices

1. **Repository Organization**
   - Create separate repositories for different artifact types
   - Consider environment-based repositories (dev, staging, prod)
   - Use consistent naming conventions
   - Tag images with both specific versions and "latest"

2. **Security**
   - Use fine-grained IAM roles for access control
   - Enable vulnerability scanning for container images
   - Consider VPC Service Controls for sensitive repositories
   - Implement Binary Authorization in production
   - Use immutable tags for production repositories

3. **Performance**
   - Create repositories in regions close to your build and deployment environments
   - Implement caching strategies for build pipelines
   - Use regional repositories to reduce latency
   - Consider replication for disaster recovery

4. **Operations**
   - Implement lifecycle policies to manage artifact retention
   - Set up monitoring and alerts for repository quotas
   - Track dependency graphs for complex packages
   - Regularly scan for and remediate vulnerabilities

5. **Cost Management**
   - Clean up unused artifacts regularly
   - Implement lifecycle policies to automatically delete old artifacts
   - Monitor storage usage across repositories
   - Consider compressing artifacts when possible

## Common Issues and Troubleshooting

### Authentication Problems
- Check service account permissions
- Verify that the correct authentication method is being used
- For Docker: Ensure `gcloud auth configure-docker` has been run
- For language packages: Check credential helper configuration

### Access Control Issues
- Review IAM roles assigned to users/service accounts
- Verify that repository permissions are correctly set
- Check if VPC Service Controls are blocking access
- Ensure that service accounts have the necessary permissions

### Image Push/Pull Failures
- Verify network connectivity to the repository
- Check for quota limits or restrictions
- Ensure proper authentication is configured
- Verify that the repository exists in the correct location

### Vulnerability Scanning
- Ensure Container Scanning API is enabled
- Check for false positives in scan results
- Implement appropriate remediation strategies
- Consider using distroless or minimal base images

## Further Reading

- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Terraform Google Artifact Registry Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository)
- [Container Vulnerability Scanning](https://cloud.google.com/container-analysis/docs/vulnerability-scanning)
- [Binary Authorization](https://cloud.google.com/binary-authorization/docs)