# GitLab Runner

## Overview

GitLab Runner is the agent that executes CI/CD jobs in the GitLab ecosystem. It runs the scripts defined in `.gitlab-ci.yml` files and reports the results back to GitLab. GitLab Runners can be installed on various platforms, from virtual machines and containers to Kubernetes clusters and serverless environments.

## Key Features

- **Distributed execution**: Run jobs on multiple machines simultaneously
- **Autoscaling**: Dynamically provision runners based on workload
- **Multiple executor options**: Shell, Docker, Kubernetes, Virtual Machine, SSH, and more
- **Job concurrency**: Configure the number of concurrent jobs per runner
- **Custom environment variables**: Pass environment-specific data to jobs
- **Artifact management**: Handle job output files automatically
- **Caching support**: Speed up builds by caching dependencies

## Installation Guide

### Linux Installation

#### Standard Linux Installation (Debian/Ubuntu)

```bash
# Add the GitLab repository
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

# Install the latest version
sudo apt-get install gitlab-runner

# Register the runner with your GitLab instance
sudo gitlab-runner register
```

Follow the interactive registration process:
1. Enter your GitLab instance URL
2. Enter the registration token from your GitLab project/group settings
3. Enter a description for the runner
4. Add tags (optional but recommended for job targeting)
5. Choose an executor (docker, shell, etc.)

#### RHEL/CentOS/Fedora Installation

```bash
# Add the GitLab repository
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash

# Install the latest version
sudo dnf install gitlab-runner

# Register the runner
sudo gitlab-runner register
```

### WSL Installation

Installing GitLab Runner in WSL combines the flexibility of Linux with integration into Windows environments:

```bash
# Update package lists
sudo apt update

# Install prerequisites
sudo apt install curl

# Download the GitLab Runner binary
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"

# Set execute permissions
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

# Register the runner
sudo gitlab-runner register
```

#### WSL-Specific Considerations

1. Ensure that Windows Defender or other security software doesn't block GitLab Runner
2. Configure WSL to maintain a persistent connection if needed with task scheduler:

```powershell
# Create a scheduled task to keep WSL running (execute in PowerShell as Admin)
$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-- sleep infinity"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
Register-ScheduledTask -TaskName "Keep WSL Running" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM" -RunLevel Highest
```

### NixOS Installation

NixOS offers a declarative approach to system configuration, making GitLab Runner setup reproducible and version-controlled.

#### NixOS Configuration

Add the following to your `configuration.nix` file:

```nix
{ config, pkgs, ... }:

{
  # Enable GitLab Runner service
  services.gitlab-runner = {
    enable = true;
    
    # Configure runners
    # You can add multiple runners with different configurations
    settings = {
      concurrent = 4;  # Number of concurrent jobs
      check_interval = 0;
    };
    
    # Define a runner
    runners = [
      {
        name = "nixos-runner";
        # Environment variables available to the build
        environment = [ "PATH=/run/wrappers/bin:/nix/var/nix/profiles/default/bin" ];
        # GitLab instance URL - replace with your instance
        url = "https://gitlab.example.com";
        # Registration token from GitLab
        registrationConfigFile = "/var/lib/gitlab-runner/registration-token";
        # Runner executor
        executor = "shell";
        # Tags for job selection
        tagList = [ "nixos" "linux" ];
        # Run as unprivileged user
        runUntagged = true;
        # Whether to run untagged jobs
        protected = false;
      }
    ];
  };
  
  # Open necessary ports for GitLab communication
  networking.firewall.allowedTCPPorts = [ 9252 ];
  
  # Add the gitlab-runner user to docker group if using Docker executor
  users.users.gitlab-runner.extraGroups = [ "docker" ];
  virtualisation.docker.enable = true;  # If using Docker executor
}
```

Create the registration token file:

```bash
sudo mkdir -p /var/lib/gitlab-runner
echo "YOUR_RUNNER_REGISTRATION_TOKEN" | sudo tee /var/lib/gitlab-runner/registration-token
sudo chmod 600 /var/lib/gitlab-runner/registration-token
```

Apply the configuration:

```bash
sudo nixos-rebuild switch
```

## Real-Life Scenarios (2025 Best Practices)

### Scenario 1: Multi-Environment CI/CD Pipeline for Microservices

**Challenge:** A team manages a microservices architecture spanning development, staging, and production environments across multiple cloud providers.

**Solution with GitLab Runner:**

1. **Environment-Specific Runners:**

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy-dev
  - deploy-staging
  - deploy-prod

variables:
  DOCKER_REGISTRY: "${CI_REGISTRY}"
  
test:
  stage: test
  image: node:18-alpine
  tags:
    - docker
  script:
    - npm ci
    - npm run test
  cache:
    paths:
      - node_modules/

build:
  stage: build
  image: docker:24.0
  tags:
    - docker
  services:
    - docker:24.0-dind
  script:
    - docker build -t ${DOCKER_REGISTRY}/${CI_PROJECT_PATH}:${CI_COMMIT_SHA} .
    - docker push ${DOCKER_REGISTRY}/${CI_PROJECT_PATH}:${CI_COMMIT_SHA}
  only:
    - main
    - tags

deploy-dev:
  stage: deploy-dev
  image: 
    name: bitnami/kubectl:1.28
    entrypoint: [""]
  tags:
    - kubernetes
    - dev
  script:
    - echo "${KUBE_CONFIG_DEV}" > kubeconfig
    - export KUBECONFIG=./kubeconfig
    - envsubst < kubernetes/dev.yaml | kubectl apply -f -
  environment:
    name: development
    url: https://dev.example.com
  only:
    - main

# Similar configurations for staging and production stages with different tags
```

2. **Runner Configuration:**

```toml
# config.toml for dedicated environment runners
concurrent = 10
check_interval = 0

[[runners]]
  name = "dev-kubernetes-runner"
  url = "https://gitlab.example.com"
  token = "TOKEN"
  executor = "kubernetes"
  [runners.kubernetes]
    namespace = "gitlab-runners"
    image = "ubuntu:22.04"
    service_account = "gitlab-runner"
    service_account_overwrite_allowed = "gitlab-runner"
    pod_annotations_overwrite_allowed = "*"
    cpu_limit = "1"
    memory_limit = "1Gi"
    helper_cpu_limit = "200m"
    helper_memory_limit = "256Mi"
    poll_interval = 5
    resource_availability_check_interval = 1

[[runners]]
  name = "prod-kubernetes-runner"
  url = "https://gitlab.example.com"
  token = "TOKEN"
  executor = "kubernetes"
  tags = ["kubernetes", "production"]
  [runners.kubernetes]
    namespace = "gitlab-runners-prod"
    # Enhanced security for production
    privileged = false
    # Production runner with higher resource limits
    cpu_limit = "2"
    memory_limit = "4Gi"
    # Use node selector for production grade nodes
    node_selector = "env=production"
    service_account = "gitlab-runner-prod"
```

### Scenario 2: Secure Infrastructure as Code Deployment

**Challenge:** Securely deploy infrastructure changes with appropriate approval gates and compliance checks.

**Solution with GitLab Runner:**

```yaml
# .gitlab-ci.yml for Terraform deployment
stages:
  - validate
  - plan
  - apply
  - verify

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_STATE_NAME: ${CI_PROJECT_PATH_SLUG}
  TF_CACHE_KEY: ${CI_COMMIT_REF_SLUG}
  TF_VAR_environment: ${CI_ENVIRONMENT_NAME}

# Include secure scanning templates
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Jobs/Infrastructure-as-Code-Security.gitlab-ci.yml

validate:
  stage: validate
  image: hashicorp/terraform:1.7
  tags:
    - docker
    - secure
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform validate
    - terraform fmt -check
  cache:
    key: ${TF_CACHE_KEY}
    paths:
      - ${TF_ROOT}/.terraform

terraform-plan:
  stage: plan
  image: hashicorp/terraform:1.7
  tags:
    - docker
    - secure
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan
    expire_in: 1 week
  cache:
    key: ${TF_CACHE_KEY}
    paths:
      - ${TF_ROOT}/.terraform
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

# The apply job requires approval before execution (2025 best practice)
terraform-apply:
  stage: apply
  image: hashicorp/terraform:1.7
  tags:
    - docker
    - secure
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform apply -auto-approve tfplan
  dependencies:
    - terraform-plan
  when: manual
  environment:
    name: production
    url: https://console.example.cloud/projects/${TF_VAR_project_id}
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  cache:
    key: ${TF_CACHE_KEY}
    paths:
      - ${TF_ROOT}/.terraform

# Verify infrastructure after deployment
verify-infrastructure:
  stage: verify
  image: python:3.12-alpine
  tags:
    - docker
  script:
    - pip install pytest boto3 azure-identity azure-mgmt-resource google-cloud-resource-manager
    - cd ${CI_PROJECT_DIR}/tests
    - python -m pytest -xvs infra_tests.py
  dependencies:
    - terraform-apply
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: on_success
```

### Scenario 3: Auto-Scaling Cloud Runners for Cost Optimization

**Challenge:** Managing pipeline costs while ensuring sufficient capacity for peak times.

**Solution with GitLab Runner on AWS/Azure/GCP:**

#### AWS Auto-Scaling Configuration (Terraform)

```hcl
# AWS auto-scaling GitLab Runners with Terraform

resource "aws_launch_template" "gitlab_runner" {
  name_prefix   = "gitlab-runner-"
  image_id      = "ami-0123456789abcdef0" # Amazon Linux 2 AMI
  instance_type = "c6a.large"  # AMD-based instances for better cost/performance
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    
    # Install GitLab Runner
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | bash
    yum install -y gitlab-runner
    
    # Register the runner with auto-scaling configuration
    gitlab-runner register \
      --non-interactive \
      --url "https://gitlab.example.com/" \
      --registration-token "${var.runner_token}" \
      --executor "docker+machine" \
      --docker-image "alpine:latest" \
      --description "Auto-scaling Runner" \
      --tag-list "aws,auto-scale" \
      --run-untagged="true" \
      --locked="false" \
      --access-level="not_protected" \
      --docker-privileged \
      --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
      --machine-idle-nodes 1 \
      --machine-idle-time 1800 \
      --machine-max-builds 100 \
      --machine-machine-driver "amazonec2" \
      --machine-machine-name "gitlab-docker-machine-%s" \
      --machine-machine-options "amazonec2-instance-type=c6a.large" \
      --machine-machine-options "amazonec2-region=${var.aws_region}" \
      --machine-machine-options "amazonec2-vpc-id=${var.vpc_id}" \
      --machine-machine-options "amazonec2-subnet-id=${var.subnet_id}" \
      --machine-machine-options "amazonec2-use-private-address=true" \
      --machine-machine-options "amazonec2-security-group=${var.security_group}" \
      --machine-machine-options "amazonec2-tags=runner,gitlab,${var.environment}"
  EOF
  )
  
  iam_instance_profile {
    name = aws_iam_instance_profile.gitlab_runner.name
  }
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "GitLab Runner"
      Environment = var.environment
      ManagedBy = "Terraform"
    }
  }
}

resource "aws_autoscaling_group" "gitlab_runner" {
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids
  
  launch_template {
    id      = aws_launch_template.gitlab_runner.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "GitLab Runner"
    propagate_at_launch = true
  }
  
  # Scale based on average CPU utilization
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
```

### Scenario 4: Secure GitLab Runners for Sensitive Workloads

**Challenge:** Running CI/CD pipelines for high-security environments with strict compliance requirements.

**Solution:**

1. Configure isolated, dedicated runners with enhanced security settings:

```toml
# config.toml for secure runners
concurrent = 4
check_interval = 0

[[runners]]
  name = "secure-compliant-runner"
  url = "https://gitlab.example.com"
  token = "TOKEN"
  executor = "docker"
  [runners.docker]
    tls_verify = true
    image = "alpine:3.19"
    privileged = false
    disable_entrypoint_overwrite = true
    oom_kill_disable = false
    disable_cache = true
    volumes = ["/cache"]
    shm_size = 0
    network_mode = "bridge"
  [runners.cache]
    Type = "s3"
    Shared = false
    [runners.cache.s3]
      ServerAddress = "s3.amazonaws.com"
      AccessKey = "${S3_ACCESS_KEY}"
      SecretKey = "${S3_SECRET_KEY}"
      BucketName = "gitlab-runner-cache"
      BucketLocation = "us-east-1"
      Insecure = false
      Encrypted = true
```

2. Pipeline configuration for sensitive workloads:

```yaml
# .gitlab-ci.yml for sensitive workloads
stages:
  - security-scan
  - test
  - build
  - deploy

# Include security scanning templates
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - template: Security/License-Scanning.gitlab-ci.yml

variables:
  # Enhance security features
  SECURE_ANALYZERS_PREFIX: "registry.gitlab.com/security-products"
  SCAN_KUBERNETES_MANIFESTS: "true"

# Interactive Application Security Testing
dast:
  stage: security-scan
  tags:
    - secure
    - compliant
  image:
    name: "${SECURE_ANALYZERS_PREFIX}/dast:latest"
  variables:
    DAST_WEBSITE: https://staging.example.com
    DAST_FULL_SCAN_ENABLED: "true"
    DAST_ZAP_USE_AJAX_SPIDER: "true"
    DAST_REQUEST_HEADERS: "Cache-Control: no-cache,User-Agent: DAST/1.0"
    # Add authentication if needed
    # DAST_AUTH_URL: https://staging.example.com/login
    # DAST_USERNAME: ${SECURITY_USERNAME}
    # DAST_PASSWORD: ${SECURITY_PASSWORD}
  allow_failure: false
  artifacts:
    reports:
      dast: gl-dast-report.json

# Secure build process
build:
  stage: build
  tags:
    - secure
    - compliant
  image: docker:24.0
  services:
    - name: docker:24.0-dind
      command: ["--tls=true", "--tlscert=/certs/server.pem", "--tlskey=/certs/server-key.pem"]
  script:
    # Sign the build for supply chain security
    - apk add --no-cache cosign
    - docker build -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA} .
    - echo "${CI_REGISTRY_PASSWORD}" | docker login -u ${CI_REGISTRY_USER} --password-stdin ${CI_REGISTRY}
    - docker push ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
    - cosign sign --key ${COSIGN_KEY} ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
  artifacts:
    reports:
      container_scanning: gl-container-scanning-report.json

# Deploy using zero-trust principles
deploy:
  stage: deploy
  tags:
    - secure
    - compliant
  image: 
    name: bitnami/kubectl:1.28
    entrypoint: [""]
  variables:
    VERIFY_TLS: "true"
  script:
    # Use short-lived credentials
    - export TOKEN=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X POST $VAULT_ADDR/v1/auth/kubernetes/login -d '{"role":"gitlab-deploy","jwt":"'$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)'"}' | jq -r '.auth.client_token')
    # Get environment-specific configs from vault
    - export KUBECONFIG=$(curl -H "X-Vault-Token: $TOKEN" -X GET $VAULT_ADDR/v1/secret/data/kubernetes/config | jq -r '.data.data.kubeconfig' > kubeconfig && echo ./kubeconfig)
    # Verify image signature before deployment
    - cosign verify --key ${COSIGN_PUBLIC_KEY} ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
    # Deploy with strict security context
    - envsubst < kubernetes/deploy-secure.yaml | kubectl apply -f -
  environment:
    name: production
    url: https://example.com
  when: manual
```

## Best Practices for GitLab Runners (2025)

### Security Best Practices

1. **Zero Trust Architecture**:
   - Implement Workload Identity Federation instead of static tokens
   - Use short-lived credentials for cloud resource access
   - Verify all artifacts with digital signatures

2. **Runner Isolation**:
   - Use dedicated runners for sensitive projects
   - Implement network segmentation for runner environments
   - Utilize container sandboxing technologies (gVisor, Kata Containers)

3. **Supply Chain Security**:
   - Sign all container images with Cosign or Notary
   - Implement Software Bill of Materials (SBOM) generation
   - Use trusted base images with vulnerability scanning

### Performance Optimization

1. **Smart Caching Strategies**:
   - Use distributed caching systems (S3, GCS, Azure Blob)
   - Implement layer caching for Docker builds
   - Cache package manager dependencies effectively

2. **Resource Allocation**:
   - Set appropriate resource limits based on job requirements
   - Utilize spot/preemptible instances for cost-efficiency
   - Implement auto-scaling based on workload patterns

3. **Containerized Execution**:
   - Use slim, purpose-built containers for jobs
   - Implement multi-stage builds to reduce image size
   - Optimize dependency management for faster execution

### Cost Optimization

1. **Intelligent Scaling**:
   - Implement predictive auto-scaling based on historical patterns
   - Use spot instances with fallback mechanisms
   - Scale to zero for non-critical environments

2. **Resource Efficiency**:
   - Tag runners for specific workloads to optimize resource use
   - Set job timeouts to prevent runaway processes
   - Implement job concurrency limits

3. **Multi-Cloud Strategy**:
   - Distribute runners across cloud providers for cost arbitrage
   - Use runners in regions with lower costs
   - Implement FinOps practices with cost monitoring

### Resilience and Reliability

1. **High Availability Setup**:
   - Deploy runners across multiple availability zones
   - Implement circuit breakers for external dependencies
   - Use health checks and automatic remediation

2. **Failure Management**:
   - Implement retry mechanisms for transient failures
   - Set up alerting for repeated job failures
   - Create runbooks for common runner issues

3. **Disaster Recovery**:
   - Backup runner configurations regularly
   - Test recovery scenarios periodically
   - Document recovery procedures

## Monitoring GitLab Runners

### Key Metrics to Monitor

1. **System Resources**:
   - CPU, memory, and disk usage
   - Network throughput and latency
   - Queue length and job wait time

2. **Job Performance**:
   - Job execution time
   - Build success/failure rate
   - Cache hit/miss ratio

3. **Cost Metrics**:
   - Runner uptime
   - Resource utilization efficiency
   - Job cost by project/branch

### Monitoring Tools Integration

```yaml
# prometheus.yml configuration
scrape_configs:
  - job_name: 'gitlab_runners'
    scrape_interval: 15s
    static_configs:
      - targets: ['gitlab-runner:9252']
```

Example Grafana dashboard query:
```
rate(gitlab_runner_jobs_total{status="success"}[5m])
```

## Conclusion

GitLab Runner remains a critical component of modern CI/CD infrastructure in 2025. By following best practices for installation, configuration, security, and scaling, organizations can build resilient and efficient pipelines that support modern software delivery practices. The platform-specific installation guides and real-world scenarios provided here should help teams implement GitLab Runner effectively across different environments.

## Additional Resources

- [Official GitLab Runner Documentation](https://docs.gitlab.com/runner/)
- [GitLab Runner Security](https://docs.gitlab.com/runner/security/)
- [Kubernetes Executor](https://docs.gitlab.com/runner/executors/kubernetes.html)
- [Auto-scaling with Docker Machine](https://docs.gitlab.com/runner/configuration/autoscale.html)