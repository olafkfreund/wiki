# TFLint (2025 Best Practices)

TFLint is a powerful tool for analyzing Terraform code, detecting potential errors, enforcing best practices, and ensuring compliance with cloud provider standards. This document includes updated best practices for 2025, real-life examples using Linux, WSL, and NixOS, and integration with LLMs like Claude, Copilot, and Gemini.

---

## Updated Best Practices (2025)

1. **LLM-Assisted Analysis**:
   - Use LLMs like Claude, Copilot, and Gemini to enhance TFLint by providing contextual recommendations and automated fixes.
   - Integrate LLMs to analyze TFLint reports and suggest improvements.

2. **Multi-Cloud Validation**:
   - Ensure TFLint is configured for AWS, Azure, and GCP simultaneously.
   - Use provider-specific plugins to enforce cloud-specific best practices.

3. **Continuous Integration**:
   - Automate TFLint scans in CI/CD pipelines using GitHub Actions, Azure Pipelines, or GitLab CI/CD.
   - Publish reports and integrate with dashboards for visibility.

4. **Custom Rules**:
   - Develop custom rules to enforce organizational standards.
   - Use the TFLint plugin system to extend functionality.

5. **Security and Compliance**:
   - Validate Terraform modules and providers for supply chain security.
   - Use signed provider plugins and verify module sources.

---

## Real-Life Examples

### Linux Integration

```bash
# Install TFLint on Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Configure TFLint for multi-cloud validation
cat > ~/.config/tflint/config.hcl <<EOF
plugin "aws" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azure" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azure"
}

plugin "google" {
  enabled = true
  version = "0.25.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
EOF

# Run TFLint
cd /path/to/terraform/code
tflint --init
tflint --module
```

### WSL Integration

```powershell
# Configure WSL for TFLint
wsl --install Ubuntu-22.04

# Install TFLint in WSL
wsl -d Ubuntu-22.04 bash -c '
  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  mkdir -p ~/.config/tflint
  echo "plugin \"aws\" { enabled = true }" > ~/.config/tflint/config.hcl
'

# Run TFLint in WSL
wsl -d Ubuntu-22.04 bash -c '
  cd /mnt/c/terraform/code
  tflint --init
  tflint --module
'
```

### NixOS Integration

```nix
# NixOS configuration for TFLint
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tflint
    terraform
  ];

  # Example TFLint configuration
  environment.etc = {
    "tflint/config.hcl".text = ''
      plugin "aws" {
        enabled = true
        version = "0.28.0"
        source  = "github.com/terraform-linters/tflint-ruleset-aws"
      }
    '';
  };
}
```

---

## LLM Integration Examples

### Claude Integration for Report Analysis

```python
from anthropic import Anthropic
import json

class TFLintAnalyzer:
    def __init__(self, api_key):
        self.client = Anthropic(api_key=api_key)

    async def analyze_report(self, report_path):
        with open(report_path, 'r') as file:
            report = file.read()

        prompt = f"""
        Analyze this TFLint report and provide:
        1. Key issues
        2. Suggested fixes
        3. Compliance risks

        Report:
        {report}
        """

        response = await self.client.messages.create(
            model="claude-3-opus-20240229",
            messages=[{"role": "user", "content": prompt}]
        )

        return response.content
```

### GitHub Copilot for Custom Rules

```hcl
# Example custom rule for enforcing naming conventions
rule "resource_naming" {
  enabled = true
  message = "Resource names must follow the pattern 'project-env-resource'."
  severity = "ERROR"
  pattern = "^[a-z0-9]+-[a-z]+-[a-z]+$"
}
```

### Gemini for Automated Fix Suggestions

```python
from gemini import Gemini

class TFLintFixer:
    def __init__(self, api_key):
        self.client = Gemini(api_key=api_key)

    async def suggest_fixes(self, issues):
        prompt = f"""
        Suggest fixes for the following TFLint issues:
        {json.dumps(issues, indent=2)}
        """

        response = await self.client.generate_content(prompt)
        return response
```

---

## Updated Azure YAML

```yaml
trigger: none
pr: none

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: QualityCheckStage
  displayName: Quality Check Stage
  jobs:
    - job: TFLintJob
      displayName: Run TFLint Scan
      steps:
      - script: |
          mkdir TFLintReport
          docker pull ghcr.io/terraform-linters/tflint-bundle:latest

          docker run \
            --rm \
            --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform:/data \
            -t ghcr.io/terraform-linters/tflint-bundle \
              --module \
              --format junit > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-Report.xml

          docker run \
            --rm \
            --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform:/data \
            -t ghcr.io/terraform-linters/tflint-bundle \
              --module
        displayName: 'TFLint Static Code Analysis'
        name: TFLintScan
        condition: always()

      - task: PublishBuildArtifacts@1
        displayName: 'Publish Artifact: TFLint Report'
        condition: succeededOrFailed()
        inputs:
          PathtoPublish: '$(System.DefaultWorkingDirectory)/TFLintReport'
          ArtifactName: TFLintReport

      - task: PublishTestResults@2
        displayName: Publish TFLint Test Results
        condition: succeededOrFailed()
        inputs:
          testResultsFormat: 'JUnit'
          testResultsFiles: '**/*TFLint-Report.xml'
          searchFolder: '$(System.DefaultWorkingDirectory)/TFLintReport'
          mergeTestResults: false
          testRunTitle: TFLint Scan
          failTaskOnFailedTests: false
          publishRunAttachments: true

      - bash: |
          docker rmi "ghcr.io/terraform-linters/tflint-bundle" -f | true
        displayName: 'Remove Terraform Quality Check Docker Images'
        condition: always()
```

---

## Updated GitHub Workflow

```yaml
name: INFRA - IaC - TFLint

on:
  workflow_dispatch:

jobs:
  tflint:
    runs-on: ubuntu-latest
    name: TFLint
    steps:
    - uses: actions/checkout@v1
      name: Checkout source code

    - uses: terraform-linters/setup-tflint@v3
      name: Setup TFLint
      with:
        tflint_version: latest

    - name: Show version
      run: tflint --version

    - name: Init TFLint
      run: tflint --init

    - name: Run TFLint
      working-directory: ./Infrastructure-Source-Code/terraform/azure
      run: tflint -f compact

    - name: Analyze with Claude
      run: |
        python3 /scripts/security/ai_scanner.py analyze_report ./TFLintReport/TFLint-Report.xml
```

---
