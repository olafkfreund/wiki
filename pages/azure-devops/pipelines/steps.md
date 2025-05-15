# Steps in Azure DevOps Pipelines

Steps are the most fundamental building blocks of an Azure DevOps pipeline. Each step represents a single action to be performed during the execution of a job. When you define a pipeline with steps and without explicitly defining jobs, Azure DevOps will create an implicit job to contain those steps.

## Step Schema

```yaml
steps: [ task | script | powershell | pwsh | bash | checkout | download | downloadBuild | getPackage | publish | template | reviewApp ] # Required. A list of steps to run in this job.
strategy: strategy # Execution strategy for this job.
continueOnError: string # Continue running even on failure?
pool: string | pool # Pool where jobs in this pipeline will run unless otherwise specified.
container: string | container # Container resource name.
services: # Container resources to run as a service container.
  string: string # Name/value pairs
workspace: # Workspace options on the agent.
  clean: string # Which parts of the workspace should be scorched before fetching.
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

## Step Types

Azure DevOps Pipelines supports several types of steps:

### Task

A task is a pre-packaged script that performs a specific action. Azure DevOps provides many built-in tasks, and you can also use tasks from the marketplace.

```yaml
- task: TaskName@version
  displayName: 'Human-readable step name'
  inputs:
    param1: value1
    param2: value2
```

### Script

A script step runs a command-line script using cmd.exe on Windows and sh on other platforms.

```yaml
- script: echo Hello, world!
  displayName: 'Say hello'
```

### PowerShell

A PowerShell step runs a script using PowerShell on Windows, macOS, and Linux.

```yaml
- powershell: |
    Write-Host "Hello from PowerShell"
    $PSVersionTable
  displayName: 'Run PowerShell'
```

### Bash

A bash step runs a script using Bash on Windows, macOS, and Linux.

```yaml
- bash: |
    echo "Hello from Bash"
    echo "Current directory: $(pwd)"
  displayName: 'Run Bash commands'
```

### Checkout

The checkout step is used to check out source code from a repository.

```yaml
- checkout: self  # self represents the repo where the pipeline is defined
  clean: true     # whether to fetch clean each time
  fetchDepth: 1   # the depth of commits to ask Git to fetch
```

### Download

The download step downloads artifacts from the current or another pipeline run.

```yaml
- download: current  # refers to artifacts published by current pipeline
  artifact: WebApp   # name of the artifact to download
  path: $(Build.ArtifactStagingDirectory)/WebApp  # download path
```

### Publish

The publish step publishes (uploads) a file or folder as a pipeline artifact.

```yaml
- publish: $(Build.ArtifactStagingDirectory)/WebApp
  artifact: WebApp
  displayName: 'Publish WebApp artifact'
```

### Template

The template step includes steps from a template file.

```yaml
- template: steps/build.yml  # Template reference
  parameters:
    buildConfiguration: 'Release'
```

## Step Properties

Common properties that can be applied to steps include:

### displayName

A friendly name displayed in the Azure DevOps UI.

```yaml
- script: echo Hello
  displayName: 'Say Hello'
```

### name

A reference name used in expressions.

```yaml
- script: echo "Setting variable"
  name: setVariable
```

### condition

A condition that determines whether the step should run.

```yaml
- script: echo "This only runs if the previous step succeeded"
  condition: succeeded()
```

### continueOnError

Whether to continue running more steps even if this step fails.

```yaml
- script: exit 1
  continueOnError: true
  displayName: 'This step will fail but pipeline continues'
```

### env

Environment variables to set for the step.

```yaml
- script: echo "Using environment variable: $GREETING"
  env:
    GREETING: Hello, world!
```

### timeoutInMinutes

The maximum time a step should run before it is canceled.

```yaml
- script: sleep 300  # Run for 5 minutes
  timeoutInMinutes: 6
  displayName: 'Step with timeout'
```

### workingDirectory

The working directory for the step.

```yaml
- script: ls -la
  workingDirectory: $(Build.SourcesDirectory)/src
  displayName: 'List files in src directory'
```

## Examples

### Basic Pipeline with Steps

```yaml
trigger:
- main

pool: 
  vmImage: ubuntu-latest

steps:
- script: echo "Hello world!"
  displayName: 'Print greeting'
```

### Multiple Step Types

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- checkout: self

- bash: |
    echo "Current directory: $(pwd)"
    echo "Repository files:"
    ls -la
  displayName: 'List files'

- task: UseDotNet@2
  displayName: 'Install .NET Core SDK'
  inputs:
    packageType: 'sdk'
    version: '6.0.x'

- script: |
    dotnet restore
    dotnet build --configuration Release
  displayName: 'Build the application'
  workingDirectory: $(Build.SourcesDirectory)/src

- task: DotNetCoreCLI@2
  displayName: 'Run unit tests'
  inputs:
    command: 'test'
    projects: '**/*Tests/*.csproj'
    arguments: '--configuration Release'
```

### Conditional Step Execution

```yaml
steps:
- script: echo "This always runs"
  displayName: 'Always run'

- script: echo "This runs only on main branch"
  displayName: 'Main branch only'
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

- script: echo "This runs only on feature branches"
  displayName: 'Feature branch only'
  condition: startsWith(variables['Build.SourceBranch'], 'refs/heads/feature/')

- script: echo "This runs only if all previous steps succeeded"
  displayName: 'Run if all succeeded'
  condition: succeeded()

- script: echo "This runs even if previous steps failed"
  displayName: 'Run even on failure'
  condition: always()
```

### Using Output Variables

```yaml
steps:
- bash: |
    echo "##vso[task.setvariable variable=myOutputVar;isOutput=true]some value"
  name: setVarStep
  displayName: 'Set output variable'

- bash: |
    echo "The output variable is: $(setVarStep.myOutputVar)"
  displayName: 'Use output variable'
  condition: succeeded()
```

### Step Templates

```yaml
# azure-pipelines.yml
steps:
- template: templates/build-steps.yml
  parameters:
    buildConfiguration: 'Release'

# templates/build-steps.yml
parameters:
  buildConfiguration: 'Debug'

steps:
- script: dotnet build --configuration ${{ parameters.buildConfiguration }}
  displayName: 'Build with ${{ parameters.buildConfiguration }} configuration'
```

### Advanced Container Example

```yaml
pool:
  vmImage: 'ubuntu-latest'

container:
  image: mcr.microsoft.com/dotnet/sdk:6.0
  options: '--name ci-container -v /var/run/docker.sock:/var/run/docker.sock'

steps:
- script: |
    dotnet --version
    dotnet build
    dotnet test
  displayName: 'Build and test'
```

## Best Practices for Steps

1. **Use descriptive displayNames**: Give each step a clear, descriptive name to make pipeline logs easier to read.

2. **Group related commands**: Use multi-line scripts for related commands rather than multiple separate script steps.

3. **Set timeouts**: For steps that might hang, set timeoutInMinutes to prevent the pipeline from waiting indefinitely.

4. **Handle errors appropriately**: Use continueOnError for non-critical steps where failures shouldn't stop the pipeline.

5. **Use conditions effectively**: Apply conditions to skip unnecessary steps based on branch name, previous results, etc.

6. **Use step templates for reusability**: Extract common sequences of steps into templates to avoid repetition.

7. **Leverage built-in expressions**: Use Azure Pipelines expressions like succeeded(), failed(), always() for conditional execution.

8. **Manage working directories**: Set the appropriate workingDirectory for each step rather than using cd commands.

9. **Be mindful of step order**: Arrange steps in a logical order of dependency to ensure proper execution flow.

10. **Publish artifacts**: Always publish important build artifacts to make them available to later stages and for troubleshooting.
