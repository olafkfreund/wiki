# Steps

ipeline with steps and one implicit job.

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

#### Examples <a href="#examples-2" id="examples-2"></a>

```yaml
trigger:
- main

pool: 
  vmImage: ubuntu-latest

steps:
- script: "Hello world!"
```

\
