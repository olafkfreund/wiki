# CI/CD for AKS apps with Azure Pipelines

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/guide/aks/media/aks-cicd-azure-pipelines-architecture.svg" alt=""><figcaption><p><em>Download a</em> <a href="https://arch-center.azureedge.net/azure-devops-ci-cd-aks-architecture.vsdx"><em>Visio file</em></a> <em>of this architecture.</em></p></figcaption></figure>

#### Dataflow <a href="#dataflow" id="dataflow"></a>

1. A pull request (PR) to Azure Repos Git triggers a PR pipeline. This pipeline runs fast quality checks such as linting, building, and unit testing the code. If any of the checks fail, the PR doesn't merge. The result of a successful run of this pipeline is a successful merge of the PR.
2. A merge to Azure Repos Git triggers a CI pipeline. This pipeline runs the same tasks as the PR pipeline with some important additions. The CI pipeline runs integration tests. These tests require secrets, so this pipeline gets those secrets from Azure Key Vault.
3. The result of a successful run of this pipeline is the creation and publishing of a container image in a non-production Azure Container Repository.
4. The completion of the CI pipeline [triggers the CD pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/pipeline-triggers).
5. The CD pipeline deploys a YAML template to the staging AKS environment. The template specifies the container image from the non-production environment. The pipeline then performs acceptance tests against the staging environment to validate the deployment. If the tests succeed, a manual validation task is run, requiring a person to validate the deployment and resume the pipeline. The manual validation step is optional. Some organizations will automatically deploy.
6. If the manual intervention is resumed, the CD pipeline promotes the image from the non-production Azure Container Registry to the production registry.
7. The CD pipeline deploys a YAML template to the production AKS environment. The template specifies the container image from the production environment.
8. Container Insights forwards performance metrics, inventory data, and health state information from container hosts and containers to Azure Monitor periodically.
9. Azure Monitor collects observability data such as logs and metrics so that an operator can analyze health, performance, and usage data. Application Insights collects all application-specific monitoring data, such as traces. Azure Log Analytics is used to store all that data.
