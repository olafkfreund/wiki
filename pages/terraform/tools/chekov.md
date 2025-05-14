---
description: >-
  Checkov is a static code analysis tool for scanning infrastructure as code
  (IaC) files for misconfigurations that may lead to security or compliance
  problems.
---

# Chekov

Install Checkov on Linux:

```bash
pip3 install checkov
```plaintext

or install by using brew:

```bash
brew install checkov
```plaintext

Use Checkov with Terraform:

```bash
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 
checkov -f tf.json
```plaintext

Docker and Podman:

{% code overflow="wrap" lineNumbers="true" %}
```bash
docker pull bridgecrew/checkov
docker run --tty --volume /user/tf:/tf --workdir /tf bridgecrew/checkov --directory /tf
```plaintext
{% endcode %}

GitHub Action:

{% code overflow="wrap" lineNumbers="true" %}
```yaml
---
name: Checkov
on:
  push:
    branches:
      - master
jobs:
  build:

    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python 3.8
        uses: actions/setup-python@v1
        with:
          python-version: 3.8
      - name: Test with Checkov
        id: checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: example/examplea
          framework: terraform 
```plaintext
{% endcode %}

Checkov with Azure DevOps for terraform:

```yaml
- task: Bash@3
  inputs:
    targetType: 'inline'
    script: 'pip3 install checkov'
  displayName: Install Checkov
- task: Bash@3
  inputs:
    targetType: 'inline'
    workingDirectory: $(System.DefaultWorkingDirectory)
    script: 'checkov -d . -o junitxml > scan-result.xml'
  displayName: Checkov source code scan
  continueOnError: true
- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'JUnit'
    searchFolder: '$(System.DefaultWorkingDirectory)'
    testResultsFiles: '**/*scan-result.xml'
    mergeTestResults: false
    testRunTitle: Terraform source code scan
    failTaskOnFailedTests: false
    publishRunmAttachments: true
  displayName: Publish Test Result
- task: Bash@3
  inputs:
    targetType: 'inline'
    workingDirectory: $(System.DefaultWorkingDirectory)
    script: |
      terraform show -json main.tfplan > main.json
        checkov -f main.json -o junitxml > Checkov-Plan-Report.xml
  continueOnError: true
  displayName: Checkov plan scan
```plaintext

Chekov with Azure DevOps and Bicep:

{% code overflow="wrap" lineNumbers="true" %}
```yaml
trigger:
- main

pool:
  vmImage: ubuntu-latest

stages:
  - stage: "runCheckov"
    displayName: "Checkov - Scan Bicep files"
    jobs:
      - job: "runCheckov"
        displayName: "Checkov scan for bicep"
        steps:
          - bash: |
              docker pull bridgecrew/checkov
            workingDirectory: $(System.DefaultWorkingDirectory)
            displayName: "Pull bridgecrew/checkov image"
          - bash: |
              docker run --volume $(pwd):/bicep bridgecrew/checkov --directory /bicep --output junitxml --soft-fail > $(pwd)/CheckovReport.xml
            workingDirectory: $(System.DefaultWorkingDirectory)
            displayName: "Run checkov"
          - task: PublishTestResults@2
            inputs:
              testRunTitle: "Checkov Results"
              failTaskOnFailedTests: true
              testResultsFormat: "JUnit"
              testResultsFiles: "CheckovReport.xml"
              searchFolder: "$(System.DefaultWorkingDirectory)"
            displayName: "Publish Test results"
```plaintext
{% endcode %}
