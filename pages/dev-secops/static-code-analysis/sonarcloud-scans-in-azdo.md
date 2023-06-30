# SonarCloud Scans in AzDO

### Preparing the project in Azure DevOps

The first thing we will have to do in order to easily integrate the SonarCloud processes in Azure DevOps is to install the [SonarCloud task](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarcloud\&targetId=501105ea-146a-4ef7-8f0e-54de940c1f3c\&utm\_source=vstsproduct\&utm\_medium=ExtHubManageList) in the organization. In case we are using SonarQube, there is also a [specific task of SonarQube](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) that we can install in the organization and that is configured practically in the same way.

Once we have the SonarCloud task installed in our organization, we will go to the Azure DevOps project properties and create a SonarCloud type service connection:

![DevOps ServiceConnection](https://cdn.plainconcepts.com/wp-content/uploads/2020/08/serviceconnection-520x390.png)

This will show us a small form where we are going to enter the token we generated in SonarCloud, and we are going to give a name to the connection. After this, just press “Verify and save” to validate the connection and save it so that we can use it in the pipelines.

![DevOps SonarConnection](https://cdn.plainconcepts.com/wp-content/uploads/2020/08/sonarconnection.png)

With these two things ready, we will create our pipeline to perform an analysis with Sonar.

YAML code for scan:

```yaml
pool:
  vmImage: 'windows-latest'
  demands: java
  
steps:
- task: UseDotNet@2
  inputs:
    packageType: 'sdk'
    version: '3.1.301'
- task: DotNetCoreCLI@2
  displayName: Restore
  inputs:
    command: 'restore'
    projects: '**/*.sln'    

- task: SonarSource.sonarcloud.14d9cde6-c1da-4d55-aa01-2965cd301255.SonarCloudPrepare@1
  displayName: 'Prepare analysis on SonarCloud'
  inputs:
    SonarCloud: SonarCloud
    organization: 'project10'
    projectKey: 'sonar-plain'
    extraProperties: |
     sonar.exclusions=**/obj/**,**/*.dll
     sonar.cs.opencover.reportsPaths=$(Build.SourcesDirectory)/**/coverage.opencover.xml
     sonar.cs.vstest.reportsPaths=$(Agent.TempDirectory)/*.trx

- task: DotNetCoreCLI@2
  displayName: Build
  inputs:
    projects: '**/*.sln'
    arguments: '--configuration Release'

- task: DotNetCoreCLI@2
  displayName: Test
  inputs:
    command: test
    projects: '**/*.sln'
    arguments: '--configuration Release /p:CollectCoverage=true /p:CoverletOutputFormat=opencover --logger trx'

- task: SonarSource.sonarcloud.ce096e50-6155-4de8-8800-4221aaeed4a1.SonarCloudAnalyze@1
  displayName: 'Run Code Analysis'

- task: SonarSource.sonarcloud.38b27399-a642-40af-bb7d-9971f69712e8.SonarCloudPublish@1
  displayName: 'Publish Quality Gate Result'
```

The report:

Run the pipeline to have available a report in which we now collect the execution of the tests and their coverage.

![SonarCloud Overview2](https://cdn.plainconcepts.com/wp-content/uploads/2020/08/sonaroverview2.png)
