# GitHub Action



You can find a omprehensive list of actions here: [https://github.com/marketplace?type=actions\&query=Azure](https://github.com/marketplace?type=actions\&query=Azure)

GitHub Actions is a platform that allows developers to automate workflows and tasks directly from their GitHub repositories. It provides a wide range of pre-built actions and allows developers to create custom actions to automate their build, test, and deployment processes.

One of the many services that GitHub Actions can integrate with is Azure. With GitHub Actions and Azure, developers can automate workflows and deploy code directly from their GitHub repositories to their Azure environments.

Here's an example code for deploying an ASP.NET Core application to Azure using GitHub Actions:

```yaml
name: ASP.NET Core CI/CD with Azure

on:
  push:
    branches:
    - main

env:
  AZURE_WEBAPP_NAME: myapp
  AZURE_WEBAPP_PACKAGE_PATH: './bin/Release/netcoreapp3.1/publish'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Setup .NET Core
      uses: actions/setup-dotnet@v1
      with:
        dotnet-version: '3.1.x'

    - name: Build and publish
      env:
        DOTNET_CLI_TELEMETRY_OPTOUT: true
      run: dotnet build --configuration Release --output ./bin/Release/netcoreapp3.1/publish

    - name: Deploy to Azure Web App
      uses: Azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
```

This code creates a workflow that automatically builds and deploys an ASP.NET Core application to an Azure Web App whenever code is pushed to the main branch. The workflow runs on an Ubuntu virtual machine and uses the `actions/checkout@v2` action to check out the code from the repository.

Next, the workflow sets up the .NET Core runtime using the `actions/setup-dotnet@v1` action and builds the application using the `dotnet build` command. The resulting binaries are published to the `./bin/Release/netcoreapp3.1/publish` directory.

Finally, the workflow deploys the application to an Azure Web App using the `Azure/webapps-deploy@v2` action. The `app-name` and `package` parameters are set using environment variables that are defined at the beginning of the file.

Overall, this example demonstrates how GitHub Actions can be used to automate the deployment of an ASP.NET Core application to an Azure environment.

```yaml
name: Azure Infrastructure Deployment

on:
  push:
    branches:
    - main

env:
  AZURE_RG: 'my-resource-group'
  AZURE_LOCATION: 'westus2'
  AZURE_TEMPLATE_FILE: './template.json'
  AZURE_PARAMETER_FILE: './parameters.json'

jobs:
  deployment:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Validate ARM Template
      uses: azure/arm-validate-action@v1
      with:
        templateFile: ${{ env.AZURE_TEMPLATE_FILE }}
        parametersFile: ${{ env.AZURE_PARAMETER_FILE }}

    - name: Create Resource Group
      uses: azure/cli@v1
      with:
        inlineScript: az group create --name ${{ env.AZURE_RG }} --location ${{ env.AZURE_LOCATION }}

    - name: Deploy ARM Template
      uses: azure/arm-deploy@v1
      with:
        templateFile: ${{ env.AZURE_TEMPLATE_FILE }}
        parametersFile: ${{ env.AZURE_PARAMETER_FILE }}
        resourceGroupName: ${{ env.AZURE_RG }}
```

This code creates a GitHub Action that deploys infrastructure in Azure using an Azure Resource Manager (ARM) template. The workflow is triggered whenever code is pushed to the main branch.

First, the workflow logs in to Azure using the `azure/login@v1` action and authenticates using the `AZURE_CREDENTIALS` secret, which should contain the Azure service principal credentials.

Next, the workflow validates the ARM template using the `azure/arm-validate-action@v1` action, which checks that the template is valid and can be deployed.

After validating the template, the workflow creates a resource group in Azure using the `azure/cli@v1` action. The resource group name and location are specified using environment variables.

Finally, the workflow deploys the ARM template to the newly created resource group using the `azure/arm-deploy@v1` action. The path to the template and parameter files is specified using environment variables, and the resource group name is also specified.

This example shows how GitHub Actions can be used to automate the deployment of infrastructure in Azure using ARM templates.
