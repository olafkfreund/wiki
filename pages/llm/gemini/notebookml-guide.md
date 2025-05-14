# NotebookML with Gemini

NotebookML is a powerful tool for working with Gemini models in a notebook-style interface. This guide shows how to use NotebookML to create interactive data analysis and infrastructure management workflows.

## What is NotebookML?

NotebookML extends traditional Jupyter notebooks with specialized capabilities for generative AI workflows:

- **AI-native**: Built specifically for working with LLMs like Gemini
- **Interactive cells**: Combine code, prompts, and outputs in a single environment
- **Model analysis**: Easily track and analyze model behavior
- **Visualization tools**: Plot model performance and response characteristics
- **Infrastructure integration**: Direct integration with cloud deployment tools

## Setup and Installation

### Prerequisites

- Python 3.9+
- Jupyter installed
- Google Gemini API access

### Installation Steps

```bash
# Create and activate a virtual environment
python -m venv notebookml-env
source notebookml-env/bin/activate  # Linux/macOS
# Or for Windows
# .\notebookml-env\Scripts\activate

# Install NotebookML and dependencies
pip install notebookml jupyter google-generativeai pandas matplotlib

# Install Jupyter extensions
jupyter nbextension enable --py widgetsnbextension
```

## Creating Your First NotebookML Project for Infrastructure

Create a new notebook (e.g., `gemini_infrastructure.ipynb`):

```bash
jupyter notebook gemini_infrastructure.ipynb
```

### Basic Structure

A typical NotebookML workflow with Gemini includes:

1. **Setup and Authentication**
2. **Model Configuration**
3. **Infrastructure Analysis**
4. **Code Generation**
5. **Evaluation and Refinement**

### Example: Infrastructure Analysis Notebook

```python
# Import libraries
import google.generativeai as genai
import notebookml as nml
import pandas as pd
import os
import json
from IPython.display import Markdown, display

# Configure API access
api_key = os.environ.get("GOOGLE_API_KEY")
if not api_key:
    api_key = input("Enter your Google API Key: ")
    os.environ["GOOGLE_API_KEY"] = api_key

genai.configure(api_key=api_key)

# Initialize a Gemini 2.5 Pro model
model = genai.GenerativeModel('gemini-2.5-pro')

# Create a NotebookML session
session = nml.Session(model_provider="gemini", model_name="gemini-2.5-pro")

# Define an infrastructure analysis prompt template
infra_analysis_template = """
Analyze the following cloud infrastructure configuration for:
1. Security vulnerabilities
2. Cost optimization opportunities
3. Performance improvements
4. Compliance with best practices

Configuration:
{config}

Provide recommendations in a structured format.
"""

# Sample Terraform configuration for analysis
terraform_config = """
resource "aws_s3_bucket" "data_lake" {
  bucket = "my-company-data-lake"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "Policy for Lambda execution"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
"""

# Run the analysis
analysis_prompt = infra_analysis_template.format(config=terraform_config)
analysis_cell = session.prompt(analysis_prompt, temperature=0.1)

# Display the analysis results
display(Markdown(analysis_cell.response))

# Extract structured feedback using another prompt
extract_prompt = """
Based on the previous analysis, generate a JSON object with the following structure:

{
  "security_issues": [
    {
      "severity": "HIGH/MEDIUM/LOW",
      "description": "Description of the issue",
      "remediation": "How to fix it"
    }
  ],
  "cost_optimizations": [
    {
      "potential_savings": "estimated savings",
      "description": "Description of the optimization",
      "implementation": "How to implement"
    }
  ],
  "performance_improvements": [
    {
      "impact": "HIGH/MEDIUM/LOW",
      "description": "Description of the improvement",
      "implementation": "How to implement"
    }
  ]
}
"""

structured_analysis = session.prompt(extract_prompt, context=[analysis_cell], temperature=0.1)

# Extract and parse the JSON response
try:
    # Find the JSON part in the response
    json_str = structured_analysis.response
    # Check if the response is wrapped in a code block
    if "```json" in json_str:
        json_str = json_str.split("```json")[1].split("```")[0].strip()
    elif "```" in json_str:
        json_str = json_str.split("```")[1].split("```")[0].strip()
        
    analysis_data = json.loads(json_str)
    
    # Convert to DataFrame for better visualization
    security_df = pd.DataFrame(analysis_data["security_issues"])
    cost_df = pd.DataFrame(analysis_data["cost_optimizations"])
    perf_df = pd.DataFrame(analysis_data["performance_improvements"])
    
    # Display tables
    display(Markdown("## Security Issues"))
    display(security_df)
    
    display(Markdown("## Cost Optimizations"))
    display(cost_df)
    
    display(Markdown("## Performance Improvements"))
    display(perf_df)
except Exception as e:
    print(f"Error parsing JSON: {e}")
    print("Raw response:")
    print(structured_analysis.response)

# Generate improved Terraform code
generate_prompt = """
Based on the analysis, generate an improved version of the Terraform configuration that addresses the security issues,
cost optimizations, and performance improvements identified.
"""

improved_code = session.prompt(generate_prompt, context=[analysis_cell, structured_analysis], temperature=0.1)

# Display the improved code
display(Markdown("## Improved Terraform Configuration"))
display(Markdown(f"```hcl\n{improved_code.response}\n```"))
```

## Advanced NotebookML Features for DevOps

### 1. Interactive Infrastructure Planning

Create diagrams and infrastructure plans that you can refine through conversation:

```python
# Infrastructure planning cell
planning_prompt = """
Design a cloud infrastructure for a microservice application with:
1. Frontend service (React)
2. Backend API service (Node.js)
3. Database (PostgreSQL)
4. Authentication service
5. Message queue for async processing

Requirements:
- High availability
- Disaster recovery
- Security best practices
- Cost optimization

Create a diagram using ASCII and explain the architecture.
"""

plan = session.prompt(planning_prompt, temperature=0.2)
display(Markdown(plan.response))

# Refinement cell
refinement_prompt = """
Refine the architecture to improve:
1. Scalability for the backend API
2. Security for the database
3. Add a CDN for the frontend
"""

refined_plan = session.prompt(refinement_prompt, context=[plan], temperature=0.2)
display(Markdown(refined_plan.response))
```

### 2. Multi-provider Infrastructure Analysis

Analyze infrastructure across multiple clouds:

```python
# Configure for multi-cloud analysis
multi_cloud_prompt = """
Compare the following AWS and Azure configurations for a web application deployment.
Identify which provider would be better for this specific architecture and why.

AWS Configuration:
```terraform
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "assets" {
  bucket = "my-webapp-assets"
}
```

Azure Configuration:
```terraform
resource "azurerm_virtual_machine" "web" {
  name                  = "web-vm"
  location              = "East US"
  resource_group_name   = "web-rg"
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.web.id]
}

resource "azurerm_storage_account" "assets" {
  name                     = "webappassets"
  resource_group_name      = "web-rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```
"""

comparison = session.prompt(multi_cloud_prompt, temperature=0.1)
display(Markdown(comparison.response))
```

### 3. Real-time Log Analysis

Process and analyze application logs:

```python
# Sample log data
sample_logs = """
2023-05-14T12:34:56Z ERROR [app-xyz] Failed to connect to database: Connection timeout after 30s
2023-05-14T12:35:01Z WARN [app-xyz] Retry attempt 1 for database connection
2023-05-14T12:35:06Z ERROR [app-xyz] Failed to connect to database: Connection timeout after 30s
2023-05-14T12:35:11Z WARN [app-xyz] Retry attempt 2 for database connection
2023-05-14T12:35:16Z ERROR [app-xyz] Failed to connect to database: Connection timeout after 30s
2023-05-14T12:35:21Z FATAL [app-xyz] Could not establish database connection after 3 attempts
2023-05-14T12:36:01Z ERROR [app-xyz] Application shutdown due to database unavailability
"""

log_analysis_prompt = """
Analyze these application logs and:
1. Identify the root cause of the issues
2. Suggest potential solutions
3. Propose monitoring improvements to catch this earlier

Logs:
{logs}
"""

log_analysis = session.prompt(log_analysis_prompt.format(logs=sample_logs), temperature=0.1)
display(Markdown(log_analysis.response))
```

## Integrating with Cloud Infrastructure

### 1. Direct Cloud Provider API Integration

```python
# Note: This requires appropriate cloud credentials and permissions
import boto3
from google.cloud import storage
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

# Example: AWS S3 bucket listing
s3 = boto3.client('s3')
response = s3.list_buckets()

# Format the data
aws_buckets = [bucket['Name'] for bucket in response['Buckets']]
aws_data = "AWS S3 Buckets:\n" + "\n".join(aws_buckets)

# Google Cloud Storage buckets
gcs_client = storage.Client()
gcs_buckets = [bucket.name for bucket in gcs_client.list_buckets()]
gcs_data = "Google Cloud Storage Buckets:\n" + "\n".join(gcs_buckets)

# Azure Resource Groups
azure_credential = DefaultAzureCredential()
subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
azure_client = ResourceManagementClient(azure_credential, subscription_id)
azure_groups = [group.name for group in azure_client.resource_groups.list()]
azure_data = "Azure Resource Groups:\n" + "\n".join(azure_groups)

# Combine all cloud data
cloud_inventory = f"{aws_data}\n\n{gcs_data}\n\n{azure_data}"

# Ask Gemini to recommend improvements
cloud_prompt = f"""
Based on the following cloud inventory, suggest optimization strategies 
and potential security improvements:

{cloud_inventory}
"""

cloud_analysis = session.prompt(cloud_prompt, temperature=0.1)
display(Markdown(cloud_analysis.response))
```

### 2. Infrastructure as Code Generation

```python
# Generate Terraform configuration based on requirements
terraform_prompt = """
Generate a Terraform configuration for a highly available web application with:

1. VPC with public and private subnets across 3 availability zones
2. Application Load Balancer in the public subnets
3. Auto Scaling Group of EC2 instances in private subnets
4. RDS PostgreSQL database in private subnets with Multi-AZ enabled
5. S3 bucket for static assets
6. CloudFront distribution for the S3 bucket
7. All necessary security groups
8. IAM roles with least privilege principle

The configuration should include proper tagging and follow AWS best practices.
"""

terraform_response = session.prompt(terraform_prompt, temperature=0.2)
terraform_code = terraform_response.response

# Save the generated Terraform code to a file
with open("generated_terraform.tf", "w") as f:
    f.write(terraform_code)

display(Markdown("Terraform configuration saved to 'generated_terraform.tf'"))
```

## Best Practices for NotebookML with Gemini

### 1. Structure Your Notebooks

Organize your notebooks into clear sections:
- Setup and configuration
- Data ingestion
- Analysis
- Visualization
- Recommendations
- Implementation code

### 2. Version Your Prompts

Keep track of prompt versions that work well:

```python
# Prompt library
prompts = {
    "infra_analysis_v1": "Analyze the following cloud infrastructure...",
    "infra_analysis_v2": "Perform a deep analysis of the following cloud resources...",
    "security_audit_v1": "Review the following configuration for security issues..."
}

# Use versioned prompts
analysis = session.prompt(prompts["infra_analysis_v2"].format(config=my_config))
```

### 3. Track Model Performance

Monitor and log performance metrics:

```python
import time
import matplotlib.pyplot as plt

# Performance tracking
def track_response(prompt, response, start_time):
    return {
        "prompt_tokens": len(prompt.split()),
        "response_tokens": len(response.split()),
        "response_time": time.time() - start_time,
        "timestamp": time.time()
    }

# Track multiple responses
performance_log = []

for i in range(5):
    test_prompt = f"Generate a Terraform configuration for scenario {i+1}"
    start = time.time()
    response = session.prompt(test_prompt, temperature=0.1)
    perf = track_response(test_prompt, response.response, start)
    performance_log.append(perf)
    time.sleep(1)  # Avoid rate limiting

# Visualize performance
df = pd.DataFrame(performance_log)
plt.figure(figsize=(10, 6))
plt.plot(df["timestamp"], df["response_time"], marker='o')
plt.title("Response Time Trend")
plt.xlabel("Timestamp")
plt.ylabel("Response Time (s)")
plt.grid(True)
plt.show()
```

### 4. Collaborative Workflows

Share notebooks with annotations for team collaboration:

```python
# Add explanatory comments in markdown cells
display(Markdown("""
## Infrastructure Analysis Notes

This section analyzes the current AWS architecture based on:
1. Cost optimization opportunities
2. Security vulnerabilities
3. Performance bottlenecks

The suggested improvements are ranked by priority and estimated impact.
"""))

# Add review comments
review_comment = """
Team: Please review the generated Terraform code with particular 
attention to the IAM permissions and security groups.
"""
display(Markdown(f"> **REVIEW NEEDED**: {review_comment}"))
```

## Integrating with Version Control

Save NotebookML outputs to your repository:

```python
import subprocess
import os

def save_to_git(filename, content, commit_message):
    """Save content to a file and commit to git"""
    with open(filename, 'w') as f:
        f.write(content)
    
    # Git operations
    subprocess.run(['git', 'add', filename])
    subprocess.run(['git', 'commit', '-m', commit_message])
    
    return f"Successfully saved and committed {filename}"

# Save generated Terraform code
terraform_output = improved_code.response
save_to_git(
    'infrastructure/main.tf', 
    terraform_output, 
    'Update infrastructure with security improvements'
)
```

## Conclusion

NotebookML combined with Gemini provides a powerful environment for DevOps professionals to analyze, generate, and refine infrastructure code. The interactive nature of notebooks makes it ideal for exploring options, documenting decision processes, and collaborating on infrastructure design.

By leveraging both the code execution capabilities of Jupyter and the AI capabilities of Gemini, teams can create repeatable, documented workflows that improve infrastructure quality and maintain architectural best practices.