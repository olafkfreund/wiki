# Jobs in Azure DevOps Pipelines

Jobs are the building blocks of an Azure DevOps pipeline that represent units of work assignable to a single agent. Jobs run in sequence or parallel within a stage and contain a series of steps that run sequentially on the same agent.

## Job Schema

```yaml
jobs: [ job | deployment | template ] # Required. Jobs represent units of work which can be assigned to a single agent or server.
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
lockBehavior: string # Behavior lock requests from this stage should exhibit in relation to other exclusive lock requests.
```

## Individual Job Schema

```yaml
job: string # Required. ID of the job.
displayName: string # Human-readable name for the job.
dependsOn: string | [ string ] # Any jobs which must complete before this one starts.
condition: string # Condition for job to execute.
continueOnError: boolean # Continue running even if the job fails.
timeoutInMinutes: number # Max time to wait for job to complete.
cancelTimeoutInMinutes: number # Max time to wait for job to cancel.
variables: variables | [ variable ] # Variables specific to this job.
pool: pool # Agent pool to use for this job.
workspace: # Workspace options on the agent.
  clean: string # Which parts of workspace should be cleaned before fetching repo.
container: string | container # Container resource name or container specification.
services: # Container resources to run as service containers.
  string: string # Name/value pairs.
uses: # External repository from which to get steps.
  repositories: [ repository ] # List of repositories.
  parameters: { string: any } # Parameters passed to template.
steps: [ task | script | powershell | pwsh | bash | checkout | download | downloadBuild | getPackage | publish | template | reviewApp ] # List of steps to run in this job.
strategy: # Execution strategy for this job.
  parallel: number # Max number of simultaneous matrix legs to run.
  matrix: { string: { string: string } } # Matrix of parameter values for each job.
  maxParallel: number # Maximum number of matrix legs to run simultaneously.
  failFast: boolean # Whether to cancel all running jobs if any job fails.
```

## Basic Example

```yaml
trigger:
- main

pool: 
  vmImage: ubuntu-latest

jobs:
- job: Build
  displayName: 'Build Job'
  steps:
  - script: echo "Building the application"
    displayName: 'Run build script'

- job: Test
  displayName: 'Test Job'
  dependsOn: Build
  steps:
  - script: echo "Running tests"
    displayName: 'Run test script'
```

## Advanced Examples

### Jobs with Dependencies

```yaml
jobs:
- job: BuildApp
  displayName: 'Build Application'
  steps:
  - script: echo "Building the application"
    displayName: 'Build'

- job: TestApp
  displayName: 'Test Application'
  dependsOn: BuildApp
  steps:
  - script: echo "Testing the application"
    displayName: 'Test'

- job: DeployDev
  displayName: 'Deploy to Dev'
  dependsOn: TestApp
  steps:
  - script: echo "Deploying to development"
    displayName: 'Deploy to dev'

# These jobs will run in parallel after TestApp completes
- job: SecurityScan
  displayName: 'Security Scan'
  dependsOn: TestApp
  steps:
  - script: echo "Running security scan"
    displayName: 'Security scan'

- job: PerformanceTest
  displayName: 'Performance Test'
  dependsOn: TestApp
  steps:
  - script: echo "Running performance tests"
    displayName: 'Performance test'

# This job runs only after both DeployDev and SecurityScan complete
- job: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: 
  - DeployDev
  - SecurityScan
  condition: succeeded()
  steps:
  - script: echo "Deploying to production"
    displayName: 'Deploy to prod'
```

### Matrix Strategy

Matrix strategy is used to run the same job multiple times with different variable sets:

```yaml
jobs:
- job: BuildMultiplePlatforms
  displayName: 'Build for Multiple Platforms'
  strategy:
    matrix:
      linux:
        imageName: 'ubuntu-latest'
        frameworkVersion: '6.0'
      windows:
        imageName: 'windows-latest'
        frameworkVersion: '6.0'
      mac:
        imageName: 'macOS-latest'
        frameworkVersion: '6.0'
    maxParallel: 2
    failFast: true
  pool:
    vmImage: $(imageName)
  steps:
  - script: echo "Building for $(imageName) with .NET $(frameworkVersion)"
    displayName: 'Print configuration'
  - script: dotnet build --configuration Release --framework net$(frameworkVersion)
    displayName: 'Build application'
```

### Job Conditions

```yaml
jobs:
- job: AlwaysRun
  displayName: 'Always Run'
  steps:
  - script: echo "This job always runs"

- job: MainBranchOnly
  displayName: 'Main Branch Only'
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  steps:
  - script: echo "This job only runs on the main branch"

- job: PROnly
  displayName: 'PR Only'
  condition: eq(variables['Build.Reason'], 'PullRequest')
  steps:
  - script: echo "This job only runs on pull requests"

- job: RunOnFailure
  displayName: 'Run on Failure'
  dependsOn: MainBranchOnly
  condition: failed()
  steps:
  - script: echo "This job runs when MainBranchOnly fails"
```

### Job with Container

```yaml
jobs:
- job: RunInContainer
  displayName: 'Run in Container'
  pool:
    vmImage: 'ubuntu-latest'
  container:
    image: node:lts
    options: '--init'
  steps:
  - script: |
      node --version
      npm --version
      npm install
      npm test
    displayName: 'Run tests in Node.js container'
```

### Deployment Jobs

Deployment jobs are a special type of job that records deployment history:

```yaml
jobs:
- deployment: DeployWeb
  displayName: 'Deploy Web App'
  environment: 'production'
  strategy:
    runOnce:
      deploy:
        steps:
        - task: AzureWebApp@1
          displayName: 'Deploy to Azure Web App'
          inputs:
            azureSubscription: 'my-azure-subscription'
            appName: 'my-web-app'
            package: '$(System.ArtifactsDirectory)/**/*.zip'
```

### Job Templates

```yaml
# azure-pipelines.yml
jobs:
- template: templates/build-job.yml
  parameters:
    name: Linux
    pool:
      vmImage: 'ubuntu-latest'

- template: templates/build-job.yml
  parameters:
    name: Windows
    pool:
      vmImage: 'windows-latest'

# templates/build-job.yml
parameters:
  name: ''
  pool: {}

jobs:
- job: ${{ parameters.name }}Build
  displayName: '${{ parameters.name }} Build'
  pool: ${{ parameters.pool }}
  steps:
  - script: echo "Building on ${{ parameters.name }}"
    displayName: 'Build'
```

## Job Types

Azure DevOps Pipelines supports three types of jobs:

### 1. Agent Jobs

Standard jobs that run on an agent. These are the most common type.

```yaml
jobs:
- job: AgentJob
  pool:
    vmImage: 'ubuntu-latest'
  steps:
  - script: echo "Running on an agent"
```

### 2. Deployment Jobs

Jobs that record deployment history.

```yaml
jobs:
- deployment: DeployJob
  environment: Production
  strategy:
    runOnce:
      deploy:
        steps:
        - script: echo "Deploying to Production"
```

### 3. Server Jobs

Jobs that run on the Azure DevOps server without an agent.

```yaml
jobs:
- job: ServerJob
  pool: server
  steps:
  - task: InvokeRESTAPI@1
    inputs:
      connectionType: 'connectedServiceName'
      serviceConnection: 'myServiceConnection'
      method: 'GET'
      headers: |
        {
          "Content-Type": "application/json"
        }
      urlSuffix: '/api/endpoint'
```

## Best Practices for Jobs

1. **Use Descriptive Names**: Give jobs meaningful names and display names to improve readability.
   ```yaml
   - job: BuildAndTest
     displayName: 'Build and Run Tests'
   ```

2. **Define Clear Dependencies**: Use `dependsOn` to create a clear execution flow between jobs.
   ```yaml
   - job: Deploy
     dependsOn: [Build, Test, SecurityScan]
   ```

3. **Set Appropriate Timeouts**: Use `timeoutInMinutes` to prevent jobs from running indefinitely.
   ```yaml
   - job: LongRunningJob
     timeoutInMinutes: 120
   ```

4. **Use Job Templates for Reusability**: Extract common job patterns into templates.
   ```yaml
   - template: templates/standard-build.yml
     parameters:
       projectName: 'MyProject'
   ```

5. **Leverage Job Conditions**: Use conditions to control when jobs should run.
   ```yaml
   - job: DeployToProduction
     condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
   ```

6. **Use Matrix Strategy Efficiently**: Use matrix when you need to run the same job with multiple configurations.
   ```yaml
   strategy:
     matrix:
       Debug_x86:
         buildConfiguration: 'Debug'
         buildPlatform: 'x86'
       Release_x86:
         buildConfiguration: 'Release'
         buildPlatform: 'x86'
       Release_x64:
         buildConfiguration: 'Release'
         buildPlatform: 'x64'
   ```

7. **Consider Parallelization**: Use parallel jobs when possible to reduce total pipeline run time.

8. **Use Job Outputs for Sharing Data**: Use job outputs to pass data between jobs.
   ```yaml
   - job: GenerateData
     steps:
     - bash: echo "##vso[task.setvariable variable=myOutputVar;isOutput=true]some value"
       name: setVarStep
   
   - job: ConsumeData
     dependsOn: GenerateData
     variables:
       myVar: $[ dependencies.GenerateData.outputs['setVarStep.myOutputVar'] ]
     steps:
     - bash: echo "The value is $(myVar)"
   ```

9. **Use Specialized Pools for Specialized Jobs**: Match job requirements to appropriate agent pools.

10. **Minimize Job Dependencies**: Break complex workflows into parallel paths where possible to optimize execution time.
