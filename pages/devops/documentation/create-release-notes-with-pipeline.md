# Automated Release Notes Generation

This guide demonstrates how to generate release notes automatically using different CI/CD platforms.

## Azure DevOps Pipeline

```yaml
trigger: none
pr: none

pool:
  vmImage: 'ubuntu-latest'

variables:
  artifactName: 'ReleaseNotes'
  templatePath: './azure-pipelines/templates/release-notes-template.md'

stages:
- stage: GenerateReleaseNotes
  displayName: Generate Release Notes
  jobs:
    - job: GenerateReleaseNotes
      steps:
      - task: XplatGenerateReleaseNotes@3
        displayName: Generate Release Notes
        inputs:
          outputfile: '$(Build.ArtifactStagingDirectory)/ReleaseNotes.md'
          templateLocation: 'File'
          templatefile: $(templatePath)
          dumpPayloadToConsole: false
          dumpPayloadToFile: true
          replaceFile: true
          getParentsAndChildren: true
          searchCrossProjectForPRs: true
          githubRepository: ''
          githubToken: ''
          overrideExistingReleaseNotes: true
          stopOnError: true

      - task: PublishPipelineArtifact@1
        displayName: Publish Release Notes
        inputs:
          targetPath: '$(Build.ArtifactStagingDirectory)/ReleaseNotes.md'
          artifact: $(artifactName)
          publishLocation: 'pipeline'

## GitHub Actions Workflow

```yaml
name: Generate Release Notes

on:
  release:
    types: [created]

jobs:
  generate-release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate Release Notes
        uses: github/generate-release-notes@v1
        with:
          previous-tag: ${{ github.event.release.target_commitish }}
        
      - name: Update Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: RELEASE_NOTES.md
          token: ${{ secrets.GITHUB_TOKEN }}

## GitLab CI Pipeline

```yaml
generate_release_notes:
  stage: release
  image: registry.gitlab.com/gitlab-org/release-cli:latest
  script:
    - |
      release-cli create \
        --name "Release $CI_COMMIT_TAG" \
        --description "$(./scripts/generate-release-notes.sh)" \
        --tag-name $CI_COMMIT_TAG \
        --ref $CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_TAG
```

## Modern Release Notes Template

```handlebars
# Release Notes for {{buildDetails.buildNumber}}

## 🚀 New Features
{{#forEach workItems}}
{{#equals this.fields.System.WorkItemType 'Feature'}}
- {{lookup this.fields 'System.Title'}}
{{/equals}}
{{/forEach}}

## 🐛 Bug Fixes
{{#forEach workItems}}
{{#equals this.fields.System.WorkItemType 'Bug'}}
- {{lookup this.fields 'System.Title'}}
{{/equals}}
{{/forEach}}

## 🔄 Pull Requests
{{#forEach pullRequests}}
- [#{{this.pullRequestId}}] {{this.title}} (@{{this.createdBy.displayName}})
{{/forEach}}

## 📝 Commits
{{#forEach commits}}
- {{this.message}} ({{this.author.displayName}})
{{/forEach}}

## 📋 Work Items
{{#forEach workItems}}
- [{{this.id}}] {{lookup this.fields 'System.Title'}}
  - Type: {{lookup this.fields 'System.WorkItemType'}}
  - Status: {{lookup this.fields 'System.State'}}
  - Assigned: {{#with (lookup this.fields 'System.AssignedTo')}}{{displayName}}{{/with}}
{{/forEach}}

---
Generated on {{buildDetails.startTime}}
Build ID: {{buildDetails.id}}
