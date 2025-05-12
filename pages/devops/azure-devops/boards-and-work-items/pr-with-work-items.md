---
description: >-
  CREATE AND COMPLETE PULL REQUEST BY ASSOCIATING WORKITEMS AND DELETING SOURCE
  BRANCH
---

# PR with work items

```yaml
- stage: PULL_REQUEST_ASSOCIATE_WORKITEMS
  condition: |
     and(succeeded(), 
       ne(variables['Build.SourceBranch'], 'refs/heads/main') 
     )
  dependsOn: DEPLOY
  jobs:
  - job: PULL_REQUEST_WORKITEMS
    displayName: CREATE PR | ASSOCIATE WORKITEMS | COMPLETE
    steps:
# Download Keyvault Secrets:
    - task: AzureKeyVault@2
      inputs:
        azureSubscription: '$(ServiceConnection)'
        KeyVaultName: '$(KV-Name)'
        SecretsFilter: '*'
        RunAsPreJob: false
# Install Az DevOps CLI Extension in the Build Agent:
    - task: AzureCLI@1
      displayName: INSTALL DEVOPS CLI EXTENSION
      inputs:
        azureSubscription: '$(ServiceConnection)'
        scriptType: ps
        scriptLocation: inlineScript
        inlineScript: |
          az extension add --name azure-devops
          az extension show --name azure-devops --output table
# Validate Az DevOps CLI Extension in the Build Agent:
    - task: PowerShell@2
      displayName: VALIDATE AZ DEVOPS CLI
      inputs:
        targetType: 'inline'
        script: |
          az devops -h
# Set Default DevOps Organization and Project:
    - task: PowerShell@2
      displayName: DEVOPS LOGIN + SET DEFAULT DEVOPS ORG & PROJECT
      inputs:
        targetType: 'inline'
        script: |
         echo "$(PAT)" | az devops login  
         az devops configure --defaults organization=$(DevOpsOrganisation) project=$(DevOpsProjName)
# Create Workitem + Create PR + Associate Workitem with PR + Complete the PR + Delete Source Branch:-
    - task: PowerShell@2
      displayName: CREATE & COMPLETE PULL REQUEST + WORKITEMS + DELETE SOURCE BRANCH
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "#######################################################"
          Write-Host "NAME OF THE SOURCE BRANCH: $(Build.SourceBranchName)"
          Write-Host "#######################################################"
          $i="PR-"
          $j=Get-Random -Maximum 1000
          Write-Host "###################################################"
          Write-Host "WORKITEM NUMBER GENERATED IN DEVOPS BOARD: $i$j"
          Write-Host "###################################################"
          $wid = az boards work-item create --title $i$j --type "Issue" --query "id"
          Write-Host "#######################################################" 
          Write-Host "WORKITEM ID is: $wid"
          Write-Host "#######################################################"
          $prid = az repos pr create --repository $(DevOpsRepoName) --source-branch $(Build.SourceBranchName) --target-branch $(DevOpsDestinationBranch) --work-items $wid --transition-work-items true --query "pullRequestId"
          Write-Host "#######################################################"
          Write-Host "PULL REQUEST ID is: $prid"
          Write-Host "#######################################################"
          Write-Host "##### TO BE MERGED FROM $(Build.SourceBranchName) TO Main #####"
          az repos pr update --id $prid --auto-complete true --squash true --status completed --delete-source-branch true
          Write-Host "##### MERGE SUCCESSFULL #####"
```plaintext
