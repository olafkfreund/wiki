# Create work item on failure

```yaml
# When manually running the pipeline, you can select whether it
# succeeds or fails.
parameters:
- name: succeed
  displayName: Succeed or fail
  type: boolean
  default: false

trigger:
- main

pool:
  vmImage: ubuntu-latest

jobs:
- job: Work
  steps:
  - script: echo Hello, world!
    displayName: 'Run a one-line script'

  # This malformed command causes the job to fail
  # Only run this command if the succeed variable is set to false
  - script: git clone malformed input
    condition: eq(${{ parameters.succeed }}, false)

# This job creates a work item, and only runs if the previous job failed
- job: ErrorHandler
  dependsOn: Work
  condition: failed()
  steps: 
  - bash: |
      az boards work-item create \
        --title "Build $(build.buildNumber) failed" \
        --type bug \
        --org $(System.TeamFoundationCollectionUri) \
        --project $(System.TeamProject)
    env: 
      AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
    displayName: 'Create work item on failure'
```plaintext
