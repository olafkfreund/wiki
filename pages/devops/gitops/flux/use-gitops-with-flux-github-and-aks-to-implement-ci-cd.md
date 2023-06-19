# Use GitOps with Flux, GitHub, and AKS to implement CI/CD

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/example-scenario/gitops-aks/media/gitops-ci-cd-flux.png" alt=""><figcaption><p><em>Download a</em> <a href="https://archcenter.blob.core.windows.net/cdn/gitops-blueprint-aks-content.md.vsdx"><em>Visio file</em></a> <em>of this architecture.</em></p></figcaption></figure>

**Dataflow for scenario**

This scenario is a pull-based DevOps pipeline for a typical web application. The pipeline uses GitHub Actions for build. For deployment, it uses Flux as the GitOps operator to pull and sync the app. The data flows through the scenario as follows:

1. The app code is developed by using an IDE such as Visual Studio Code.
2. The app code is committed to a GitHub repository.
3. GitHub Actions builds a container image from the app code and pushes the container image to Azure Container Registry.
4. GitHub Actions updates a Kubernetes manifest deployment file with the current image version that's based on the version number of the container image in Azure Container Registry.
5. The Flux operator detects configuration drift in the Git repository and pulls the configuration changes.
6. Flux uses manifest files to deploy the app to the AKS cluster.
