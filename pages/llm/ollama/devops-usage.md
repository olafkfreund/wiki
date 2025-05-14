# Ollama for DevOps Engineers

This guide provides practical examples of how DevOps engineers can leverage Ollama's local LLM capabilities to streamline workflows, automate tasks, and enhance productivity.

## Why Use Ollama in DevOps Workflows?

Ollama offers several advantages for DevOps engineers:

- **Privacy**: Keep sensitive code and infrastructure details private by running models locally
- **Offline access**: Work without internet connectivity or API rate limits
- **Reduced costs**: No subscription fees or usage-based pricing
- **Customization**: Fine-tune models for specific DevOps knowledge domains
- **Automation**: Integrate LLMs into CI/CD pipelines, scripts, and tools

## Setup for DevOps Use Cases

Before using Ollama for DevOps tasks, configure it with a model specialized for code and infrastructure:

```bash
# Create a DevOps-focused Modelfile
cat > DevOps-Modelfile << 'EOF'
FROM codellama:7b-code

# Set parameters for consistent, deterministic responses
PARAMETER temperature 0.2
PARAMETER top_p 0.9

# Define the system prompt
SYSTEM You are a DevOps specialist with expertise in:
- Infrastructure as Code (Terraform, Bicep, CloudFormation, ARM)
- CI/CD pipelines (GitHub Actions, Azure DevOps, GitLab CI, Jenkins)
- Containerization (Docker, Kubernetes, Helm)
- Cloud platforms (AWS, Azure, GCP)
- Linux system administration and shell scripting
- Configuration management (Ansible, Puppet, Chef)
- Monitoring and observability (Prometheus, Grafana, ELK)

You provide clear, concise, and practical solutions focused on DevOps best practices.
When providing code, ensure it follows security best practices and includes comments.
EOF

# Create the custom model
ollama create devops-assistant -f DevOps-Modelfile

# Test the model
ollama run devops-assistant "Generate a basic Terraform module for an AWS S3 bucket with versioning enabled"
```

## Code Review and Analysis

### Automated Terraform Reviews

Create a script that uses Ollama to review Terraform files for best practices and security concerns:

```bash
#!/bin/bash
# terraform-reviewer.sh

set -e

# Define the Terraform file to review
TF_FILE="$1"

if [[ ! -f "$TF_FILE" ]]; then
    echo "File not found: $TF_FILE"
    exit 1
fi

# Generate the prompt with the file content
CONTENT=$(cat "$TF_FILE")
PROMPT="Review this Terraform code for potential issues, security concerns, and best practice violations. Suggest improvements.

\`\`\`terraform
$CONTENT
\`\`\`

Organize your response in these sections:
1. Security Issues
2. Best Practice Violations 
3. Optimizations
4. Suggested Improvements"

# Run the analysis with Ollama
echo "Analyzing $TF_FILE..."
ollama run devops-assistant "$PROMPT" | tee "${TF_FILE%.tf}_review.md"

echo "Review complete! Check ${TF_FILE%.tf}_review.md"
```

Make the script executable and use it:

```bash
chmod +x terraform-reviewer.sh
./terraform-reviewer.sh main.tf
```

### Kubernetes Manifest Analysis

Create a script to validate and improve Kubernetes manifests:

```bash
#!/bin/bash
# k8s-analyzer.sh

set -e

# Define the K8s manifest file to analyze
K8S_FILE="$1"

if [[ ! -f "$K8S_FILE" ]]; then
    echo "File not found: $K8S_FILE"
    exit 1
fi

# Generate the prompt with the file content
CONTENT=$(cat "$K8S_FILE")
PROMPT="Review this Kubernetes manifest for issues, security concerns, and best practice violations. Suggest improvements.

\`\`\`yaml
$CONTENT
\`\`\`

Focus on:
1. Security context settings
2. Resource requests and limits
3. Health checks
4. Network policies
5. Pod security standards"

# Run the analysis with Ollama
echo "Analyzing $K8S_FILE..."
ollama run devops-assistant "$PROMPT" | tee "${K8S_FILE%.*}_review.md"

echo "Review complete! Check ${K8S_FILE%.*}_review.md"
```

## Documentation Generation

### Automatic README Generation

Create a script to generate README documentation for infrastructure projects:

```bash
#!/bin/bash
# generate-readme.sh

set -e

# Define the project directory
PROJECT_DIR="$1"
OUTPUT_FILE="$PROJECT_DIR/README.md"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Directory not found: $PROJECT_DIR"
    exit 1
fi

# Find all HCL/TF files in the project
TF_FILES=$(find "$PROJECT_DIR" -type f -name "*.tf" | sort)

# Extract variables, outputs, and module structure
VARS_CONTENT=$(find "$PROJECT_DIR" -name "variables.tf" -exec cat {} \;)
OUTPUTS_CONTENT=$(find "$PROJECT_DIR" -name "outputs.tf" -exec cat {} \;)
STRUCTURE=$(find "$PROJECT_DIR" -name "*.tf" | xargs -I{} basename {} | sort | uniq)

# Generate the prompt
PROMPT="Based on the following Terraform files structure and content, generate a comprehensive README.md in markdown format.

Project structure:
$STRUCTURE

Variables defined:
\`\`\`hcl
$VARS_CONTENT
\`\`\`

Outputs defined:
\`\`\`hcl
$OUTPUTS_CONTENT
\`\`\`

The README should include:
1. Project title and description
2. Prerequisites
3. Usage examples
4. Variables documentation (formatted as a table)
5. Outputs documentation (formatted as a table)
6. Contributing guidelines"

# Generate the README using Ollama
echo "Generating README for $PROJECT_DIR..."
ollama run devops-assistant "$PROMPT" > "$OUTPUT_FILE"

echo "README generated: $OUTPUT_FILE"
```

### Auto-Generating Architecture Decision Records (ADR)

Script to help create ADRs based on discussions or requirements:

```bash
#!/bin/bash
# generate-adr.sh

TITLE="$1"
CONTEXT="$2"
ADR_DIR="docs/architecture/decisions"
ADR_NUM=$(find "$ADR_DIR" -name "*.md" | wc -l)
ADR_NUM=$((ADR_NUM + 1))
ADR_FILE="${ADR_DIR}/$(printf "%04d" $ADR_NUM)-$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-').md"

mkdir -p "$ADR_DIR"

PROMPT="Generate an Architecture Decision Record (ADR) with the title '$TITLE' and the following context:

$CONTEXT

The ADR should follow the standard format with:
1. Title: $TITLE
2. Status: Proposed
3. Context: (based on the provided information)
4. Decision: (recommend a decision based on the context)
5. Consequences: (list positive and negative consequences)
6. References: (suggest any potential references)"

echo "Generating ADR for '$TITLE'..."
ollama run devops-assistant "$PROMPT" > "$ADR_FILE"

echo "ADR created: $ADR_FILE"
```

## Automated Troubleshooting

### Log Analysis Assistant

Create a script to analyze log files and suggest solutions:

```bash
#!/bin/bash
# log-analyzer.sh

LOG_FILE="$1"
MAX_LINES=500  # Avoid context window limits

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Get the file type for better context
FILE_TYPE=$(file "$LOG_FILE")

# Extract a sample from the beginning and end if the file is large
if [[ $(wc -l < "$LOG_FILE") -gt $MAX_LINES ]]; then
    LOG_CONTENT=$(head -n $((MAX_LINES/2)) "$LOG_FILE"; echo "--- [TRUNCATED] ---"; tail -n $((MAX_LINES/2)) "$LOG_FILE")
else
    LOG_CONTENT=$(cat "$LOG_FILE")
fi

# Create the prompt
PROMPT="Analyze these logs and identify potential issues or errors. Suggest troubleshooting steps or solutions.
File type: $FILE_TYPE

\`\`\`
$LOG_CONTENT
\`\`\`

Please provide:
1. A summary of identified issues
2. Root causes if apparent
3. Recommended troubleshooting steps
4. Potential solutions"

# Generate the analysis
echo "Analyzing $LOG_FILE..."
ollama run devops-assistant "$PROMPT" | tee "${LOG_FILE}.analysis.md"

echo "Analysis complete! Check ${LOG_FILE}.analysis.md"
```

### Pipeline Failure Analysis

Script to diagnose CI/CD pipeline failures:

```bash
#!/bin/bash
# pipeline-analyzer.sh

CI_LOG="$1"

if [[ ! -f "$CI_LOG" ]]; then
    echo "CI log file not found: $CI_LOG"
    exit 1
fi

# Extract relevant parts of the log file
CI_CONTENT=$(cat "$CI_LOG" | grep -A 20 -B 5 "error\|failure\|failed\|exception" | head -n 1000)

PROMPT="Analyze this CI/CD pipeline log and identify the root cause of the failure. Suggest steps to fix the issue.

\`\`\`
$CI_CONTENT
\`\`\`

Please provide:
1. Identified failure point
2. Root cause analysis
3. Recommended fixes
4. Prevention measures for future runs"

echo "Analyzing pipeline failure..."
ollama run devops-assistant "$PROMPT" | tee "pipeline_failure_analysis.md"

echo "Analysis complete! Check pipeline_failure_analysis.md"
```

## Infrastructure as Code Assistance

### Terraform Generator

Create a script to generate Terraform configurations based on requirements:

```bash
#!/bin/bash
# tf-generator.sh

REQUIREMENTS="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"

PROMPT="Generate Terraform code for the following infrastructure requirements:

$REQUIREMENTS

Please provide:
1. main.tf with resource definitions
2. variables.tf with properly documented variables
3. outputs.tf with useful outputs
4. providers.tf with provider configuration
5. versions.tf with terraform block and required providers

Each file should follow Terraform best practices, including proper naming conventions, 
descriptions for variables and outputs, and appropriate use of data sources."

echo "Generating Terraform code based on requirements..."
ollama run devops-assistant "$PROMPT" > /tmp/tf_response.txt

# Extract the code blocks and save to separate files
grep -n '```' /tmp/tf_response.txt | cut -d ':' -f1 | paste - - | while read start end; do
    file_type=$(sed -n "${start}p" /tmp/tf_response.txt | grep -oP '```\K[a-zA-Z0-9]*')
    if [[ "$file_type" == "hcl" || "$file_type" == "terraform" ]]; then
        file_name=$(sed -n "$((start-1))p" /tmp/tf_response.txt | grep -oP '[a-zA-Z0-9_-]+\.tf')
        if [[ -n "$file_name" ]]; then
            sed -n "$((start+1)),$((end-1))p" /tmp/tf_response.txt > "$OUTPUT_DIR/$file_name"
            echo "Created $file_name"
        fi
    fi
done

echo "Terraform code generated in $OUTPUT_DIR"
```

### Infrastructure Code Converter

Script to convert between IaC formats (e.g., CloudFormation to Terraform):

```bash
#!/bin/bash
# iac-converter.sh

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"  # terraform, bicep, etc.
OUTPUT_DIR="$3"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Input file not found: $INPUT_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Determine input format based on file extension
INPUT_FORMAT=$(echo "$INPUT_FILE" | grep -oP '\.(\w+)$' | tr -d '.')
case "$INPUT_FORMAT" in
    json|yaml|yml) 
        if grep -q "AWSTemplateFormatVersion\|Resources" "$INPUT_FILE"; then
            INPUT_FORMAT="cloudformation"
        fi
        ;;
esac

# Read the input file
INPUT_CONTENT=$(cat "$INPUT_FILE")

PROMPT="Convert the following $INPUT_FORMAT code to $OUTPUT_FORMAT:

\`\`\`$INPUT_FORMAT
$INPUT_CONTENT
\`\`\`

Please follow these guidelines:
1. Maintain the same resource names where possible
2. Use idiomatic patterns for the target format
3. Include comments to explain the conversion choices
4. Split the output into appropriate files for the target format"

echo "Converting from $INPUT_FORMAT to $OUTPUT_FORMAT..."
ollama run devops-assistant "$PROMPT" > /tmp/conversion_result.txt

# Process the output based on target format
case "$OUTPUT_FORMAT" in
    terraform)
        grep -n '```' /tmp/conversion_result.txt | cut -d ':' -f1 | paste - - | while read start end; do
            file_type=$(sed -n "${start}p" /tmp/conversion_result.txt | grep -oP '```\K[a-zA-Z0-9]*')
            if [[ "$file_type" == "hcl" || "$file_type" == "terraform" ]]; then
                file_name=$(sed -n "$((start-1))p" /tmp/conversion_result.txt | grep -oP '[a-zA-Z0-9_-]+\.tf')
                if [[ -n "$file_name" ]]; then
                    sed -n "$((start+1)),$((end-1))p" /tmp/conversion_result.txt > "$OUTPUT_DIR/$file_name"
                    echo "Created $file_name"
                fi
            fi
        done
        ;;
    bicep)
        grep -n '```' /tmp/conversion_result.txt | cut -d ':' -f1 | paste - - | while read start end; do
            if [[ $(sed -n "${start}p" /tmp/conversion_result.txt) == *"bicep"* ]]; then
                sed -n "$((start+1)),$((end-1))p" /tmp/conversion_result.txt > "$OUTPUT_DIR/main.bicep"
                echo "Created main.bicep"
            fi
        done
        ;;
esac

echo "Conversion complete. Output saved to $OUTPUT_DIR"
```

## CI/CD Integration

### Auto-Commenting on Pull Requests

To integrate Ollama into a GitHub Actions workflow for PR code reviews:

```yaml
# .github/workflows/code-review.yml
name: Ollama Code Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - '**.tf'
      - '**.yaml'
      - '**.yml'
      - 'Dockerfile'

jobs:
  code-review:
    runs-on: self-hosted  # Requires runner with Ollama installed
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          
      - name: Get changed files
        id: changed-files
        run: |
          echo "files=$(git diff --name-only ${{ github.event.pull_request.base.sha }} ${{ github.event.pull_request.head.sha }} | grep -E '\.tf$|\.ya?ml$|Dockerfile$' | xargs)" >> $GITHUB_OUTPUT
      
      - name: Review changed files
        run: |
          mkdir -p reviews
          for file in ${{ steps.changed-files.outputs.files }}; do
            echo "Reviewing $file..."
            CONTENT=$(cat "$file")
            
            # Determine file type for specialized prompts
            case "$file" in
              *.tf)
                PROMPT="Review this Terraform code for security issues, best practices, and improvements:"
                ;;
              *.yml|*.yaml)
                PROMPT="Review this YAML file (likely Kubernetes or CI config) for issues and best practices:"
                ;;
              Dockerfile)
                PROMPT="Review this Dockerfile for security issues, best practices, and improvements:"
                ;;
              *)
                PROMPT="Review this code for issues and suggest improvements:"
                ;;
            esac
            
            PROMPT="$PROMPT

            \`\`\`
            $CONTENT
            \`\`\`
            
            Format your response as markdown with sections for:
            1. Security Issues (if any)
            2. Best Practice Violations (if any)
            3. Suggested Improvements
            Keep your response concise and focused on actionable items."
            
            ollama run devops-assistant "$PROMPT" > "reviews/$(basename "$file").md"
          done
          
      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            const path = require('path');
            
            const reviewDir = path.join(process.env.GITHUB_WORKSPACE, 'reviews');
            const files = fs.readdirSync(reviewDir);
            
            for (const file of files) {
              const content = fs.readFileSync(path.join(reviewDir, file), 'utf8');
              const originalFile = file.replace(/\.md$/, '');
              
              await github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: `## AI Review for \`${originalFile}\`\n\n${content}\n\n*Generated by Ollama*`
              });
            }
```

### Knowledge Base Generation

Script to generate documentation from your infrastructure code:

```bash
#!/bin/bash
# generate-docs.sh

PROJECT_DIR="$1"
DOCS_DIR="$PROJECT_DIR/docs"

mkdir -p "$DOCS_DIR/resources"
mkdir -p "$DOCS_DIR/diagrams"

# Generate overall architecture description
find "$PROJECT_DIR" -name "*.tf" -type f | xargs cat | \
ollama run devops-assistant "Based on this Terraform code, generate a high-level architecture document describing the infrastructure. Include sections for main components, networking, security, and scalability considerations." \
> "$DOCS_DIR/architecture.md"

# Generate resource-specific documentation
for RESOURCE_TYPE in $(grep -h "resource" "$PROJECT_DIR"/*.tf | grep -oP 'resource "\K[^"]+' | sort | uniq); do
  echo "Generating docs for $RESOURCE_TYPE resources..."
  grep -r -A 20 "resource \"$RESOURCE_TYPE\"" "$PROJECT_DIR" | \
  ollama run devops-assistant "Based on these Terraform resource definitions for '$RESOURCE_TYPE', create detailed documentation explaining their purpose, configuration, and relationships with other resources." \
  > "$DOCS_DIR/resources/$RESOURCE_TYPE.md"
done

echo "Documentation generated in $DOCS_DIR"
```

## RAG Implementation for DevOps Knowledge Base

Create a simple Retrieval-Augmented Generation system for your documentation and runbooks:

```bash
#!/bin/bash
# devops-assistant.sh

# Simple RAG implementation for DevOps documents
DOCS_DIR="$HOME/docs"  # Directory containing runbooks, guides, etc.
QUERY="$*"             # User question from command line arguments

if [[ -z "$QUERY" ]]; then
  echo "Usage: ./devops-assistant.sh 'your question here'"
  exit 1
fi

# Find relevant documents using grep (simpler than vector DB but works for small docs)
echo "🔍 Searching for relevant information..."
CONTEXT=$(grep -l -r -i "$(echo $QUERY | tr ' ' '\|')" "$DOCS_DIR" | xargs cat | head -n 1000)

if [[ -z "$CONTEXT" ]]; then
  echo "⚠️ No specific documents found. Proceeding with general knowledge."
  PROMPT="$QUERY

  Please provide a detailed answer based on DevOps best practices. Include code examples if relevant."
else
  # Create a prompt with the retrieved context
  PROMPT="Based on the following documentation and the query, provide a helpful response.

  DOCUMENTATION:
  $CONTEXT

  QUERY: $QUERY

  Respond directly to the query using the information in the documentation. If the documentation doesn't address the query completely, supplement with DevOps best practices."
fi

# Get answer from Ollama
echo "🤖 Generating response..."
echo ""
ollama run devops-assistant "$PROMPT"
```

## Pros and Cons of Using Ollama in DevOps

### Pros

| Advantage | Description |
|-----------|-------------|
| **Privacy** | Sensitive code and credentials remain local |
| **Offline capability** | Work without internet connection |
| **No rate limits** | Unlimited queries and generations |
| **Cost-effective** | No subscription or per-token fees |
| **Customizable** | Adapt models for specific DevOps needs |
| **Integration** | Easily incorporated into scripts and CI/CD |
| **Low latency** | Local execution offers faster responses |

### Cons

| Disadvantage | Description |
|--------------|-------------|
| **Resource intensive** | Requires significant RAM and CPU/GPU |
| **Limited model size** | Cannot run the largest models on average hardware |
| **Setup complexity** | Initial configuration can be challenging |
| **Knowledge cutoff** | Models may lack knowledge of newer technologies |
| **Quality variance** | May not match commercial API quality in some cases |
| **Maintenance required** | Need to update models and tools manually |
| **Limited tooling** | Fewer ready-made integrations than commercial alternatives |

## Best Practices for DevOps Integration

1. **Create domain-specific models**: Customize models for your specific tech stack
2. **Batch processing**: Process multiple files or inputs in batch for efficiency
3. **Version control all prompts**: Store prompt templates in your repo for consistency
4. **Implement human review**: Always review generated code before deployment
5. **Layer RAG capabilities**: Enhance models with company-specific knowledge
6. **Establish clear boundaries**: Define when to use LLMs vs. when to use traditional tools
7. **Document limitations**: Make team members aware of model limitations
8. **Use semantic caching**: Cache responses for similar queries to improve efficiency

## Next Steps

After implementing Ollama in your DevOps workflows:

1. [Explore advanced model customization](models.md)
2. [Set up Open WebUI](open-webui.md) for team collaboration
3. [Configure optimal GPU settings](gpu-setup.md) for better performance