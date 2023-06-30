# Terrascan

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
    - job: TerraScanJob
      displayName: Run TerraScan Scan
      steps:
      - script: | 
          mkdir TerraScanReport
          docker pull accurics/terrascan
          docker run \
            --rm \
            --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform/azure:/iac \
            --workdir /iac \
            accurics/terrascan:latest scan \
              --iac-type terraform \
              --policy-type all \
              --verbose \
              --output xml > $(System.DefaultWorkingDirectory)/TerraScanReport/TerraScan-Report.xml
          
          docker run \
            --rm \
            --volume $(System.DefaultWorkingDirectory)/Infrastructure-Source-Code/terraform/azure:/iac \
            --workdir /iac \
            accurics/terrascan:latest scan \
              --iac-type terraform \
              --policy-type all \
              --verbose
        displayName: 'Accurics TerraScan Code Analysis'
      
      - script: |
          cd $(System.DefaultWorkingDirectory)/TerraScanReport
          ls -la
        displayName: 'DIR Contents'
        condition: always()
      
      # Publish the TerraScan report as an artifact to Azure Pipelines
      - task: PublishBuildArtifacts@1
        displayName: 'Publish Artifact: Terrascan Report'
        condition: succeededOrFailed()
        inputs:
          PathtoPublish: '$(System.DefaultWorkingDirectory)/TerraScanReport'
          ArtifactName: TerrascanReport

      - task: PublishTestResults@2
        displayName: Publish Terrascan Test Results
        condition: succeededOrFailed()
        inputs:
          testResultsFormat: 'JUnit' # Options JUnit, NUnit, VSTest, xUnit, cTest
          testResultsFiles: '**/*TerraScan-Report.xml'
          searchFolder: '$(System.DefaultWorkingDirectory)/TerraScanReport'
          mergeTestResults: false
          testRunTitle: Terrascan Scan
          failTaskOnFailedTests: false
          publishRunAttachments: true
```

GitHub Workflow;

```yaml
name: INFA - IaC - TerraScan

on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  terrascan_job:
    runs-on: ubuntu-latest
    name: TerraScan-Action
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Run Terrascan IaC Scanner
      id: terrascan
      uses: accurics/terrascan-action@main
      with:
        iac_type: 'terraform' #Required (helm, k8s, kustomize, terraform)
        iac_version: 'v14' #(helm: v3, k8s: v1, kustomize: v3, terraform: v12, v14)
        policy_type: 'all' #optional (all, aws, azure, gcp, github, k8s) (default all)
        only_warn: false #optional (the action will only warn and not error when violations are found)
        sarif_upload: true
        #non_recursive:
        iac_dir: ./Infrastructure-Source-Code/terraform/azure/ #optional, default is .
        #policy_path: #optional (policy path directory for custom policies)
        #skip_rules: #optional (one or more rules to skip while scanning (example: "ruleID1,ruleID2")
        #config_path:
        #webhook_url:
        #webhook_token:
        verbose: true #optional (scan will show violations with additional details (Rule Name/ID, Resource Name/Type, Violation Category))

    - name: Upload SARIF file
      uses: github/codeql-action/upload-sarif@v1
      with:
        sarif_file: terrascan.sarif
```
