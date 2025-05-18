# Azure Load Testing

Azure Load Testing is a managed service for running large-scale load tests on your applications and APIs. It integrates seamlessly with GitHub Actions, Azure Pipelines, and supports secure secret management for sensitive data like API tokens.

## Passing Secrets in GitHub Actions

The following YAML snippet shows how to securely pass a secret (such as an API token) to the [Azure Load Testing GitHub Action](https://github.com/marketplace/actions/azure-load-testing):

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
```

## Passing Secrets in Azure Pipelines

The following YAML snippet shows how to pass a secret to the [Azure Pipelines Load Testing task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/test/azure-load-testing):

```yaml
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
```

---

## Real-Life Example: Secure API Load Test

Suppose you want to load test a production API that requires an authentication token. Store the token in Azure Key Vault or your CI/CD secrets store, and reference it as shown above. This ensures your secrets are never hardcoded or exposed in your repository.

**Best Practice:** Always use secret variables and never commit sensitive values to source control.

---

## Load Testing ASCII Art

```
        .-"""-.
       /       \
      |  (o) (o) |
      |    ^    |
      |  '-'  |
      +-------+
     /  LOAD   \
    /  TESTING  \
   +------------+
   |  PRESSURE! |
   +------------+
```

*"If your server starts making this face, it might be time to scale up!"*

---

For more details, see the [official Azure Load Testing documentation](https://learn.microsoft.com/en-us/azure/load-testing/).

