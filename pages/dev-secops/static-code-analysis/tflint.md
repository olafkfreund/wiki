# TFLint

Azure YAML

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
      # TFLint is a framework that finds possible errors (like illegal instance types) for major cloud providers (AWS/Azure/GCP),
      # warn about deprecated syntax, unused declarations, and enforce best practices, naming conventions.
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
      
      # Publish the TFLint report as an artifact to Azure Pipelines
      - task: PublishBuildArtifacts@1
        displayName: 'Publish Artifact: TFLint Report'
        condition: succeededOrFailed()
        inputs:
          PathtoPublish: '$(System.DefaultWorkingDirectory)/TFLintReport'
          ArtifactName: TFLintReport

      # Publish the results of the TFLint analysis as Test Results to the pipeline
      - task: PublishTestResults@2
        displayName: Publish TFLint Test Results
        condition: succeededOrFailed()
        inputs:
          testResultsFormat: 'JUnit' # Options JUnit, NUnit, VSTest, xUnit, cTest
          testResultsFiles: '**/*TFLint-Report.xml'
          searchFolder: '$(System.DefaultWorkingDirectory)/TFLintReport'
          mergeTestResults: false
          testRunTitle: TFLint Scan
          failTaskOnFailedTests: false
          publishRunAttachments: true

      # Clean up any of the containers / images that were used for quality checks
      - bash: |
          docker rmi "ghcr.io/terraform-linters/tflint-bundle" -f | true
        displayName: 'Remove Terraform Quality Check Docker Images'
        condition: always()
```

GitHub Workflow

```yaml
name: INFRA - IaC - TFLint

on:
  # Allows you to run this workflow manually from the Actions tab
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
```
