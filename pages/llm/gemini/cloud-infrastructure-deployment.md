# Deploying Cloud Infrastructure with Gemini

This guide demonstrates how to use Google Gemini to design, deploy, and manage cloud infrastructure across major cloud providers. We'll provide real-world examples and implementation patterns for DevOps professionals.

## Introduction

Gemini excels at cloud infrastructure tasks due to its:

1. Deep understanding of cloud provider services and best practices
2. Ability to generate and review infrastructure as code
3. Context awareness for complex architectures
4. Multimodal capabilities for architecture diagrams

## Setting Up Your Environment

Before deploying infrastructure with Gemini, ensure you have:

1. A working Gemini API setup (see installation guides)
2. Proper cloud provider credentials configured
3. Infrastructure as Code tools installed (Terraform, AWS CDK, etc.)
4. Version control for generated code

## Infrastructure Design Patterns

### Pattern 1: The Design-Review-Deploy Cycle

This pattern uses Gemini to iteratively design and refine infrastructure:

1. **Design**: Generate initial infrastructure code from requirements
2. **Review**: Have Gemini analyze the design for issues
3. **Refine**: Incorporate feedback and improve the design
4. **Deploy**: Use CI/CD to deploy the validated infrastructure
5. **Monitor**: Analyze logs and metrics for improvement

#### Example Implementation

```python
import google.generativeai as genai
import os
import json
import subprocess

# Configure API access
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])
model = genai.GenerativeModel('gemini-2.5-pro')

# Step 1: Design - Generate initial infrastructure
requirements = """
Create a resilient microservice architecture with:
- 3-tier web application (frontend, API, database)
- Auto-scaling for the application tier
- High-availability PostgreSQL database
- CDN for static content delivery
- Web Application Firewall
- Infrastructure monitoring and alerting
- Daily automated backups
- Environment: Production
- Cloud provider: AWS
"""

design_prompt = f"""
Generate Terraform code for the following requirements:

{requirements}

The code should follow AWS best practices, implement least privilege security,
and include proper tagging for cost allocation. Organize the code into 
multiple files following Terraform best practices.
"""

design_response = model.generate_content(design_prompt)

# Save the initial design
os.makedirs("infrastructure/initial", exist_ok=True)
with open("infrastructure/initial/main.tf", "w") as f:
    f.write(design_response.text)

# Step 2: Review - Analyze the design for issues
review_prompt = f"""
Review the following Terraform code for:
1. Security vulnerabilities
2. Cost optimization opportunities
3. Resilience improvements
4. Compliance with AWS best practices

```terraform
{design_response.text}
```

Provide specific, actionable feedback that can be implemented.
"""

review_response = model.generate_content(review_prompt)
print("REVIEW FEEDBACK:")
print(review_response.text)

# Step 3: Refine - Improve based on feedback
refine_prompt = f"""
Refine the following Terraform code based on this feedback:

Original code:
```terraform
{design_response.text}
```

Feedback:
{review_response.text}

Generate improved Terraform code that addresses all the feedback points.
"""

refined_response = model.generate_content(refine_prompt)

# Save the refined design
os.makedirs("infrastructure/refined", exist_ok=True)
with open("infrastructure/refined/main.tf", "w") as f:
    f.write(refined_response.text)

# Step 4: Deploy (simulation)
print("\nDEPLOYMENT SIMULATION:")
print("Running 'terraform init' and 'terraform plan'...")

# In production, you would actually run:
# subprocess.run(["terraform", "init"], cwd="infrastructure/refined")
# subprocess.run(["terraform", "plan", "-out=tfplan"], cwd="infrastructure/refined")
# Then review the plan and apply if appropriate
```

### Pattern 2: Multi-Environment Configuration Generator

This pattern uses Gemini to generate consistent configurations across environments:

```python
environments = ["dev", "staging", "production"]
base_config = """
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  
  name = "main-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Environment = "base"
    Terraform = "true"
  }
}
"""

for env in environments:
    env_prompt = f"""
    Transform this base Terraform configuration for the {env} environment.
    
    Base configuration:
    ```terraform
    {base_config}
    ```
    
    For {env}, make these environment-specific adjustments:
    1. Update all naming to include the environment name
    2. Adjust resource sizes and counts appropriately for {env}
       (dev=small/minimal, staging=moderate, production=full/redundant)
    3. Set appropriate environment-specific tags
    4. For production, ensure high availability across all components
    5. For dev, optimize for cost savings
    
    Return ONLY the modified Terraform code.
    """
    
    env_response = model.generate_content(env_prompt)
    
    os.makedirs(f"infrastructure/{env}", exist_ok=True)
    with open(f"infrastructure/{env}/main.tf", "w") as f:
        f.write(env_response.text)
    
    print(f"Generated configuration for {env} environment")
```

### Pattern 3: Infrastructure Testing Strategy

This pattern uses Gemini to generate comprehensive tests for your infrastructure:

```python
infra_code = """
// Read your Terraform files here
"""

test_prompt = f"""
Generate Terratest code in Go to test the following Terraform infrastructure:

```terraform
{infra_code}
```

Include tests for:
1. Correct resource creation
2. Security group configurations
3. Network connectivity
4. Scaling capabilities
5. Backup and recovery processes

Structure the tests following best practices with setup, verification, and cleanup stages.
"""

test_code = model.generate_content(test_prompt)

os.makedirs("tests", exist_ok=True)
with open("tests/infrastructure_test.go", "w") as f:
    f.write(test_code.text)
```

## Real-World Examples

### Example 1: Kubernetes Cluster Deployment on GCP

In this example, we'll use Gemini to help design, validate, and deploy a production-grade Kubernetes cluster on Google Cloud Platform using Terraform.

```python
# 1. Generate the initial Terraform configuration
k8s_requirements = """
Requirements for Kubernetes cluster on GCP:
- Production-grade cluster for an e-commerce application
- Multi-zonal deployment for high availability
- Node auto-scaling from 3-15 nodes based on load
- Separate node pools for general workloads and memory-intensive workloads
- Private cluster with limited external access
- Google Cloud Armor for WAF protection
- Cloud CDN integration for static assets
- Secret management with Google Secret Manager
- Monitoring and logging with Cloud Operations
"""

k8s_prompt = f"""
Generate Terraform code for a GKE cluster with the following requirements:

{k8s_requirements}

Include all necessary resources and follow Google Cloud best practices for security and reliability.
"""

k8s_response = model.generate_content(k8s_prompt)
k8s_code = k8s_response.text

# 2. Generate Kubernetes manifests for core infrastructure
k8s_manifests_prompt = f"""
Generate Kubernetes manifest files for the following components to be deployed on the GKE cluster:
1. Nginx Ingress Controller
2. Cert-Manager for TLS certificates
3. Prometheus and Grafana for monitoring
4. A sample deployment with HPA (Horizontal Pod Autoscaler)

Structure these as separate YAML files following Kubernetes best practices.
"""

k8s_manifests_response = model.generate_content(k8s_manifests_prompt)

# 3. Generate deployment pipeline
pipeline_prompt = """
Create a GitHub Actions workflow that:
1. Validates the Terraform code
2. Plans and applies the GKE infrastructure
3. Deploys the Kubernetes manifests to the cluster
4. Performs basic verification tests
5. Notifies on Slack about deployment status

Use GitHub environments to separate staging and production deployments.
"""

pipeline_response = model.generate_content(pipeline_prompt)

# Save all generated files to their appropriate locations
os.makedirs("k8s-infrastructure/terraform", exist_ok=True)
os.makedirs("k8s-infrastructure/manifests", exist_ok=True)
os.makedirs("k8s-infrastructure/.github/workflows", exist_ok=True)

with open("k8s-infrastructure/terraform/main.tf", "w") as f:
    f.write(k8s_code)

with open("k8s-infrastructure/manifests/k8s-resources.yaml", "w") as f:
    f.write(k8s_manifests_response.text)

with open("k8s-infrastructure/.github/workflows/deploy.yaml", "w") as f:
    f.write(pipeline_response.text)
```

### Example 2: Multi-Region AWS Infrastructure with Failover

This example shows how to use Gemini to create a multi-region AWS infrastructure with automatic failover capabilities:

```python
# 1. Generate multi-region Terraform configuration
multi_region_prompt = """
Create a Terraform configuration for a multi-region AWS deployment with:
1. Primary region: us-west-2
2. Failover region: us-east-1
3. Application: Web application with RDS backend
4. Requirements:
   - Route 53 health checks and failover routing
   - Cross-region read replicas for RDS
   - DynamoDB global tables for session management
   - CloudFront distribution with multiple origins
   - Lambda@Edge for request processing
   - S3 cross-region replication
   - Regional Load Balancers
   - Auto-scaling groups in each region

Structure the code to use Terraform modules for reusability.
"""

multi_region_response = model.generate_content(multi_region_prompt)

# 2. Generate disaster recovery playbook
dr_prompt = """
Based on the multi-region AWS infrastructure, create a disaster recovery playbook that includes:
1. Failure detection mechanisms
2. Manual failover procedure steps
3. Automatic failover configuration
4. Data consistency validation steps
5. Failback procedures
6. Regular DR testing instructions

Format as a markdown document with clear sections and code examples where needed.
"""

dr_response = model.generate_content(dr_prompt)

# Save the files
os.makedirs("aws-multi-region/terraform", exist_ok=True)
os.makedirs("aws-multi-region/docs", exist_ok=True)

with open("aws-multi-region/terraform/main.tf", "w") as f:
    f.write(multi_region_response.text)

with open("aws-multi-region/docs/disaster-recovery.md", "w") as f:
    f.write(dr_response.text)
```

### Example 3: Serverless Architecture on Azure

This example demonstrates using Gemini to create a modern serverless architecture on Azure:

```python
# 1. Generate Azure Functions + CosmosDB architecture
serverless_prompt = """
Generate Terraform code for an Azure serverless architecture with:
1. Azure Functions (consumption plan) for API endpoints
2. CosmosDB with SQL API for data storage
3. Event Grid for event-driven processing
4. Azure API Management for API gateway
5. Azure CDN for static content
6. Azure Key Vault for secrets management
7. Application Insights for monitoring
8. Azure DevOps pipelines for CI/CD

The application is a content management system with separate read and write paths.
"""

serverless_response = model.generate_content(serverless_prompt)

# 2. Generate cost estimation
cost_prompt = f"""
Based on the following Azure serverless architecture, provide a detailed cost estimation for:
1. Development environment (minimal usage)
2. Production environment (moderate usage with 100,000 requests per day)
3. Scale scenario (high usage with 1,000,000 requests per day)

Include strategies to optimize costs in each scenario.

Architecture:
```terraform
{serverless_response.text}
```
"""

cost_response = model.generate_content(cost_prompt)

# Save the files
os.makedirs("azure-serverless/terraform", exist_ok=True)
os.makedirs("azure-serverless/docs", exist_ok=True)

with open("azure-serverless/terraform/main.tf", "w") as f:
    f.write(serverless_response.text)

with open("azure-serverless/docs/cost-estimation.md", "w") as f:
    f.write(cost_response.text)
```

## Best Practices for Gemini-assisted Cloud Deployment

### Code Review and Validation

Always validate Gemini-generated infrastructure code:

1. **Automated validation**: Use tools like `terraform validate` and `tflint`
2. **Security scanning**: Run tools like `tfsec` and `checkov`
3. **Manual review**: Have team members review critical security components
4. **Incremental deployment**: Deploy in phases starting with non-production

Example validation script:

```bash
#!/bin/bash
# Validate Gemini-generated Terraform code

set -e

TERRAFORM_DIR=$1

if [ ! -d "$TERRAFORM_DIR" ]; then
  echo "Directory $TERRAFORM_DIR not found!"
  exit 1
fi

echo "Running Terraform validation..."
terraform -chdir="$TERRAFORM_DIR" init -backend=false
terraform -chdir="$TERRAFORM_DIR" validate

echo "Running tflint..."
tflint "$TERRAFORM_DIR"

echo "Running tfsec..."
tfsec "$TERRAFORM_DIR"

echo "Running checkov..."
checkov -d "$TERRAFORM_DIR"

echo "Validation complete!"
```

### Environment Consistency

Maintain consistency across environments:

1. Use a DRY (Don't Repeat Yourself) approach with Terraform modules
2. Parameterize differences between environments
3. Keep the same architecture across environments, scaling resources appropriately
4. Use the same pipeline to deploy to all environments

Example environment configuration:

```hcl
# environments.tf

locals {
  environments = {
    dev = {
      name       = "dev"
      region     = "us-west-2"
      instance_type = "t3.small"
      min_capacity = 1
      max_capacity = 3
      multi_az      = false
      alert_emails  = ["dev-team@example.com"]
    }
    
    staging = {
      name       = "staging"
      region     = "us-west-2"
      instance_type = "t3.medium"
      min_capacity = 2
      max_capacity = 5
      multi_az      = true
      alert_emails  = ["dev-team@example.com", "qa-team@example.com"]
    }
    
    production = {
      name       = "production"
      region     = "us-west-2"
      instance_type = "t3.large"
      min_capacity = 3
      max_capacity = 10
      multi_az      = true
      alert_emails  = ["dev-team@example.com", "ops-team@example.com", "alerts@example.com"]
    }
  }
  
  # Select environment based on workspace
  env = local.environments[terraform.workspace]
}
```

### Infrastructure Documentation Generation

Use Gemini to automatically generate comprehensive documentation:

```python
# Generate documentation for your Terraform modules
tf_files = """
# Content of your Terraform files here
"""

docs_prompt = f"""
Generate comprehensive documentation for the following Terraform infrastructure:

```terraform
{tf_files}
```

The documentation should include:
1. Architecture overview with a diagram description
2. Resource inventory and purpose
3. Security considerations
4. Scaling characteristics
5. Monitoring points
6. Operational procedures (deployment, updates, rollback)
7. Cost optimization recommendations

Format the output as Markdown.
"""

docs_response = model.generate_content(docs_prompt)

with open("docs/infrastructure.md", "w") as f:
    f.write(docs_response.text)
```

## Using Gemini for Infrastructure Troubleshooting

Gemini can help diagnose and fix infrastructure issues:

```python
# Troubleshooting example
error_logs = """
Error: Error creating EC2 Instance: InvalidSubnetID.NotFound: The subnet ID 'subnet-12345678' does not exist
    status code: 400, request id: a1b2c3d4-5678-90ab-cdef-EXAMPLE11111

Error: Error creating Application Load Balancer: ValidationError: At least two subnets in two different Availability Zones must be specified
    status code: 400, request id: a1b2c3d4-5678-90ab-cdef-EXAMPLE22222
"""

terraform_code = """
# Your Terraform code that's causing the error
"""

troubleshoot_prompt = f"""
I'm encountering the following errors when applying my Terraform configuration:

```
{error_logs}
```

Here's my Terraform code:

```terraform
{terraform_code}
```

Please:
1. Identify the root causes of these errors
2. Explain what's happening in detail
3. Provide specific fixes for each issue
4. Suggest improvements to prevent similar issues
"""

solution = model.generate_content(troubleshoot_prompt)
print(solution.text)
```

## Conclusion

Gemini provides powerful capabilities for cloud infrastructure deployment, allowing DevOps teams to:

1. Generate high-quality infrastructure code following best practices
2. Validate and improve existing configurations
3. Create comprehensive testing strategies
4. Streamline multi-environment deployments
5. Automate documentation generation
6. Troubleshoot complex infrastructure issues

By combining Gemini's intelligence with proper DevOps practices, teams can build more reliable, secure, and efficient cloud infrastructure with less manual effort.

Remember that while Gemini can significantly enhance your infrastructure processes, it's essential to maintain proper review procedures, security practices, and testing protocols. Always validate generated code before deploying to production environments.