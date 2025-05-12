---
description: GitOps for AKS
---

# Flux

This is taken from: [https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli)

```bash
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
```plaintext

Install the latest `k8s-configuration` and `k8s-extension` CLI extension packages:

```bash
az extension add -n k8s-configuration
az extension add -n k8s-extension
```plaintext



The following example applies a Flux configuration to a cluster, using the following values and settings:

* The resource group that contains the cluster is `flux-demo-rg`.
* The name of the Azure Arc cluster is `flux-demo-arc`.
* The cluster type is Azure Arc (`-t connectedClusters`), but this example also works with AKS (`-t managedClusters`) and AKS hybrid clusters provisioned from Azure (`-t provisionedClusters`).
* The name of the Flux configuration is `cluster-config`.
* The namespace for configuration installation is `cluster-config`.
* The URL for the public Git repository is `https://github.com/Azure/gitops-flux2-kustomize-helm-mt`.
* The Git repository branch is `main`.
* The scope of the configuration is `cluster`. This gives the operators permissions to make changes throughout cluster.&#x20;
* Two kustomizations are specified with names `infra` and `apps`. Each is associated with a path in the repository.
* The `apps` kustomization depends on the `infra` kustomization. (The `infra` kustomization must finish before the `apps` kustomization runs.)
* Set `prune=true` on both kustomizations. This setting ensures that the objects that Flux deployed to the cluster will be cleaned up if they're removed from the repository or if the Flux configuration or kustomizations are deleted.

```bash
az k8s-configuration flux create -g flux-demo-rg \
-c flux-demo-arc \
-n cluster-config \
--namespace cluster-config \
-t connectedClusters \
--scope cluster \
-u https://github.com/Azure/gitops-flux2-kustomize-helm-mt \
--branch main  \
--kustomization name=infra path=./infrastructure prune=true \
--kustomization name=apps path=./apps/staging prune=true dependsOn=\["infra"\]
```plaintext

The `microsoft.flux` extension will be installed on the cluster (if it hasn't already been installed due to a previous GitOps deployment).

When the flux configuration is first installed, the initial compliance state may be `Pending` or `Non-compliant` because reconciliation is still ongoing. After a minute or so, query the configuration again to see the final compliance state.

```bash
az k8s-configuration flux show -g flux-demo-rg -c flux-demo-arc -n cluster-config -t connectedClusters
```plaintext

To confirm that the deployment was successful, run the following command:

```bash
az k8s-configuration flux show -g flux-demo-rg -c flux-demo-arc -n cluster-config -t connectedClusters
```plaintext

With a successful deployment the following namespaces are created:

* `flux-system`: Holds the Flux extension controllers.
* `cluster-config`: Holds the Flux configuration objects.
* `nginx`, `podinfo`, `redis`: Namespaces for workloads described in manifests in the Git repository.

To confirm the namespaces, run the following command:

Azure CLICopy

```bash
kubectl get namespaces
```plaintext

The `flux-system` namespace contains the Flux extension objects:

* Azure Flux controllers: `fluxconfig-agent`, `fluxconfig-controller`
* OSS Flux controllers: `source-controller`, `kustomize-controller`, `helm-controller`, `notification-controller`

The Flux agent and controller pods should be in a running state. Confirm this using the following command:

```bash
kubectl get pods -n flux-system

NAME                                      READY   STATUS    RESTARTS   AGE
fluxconfig-agent-9554ffb65-jqm8g          2/2     Running   0          21m
fluxconfig-controller-9d99c54c8-nztg8     2/2     Running   0          21m
helm-controller-59cc74dbc5-77772          1/1     Running   0          21m
kustomize-controller-5fb7d7b9d5-cjdhx     1/1     Running   0          21m
notification-controller-7d45678bc-fvlvr   1/1     Running   0          21m
source-controller-df7dc97cd-4drh2         1/1     Running   0          21m
```plaintext

The namespace `cluster-config` has the Flux configuration objects.

```bash
kubectl get crds

NAME                                                   CREATED AT
alerts.notification.toolkit.fluxcd.io                  2022-04-06T17:15:48Z
arccertificates.clusterconfig.azure.com                2022-03-28T21:45:19Z
azureclusteridentityrequests.clusterconfig.azure.com   2022-03-28T21:45:19Z
azureextensionidentities.clusterconfig.azure.com       2022-03-28T21:45:19Z
buckets.source.toolkit.fluxcd.io                       2022-04-06T17:15:48Z
connectedclusters.arc.azure.com                        2022-03-28T21:45:19Z
customlocationsettings.clusterconfig.azure.com         2022-03-28T21:45:19Z
extensionconfigs.clusterconfig.azure.com               2022-03-28T21:45:19Z
fluxconfigs.clusterconfig.azure.com                    2022-04-06T17:15:48Z
gitconfigs.clusterconfig.azure.com                     2022-03-28T21:45:19Z
gitrepositories.source.toolkit.fluxcd.io               2022-04-06T17:15:48Z
helmcharts.source.toolkit.fluxcd.io                    2022-04-06T17:15:48Z
helmreleases.helm.toolkit.fluxcd.io                    2022-04-06T17:15:48Z
helmrepositories.source.toolkit.fluxcd.io              2022-04-06T17:15:48Z
imagepolicies.image.toolkit.fluxcd.io                  2022-04-06T17:15:48Z
imagerepositories.image.toolkit.fluxcd.io              2022-04-06T17:15:48Z
imageupdateautomations.image.toolkit.fluxcd.io         2022-04-06T17:15:48Z
kustomizations.kustomize.toolkit.fluxcd.io             2022-04-06T17:15:48Z
providers.notification.toolkit.fluxcd.io               2022-04-06T17:15:48Z
receivers.notification.toolkit.fluxcd.io               2022-04-06T17:15:48Z
volumesnapshotclasses.snapshot.storage.k8s.io          2022-03-28T21:06:12Z
volumesnapshotcontents.snapshot.storage.k8s.io         2022-03-28T21:06:12Z
volumesnapshots.snapshot.storage.k8s.io                2022-03-28T21:06:12Z
websites.extensions.example.com                        2022-03-30T23:42:32Z
```plaintext

Confirm other details of the configuration by using the following commands.

{% code overflow="wrap" lineNumbers="true" %}
```bash
kubectl get fluxconfigs -A

NAMESPACE        NAME             SCOPE     URL                                                       PROVISION   AGE
cluster-config   cluster-config   cluster   https://github.com/Azure/gitops-flux2-kustomize-helm-mt   Succeeded   44m
```plaintext
{% endcode %}

{% code overflow="wrap" lineNumbers="true" %}
```bash
kubectl get gitrepositories -A

NAMESPACE        NAME             URL                                                       READY   STATUS                                                            AGE
cluster-config   cluster-config   https://github.com/Azure/gitops-flux2-kustomize-helm-mt   True    Fetched revision: main/4f1bdad4d0a54b939a5e3d52c51464f67e474fcf   45m
```plaintext
{% endcode %}

```bash
kubectl get helmreleases -A

NAMESPACE        NAME      READY   STATUS                             AGE
cluster-config   nginx     True    Release reconciliation succeeded   66m
cluster-config   podinfo   True    Release reconciliation succeeded   66m
cluster-config   redis     True    Release reconciliation succeeded   66m
```plaintext

```bash
kubectl get kustomizations -A


NAMESPACE        NAME                   READY   STATUS                                                            AGE
cluster-config   cluster-config-apps    True    Applied revision: main/4f1bdad4d0a54b939a5e3d52c51464f67e474fcf   65m
cluster-config   cluster-config-infra   True    Applied revision: main/4f1bdad4d0a54b939a5e3d52c51464f67e474fcf   65m
```plaintext

Workloads are deployed from manifests in the Git repository.

```bash
kubectl get deploy -n nginx

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
nginx-ingress-controller                   1/1     1            1           67m
nginx-ingress-controller-default-backend   1/1     1            1           67m

kubectl get deploy -n podinfo

NAME      READY   UP-TO-DATE   AVAILABLE   AGE
podinfo   1/1     1            1           68m

kubectl get all -n redis

NAME                 READY   STATUS    RESTARTS   AGE
pod/redis-master-0   1/1     Running   0          68m

NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/redis-headless   ClusterIP   None          <none>        6379/TCP   68m
service/redis-master     ClusterIP   10.0.13.182   <none>        6379/TCP   68m

NAME                            READY   AGE
statefulset.apps/redis-master   1/1     68m
```plaintext

**Create an image pull secret**

To connect non-AKS and local clusters to your Azure Container Registry, create an image pull secret. Kubernetes uses image pull secrets to store information needed to authenticate your registry.

Create an image pull secret with the following `kubectl` command. Repeat for both the `dev` and `stage` namespaces.

```bash
kubectl create secret docker-registry <secret-name> \
    --namespace <namespace> \
    --docker-server=<container-registry-name>.azurecr.io \
    --docker-username=<service-principal-ID> \
    --docker-password=<service-principal-password>
```plaintext

To avoid having to set an imagePullSecret for every Pod, consider adding the imagePullSecret to the Service account in the `dev` and `stage` namespaces.&#x20;

Depending on the CI/CD orchestrator you prefer, you can proceed with instructions either for Azure DevOps or for GitHub.

#### Connect the GitOps repository <a href="#connect-the-gitops-repository" id="connect-the-gitops-repository"></a>

To continuously deploy your app, connect the application repository to your cluster using GitOps. Your **arc-cicd-demo-gitops** GitOps repository contains the basic resources to get your app up and running on your **arc-cicd-cluster** cluster.

The initial GitOps repository contains only a [manifest](https://github.com/Azure/arc-cicd-demo-gitops/blob/master/arc-cicd-cluster/manifests/namespaces.yml) that creates the **dev** and **stage** namespaces corresponding to the deployment environments.

The GitOps connection that you create will automatically:

* Sync the manifests in the manifest directory.
* Update the cluster state.

The CI/CD workflow populates the manifest directory with extra manifests to deploy the app.

1.  [Create a new GitOps connection](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2) to your newly imported **arc-cicd-demo-gitops** repository in Azure Repos.

    Azure CLICopy

    ```bash
    az k8s-configuration flux create \
       --name cluster-config \
       --cluster-name arc-cicd-cluster \
       --namespace flux-system \
       --resource-group myResourceGroup \
       -u https://dev.azure.com/<Your organization>/<Your project>/_git/arc-cicd-demo-gitops \
       --https-user <Azure Repos username> \
       --https-key <Azure Repos PAT token> \
       --scope cluster \
       --cluster-type connectedClusters \
       --branch master \
       --kustomization name=cluster-config prune=true path=arc-cicd-cluster/manifestsas
    ```plaintext

### Implement CI/CD with GitHub <a href="#implement-cicd-with-github" id="implement-cicd-with-github"></a>

#### Fork application and GitOps repositories <a href="#fork-application-and-gitops-repositories" id="fork-application-and-gitops-repositories"></a>

Fork an [application repository](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-ci-cd#application-repo) and a [GitOps repository](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-ci-cd#gitops-repo). For this tutorial, use the following example repositories:

* **arc-cicd-demo-src** application repository
  * URL: [https://github.com/Azure/arc-cicd-demo-src](https://github.com/Azure/arc-cicd-demo-src)
  * Contains the example Azure Vote App that you will deploy using GitOps.
* **arc-cicd-demo-gitops** GitOps repository
  * URL: [https://github.com/Azure/arc-cicd-demo-gitops](https://github.com/Azure/arc-cicd-demo-gitops)
  * Works as a base for your cluster resources that house the Azure Vote App.

#### Connect the GitOps repository <a href="#connect-the-gitops-repository-1" id="connect-the-gitops-repository-1"></a>

To continuously deploy your app, connect the application repository to your cluster using GitOps. Your **arc-cicd-demo-gitops** GitOps repository contains the basic resources to get your app up and running on your **arc-cicd-cluster** cluster.

The initial GitOps repository contains only a [manifest](https://github.com/Azure/arc-cicd-demo-gitops/blob/master/arc-cicd-cluster/manifests/namespaces.yml) that creates the **dev** and **stage** namespaces corresponding to the deployment environments.

The GitOps connection that you create will automatically:

* Sync the manifests in the manifest directory.
* Update the cluster state.

The CI/CD workflow populates the manifest directory with extra manifests to deploy the app.

1.  [Create a new GitOps connection](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2) to your newly forked **arc-cicd-demo-gitops** repository in GitHub.



    ```bash
    az k8s-configuration flux create \
       --name cluster-config \
       --cluster-name arc-cicd-cluster \
       --namespace cluster-config \
       --resource-group myResourceGroup \
       -u  https://github.com/<Your organization>/arc-cicd-demo-gitops.git \
       --https-user <Azure Repos username> \
       --https-key <Azure Repos PAT token> \
       --scope cluster \
       --cluster-type connectedClusters \
       --branch master \
       --kustomization name=cluster-config prune=true path=arc-cicd-cluster/manifests
    ```plaintext
2. Check the state of the deployment in Azure portal.
   * If successful, you'll see both `dev` and `stage` namespaces created in your cluster.
