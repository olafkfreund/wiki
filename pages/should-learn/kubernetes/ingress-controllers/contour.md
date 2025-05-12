# Contour

### Install Contour and Envoy <a href="#install-contour-and-envoy" id="install-contour-and-envoy"></a>

#### Option 1: YAML <a href="#option-1-yaml" id="option-1-yaml"></a>

Run the following to install Contour:

```bash
$ kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```plaintext

Verify the Contour pods are ready by running the following:

```bash
$ kubectl get pods -n projectcontour -o wide
```plaintext

You should see the following:

* 2 Contour pods each with status **Running** and 1/1 **Ready**
* 1+ Envoy pod(s), each with the status **Running** and 2/2 **Ready**

#### Option 2: Helm <a href="#option-2-helm" id="option-2-helm"></a>

This option requires [Helm to be installed locally](https://helm.sh/docs/intro/install/).

Add the bitnami chart repository (which contains the Contour chart) by running the following:

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```plaintext

Install the Contour chart by running the following:

```bash
$ helm install my-release bitnami/contour --namespace projectcontour --create-namespace
```plaintext

Verify Contour is ready by running:

```bash
$ kubectl -n projectcontour get po,svc
```plaintext

You should see the following:

* 1 instance of pod/my-release-contour-contour with status **Running** and 1/1 **Ready**
* 1+ instance(s) of pod/my-release-contour-envoy with each status **Running** and 2/2 **Ready**
* 1 instance of service/my-release-contour
* 1 instance of service/my-release-contour-envoy

#### Option 3: Contour Gateway Provisioner (beta) <a href="#option-3-contour-gateway-provisioner-beta" id="option-3-contour-gateway-provisioner-beta"></a>

The Gateway provisioner watches for the creation of [Gateway API](https://gateway-api.sigs.k8s.io/) `Gateway` resources, and dynamically provisions Contour+Envoy instances based on the `Gateway's` spec. Note that although the provisioning request itself is made via a Gateway API resource (`Gateway`), this method of installation still allows you to use _any_ of the supported APIs for defining virtual hosts and routes: `Ingress`, `HTTPProxy`, or Gateway API’s `HTTPRoute` and `TLSRoute`. In fact, this guide will use an `Ingress` resource to define routing rules, even when using the Gateway provisioner for installation.

Deploy the Gateway provisioner:

```bash
$ kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
```plaintext

Verify the Gateway provisioner deployment is available:

```bash
$ kubectl -n projectcontour get deployments
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
contour-gateway-provisioner   1/1     1            1           1m
```plaintext

Create a GatewayClass:

```shell
kubectl apply -f - <<EOF
kind: GatewayClass
apiVersion: gateway.networking.k8s.io/v1beta1
metadata:
  name: contour
spec:
  controllerName: projectcontour.io/gateway-controller
EOF
```plaintext

Create a Gateway:

```shell
kubectl apply -f - <<EOF
kind: Gateway
apiVersion: gateway.networking.k8s.io/v1beta1
metadata:
  name: contour
  namespace: projectcontour
spec:
  gatewayClassName: contour
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
EOF
```plaintext

Verify the `Gateway` is available (it may take up to a minute to become available):

```bash
$ kubectl -n projectcontour get gateways
NAME        CLASS     ADDRESS         READY   AGE
contour     contour                   True    27s
```plaintext

Verify the Contour pods are ready by running the following:

```bash
$ kubectl -n projectcontour get pods
```plaintext

You should see the following:

* 2 Contour pods each with status **Running** and 1/1 **Ready**
* 1+ Envoy pod(s), each with the status **Running** and 2/2 **Ready**

### Test it out! <a href="#test-it-out" id="test-it-out"></a>

Congratulations, you have installed Contour and Envoy! Let’s install a web application workload and get some traffic flowing to the backend.

To install [httpbin](https://httpbin.org/), run the following:

```bash
kubectl apply -f https://projectcontour.io/examples/httpbin.yaml
```plaintext

Verify the pods and service are ready by running:

```bash
kubectl get po,svc,ing -l app=httpbin
```plaintext

You should see the following:

* 3 instances of pods/httpbin, each with status **Running** and 1/1 **Ready**
* 1 service/httpbin CLUSTER-IP listed on port 80
* 1 Ingress on port 80

**NOTE**: the Helm install configures Contour to filter Ingress and HTTPProxy objects based on the `contour` IngressClass name. If using Helm, ensure the Ingress has an ingress class of `contour` with the following:

```bash
kubectl patch ingress httpbin -p '{"spec":{"ingressClassName": "contour"}}'
```plaintext

Now we’re ready to send some traffic to our sample application, via Contour & Envoy.

_Note, for simplicity and compatibility across all platforms we’ll use `kubectl port-forward` to get traffic to Envoy, but in a production environment you would typically use the Envoy service’s address._

Port-forward from your local machine to the Envoy service:

```shell
# If using YAML
$ kubectl -n projectcontour port-forward service/envoy 8888:80

# If using Helm
$ kubectl -n projectcontour port-forward service/my-release-contour-envoy 8888:80

# If using the Gateway provisioner
$ kubectl -n projectcontour port-forward service/envoy-contour 8888:80
```plaintext

In a browser or via `curl`, make a request to [http://local.projectcontour.io:8888](http://local.projectcontour.io:8888/) (note, `local.projectcontour.io` is a public DNS record resolving to 127.0.0.1 to make use of the forwarded port). You should see the `httpbin` home page.

Congratulations, you have installed Contour, deployed a backend application, created an `Ingress` to route traffic to the application, and successfully accessed the app with Contour!
