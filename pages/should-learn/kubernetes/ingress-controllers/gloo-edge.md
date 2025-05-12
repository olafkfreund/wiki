# Gloo Edge

1.  Add the Helm repository for Gloo Edge.

    ```shell
    helm repo add gloo https://storage.googleapis.com/solo-public-helm
    helm repo update
    ```plaintext
2.  Install the Helm chart. This command creates the `gloo-system` namespace and installs the Gloo Edge components into it.

    ```shell
    helm install gloo gloo/gloo --namespace gloo-system --create-namespace
    ```plaintext

### Example Application Setup  <a href="#example-application-setup" id="example-application-setup"></a>

On your Kubernetes installation, you will deploy the Pet Store Application and validate this it is operational.

Let’s deploy the Pet Store Application on Kubernetes using a YAML file hosted on GitHub. The deployment will stand up the Pet Store container and expose the Pet Store API through a Kubernetes service.

```shell
kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/v1.13.x/example/petstore/petstore.yaml
```plaintext

```console
deployment.extensions/petstore created
service/petstore created
```plaintext

#### Verify the Pet Store Application  <a href="#verify-the-pet-store-application" id="verify-the-pet-store-application"></a>

Now let’s verify the pod running the Pet Store application launched successfully the petstore service has been created:

```shell
kubectl -n default get pods
```plaintext

```console
NAME                READY  STATUS   RESTARTS  AGE
petstore-####-####  1/1    Running  0         30s
```plaintext

If the pod is not yet running, run the `kubectl -n default get pods -w` command and wait until it is. Then enter `Ctrl-C` to break out of the wait loop.

Let’s verify that the petstore service has been created as well.

```shell
kubectl -n default get svc petstore
```plaintext

Note that the service does not have an external IP address. It is only accessible within the Kubernetes cluster.

```console
NAME      TYPE       CLUSTER-IP   EXTERNAL-IP  PORT(S)   AGE
petstore  ClusterIP  10.XX.XX.XX  <none>       8080/TCP  1m
```plaintext

Let’s verify this by using the `glooctl` command line tool:

```shell
glooctl get upstreams
```plaintext

```console
+--------------------------------+------------+----------+------------------------------+
|            UPSTREAM            |    TYPE    |  STATUS  |           DETAILS            |
+--------------------------------+------------+----------+------------------------------+
| default-kubernetes-443         | Kubernetes | Pending  | svc name:      kubernetes    |
|                                |            |          | svc namespace: default       |
|                                |            |          | port:          8443          |
|                                |            |          |                              |
| default-petstore-8080          | Kubernetes | Accepted | svc name:      petstore      |
|                                |            |          | svc namespace: default       |
|                                |            |          | port:          8080          |
|                                |            |          |                              |
| gloo-system-gateway-proxy-8080 | Kubernetes | Accepted | svc name:      gateway-proxy |
|                                |            |          | svc namespace: gloo-system   |
|                                |            |          | port:          8080          |
|                                |            |          |                              |
| gloo-system-gloo-9977          | Kubernetes | Accepted | svc name:      gloo          |
|                                |            |          | svc namespace: gloo-system   |
|                                |            |          | port:          9977          |
|                                |            |          |                              |
+--------------------------------+------------+----------+------------------------------+
```plaintext

This command lists all the Upstreams Gloo Edge has discovered, each written to an _Upstream_ CR.

The Upstream we want to see is `default-petstore-8080`.

et’s take a closer look at the upstream that Gloo Edge’s Discovery service created:

```shell
glooctl get upstream default-petstore-8080 --output kube-yaml
```plaintext

```yaml
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  labels:
    app: petstore
    discovered_by: kubernetesplugin
  name: default-petstore-8080
  namespace: gloo-system
spec:
  discoveryMetadata: {}
  kube:
    selector:
      app: petstore
    serviceName: petstore
    serviceNamespace: default
    servicePort: 8080
status:
  statuses:
    gloo-system:
      reportedBy: gloo
      state: 1
```plaintext

By default the upstream created is rather simple. It represents a specific kubernetes service. However, the petstore application is a swagger service. Gloo Edge can discover this swagger spec, but by default Gloo Edge’s function discovery features are turned off to improve performance. To enable Function Discovery Service (fds) on our petstore, we need to label the namespace.

```shell
kubectl label namespace default  discovery.solo.io/function_discovery=enabled
```plaintext

Now Gloo Edge’s function discovery will discover the swagger spec. Fds populated our Upstream with the available rest endpoints it implements.

```shell
glooctl get upstream default-petstore-8080
```plaintext

```console
+-----------------------+------------+----------+-------------------------+
|       UPSTREAM        |    TYPE    |  STATUS  |         DETAILS         |
+-----------------------+------------+----------+-------------------------+
| default-petstore-8080 | Kubernetes | Accepted | svc name:      petstore |
|                       |            |          | svc namespace: default  |
|                       |            |          | port:          8080     |
|                       |            |          | REST service:           |
|                       |            |          | functions:              |
|                       |            |          | - addPet                |
|                       |            |          | - deletePet             |
|                       |            |          | - findPetById           |
|                       |            |          | - findPets              |
|                       |            |          |                         |
+-----------------------+------------+----------+-------------------------+
```plaintext

```shell
glooctl get upstream default-petstore-8080 --output kube-yaml
```plaintext

```yaml
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  labels:
    discovered_by: kubernetesplugin
    service: petstore
  name: default-petstore-8080
  namespace: gloo-system
spec:
  discoveryMetadata: {}
  kube:
    selector:
      app: petstore
    serviceName: petstore
    serviceNamespace: default
    servicePort: 8080
    serviceSpec:
      rest:
        swaggerInfo:
          url: http://petstore.default.svc.cluster.local:8080/swagger.json
        transformations:
          addPet:
            body:
              text: '{"id": {{ default(id, "") }},"name": "{{ default(name, "")}}","tag":
                "{{ default(tag, "")}}"}'
            headers:
              :method:
                text: POST
              :path:
                text: /api/pets
              content-type:
                text: application/json
          deletePet:
            headers:
              :method:
                text: DELETE
              :path:
                text: /api/pets/{{ default(id, "") }}
              content-type:
                text: application/json
          findPetById:
            body: {}
            headers:
              :method:
                text: GET
              :path:
                text: /api/pets/{{ default(id, "") }}
              content-length:
                text: "0"
              content-type: {}
              transfer-encoding: {}
          findPets:
            body: {}
            headers:
              :method:
                text: GET
              :path:
                text: /api/pets?tags={{default(tags, "")}}&limit={{default(limit,
                  "")}}
              content-length:
                text: "0"
              content-type: {}
              transfer-encoding: {}
status:
  statuses:
    gloo-system:
      reportedBy: gloo
      state: 1
```plaintext

The application endpoints were discovered by Gloo Edge’s Function Discovery (fds) service. This was possible because the petstore application implements OpenAPI (specifically, discovering a Swagger JSON document at `petstore/swagger.json`).

#### Add a Routing Rule  <a href="#add-a-routing-rule" id="add-a-routing-rule"></a>

Even though the Upstream has been created, Gloo Edge will not route traffic to it until we add some routing rules on a Virtual Service. Let’s now use glooctl to create a basic route for this Upstream with the `--prefix-rewrite` flag to rewrite the path on incoming requests to match the path our petstore application expects.

```shell
glooctl add route \
  --path-exact /all-pets \
  --dest-name default-petstore-8080 \
  --prefix-rewrite /api/pets
```plaintext

If using Git Bash on Windows, the above will not work; Git Bash interprets the route parameters as Unix file paths and mangles them. Adding `MSYS_NO_PATHCONV=1` to the start of the above command should allow it to execute correctly.

We do not specify a specific Virtual Service, so the route is added to the `default` Virtual Service. If a `default` Virtual Service does not exist, `glooctl` will create one.

```console
+-----------------+--------------+---------+------+---------+-----------------+---------------------------+
| VIRTUAL SERVICE | DISPLAY NAME | DOMAINS | SSL  | STATUS  | LISTENERPLUGINS |          ROUTES           |
+-----------------+--------------+---------+------+---------+-----------------+---------------------------+
| default         |              | *       | none | Pending |                 | /all-pets -> gloo-system. |
|                 |              |         |      |         |                 | .default-petstore-8080    |
+-----------------+--------------+---------+------+---------+-----------------+---------------------------+
```plaintext

The initial **STATUS** of the petstore Virtual Service will be **Pending**. After a few seconds it should change to **Accepted**. Let’s verify that by retrieving the `default` Virtual Service with `glooctl`.

```shell
glooctl get virtualservice default
```plaintext

```console
+-----------------+--------------+---------+------+----------+-----------------+---------------------------+
| VIRTUAL SERVICE | DISPLAY NAME | DOMAINS | SSL  | STATUS   | LISTENERPLUGINS |          ROUTES           |
+-----------------+--------------+---------+------+----------+-----------------+---------------------------+
| default         |              | *       | none | Accepted |                 | /all-pets -> gloo-system. |
|                 |              |         |      |          |                 | .default-petstore-8080    |
+-----------------+--------------+---------+------+----------+-----------------+---------------------------+
```plaintext

#### Verify Virtual Service Creation  <a href="#verify-virtual-service-creation" id="verify-virtual-service-creation"></a>

Let’s verify that a Virtual Service was created with that route.

Routes are associated with Virtual Services in Gloo Edge. When we created the route in the previous step, we didn’t provide a Virtual Service, so Gloo Edge created a Virtual Service called `default` and added the route.

With `glooctl`, we can see that the `default` Virtual Service was created with our route:

```shell
glooctl get virtualservice default --output kube-yaml
```plaintext

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
  ownerReferences: []
status:
  statuses:
    gloo-system:
      reportedBy: gloo
      state: Accepted
      subresourceStatuses:
        '*v1.Proxy.gateway-proxy_gloo-system':
          reportedBy: gloo
          state: Accepted
spec:
  virtualHost:
    domains:
    - '*'
    routes:
    - matchers:
      - exact: /all-pets
      options:
        prefixRewrite: /api/pets
      routeAction:
        single:
          upstream:
            name: default-petstore-8080
            namespace: gloo-system
```plaintext

When a Virtual Service is created, Gloo Edge immediately updates the proxy configuration. Since the status of this Virtual Service is `Accepted`, we know this route is now active.

At this point we have a Virtual Service with a routing rule sending traffic on the path `/all-pets` to the Upstream `petstore` at a path of `/api/pets`.

#### Test the Route Rule  <a href="#test-the-route-rule" id="test-the-route-rule"></a>

Let’s test the route rule by retrieving the URL of Gloo Edge, and sending a web request to the `/all-pets` path of the URL using curl:

```shell
curl $(glooctl proxy url)/all-pets
```plaintext

```json
[{"id":1,"name":"Dog","status":"available"},{"id":2,"name":"Cat","status":"pending"}]
```plaintext

The proxy has now been configured to route requests to the `/api/pets` REST endpoint on the Pet Store application in Kubernetes.
