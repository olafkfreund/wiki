# CI/CD for AKS apps with GitHub Actions and GitFlow

#### Option 1: Push-based CI/CD <a href="#option-1-push-based-cicd" id="option-1-push-based-cicd"></a>

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/guide/aks/media/ci-cd-gitops-github-actions-aks-push.png" alt=""><figcaption><p><em>Push-based architecture with GitHub Actions for CI and CD.</em></p></figcaption></figure>

**Dataflow**

This scenario covers a push-based DevOps pipeline for a two-tier web application, with a front-end web component and a back-end that uses Redis. This pipeline uses GitHub Actions for build and deployment. The data flows through the scenario as follows:

1. The app code is developed.
2. The app code is committed to a GitHub git repository.
3. GitHub Actions builds a container image from the app code and pushes the container image to Azure Container Registry.
4. A GitHub Actions job deploys, or pushes, the app to the Azure Kubernetes Service (AKS) cluster using kubectl deployment of the Kubernetes manifest files.

#### Option 2: Pull-based CI/CD (GitOps) <a href="#option-2-pull-based-cicd-gitops" id="option-2-pull-based-cicd-gitops"></a>

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/guide/aks/media/ci-cd-gitops-github-actions-aks-pull.png" alt=""><figcaption><p><em>Pull-based architecture with GitHub Actions for CI and Argo CD for CD.</em></p></figcaption></figure>

_Download a_ [_Visio file_](https://arch-center.azureedge.net/cicd-gitops-github-actions-aks-pull.vsdx) _of this architecture._

**Dataflow**

This scenario covers a pull-based DevOps pipeline for a two-tier web application, with a front-end web component and a back-end that uses Redis. This pipeline uses GitHub Actions for build. For deployment, it uses Argo CD as a GitOps operator to pull/sync the app. The data flows through the scenario as follows:

1. The app code is developed.
2. The app code is committed to a GitHub repository.
3. GitHub Actions builds a container image from the app code and pushes the container image to Azure Container Registry.
4. GitHub Actions updates a Kubernetes manifest deployment file with the current image version based on the version number of the container image in the Azure Container Registry.
5. Argo CD syncs with, or pulls from, the Git repository.
6. Argo CD deploys the app to the AKS cluster.
