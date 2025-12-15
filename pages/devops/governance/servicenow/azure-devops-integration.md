---
description: Integrate ServiceNow with Azure DevOps Pipelines for automated change management and deployment tracking
keywords: servicenow, azure devops, azure pipelines, ci/cd, change management, devops integration
---

# ServiceNow Azure DevOps Integration

## Overview

This guide demonstrates how to integrate ServiceNow change management with Azure DevOps Pipelines. ServiceNow provides an official Azure DevOps extension that simplifies integration, along with REST API options for custom workflows.

## Integration Architecture

```
┌────────────────────────────────────────────┐
│       Azure DevOps Pipeline                │
│                                            │
│  ┌──────┐  ┌──────┐  ┌───────────────┐   │
│  │Build │─→│ Test │─→│ Create SNOW   │   │
│  └──────┘  └──────┘  │ Change Request│   │
│                       └───────┬───────┘   │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Approval Gate      │ │
│                    └──────────┬─────────┘ │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Deploy to Prod     │ │
│                    └──────────┬─────────┘ │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Close Change       │ │
│                    └────────────────────┘ │
└────────────────────────────────────────────┘
                        │
                        ▼
              ┌──────────────────┐
              │   ServiceNow     │
              │  Change Request  │
              └──────────────────┘
```

## Method 1: Official ServiceNow Extension

### Installation

1. **Install Extension from Marketplace**:
   - Navigate to: https://marketplace.visualstudio.com/items?itemName=ServiceNow.vss-services-servicenow-cicd
   - Click "Get it free"
   - Select your Azure DevOps organization
   - Install the extension

2. **Configure Service Connection**:
   - Go to **Project Settings > Service Connections**
   - Click **New service connection**
   - Select **ServiceNow**
   - Fill in:
     - ServiceNow URL: `https://your-instance.service-now.com`
     - Username: ServiceNow service account
     - Password: Service account password
     - Service connection name: `ServiceNow-Prod`

### Using ServiceNow Tasks

```yaml
trigger:
  branches:
    include:
      - main
      - release/*

pool:
  vmImage: 'ubuntu-latest'

variables:
  serviceNowConnection: 'ServiceNow-Prod'
  assignmentGroup: 'DevOps Team'
  cmdbCI: 'prod-k8s-cluster'

stages:
- stage: Build
  jobs:
  - job: BuildAndTest
    steps:
    - task: Docker@2
      inputs:
        command: 'build'
        Dockerfile: '**/Dockerfile'
        tags: '$(Build.BuildId)'

    - task: DotNetCoreCLI@2
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'

- stage: CreateChange
  dependsOn: Build
  jobs:
  - job: ServiceNowChange
    steps:
    - task: ServiceNow-DevOps-Agent-Artifact-Registration@1
      inputs:
        connectedServiceName: '$(serviceNowConnection)'
        artifactToolIdExists: false
        artifactType: 'package'
        artifactName: '$(Build.Repository.Name)'
        version: '$(Build.BuildNumber)'
        artifactsPayload: |
          {
            "artifacts": [
              {
                "name": "$(Build.Repository.Name)",
                "version": "$(Build.BuildNumber)",
                "semanticVersion": "$(Build.BuildNumber)",
                "repositoryName": "$(Build.Repository.Name)"
              }
            ]
          }

    - task: ServiceNow-DevOps-Agent-Change-Create@1
      name: createChange
      inputs:
        connectedServiceName: '$(serviceNowConnection)'
        shortDescription: 'Deploy $(Build.Repository.Name) $(Build.BuildNumber)'
        description: |
          Automated deployment from Azure DevOps
          Pipeline: $(System.TeamProject)/$(Build.DefinitionName)
          Build: $(Build.BuildNumber)
          Commit: $(Build.SourceVersion)
        assignmentGroup: '$(assignmentGroup)'
        configurationItem: '$(cmdbCI)'
        implementationPlan: 'Deploy containerized application using Helm chart to Kubernetes'
        backoutPlan: 'Rollback deployment using helm rollback command'
        testPlan: 'Automated tests passed in build stage'

- stage: WaitForApproval
  dependsOn: CreateChange
  jobs:
  - job: WaitApproval
    steps:
    - task: ServiceNow-DevOps-Agent-Get-Change@1
      inputs:
        connectedServiceName: '$(serviceNowConnection)'
        changeRequestNumber: '$(createChange.changeRequestNumber)'

- stage: Deploy
  dependsOn: WaitForApproval
  jobs:
  - deployment: DeployProduction
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubernetesManifest@0
            inputs:
              action: 'deploy'
              kubernetesServiceConnection: 'k8s-prod'
              manifests: '$(Pipeline.Workspace)/k8s/*.yaml'

          - task: ServiceNow-DevOps-Agent-Update-Change@1
            inputs:
              connectedServiceName: '$(serviceNowConnection)'
              changeRequestNumber: '$(createChange.changeRequestNumber)'
              state: 'implement'
              workNotes: 'Deployment completed at $(System.DateTime)'

- stage: CloseChange
  dependsOn: Deploy
  condition: succeeded()
  jobs:
  - job: CloseChangeRequest
    steps:
    - task: ServiceNow-DevOps-Agent-Update-Change@1
      inputs:
        connectedServiceName: '$(serviceNowConnection)'
        changeRequestNumber: '$(createChange.changeRequestNumber)'
        state: 'closed'
        closeCode: 'successful'
        closeNotes: 'Deployment verified successfully in production'
```

## Method 2: REST API Integration

### Using PowerShell

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  serviceNowInstance: 'your-instance'
  serviceNowUrl: 'https://$(serviceNowInstance).service-now.com'

stages:
- stage: Build
  jobs:
  - job: BuildApp
    steps:
    - script: |
        echo "Building application..."
        dotnet build
      displayName: 'Build Application'

    - script: |
        echo "Running tests..."
        dotnet test
      displayName: 'Run Tests'

- stage: ChangeManagement
  jobs:
  - job: CreateChange
    variables:
      snowUser: $(ServiceNowUsername)
      snowPass: $(ServiceNowPassword)
    steps:
    - task: PowerShell@2
      name: CreateChangeRequest
      inputs:
        targetType: 'inline'
        script: |
          $pair = "$($env:SNOWUSER):$($env:SNOWPASS)"
          $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
          $base64 = [System.Convert]::ToBase64String($bytes)
          $headers = @{
              Authorization = "Basic $base64"
              "Content-Type" = "application/json"
          }

          $body = @{
              short_description = "Deploy $(Build.Repository.Name) $(Build.BuildNumber)"
              description = @"
          Automated deployment from Azure DevOps
          Pipeline: $(System.TeamProject)/$(Build.DefinitionName)
          Build URL: $(System.CollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)
          Commit: $(Build.SourceVersion)
          "@
              assignment_group = "DevOps Team"
              type = "standard"
              priority = "3"
              risk = "low"
              impact = "2"
              implementation_plan = "Deploy using Kubernetes Helm chart"
              backout_plan = "Rollback using helm rollback command"
          } | ConvertTo-Json

          $response = Invoke-RestMethod -Uri "$(serviceNowUrl)/api/now/table/change_request" `
                                        -Method Post `
                                        -Headers $headers `
                                        -Body $body

          $sysId = $response.result.sys_id
          $changeNumber = $response.result.number

          Write-Host "Created ServiceNow Change Request: $changeNumber"
          Write-Host "Change SYS_ID: $sysId"

          # Set pipeline variables
          Write-Host "##vso[task.setvariable variable=changeSysId;isOutput=true]$sysId"
          Write-Host "##vso[task.setvariable variable=changeNumber;isOutput=true]$changeNumber"
      env:
        SNOWUSER: $(snowUser)
        SNOWPASS: $(snowPass)

  - job: WaitForApproval
    dependsOn: CreateChange
    variables:
      changeSysId: $[ dependencies.CreateChange.outputs['CreateChangeRequest.changeSysId'] ]
      changeNumber: $[ dependencies.CreateChange.outputs['CreateChangeRequest.changeNumber'] ]
    steps:
    - task: PowerShell@2
      inputs:
        targetType: 'inline'
        script: |
          $pair = "$(ServiceNowUsername):$(ServiceNowPassword)"
          $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
          $base64 = [System.Convert]::ToBase64String($bytes)
          $headers = @{
              Authorization = "Basic $base64"
              Accept = "application/json"
          }

          $timeout = 3600  # 1 hour
          $interval = 60   # Check every minute
          $elapsed = 0

          Write-Host "Waiting for approval of change: $(changeNumber)"

          while ($elapsed -lt $timeout) {
              $response = Invoke-RestMethod -Uri "$(serviceNowUrl)/api/now/table/change_request/$(changeSysId)?sysparm_fields=state,approval,number" `
                                            -Method Get `
                                            -Headers $headers

              $state = $response.result.state
              $approval = $response.result.approval

              Write-Host "Change $(changeNumber) - State: $state, Approval: $approval"

              # Check if approved (state: -2 = Scheduled, -1 = Implement)
              if ($state -eq "-2" -or $state -eq "-1") {
                  Write-Host "✓ Change request approved!"
                  exit 0
              }

              # Check if rejected or canceled
              if ($state -eq "4" -or $approval -eq "rejected") {
                  Write-Host "✗ Change request rejected or canceled"
                  exit 1
              }

              Start-Sleep -Seconds $interval
              $elapsed += $interval
          }

          Write-Host "✗ Timeout waiting for approval"
          exit 1

- stage: Deploy
  dependsOn: ChangeManagement
  variables:
    changeSysId: $[ stageDependencies.ChangeManagement.CreateChange.outputs['CreateChangeRequest.changeSysId'] ]
  jobs:
  - deployment: DeployProd
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              echo "Deploying to production..."
              kubectl apply -f k8s/production/
            displayName: 'Deploy to Kubernetes'

          - task: PowerShell@2
            inputs:
              targetType: 'inline'
              script: |
                $pair = "$(ServiceNowUsername):$(ServiceNowPassword)"
                $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
                $base64 = [System.Convert]::ToBase64String($bytes)
                $headers = @{
                    Authorization = "Basic $base64"
                    "Content-Type" = "application/json"
                }

                $body = @{
                    state = "-1"
                    work_notes = "Deployment completed at $(Get-Date -Format o)"
                } | ConvertTo-Json

                Invoke-RestMethod -Uri "$(serviceNowUrl)/api/now/table/change_request/$(changeSysId)" `
                                  -Method Patch `
                                  -Headers $headers `
                                  -Body $body

                Write-Host "✓ Updated change request to 'Implementing'"
            displayName: 'Update Change - Implementing'

- stage: CloseChange
  dependsOn: Deploy
  condition: succeeded()
  variables:
    changeSysId: $[ stageDependencies.ChangeManagement.CreateChange.outputs['CreateChangeRequest.changeSysId'] ]
  jobs:
  - job: CloseChangeRequest
    steps:
    - task: PowerShell@2
      inputs:
        targetType: 'inline'
        script: |
          $pair = "$(ServiceNowUsername):$(ServiceNowPassword)"
          $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
          $base64 = [System.Convert]::ToBase64String($bytes)
          $headers = @{
              Authorization = "Basic $base64"
              "Content-Type" = "application/json"
          }

          $body = @{
              state = "3"
              close_code = "successful"
              close_notes = "Deployment verified successfully in production. Commit: $(Build.SourceVersion)"
          } | ConvertTo-Json

          Invoke-RestMethod -Uri "$(serviceNowUrl)/api/now/table/change_request/$(changeSysId)" `
                            -Method Patch `
                            -Headers $headers `
                            -Body $body

          Write-Host "✓ Closed change request successfully"
      displayName: 'Close Change Request'
```

### Using Bash/cURL

```yaml
stages:
- stage: ChangeManagement
  jobs:
  - job: CreateChange
    steps:
    - bash: |
        RESPONSE=$(curl -X POST \
          "$(serviceNowUrl)/api/now/table/change_request" \
          -u "$(ServiceNowUsername):$(ServiceNowPassword)" \
          -H "Content-Type: application/json" \
          -H "Accept: application/json" \
          -d "{
            \"short_description\": \"Deploy $(Build.Repository.Name) $(Build.BuildNumber)\",
            \"description\": \"Automated deployment from Azure DevOps\\nPipeline: $(System.TeamProject)/$(Build.DefinitionName)\\nCommit: $(Build.SourceVersion)\",
            \"assignment_group\": \"DevOps Team\",
            \"type\": \"standard\",
            \"priority\": \"3\"
          }")

        SYS_ID=$(echo "$RESPONSE" | jq -r '.result.sys_id')
        CHANGE_NUMBER=$(echo "$RESPONSE" | jq -r '.result.number')

        echo "Created ServiceNow Change Request: $CHANGE_NUMBER"
        echo "##vso[task.setvariable variable=changeSysId;isOutput=true]$SYS_ID"
        echo "##vso[task.setvariable variable=changeNumber;isOutput=true]$CHANGE_NUMBER"
      name: CreateChangeRequest
      displayName: 'Create ServiceNow Change Request'
```

## Method 3: Azure DevOps Extensions with Variable Groups

### Configure Variable Group

1. **Create Variable Group** (Pipelines > Library):
   - Name: `ServiceNow-Config`
   - Variables:
     - `ServiceNowInstance`: your-instance
     - `ServiceNowUsername`: service-account
     - `ServiceNowPassword`: ••••••• (mark as secret)
     - `AssignmentGroup`: DevOps Team
     - `CMDB_CI`: prod-k8s-cluster

2. **Link to Pipeline**:

```yaml
variables:
- group: ServiceNow-Config

stages:
- stage: Deploy
  jobs:
  - job: DeployWithChange
    steps:
    - task: PowerShell@2
      inputs:
        targetType: 'inline'
        script: |
          # Variables from Variable Group are automatically available
          Write-Host "Using instance: $(ServiceNowInstance)"
          # Create change request using variables
```

## Standard Changes for Faster Deployments

```yaml
stages:
- stage: StandardChange
  jobs:
  - job: CreateStandardChange
    steps:
    - task: ServiceNow-DevOps-Agent-Change-Create@1
      inputs:
        connectedServiceName: 'ServiceNow-Prod'
        changeType: 'standard'
        standardChangeTemplate: 'app-deployment-v1'
        shortDescription: 'Deploy $(Build.Repository.Name)'
        # Standard changes auto-approved

- stage: Deploy
  # No approval wait needed for standard changes
  dependsOn: StandardChange
  jobs:
  - deployment: DeployImmediate
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: kubectl apply -f k8s/
```

## Multi-Stage Deployments

```yaml
stages:
- stage: DeployStaging
  jobs:
  - deployment: DeployStaging
    environment: staging
    strategy:
      runOnce:
        deploy:
          steps:
          - script: kubectl apply -f k8s/staging/

- stage: CreateProductionChange
  dependsOn: DeployStaging
  condition: succeeded()
  jobs:
  - job: CreateChange
    steps:
    - task: ServiceNow-DevOps-Agent-Change-Create@1
      name: prodChange
      inputs:
        connectedServiceName: 'ServiceNow-Prod'
        shortDescription: 'Promote $(Build.Repository.Name) to Production'

- stage: DeployProduction
  dependsOn: CreateProductionChange
  jobs:
  - deployment: DeployProd
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: kubectl apply -f k8s/production/
```

## Integrating with Azure DevOps Environments

```yaml
stages:
- stage: Deploy
  jobs:
  - deployment: DeployProduction
    environment: production  # Azure DevOps environment approval
    strategy:
      runOnce:
        preDeploy:
          steps:
          - task: ServiceNow-DevOps-Agent-Change-Create@1
            name: createChange
            inputs:
              connectedServiceName: 'ServiceNow-Prod'
              shortDescription: 'Deploy to production'

          # Wait for ServiceNow approval
          - task: ServiceNow-DevOps-Agent-Get-Change@1
            inputs:
              connectedServiceName: 'ServiceNow-Prod'
              changeRequestNumber: '$(createChange.changeRequestNumber)'

        deploy:
          steps:
          - script: kubectl apply -f k8s/production/

        postDeploy:
          steps:
          - task: ServiceNow-DevOps-Agent-Update-Change@1
            inputs:
              connectedServiceName: 'ServiceNow-Prod'
              changeRequestNumber: '$(createChange.changeRequestNumber)'
              state: 'closed'
              closeCode: 'successful'
```

## Error Handling and Rollback

```yaml
stages:
- stage: Deploy
  jobs:
  - deployment: DeployProd
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: kubectl apply -f k8s/
            name: DeployStep
            continueOnError: true

          - task: PowerShell@2
            condition: failed()
            inputs:
              targetType: 'inline'
              script: |
                # Update change as failed
                $body = @{
                    state = "4"
                    close_code = "unsuccessful"
                    close_notes = "Deployment failed. Rolling back."
                } | ConvertTo-Json

                Invoke-RestMethod -Uri "$(serviceNowUrl)/api/now/table/change_request/$(changeSysId)" `
                                  -Method Patch `
                                  -Headers $headers `
                                  -Body $body

                # Execute rollback
                kubectl rollout undo deployment/myapp
            displayName: 'Handle Failure and Rollback'
```

## Best Practices

### Use Service Principal Authentication

Instead of username/password, use Service Principal:

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Azure-ServicePrincipal'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Get token for ServiceNow API
      TOKEN=$(az account get-access-token --resource https://$(serviceNowInstance).service-now.com --query accessToken -o tsv)
      curl -H "Authorization: Bearer $TOKEN" ...
```

### Cache ServiceNow Metadata

```yaml
- task: CacheBeta@0
  inputs:
    key: 'servicenow | metadata | v1'
    path: $(Pipeline.Workspace)/.snow-cache
    cacheHitVar: 'CACHE_RESTORED'

- script: |
    if [ "$CACHE_RESTORED" != "true" ]; then
      # Fetch and cache assignment groups, CMDB CIs, etc.
    fi
```

### Parallel Deployments with Change Tracking

```yaml
strategy:
  parallel: 3
  matrix:
    App1:
      appName: 'microservice-api'
    App2:
      appName: 'microservice-web'
    App3:
      appName: 'microservice-worker'

steps:
- task: ServiceNow-DevOps-Agent-Change-Create@1
  inputs:
    shortDescription: 'Deploy $(appName)'
```

## Troubleshooting

### Enable Debug Logging

```yaml
variables:
  system.debug: true  # Enable verbose logging

steps:
- task: PowerShell@2
  inputs:
    script: |
      Write-Host "##[debug]ServiceNow URL: $(serviceNowUrl)"
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Service connection fails | Verify URL format: `https://instance.service-now.com` |
| Extension tasks not found | Install ServiceNow extension in Azure DevOps organization |
| Variable not available | Use `stageDependencies` syntax for cross-stage variables |
| PowerShell authentication fails | Check Base64 encoding of credentials |

## Next Steps

- [ServiceNow Best Practices](best-practices.md)
- [CI/CD Integration Overview](cicd-integration-overview.md)
- [GitLab Integration](gitlab-integration.md)

## Additional Resources

- [ServiceNow Azure DevOps Extension](https://marketplace.visualstudio.com/items?itemName=ServiceNow.vss-services-servicenow-cicd)
- [Azure DevOps Pipeline Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [ServiceNow REST API](https://developer.servicenow.com/dev.do#!/reference/api/vancouver/rest/)
- [Azure DevOps Service Connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)
