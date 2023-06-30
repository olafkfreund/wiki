# Checkov

## Checkov is a static code analysis tool for infrastructure-as-code.

It scans cloud infrastructure provisioned using Terraform, Cloudformation, Kubernetes, Serverlessor ARM Templates and detects security and compliance misconfigurations.

```
Documentation: https://github.com/bridgecrewio/checkov
```

```yaml
trigger: none
pr: none

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: QualityCheckStage
  displayName: Quality Check Stage
  jobs:
    - job: CheckovJob
      displayName: Run Checkov Scan
      steps:
      # NOTE: If you want to skip a specific check from the analysis, include it in the command-line as 
      # follows: --skip-check CKV_AWS_70,CKV_AWS_52,CKV_AWS_21,CKV_AWS_18,CKV_AWS_19
      - script: |
          mkdir CheckovReport
          docker pull bridgecrew/checkov:latest

          docker run \
            --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform:/tf \
            bridgecrew/checkov \
              --directory /tf \
              --output junitxml > $(System.DefaultWorkingDirectory)/CheckovReport/Checkov-Report.xml

          docker run \
          --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform:/tf \
          bridgecrew/checkov \
            --directory /tf
        displayName: 'Checkov Static Code Analysis'
        name: CheckovScan
        condition: always()
      
      # Publish the Checkov report as an artifact to Azure Pipelines
      - task: PublishBuildArtifacts@1
        displayName: 'Publish Artifact: Checkov Report'
        condition: succeededOrFailed()
        inputs:
          PathtoPublish: '$(System.DefaultWorkingDirectory)/CheckovReport'
          ArtifactName: CheckovReport

      # Publish the results of the Checkov analysis as Test Results to the pipeline
      # NOTE: There is a current issue with the produced XML that fails to publish the test results correctly.
      # Discussed issue with BridgeCrew, which is looking into it.
      # Work-around is to include the Script step to remove the last 2 lines from the file before processing.
      - task: PublishTestResults@2
        displayName: Publish Checkov Test Results
        condition: succeededOrFailed()
        inputs:
          testResultsFormat: 'JUnit' # Options JUnit, NUnit, VSTest, xUnit, cTest
          testResultsFiles: '**/*Checkov-Report.xml'
          searchFolder: '$(System.DefaultWorkingDirectory)/CheckovReport'
          mergeTestResults: false
          testRunTitle: Checkov Scan
          failTaskOnFailedTests: false
          publishRunAttachments: true

      # Clean up any of the containers / images that were used for quality checks
      - bash: |
          docker rmi "bridgecrew/checkov" -f | true
        displayName: 'Remove Terraform Quality Check Docker Images'
        condition: always()
```

GitHub Workflow:

```yaml
name: INFRA - IaC - Checkov

on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
   checkov:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Run Checkov IaC Scanner
      id: checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: ./Infrastructure-Source-Code/terraform/azure
        # check: CKV_AWS_1 # optional: run only a specific check_id. can be comma separated list
        # skip_check: CKV_AWS_2 # optional: skip a specific check_id. can be comma separated list
        quiet: true # optional: display only failed checks
        soft_fail: false # optional: do not return an error code if there are failed checks
        framework: terraform # optional: run only on a specific infrastructure {cloudformation,terraform,kubernetes,all}
        output_format: cli # optional: the output format, one of: cli, json, junitxml, github_failed_only, or sarif. Default: sarif
        download_external_modules: true # optional: download external terraform modules from public git repositories and terraform registry
        log_level: WARNING # optional: set log level. Default WARNING
        # config_file: path/this_file
        # baseline: cloudformation/.checkov.baseline # optional: Path to a generated baseline file. Will only report results not in the baseline.
        # container_user: 1000 # optional: Define what UID and / or what GID to run the container under to prevent permission issues
      env:  
        GITHUB_REPOSITORY: ${{ github.repository }}
        GITHUB_REF: ${{ github.ref }}
        GITHUB_SHA: ${{ github.sha }}
        #GITHUB_SERVER_URL: $GITHUB_SERVER_URL
    
    - name: Generate SARIF Report
      uses: bridgecrewio/checkov-action@master
      if: ${{ success() || failure() }}
      with:
        directory: ./Infrastructure-Source-Code/terraform/azure
        quiet: true # optional: display only failed checks
        soft_fail: false # optional: do not return an error code if there are failed checks
        framework: terraform # optional: run only on a specific infrastructure {cloudformation,terraform,kubernetes,all}
        output_format: sarif # optional: the output format, one of: cli, json, junitxml, github_failed_only, or sarif. Default: sarif
        download_external_modules: true # optional: download external terraform modules from public git repositories and terraform registry
        log_level: WARNING # optional: set log level. Default WARNING
      env:  
        GITHUB_REPOSITORY: ${{ github.repository }}
        GITHUB_REF: ${{ github.ref }}
        GITHUB_SHA: ${{ github.sha }}
    
    - name: Publish Workflow Artifact
      if: ${{ always() }}
      uses: actions/upload-artifact@v2
      with:
        name: SARIF results
        path: results.sarif
    
    - name: Upload Checkov scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: ${{ always() }}
      with:
        sarif_file: results.sarif
```
