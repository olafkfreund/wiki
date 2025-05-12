# Azure Load Testing

The following YAML snippet shows how to pass the secret to the [Load Testing GitHub action](https://github.com/marketplace/actions/azure-load-testing):

```yaml
- name: 'Azure Load Testing'
  uses: azure/load-testing@v1
  with:
    loadtestConfigFile: 'SampleApp.yaml'
    loadtestResource: 'MyTest'
    resourceGroup: 'loadtests-rg'
    secrets: |
    [
        {
        "name": "appToken",
        "value": "${{ secrets.MY_SECRET }}"
        }
    ]
```plaintext

The following YAML snippet shows how to pass the secret to the [Azure Pipelines task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/test/azure-load-testing):

```yml
- task: AzureLoadTest@1
  inputs:
    azureSubscription: 'MyAzureLoadTestingRG'
    loadTestConfigFile: 'SampleApp.yaml'
    loadTestResource: 'MyTest'
    resourceGroup: 'loadtests-rg'
    secrets: |
      [
          {
          "name": "appToken",
          "value": "$(mySecret)"
          }
      ]
```plaintext

