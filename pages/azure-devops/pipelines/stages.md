# Stages in Azure DevOps Pipelines

Stages are a key organizational concept in Azure DevOps Pipelines that allow you to group jobs together and run them in a specific sequence. Each stage represents a logical boundary in your pipeline, such as build, test, and deploy, enabling you to implement practices like Continuous Integration (CI) and Continuous Deployment (CD).

## Pipeline Schema for Stages

```yaml
stages: [ stage | template ] # Required. Stages are groups of jobs that can run sequentially or in parallel.
pool: string | pool # Pool where jobs in this pipeline will run unless otherwise specified.
name: string # Pipeline run number.
appendCommitMessageToRunName: boolean # Append the commit message to the build number. The default is true.
trigger: none | trigger | [ string ] # Continuous integration triggers.
parameters: [ parameter ] # Pipeline template parameters.
pr: none | pr | [ string ] # Pull request triggers.
schedules: [ cron ] # Scheduled triggers.
resources: # Containers and repositories used in the build.
  builds: [ build ] # List of build resources referenced by the pipeline.
  containers: [ container ] # List of container images.
  pipelines: [ pipeline ] # List of pipeline resources.
  repositories: [ repository ] # List of repository resources.
  webhooks: [ webhook ] # List of webhooks.
  packages: [ package ] # List of package resources.
variables: variables | [ variable ] # Variables for this pipeline.
lockBehavior: string # Behavior lock requests from this stage should exhibit in relation to other exclusive lock requests
```

## Stage Schema

```yaml
stage: string # Required. Name of the stage.
displayName: string # Human-readable name for the stage.
dependsOn: string | [ string ] # Stage(s) that must complete before this stage runs.
condition: string # Condition that must be met for the stage to run.
variables: variables | [ variable ] # Stage-specific variables.
jobs: [ job | template ] # Jobs that make up the stage.
pool: pool # Pool where jobs in this stage will run unless specified for each job.
lockBehavior: string # Behavior lock requests from this stage should exhibit in relation to other exclusive lock requests
```

## Basic Stage Example

```yaml
trigger:
- main

pool: 
  vmImage: ubuntu-latest

stages:
- stage: Build
  displayName: 'Build Stage'
  jobs:
  - job: BuildJob
    steps:
    - script: echo "Building the application"
      displayName: 'Build Application'

- stage: Test
  displayName: 'Test Stage'
  dependsOn: Build
  jobs:
  - job: TestJob
    steps:
    - script: echo "Running tests"
      displayName: 'Run Tests'

- stage: Deploy
  displayName: 'Deploy Stage'
  dependsOn: Test
  jobs:
  - job: DeployJob
    steps:
    - script: echo "Deploying to production"
      displayName: 'Deploy to Production'
```

## Advanced Examples

### Conditional Stages

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildApp
    steps:
    - script: echo "Building the application"

- stage: DeployDev
  dependsOn: Build
  condition: succeeded()
  jobs:
  - job: DeployToDev
    steps:
    - script: echo "Deploying to Dev environment"

- stage: DeployProd
  dependsOn: DeployDev
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: DeployToProd
    steps:
    - script: echo "Deploying to Production environment"
```

### Parallel and Sequential Stages

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildApp
    steps:
    - script: echo "Building the application"

# These stages run in parallel after Build completes
- stage: Test
  dependsOn: Build
  jobs:
  - job: RunTests
    steps:
    - script: echo "Running tests"

- stage: Scan
  dependsOn: Build
  jobs:
  - job: SecurityScan
    steps:
    - script: echo "Running security scans"

# This stage runs after both Test and Scan complete
- stage: Deploy
  dependsOn: 
  - Test
  - Scan
  condition: and(succeeded('Test'), succeeded('Scan'))
  jobs:
  - job: DeployApp
    steps:
    - script: echo "Deploying application"
```

### Stages with Approval Gates

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - script: echo "Building application"

- stage: DeployToProduction
  dependsOn: Build
  jobs:
  - deployment: Deploy
    environment: Production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo "Deploying to Production"
```

### Stages with Variables

```yaml
stages:
- stage: BuildTest
  variables:
    buildConfiguration: 'Debug'
  jobs:
  - job: Build
    steps:
    - script: dotnet build --configuration $(buildConfiguration)
      displayName: 'Build with $(buildConfiguration)'

- stage: Deploy
  variables:
    buildConfiguration: 'Release'
  jobs:
  - job: DeployJob
    steps:
    - script: dotnet publish --configuration $(buildConfiguration)
      displayName: 'Publish with $(buildConfiguration)'
```

### Using Templates in Stages

```yaml
# Main pipeline file
trigger:
- main

stages:
- template: templates/build-stage.yml
- template: templates/test-stage.yml
  parameters:
    runExtendedTests: true
- template: templates/deploy-stage.yml
  parameters:
    environment: 'Production'
    serviceConnection: 'AzureServiceConnection'
```

```yaml
# templates/build-stage.yml
stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - script: echo "Build steps go here"
```

### Deployment Stages with Multiple Jobs

```yaml
stages:
- stage: Deploy
  displayName: Deploy Stage
  jobs:
  - deployment: DeployWeb
    displayName: Deploy Web App
    environment: Production
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'YourServiceConnection'
              appName: 'YourWebAppName'
              package: '$(System.DefaultWorkingDirectory)/**/*.zip'

  - deployment: DeployAPI
    displayName: Deploy API
    environment: Production
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureFunctionApp@1
            inputs:
              azureSubscription: 'YourServiceConnection'
              appName: 'YourAPIName'
              package: '$(System.DefaultWorkingDirectory)/**/*.zip'
```

## Best Practices for Using Stages

1. **Logical Grouping**: Group related jobs into stages based on their purpose (build, test, deploy)
2. **Clear Naming**: Use descriptive stage names that indicate their purpose
3. **Dependencies**: Clearly define stage dependencies using the `dependsOn` property
4. **Conditions**: Use conditions to control when stages should run
5. **Environments**: For deployment stages, associate with environments to enable approvals and checks
6. **Templates**: Extract reusable stage configurations into templates
7. **Variables**: Scope variables to the stages where they are needed

## Stage Lock Behavior

The `lockBehavior` property controls how a stage interacts with exclusive pipeline locks:

```yaml
stages:
- stage: Deploy
  lockBehavior: sequential # Sequential (default) or runLatest
  jobs:
  - job: DeployJob
    steps:
    - script: echo "Deploying"
```

- `sequential`: Wait for earlier requested exclusive locks (default)
- `runLatest`: Run only the latest requested exclusive lock
