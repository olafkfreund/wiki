# Istio

Istio is an open-source service mesh that overlays current distributed applications in a transparent manner. Istio functions as a connective tissue between your services, providing features such as traffic control, service discovery, load balancing, resilience, observability, and security. In this blog, I’ll guide you to install Istio on the Kubernetes cluster step by step.\
Prior to setting up Istio, I hope you have set up a Kubernetes cluster in minikube or any cloud platform. If you haven’t set up a K8s cluster yet, I recommend you read one of my previous [blog posts](https://medium.com/@sumudu\_liyan/how-to-set-up-a-simple-kubernetes-cluster-on-google-cloud-platform-f7839323579f) which will guide you to set up a Kubernetes cluster on Google Cloud Provider. If you are using minikube or any other cloud platform, refer to some materials and set up a K8s cluster.\
Here, we are installing istio with istioctl.

## **1. Download Istio** <a href="#189c" id="189c"></a>

**1.1. Download the Istio installation file.**\
_curl -L_ [_https://istio.io/downloadIstio_](https://istio.io/downloadIstio) _| sh -_

**1.2. Move to the Istio package directory. Let’s say the downloaded Istio version is istio-1.13.0.**\
**(If you are unable to find the Istio version, use **_**ls**_** command in the terminal and then you will see the istio directory.)**\
_cd istio-1.13.0_

**1.3. Add the istioctl client to your path.**\
_`export PATH=$PWD/bin:$PATH`_

## **2. Install Istio** <a href="#cb2a" id="cb2a"></a>

**2.1. In this installation, we use the demo configuration profile.**\
_`istioctl install --set profile=demo -y`_

If your installation is successful, you will get the below result.

<figure><img src="https://miro.medium.com/v2/resize:fit:681/0*m8w4hKXLiJIaQInO" alt="" height="253" width="681"><figcaption></figcaption></figure>

**2.2. Add a namespace label to tell Istio to inject Envoy sidecar proxies automatically when you deploy your app later:**\
_`kubectl label namespace default \istio-injection=enabled`_

> Note: Here, we are enabling envoy sidecar proxies injection for default namespace. If your application is going to be deployed in a different namespace, you will have to enable istio-injection for that particular namespace. For an example, let’s think my application is going to be deployed under the namespace, mesh-test. Then, you will have to change the above command like below.\
> **`kubectl label namespace mesh-test \istio-injection=enabled`**

Now, you have successfully set up Istio on K8s cluster!



## Install with Helm <a href="#title" id="title"></a>

Follow this guide to install and configure an Istio mesh using [Helm](https://helm.sh/docs/).

The Helm charts used in this guide are the same underlying charts used when installing Istio via [Istioctl](https://istio.io/latest/docs/setup/install/istioctl/) or the [Operator](https://istio.io/latest/docs/setup/install/operator/).

### Prerequisites <a href="#prerequisites" id="prerequisites"></a>

1. Perform any necessary [platform-specific setup](https://istio.io/latest/docs/setup/platform-setup/).
2. Check the [Requirements for Pods and Services](https://istio.io/latest/docs/ops/deployment/requirements/).
3. [Install the Helm client](https://helm.sh/docs/intro/install/), version 3.6 or above.
4. Configure the Helm repository:

```sh
$ helm repo add istio https://istio-release.storage.googleapis.com/charts
$ helm repo update
```plaintext

### Installation steps <a href="#installation-steps" id="installation-steps"></a>

This section describes the procedure to install Istio using Helm. The general syntax for helm installation is:

```sh
$ helm install <release> <chart> --namespace <namespace> --create-namespace [--set <other_parameters>]
```plaintext

The variables specified in the command are as follows:

* `<chart>` A path to a packaged chart, a path to an unpacked chart directory or a URL.
* `<release>` A name to identify and manage the Helm chart once installed.
* `<namespace>` The namespace in which the chart is to be installed.

Default configuration values can be changed using one or more `--set <parameter>=<value>` arguments. Alternatively, you can specify several parameters in a custom values file using the `--values <file>` argument.

You can display the default values of configuration parameters using the `helm show values <chart>` command or refer to `artifacthub` chart documentation at [Custom Resource Definition parameters](https://artifacthub.io/packages/helm/istio-official/base?modal=values), [Istiod chart configuration parameters](https://artifacthub.io/packages/helm/istio-official/istiod?modal=values) and [Gateway chart configuration parameters](https://artifacthub.io/packages/helm/istio-official/gateway?modal=values).

1.  Create the namespace, `istio-system`, for the Istio components:

    This step can be skipped if using the `--create-namespace` argument in step 2.

    ```shell
    $ kubectl create namespace istio-system
    ```plaintext
2.  Install the Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane:

    When performing a revisioned installation, the base chart requires the `--set defaultRevision=<revision>` value to be set for resource validation to function. Below we install the `default` revision, so `--set defaultRevision=default` is configured.

    ```sh
    $ helm install istio-base istio/base -n istio-system --set defaultRevision=default
    ```plaintext
3.  Validate the CRD installation with the `helm ls` command:

    ```sh
    $ helm ls -n istio-system
    NAME       NAMESPACE    REVISION UPDATED         STATUS   CHART        APP VERSION
    istio-base istio-system 1        ... ... ... ... deployed base-1.16.1  1.16.1
    ```plaintext

    In the output locate the entry for `istio-base` and make sure the status is set to `deployed`.
4.  Install the Istio discovery chart which deploys the `istiod` service:

    ```sh
    $ helm install istiod istio/istiod -n istio-system --wait
    ```plaintext
5.  Verify the Istio discovery chart installation:

    ```shell
    $ helm ls -n istio-system
    NAME       NAMESPACE    REVISION UPDATED         STATUS   CHART         APP VERSION
    istio-base istio-system 1        ... ... ... ... deployed base-1.16.1   1.16.1
    istiod     istio-system 1        ... ... ... ... deployed istiod-1.16.1 1.16.1
    ```plaintext
6.  Get the status of the installed helm chart to ensure it is deployed:

    ```sh
    $ helm status istiod -n istio-system
    NAME: istiod
    LAST DEPLOYED: Fri Jan 20 22:00:44 2023
    NAMESPACE: istio-system
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    "istiod" successfully installed!

    To learn more about the release, try:
      $ helm status istiod
      $ helm get all istiod

    Next steps:
      * Deploy a Gateway: https://istio.io/latest/docs/setup/additional-setup/gateway/
      * Try out our tasks to get started on common configurations:
        * https://istio.io/latest/docs/tasks/traffic-management
        * https://istio.io/latest/docs/tasks/security/
        * https://istio.io/latest/docs/tasks/policy-enforcement/
        * https://istio.io/latest/docs/tasks/policy-enforcement/
      * Review the list of actively supported releases, CVE publications and our hardening guide:
        * https://istio.io/latest/docs/releases/supported-releases/
        * https://istio.io/latest/news/security/
        * https://istio.io/latest/docs/ops/best-practices/security/

    For further documentation see https://istio.io website

    Tell us how your install/upgrade experience went at https://forms.gle/99uiMML96AmsXY5d6
    ```plaintext
7.  Check `istiod` service is successfully installed and its pods are running:

    ```shell
    $ kubectl get deployments -n istio-system --output wide
    NAME     READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                         SELECTOR
    istiod   1/1     1            1           10m   discovery    docker.io/istio/pilot:1.16.1   istio=pilot
    ```plaintext
8.  (Optional) Install an ingress gateway:

    ```plaintext
    $ kubectl create namespace istio-ingress
    $ helm install istio-ingress istio/gateway -n istio-ingress --wait
    ```plaintext

    See [Installing Gateways](https://istio.io/latest/docs/setup/additional-setup/gateway/) for in-depth documentation on gateway installation.

    The namespace the gateway is deployed in must not have a `istio-injection=disabled` label. See [Controlling the injection policy](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#controlling-the-injection-policy) for more info.

See [Advanced Helm Chart Customization](https://istio.io/latest/docs/setup/additional-setup/customize-installation-helm/) for in-depth documentation on how to use Helm post-renderer to customize the Helm charts.

### Updating your Istio configuration <a href="#updating-your-istio-configuration" id="updating-your-istio-configuration"></a>

You can provide override settings specific to any Istio Helm chart used above and follow the Helm upgrade workflow to customize your Istio mesh installation. The available configurable options can be found by using `helm show values istio/<chart>`; for example `helm show values istio/gateway`.
