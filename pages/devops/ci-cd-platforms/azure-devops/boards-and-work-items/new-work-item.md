# New work item

```yaml
- task: PowerShell@2
  displayName: 'Create workitem task'
  env:
    AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
  inputs:
    targetType: 'inline'
    script: |
      $nameLine= az boards iteration team list --team "DevOpsTesting Team" --timeframe current --project $(System.TeamProject) | findstr "name" 
      $nameOnly= (select-string ":(.*)" -inputobject $nameLine).Matches.Groups[1].Value.Replace(",","").Replace("`"","").Trim()
      $workitem =  az boards work-item create --title "New PR request for version from $(Build.RequestedFor)" --type Task --project $(System.TeamProject) --iteration "$(System.TeamProject)\\$nameOnly" --assigned-to <some_user_email> --fields "Description=$(Build.RequestedFor) want to merge into Main, a PR is open, please test the new exe version and approve. link to download: $(System.CollectionUri)$(System.TeamProject)/_apis/build/builds/$(build.buildid)/artifacts?artifactName=<some_name>&%24format=zip"
      $workitemid =  $workitem.id

      az repos pr work-item add --work-items  $workitemid  --id $(System.PullRequest.PullRequestId)
  timeoutInMinutes: 5
```plaintext
