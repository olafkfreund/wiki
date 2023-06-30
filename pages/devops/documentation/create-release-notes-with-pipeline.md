# Create Release Notes with pipeline

Create release notes with azure pipeline.

```yaml
trigger: none
pr: none

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: GenerateReleaseNotes
  displayName: Generate Release Notes
  jobs:
    - job: GenerateReleaseNotes
      displayName: Generate Release Notes
      steps:
      # Generate Release Notes (Crossplatform)
      # Description - Generates a release notes file in a format of your choice from the build or release history
      - task: XplatGenerateReleaseNotes@2
        displayName: Release Notes Generator
        inputs: 
           # Required arguments
           outputfile: $(Build.ArtifactStagingDirectory)\ReleaseNotes.md
           templateLocation: File
           templatefile: ./azure-pipelines/templates/build-handlebars-template.md
           inlinetemplate: 
           delimiter: ':'
           fieldEquality: =
           anyFieldContent: '*'
           dumpPayloadToConsole: false
           dumpPayloadToFile: false
           replaceFile: True
           appendToFile: True
           getParentsAndChildren: False

      - task: PublishPipelineArtifact@1
        displayName: Publish Artifact
        inputs:
          targetPath: '$(Build.ArtifactStagingDirectory)\ReleaseNotes.md'
          artifact: 'ReleaseNotes'
          publishLocation: 'pipeline'
```

Included template for release notes.

```markup
# Notes for build 
**Build Number**: {{buildDetails.id}}
**Build Trigger PR Number**: {{lookup buildDetails.triggerInfo 'pr.number'}} 

# Associated Pull Requests ({{pullRequests.length}})
{{#forEach pullRequests}}
{{#if isFirst}}### Associated Pull Requests (only shown if  PR) {{/if}}
*  **{{this.pullRequestId}}** {{this.title}}
{{/forEach}}

# Global list of WI ({{workItems.length}})
{{#forEach workItems}}
{{#if isFirst}}## Associated Work Items (only shown if  WI) {{/if}}
*  **{{this.id}}**  {{lookup this.fields 'System.Title'}}
  - **WIT** {{lookup this.fields 'System.WorkItemType'}} 
  - **Tags** {{lookup this.fields 'System.Tags'}}
  - **Assigned** {{#with (lookup this.fields 'System.AssignedTo')}} {{displayName}} {{/with}}
{{/forEach}}

# Global list of CS ({{commits.length}})
{{#forEach commits}}
{{#if isFirst}}### Associated commits  (only shown if CS) {{/if}}
* ** ID{{this.id}}** 
  -  **Message:** {{this.message}}
  -  **Commited by:** {{this.author.displayName}} 
{{/forEach}
```
