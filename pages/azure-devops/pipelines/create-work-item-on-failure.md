# Automated Work Item Creation on Pipeline Failure

In modern DevOps practices, automatically creating work items when pipelines fail helps teams track and resolve issues efficiently. This approach minimizes manual intervention and ensures that failures are properly documented and addressed.

## Basic Implementation (2025)

```yaml
# When manually running the pipeline, you can choose success or failure path
parameters:
- name: succeed
  displayName: Succeed or fail
  type: boolean
  default: true
- name: workItemPriority
  displayName: Work Item Priority
  type: string
  default: '2'
  values:
  - '1' # Critical
  - '2' # High
  - '3' # Medium
  - '4' # Low

trigger:
- main

pool:
  vmImage: ubuntu-latest

jobs:
- job: Work
  steps:
  - script: echo Hello, world!
    displayName: 'Run a one-line script'
    
  # This will cause the job to fail if succeed parameter is false
  - script: |
      if [[ "${{ parameters.succeed }}" == "false" ]]; then
        echo "Simulating a failure for demonstration purposes"
        exit 1
      else
        echo "Continuing with success path"
      fi
    displayName: 'Conditional failure simulation'

# This job creates a detailed work item and only runs if the previous job failed
- job: ErrorHandler
  dependsOn: Work
  condition: failed()
  steps: 
  - bash: |
      # Capture pipeline details for error context
      ERROR_DETAILS=$(curl -s -H "Authorization: Bearer $(System.AccessToken)" "$(System.CollectionUri)$(System.TeamProject)/_apis/build/builds/$(Build.BuildId)/logs?api-version=7.1")
      
      # Create a detailed work item with error information
      az boards work-item create \
        --title "Pipeline Failure: $(Build.DefinitionName) #$(Build.BuildNumber)" \
        --type bug \
        --org $(System.TeamFoundationCollectionUri) \
        --project $(System.TeamProject) \
        --priority ${{ parameters.workItemPriority }} \
        --assigned-to "$(Build.RequestedFor)" \
        --fields "System.Tags=Pipeline;Automated;Failure" \
        "System.Description=<h3>Pipeline Failure Details</h3><p><b>Pipeline:</b> $(Build.DefinitionName)<br><b>Build Number:</b> $(Build.BuildNumber)<br><b>Triggered by:</b> $(Build.RequestedFor)<br><b>Error Repository:</b> $(Build.Repository.Name)<br><b>Branch:</b> $(Build.SourceBranch)<br><b>Commit:</b> $(Build.SourceVersion)</p><p>Please investigate the pipeline logs for detailed error information.</p><a href='$(System.CollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)'>View Build Details</a>"
    env: 
      AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
    displayName: 'Create detailed work item on failure'
    
  # Notify on failure through Teams webhook
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        $teamsMessage = @{
          "@type" = "MessageCard"
          "@context" = "https://schema.org/extensions"
          "summary" = "Build Failure Notification"
          "themeColor" = "D70000"
          "title" = "Pipeline $(Build.DefinitionName) has failed"
          "sections" = @(
            @{
              "facts" = @(
                @{ "name" = "Pipeline"; "value" = "$(Build.DefinitionName)" },
                @{ "name" = "Build Number"; "value" = "$(Build.BuildNumber)" },
                @{ "name" = "Repository"; "value" = "$(Build.Repository.Name)" },
                @{ "name" = "Branch"; "value" = "$(Build.SourceBranch)" },
                @{ "name" = "Triggered by"; "value" = "$(Build.RequestedFor)" }
              )
              "text" = "A work item has been automatically created to track this issue."
            }
          )
          "potentialAction" = @(
            @{
              "@type" = "OpenUri"
              "name" = "View Build Details"
              "targets" = @(
                @{ "os" = "default"; "uri" = "$(System.CollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)" }
              )
            }
          )
        }
        
        $body = ConvertTo-Json -Depth 10 $teamsMessage
        
        try {
          Invoke-RestMethod -Uri "$(TeamsWebhookUrl)" -Method Post -ContentType 'application/json' -Body $body
          Write-Host "Teams notification sent successfully"
        }
        catch {
          Write-Host "Failed to send Teams notification: $_"
        }
    displayName: 'Send Teams notification'
    condition: always() # Ensure notification runs even if work item creation fails
```

## Real-life Example: Microservices CI/CD Pipeline

The following example demonstrates a real-world implementation for a microservices architecture where failures in any service build need to be tracked and managed:

```yaml
# Microservices CI/CD Pipeline with Advanced Error Handling
parameters:
- name: services
  type: object
  default:
    - name: api-service
      path: ./services/api
      tests: true
    - name: auth-service
      path: ./services/auth
      tests: true
    - name: payment-service
      path: ./services/payment
      tests: true

variables:
  - name: isProduction
    value: $[eq(variables['Build.SourceBranch'], 'refs/heads/main')]
  - group: notification-settings

trigger:
  branches:
    include:
    - main
    - feature/*
    - hotfix/*

pool:
  vmImage: ubuntu-latest

stages:
- stage: Build
  jobs:
  - ${{ each service in parameters.services }}:
    - job: Build_${{ service.name }}
      displayName: 'Build ${{ service.name }}'
      steps:
      - checkout: self
      
      - task: Docker@2
        displayName: 'Build Docker image'
        inputs:
          command: build
          buildContext: ${{ service.path }}
          dockerfile: '${{ service.path }}/Dockerfile'
          tags: |
            $(Build.BuildId)-${{ service.name }}
            latest-${{ service.name }}
      
      - ${{ if eq(service.tests, true) }}:
        - script: |
            cd ${{ service.path }}
            npm install
            npm test
          displayName: 'Run tests'
          continueOnError: false

- stage: ErrorProcessing
  dependsOn: Build
  condition: failed('Build')
  jobs:
  - job: ProcessErrors
    steps:
    - task: PowerShell@2
      displayName: 'Analyze failures and create work items'
      inputs:
        targetType: 'inline'
        script: |
          # Fetch build details to identify which services failed
          $buildDetails = Invoke-RestMethod -Uri "$(System.CollectionUri)$(System.TeamProject)/_apis/build/builds/$(Build.BuildId)?api-version=7.1" -Headers @{Authorization = "Bearer $(System.AccessToken)"}
          
          # Get job results
          $jobs = Invoke-RestMethod -Uri "$(System.CollectionUri)$(System.TeamProject)/_apis/build/builds/$(Build.BuildId)/timeline?api-version=7.1" -Headers @{Authorization = "Bearer $(System.AccessToken)"}
          
          # Find failed jobs
          $failedJobs = $jobs.records | Where-Object { $_.result -eq 'failed' -and $_.type -eq 'Job' }
          
          foreach ($failedJob in $failedJobs) {
              # Extract service name from job name (Build_service-name)
              $serviceName = ($failedJob.name -split '_')[1]
              
              if (-not [string]::IsNullOrEmpty($serviceName)) {
                  Write-Host "Creating work item for failed service: $serviceName"
                  
                  # Find logs for the failed job
                  $jobLogs = Invoke-RestMethod -Uri "$($failedJob.log.url)" -Headers @{Authorization = "Bearer $(System.AccessToken)"}
                  $logContent = $jobLogs.value | ForEach-Object { $_.line } | Out-String
                  
                  # Create work item with service-specific details
                  $workItemArgs = @(
                      "boards", "work-item", "create",
                      "--title", "Build failure in $serviceName (Build #$(Build.BuildNumber))",
                      "--type", "bug",
                      "--org", "$(System.TeamFoundationCollectionUri)",
                      "--project", "$(System.TeamProject)",
                      "--assigned-to", "$(Build.RequestedFor)",
                      "--fields", "System.Tags=Pipeline;Failure;$serviceName",
                      "System.Description=<h2>Service Failure: $serviceName</h2><p><b>Pipeline:</b> $(Build.DefinitionName)<br><b>Build:</b> <a href='$(System.CollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)'>$(Build.BuildNumber)</a><br><b>Branch:</b> $(Build.SourceBranch)<br><b>Commit:</b> <a href='$(Build.Repository.Uri)/commit/$(Build.SourceVersion)'>$(Build.SourceVersion)</a></p>"
                  )
                  
                  # Add development team field if defined for this service
                  if ('$(serviceTeams)' -ne '') {
                      $serviceTeamsObj = ConvertFrom-Json '$(serviceTeams)'
                      if ($serviceTeamsObj.$serviceName) {
                          $workItemArgs += "--fields"
                          $workItemArgs += "System.AreaPath=$(System.TeamProject)\$($serviceTeamsObj.$serviceName)"
                      }
                  }
                  
                  & az $workItemArgs
                  
                  # Link work item to build
                  $workItem = (& az boards work-item show --org "$(System.TeamFoundationCollectionUri)" --id $LASTEXITCODE) | ConvertFrom-Json
                  if ($workItem -and $workItem.id) {
                      & az boards work-item relation add --org "$(System.TeamFoundationCollectionUri)" --id $workItem.id --relation-type "Build" --target-id $(Build.BuildId)
                  }
              }
          }
      env:
        AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
        serviceTeams: '{"api-service": "API Team", "auth-service": "Security Team", "payment-service": "Payment Team"}'

    - task: AzureFunction@1
      displayName: 'Trigger incident management workflow'
      inputs:
        function: '$(IncidentFunctionUrl)'
        key: '$(IncidentFunctionKey)'
        body: |
          {
            "pipeline": "$(Build.DefinitionName)",
            "buildId": "$(Build.BuildId)",
            "buildNumber": "$(Build.BuildNumber)",
            "repository": "$(Build.Repository.Name)",
            "branch": "$(Build.SourceBranch)",
            "requestedBy": "$(Build.RequestedFor)",
            "requestedForEmail": "$(Build.RequestedForEmail)",
            "status": "Failed",
            "failureLink": "$(System.CollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)",
            "isProduction": $(isProduction)
          }
      condition: and(failed(), eq(variables.isProduction, true))
```

## Integration with ServiceNow (Enterprise Example)

For enterprise scenarios where ServiceNow is used for IT service management:

```yaml
# Example fragment showing ServiceNow integration
- job: CreateServiceNowIncident
  dependsOn: Work
  condition: failed()
  steps:
  - task: ServiceNowCICD@1
    displayName: 'Create ServiceNow incident'
    inputs:
      connectedServiceName: 'ServiceNow-Connection'
      serviceNowInstance: '$(ServiceNowUrl)'
      createIncident: true
      incidentData: |
        {
          "short_description": "Pipeline failure: $(Build.DefinitionName) #$(Build.BuildNumber)",
          "description": "A critical pipeline has failed in Azure DevOps.\n\nDetails:\nPipeline: $(Build.DefinitionName)\nBuild: $(Build.BuildNumber)\nTriggered by: $(Build.RequestedFor)\nRepository: $(Build.Repository.Name)\nBranch: $(Build.SourceBranch)\nCommit: $(Build.SourceVersion)",
          "impact": "2",
          "urgency": "2",
          "category": "Infrastructure",
          "assignment_group": "DevOps Support"
        }
```

## Best Practices for Work Item Creation in 2025

1. **Contextual work item creation** - Include specific information about the failure context
2. **Proper assignment** - Direct work items to responsible teams or individuals
3. **Integration with communication tools** - Send notifications to Teams, Slack, or email
4. **Consistent tagging** - Use standardized tags for filtering and reporting
5. **Failure categorization** - Identify whether failures are in tests, builds, or deployments
6. **Rich descriptions** - Add links to logs, repositories, and specific code snippets
7. **Priority classification** - Assign appropriate priority based on impact

By implementing these patterns, teams can transform pipeline failures into actionable tasks, reduce mean time to recovery, and maintain higher quality standards throughout the development lifecycle.
