# Extends in Azure DevOps Pipelines

The `extends` keyword allows you to create a pipeline that inherits from and extends a template. This approach is powerful for standardizing pipelines across your organization while still providing flexibility for individual projects.

## Schema Reference

```yaml
extends: # Required. Extends a template.
  template: string # The template referenced by the pipeline to extend.
  parameters: # Parameters used in the extend.
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

## Basic Example

Here's a basic example of a pipeline that extends a template:

```yaml
# azure-pipelines.yml
extends:
  template: templates/main-pipeline-template.yml
  parameters:
    projectName: 'MyProject'
    buildConfiguration: 'Release'

trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'
```

## Template Example

The template being extended (`templates/main-pipeline-template.yml`):

```yaml
# templates/main-pipeline-template.yml
parameters:
  - name: projectName
    type: string
    default: 'DefaultProject'
  - name: buildConfiguration
    type: string
    default: 'Debug'

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - script: echo "Building ${{ parameters.projectName }} in ${{ parameters.buildConfiguration }} mode"
      displayName: 'Build Project'

- stage: Test
  jobs:
  - job: TestJob
    steps:
    - script: echo "Testing ${{ parameters.projectName }}"
      displayName: 'Test Project'
```

## Advanced Examples

### Extending Templates with Multiple Stages

```yaml
# azure-pipelines.yml
extends:
  template: templates/enterprise-ci-cd-template.yml
  parameters:
    projectName: 'MyWebApp'
    environmentsToDeploy:
      - name: 'Development'
        serviceName: 'webapp-dev'
        serviceConnection: 'azure-dev'
      - name: 'Staging'
        serviceName: 'webapp-staging'
        serviceConnection: 'azure-staging'
        approvalRequired: true

trigger:
  branches:
    include:
      - main
      - release/*

variables:
  buildConfiguration: 'Release'
  dotNetVersion: '6.0.x'
```

### Template with Conditional Stages

```yaml
# templates/enterprise-ci-cd-template.yml
parameters:
  - name: projectName
    type: string
  - name: environmentsToDeploy
    type: object
    default: []
  - name: runSecurityScan
    type: boolean
    default: true

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - task: UseDotNet@2
      inputs:
        packageType: 'sdk'
        version: '$(dotNetVersion)'
    - script: dotnet build --configuration $(buildConfiguration)
      displayName: 'Build ${{ parameters.projectName }}'
    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

- ${{ if eq(parameters.runSecurityScan, true) }}:
  - stage: SecurityScan
    displayName: 'Security Scan'
    dependsOn: Build
    jobs:
    - job: RunSecurityScan
      steps:
      - script: echo "Running security scan on ${{ parameters.projectName }}"
        displayName: 'Security Scan'

# Dynamic stages for each environment
- ${{ each environment in parameters.environmentsToDeploy }}:
  - stage: Deploy_${{ environment.name }}
    displayName: 'Deploy to ${{ environment.name }}'
    dependsOn: ${{ if eq(parameters.runSecurityScan, true) }}:
      - SecurityScan
    ${{ else }}:
      - Build
    jobs:
    - deployment: Deploy
      environment: ${{ environment.name }}
      ${{ if eq(environment.approvalRequired, true) }}:
        strategy:
          runOnce:
            deploy:
              steps:
              - task: AzureWebApp@1
                displayName: 'Deploy to Azure Web App'
                inputs:
                  azureSubscription: '${{ environment.serviceConnection }}'
                  appName: '${{ environment.serviceName }}'
                  package: '$(System.ArtifactsDirectory)/**/*.zip'
      ${{ else }}:
        strategy:
          runOnce:
            deploy:
              steps:
              - task: AzureWebApp@1
                displayName: 'Deploy to Azure Web App'
                inputs:
                  azureSubscription: '${{ environment.serviceConnection }}'
                  appName: '${{ environment.serviceName }}'
                  package: '$(System.ArtifactsDirectory)/**/*.zip'
```

## Using Extends with Repository Templates

Templates can be stored in different repositories and reused across multiple projects:

```yaml
# azure-pipelines.yml
resources:
  repositories:
    - repository: templates
      type: git
      name: DevOpsTemplates/pipeline-templates
      ref: refs/tags/v1.0

extends:
  template: dotnet-web-app-ci-cd.yml@templates
  parameters:
    projectName: 'CustomerPortal'
    sonarQubeProject: 'customer-portal'
    artifactName: 'website'
```

## Best Practices for Template Extension

1. **Standardize Core Build Logic**: Keep core build, test, and deployment logic in templates to ensure consistency across projects.

2. **Use Parameters for Flexibility**: Design templates with parameters to accommodate different project requirements without modifying the template itself.

3. **Version Your Templates**: Use tags or specific branch references when extending templates from a shared repository to ensure stability.

4. **Template Composition**: Create specialized templates for different types of projects (e.g., web apps, APIs, libraries) that can extend more generic base templates.

5. **Document Template Parameters**: Clearly document the required and optional parameters for each template to facilitate adoption.

6. **Include Validation**: Add parameter validation in your templates to catch configuration errors early.

7. **Multi-stage Templates**: Design templates that cover the entire CI/CD process, from build to deployment across multiple environments.

8. **Environment Specific Logic**: Use conditionals to include environment-specific steps (e.g., additional security checks for production).

## Template Extension Use Cases

1. **Standardized CI/CD Pipelines**: Create organizational standards for different application types.

2. **Compliance Enforcement**: Ensure all projects follow security and compliance requirements by embedding them in templates.

3. **Accelerating New Projects**: Provide ready-to-use pipeline templates for new projects, reducing setup time.

4. **Multi-environment Deployment**: Create templates that handle the complexity of deploying to multiple environments with appropriate approvals.

5. **Cross-platform Applications**: Use templates with matrix strategies to build and test applications on multiple platforms.
