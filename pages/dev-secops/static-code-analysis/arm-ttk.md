# ARM TTK

The ARM Template Tool Kit is a new static code analyser for ARM templates created by Microsoft. It's an open-source PowerShell library that you can use to validate your templates against a series of test cases. These test cases are generic and designed to validate that your templates are following best practice, a little like the PowerShell PSScriptAnalyzer tool. The ARM TTK tests for things like:

* Templates are using a valid schema
* Locations are not hardcoded
* Outputs don't contain secrets
* ID's are derived from resource ID's
* Templates do not contain blanks

For full details of the ARM TTK visit it's [Git repository](https://github.com/Azure/azure-quickstart-templates/tree/master/test/arm-ttk)

```yaml
trigger: none
pr: none

pool:
  vmImage: 'windows-latest'


stages:
- stage: QualityCheckStage
  displayName: Quality Check Stage
  jobs:
    - job: ARMTTKJob
      displayName: Run Azure Resource Manager (ARM) Template Tool Kit (TTK) Tests
      steps:
      - task: RunARMTTKTests@1
        displayName: Run ARM TTK Tests
        inputs:
          templatelocation: '$(System.DefaultWorkingDirectory)\Infrastructure-Source-Code\ARMTTK-TestFiles'
          resultLocation: '$(System.DefaultWorkingDirectory)\Results'
          # includeTests: 'VM Images Should Use Latest Version,Resources Should Have Location'
          # skipTests: 'VM Images Should Use Latest Version,Resources Should Have Location'
          # mainTemplates: 'template1.json, template2.json'
          allTemplatesMain: true
          cliOutputResults: true

      - task: PublishTestResults@2
        displayName: Publish Test Results
        inputs:
          testResultsFormat: 'NUnit'
          testResultsFiles: '$(System.DefaultWorkingDirectory)\Results\*-armttk.xml'
        condition: always()
```plaintext
