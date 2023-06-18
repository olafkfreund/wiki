# Jobs

Pipeline with jobs and one implicit stage.

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

#### Examples <a href="#examples-1" id="examples-1"></a>

```yaml
trigger:
- main

pool: 
  vmImage: ubuntu-latest

jobs:
- job: PreWork
  steps:
  - script: "Do pre-work"

- job: PostWork
  pool: windows-latest
  steps:
  - script: "Do post-work using a different hosted image"
```

\
