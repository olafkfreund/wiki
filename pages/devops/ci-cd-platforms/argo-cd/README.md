# Argo CD

### What Is Argo CD?[¶](https://argo-cd.readthedocs.io/en/stable/#what-is-argo-cd) <a href="#what-is-argo-cd" id="what-is-argo-cd"></a>

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

![Argo CD UI](https://argo-cd.readthedocs.io/en/stable/assets/argocd-ui.gif)

### Why Argo CD?[¶](https://argo-cd.readthedocs.io/en/stable/#why-argo-cd) <a href="#why-argo-cd" id="why-argo-cd"></a>

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

### Requirements[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#requirements) <a href="#requirements" id="requirements"></a>

* Installed [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) command-line tool.
* Have a [kubeconfig](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) file (default location is `~/.kube/config`).
* CoreDNS. Can be enabled for microk8s by `microk8s enable dns && microk8s stop && microk8s start`

### 1. Install Argo CD[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#1-install-argo-cd) <a href="#1-install-argo-cd" id="1-install-argo-cd"></a>

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```plaintext

This will create a new namespace, `argocd`, where Argo CD services and application resources will live.

Warning

The installation manifests include `ClusterRoleBinding` resources that reference `argocd` namespace. If you are installing Argo CD into a different namespace then make sure to update the namespace reference.

If you are not interested in UI, SSO, multi-cluster features then you can install [core](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#core) Argo CD components only:

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
```plaintext

This default installation will have a self-signed certificate and cannot be accessed without a bit of extra work. Do one of:

* Follow the [instructions to configure a certificate](https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/) (and ensure that the client OS trusts it).
* Configure the client OS to trust the self signed certificate.
* Use the --insecure flag on all Argo CD CLI operations in this guide.

Use `argocd login --core` to [configure](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd\_login/) CLI access and skip steps 3-5.

### 2. Download Argo CD CLI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#2-download-argo-cd-cli) <a href="#2-download-argo-cd-cli" id="2-download-argo-cd-cli"></a>

Download the latest Argo CD version from [https://github.com/argoproj/argo-cd/releases/latest](https://github.com/argoproj/argo-cd/releases/latest). More detailed installation instructions can be found via the [CLI installation documentation](https://argo-cd.readthedocs.io/en/stable/cli\_installation/).

Also available in Mac, Linux and WSL Homebrew:

```sh
brew install argocd
```plaintext

### 3. Access The Argo CD API Server[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#3-access-the-argo-cd-api-server) <a href="#3-access-the-argo-cd-api-server" id="3-access-the-argo-cd-api-server"></a>

By default, the Argo CD API server is not exposed with an external IP. To access the API server, choose one of the following techniques to expose the Argo CD API server:

#### Service Type Load Balancer[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#service-type-load-balancer) <a href="#service-type-load-balancer" id="service-type-load-balancer"></a>

Change the argocd-server service type to `LoadBalancer`:

```sh
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```plaintext

#### Ingress[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#ingress) <a href="#ingress" id="ingress"></a>

Follow the [ingress documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/) on how to configure Argo CD with ingress.

#### Port Forwarding[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#port-forwarding) <a href="#port-forwarding" id="port-forwarding"></a>

Kubectl port-forwarding can also be used to connect to the API server without exposing the service.

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```plaintext

The API server can then be accessed using https://localhost:8080

### 4. Login Using The CLI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#4-login-using-the-cli) <a href="#4-login-using-the-cli" id="4-login-using-the-cli"></a>

The initial password for the `admin` account is auto-generated and stored as clear text in the field `password` in a secret named `argocd-initial-admin-secret` in your Argo CD installation namespace. You can simply retrieve this password using the `argocd` CLI:

```shell
argocd admin initial-password -n argocd
```plaintext

Warning

You should delete the `argocd-initial-admin-secret` from the Argo CD namespace once you changed the password. The secret serves no other purpose than to store the initially generated password in clear and can safely be deleted at any time. It will be re-created on demand by Argo CD if a new admin password must be re-generated.

Using the username `admin` and the password from above, login to Argo CD's IP or hostname:

```shell
argocd login <ARGOCD_SERVER>
```plaintext

Note

The CLI environment must be able to communicate with the Argo CD API server. If it isn't directly accessible as described above in step 3, you can tell the CLI to access it using port forwarding through one of these mechanisms: 1) add `--port-forward-namespace argocd` flag to every CLI command; or 2) set `ARGOCD_OPTS` environment variable: `export ARGOCD_OPTS='--port-forward-namespace argocd'`.

Change the password using the command:

```sh
argocd account update-password
```plaintext

### 5. Register A Cluster To Deploy Apps To (Optional)[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#5-register-a-cluster-to-deploy-apps-to-optional) <a href="#5-register-a-cluster-to-deploy-apps-to-optional" id="5-register-a-cluster-to-deploy-apps-to-optional"></a>

This step registers a cluster's credentials to Argo CD, and is only necessary when deploying to an external cluster. When deploying internally (to the same cluster that Argo CD is running in), https://kubernetes.default.svc should be used as the application's K8s API server address.

First list all clusters contexts in your current kubeconfig:

```sh
kubectl config get-contexts -o name
```plaintext

Choose a context name from the list and supply it to `argocd cluster add CONTEXTNAME`. For example, for docker-desktop context, run:

```shell
argocd cluster add docker-desktop
```plaintext

The above command installs a ServiceAccount (`argocd-manager`), into the kube-system namespace of that kubectl context, and binds the service account to an admin-level ClusterRole. Argo CD uses this service account token to perform its management tasks (i.e. deploy/monitoring).

Note

The rules of the `argocd-manager-role` role can be modified such that it only has `create`, `update`, `patch`, `delete` privileges to a limited set of namespaces, groups, kinds. However `get`, `list`, `watch` privileges are required at the cluster-scope for Argo CD to function.

### 6. Create An Application From A Git Repository[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#6-create-an-application-from-a-git-repository) <a href="#6-create-an-application-from-a-git-repository" id="6-create-an-application-from-a-git-repository"></a>

An example repository containing a guestbook application is available at [https://github.com/argoproj/argocd-example-apps.git](https://github.com/argoproj/argocd-example-apps.git) to demonstrate how Argo CD works.

#### Creating Apps Via CLI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#creating-apps-via-cli) <a href="#creating-apps-via-cli" id="creating-apps-via-cli"></a>

First we need to set the current namespace to argocd running the following command:

```sh
kubectl config set-context --current --namespace=argocd
```plaintext

Create the example guestbook application with the following command:

```shell
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```plaintext

#### Creating Apps Via UI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#creating-apps-via-ui) <a href="#creating-apps-via-ui" id="creating-apps-via-ui"></a>

Open a browser to the Argo CD external UI, and login by visiting the IP/hostname in a browser and use the credentials set in step 4.

After logging in, click the **+ New App** button as shown below:

![+ new app button](https://argo-cd.readthedocs.io/en/stable/assets/new-app.png)

Give your app the name `guestbook`, use the project `default`, and leave the sync policy as `Manual`:

![app information](https://argo-cd.readthedocs.io/en/stable/assets/app-ui-information.png)

Connect the [https://github.com/argoproj/argocd-example-apps.git](https://github.com/argoproj/argocd-example-apps.git) repo to Argo CD by setting repository url to the github repo url, leave revision as `HEAD`, and set the path to `guestbook`:

![connect repo](https://argo-cd.readthedocs.io/en/stable/assets/connect-repo.png)

For **Destination**, set cluster URL to `https://kubernetes.default.svc` (or `in-cluster` for cluster name) and namespace to `default`:

![destination](https://argo-cd.readthedocs.io/en/stable/assets/destination.png)

After filling out the information above, click **Create** at the top of the UI to create the `guestbook` application:

![destination](https://argo-cd.readthedocs.io/en/stable/assets/create-app.png)

### 7. Sync (Deploy) The Application[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#7-sync-deploy-the-application) <a href="#7-sync-deploy-the-application" id="7-sync-deploy-the-application"></a>

#### Syncing via CLI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#syncing-via-cli) <a href="#syncing-via-cli" id="syncing-via-cli"></a>

Once the guestbook application is created, you can now view its status:

```sh
$ argocd app get guestbook
Name:               guestbook
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://10.97.164.88/applications/guestbook
Repo:               https://github.com/argoproj/argocd-example-apps.git
Target:
Path:               guestbook
Sync Policy:        <none>
Sync Status:        OutOfSync from  (1ff8a67)
Health Status:      Missing

GROUP  KIND        NAMESPACE  NAME          STATUS     HEALTH
apps   Deployment  default    guestbook-ui  OutOfSync  Missing
       Service     default    guestbook-ui  OutOfSync  Missing
```plaintext

The application status is initially in `OutOfSync` state since the application has yet to be deployed, and no Kubernetes resources have been created. To sync (deploy) the application, run:

```sh
argocd app sync guestbook
```plaintext

This command retrieves the manifests from the repository and performs a `kubectl apply` of the manifests. The guestbook app is now running and you can now view its resource components, logs, events, and assessed health status.

#### Syncing via UI[¶](https://argo-cd.readthedocs.io/en/stable/getting\_started/#syncing-via-ui) <a href="#syncing-via-ui" id="syncing-via-ui"></a>

![guestbook app](https://argo-cd.readthedocs.io/en/stable/assets/guestbook-app.png) ![view app](https://argo-cd.readthedocs.io/en/stable/assets/guestbook-tree.png)

