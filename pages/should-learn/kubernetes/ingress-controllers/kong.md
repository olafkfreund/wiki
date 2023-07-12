# Kong

### Features

* **Ingress routing** Use [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resources to configure Kong.
* **Enhanced API management using plugins** Use a wide array of [plugins](https://docs.konghq.com/hub/) to monitor, transform and protect your traffic.
* **Native gRPC support** Proxy gRPC traffic and gain visibility into it using Kong's plugins.
* **Health checking and Load-balancing** Load balance requests across your pods and supports active & passive health-checks.
* **Request/response transformations** Use plugins to modify your requests/responses on the fly.
* **Authentication** Protect your services using authentication methods of your choice.
* **Declarative configuration for Kong** Configure all of Kong using CRDs in Kubernetes and manage Kong declaratively.
* **Gateway Discovery** Monitors your Kong Gateways and pushes configuration to all replicas.

Setting up Kong for Kubernetes is as simple as:

```sh
# using YAMLs
$ kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/latest/deploy/single/all-in-one-dbless.yaml

# or using Helm
$ helm repo add kong https://charts.konghq.com
$ helm repo update

# Helm 3
$ helm install kong/kong --generate-name --set ingressController.installCRDs=false
```

Once installed, set an environment variable, $PROXY\_IP with the External IP address of the `demo-kong-proxy` service in `kong` namespace:

```sh
export PROXY_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" service -n kong demo-kong-proxy)
```

### Testing connectivity to Kong Gateway <a href="#testing-connectivity-to-kong-gateway" id="testing-connectivity-to-kong-gateway"></a>

This guide assumes that `PROXY_IP` environment variable is set to contain the IP address or URL pointing to Kong Gateway. If you’ve not done so, follow one of the [deployment guides](https://docs.konghq.com/kubernetes-ingress-controller/2.10.x/deployment/overview) to configure this environment variable.

If everything is setup correctly, making a request to Kong Gateway should return back a HTTP `404 Not Found` status code:

```sh
curl -i $PROXY_IP
```

Response:

```sh
HTTP/1.1 404 Not Found
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 48
X-Kong-Response-Latency: 0
Server: kong/3.0.0

{"message":"no Route matched with those values"}
```

This is expected since Kong Gateway doesn’t know how to proxy the request yet.

### Deploy an upstream HTTP application <a href="#deploy-an-upstream-http-application" id="deploy-an-upstream-http-application"></a>

To proxy requests, you need an upstream application to proxy to. Deploying this echo server provides a simple application that returns information about the Pod it’s running in:

```sh
echo "
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echo
  name: echo
spec:
  ports:
  - port: 1025
    name: tcp
    protocol: TCP
    targetPort: 1025
  - port: 1026
    name: udp
    protocol: TCP
    targetPort: 1026
  - port: 1027
    name: http
    protocol: TCP
    targetPort: 1027
  selector:
    app: echo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: echo
  name: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: echo
    spec:
      containers:
      - image: kong/go-echo:latest
        name: echo
        ports:
        - containerPort: 1027
        env:
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
        resources: {}
" | kubectl apply -f -
```

Response:

```sh
service/echo created
deployment.apps/echo created
```

### Create a configuration group <a href="#create-a-configuration-group" id="create-a-configuration-group"></a>

Ingress and Gateway APIs controllers need a configuration that indicates which set of routing configuration they should recognize. This allows multiple controllers to coexist in the same cluster. Before creating individual routes, you need to create a class configuration to associate routes with:

IngressGateway APIs

Official distributions of Kong Ingress Controller come with a `kong` IngressClass by default. If `kubectl get ingressclass kong` does not return a `not found` error, you can skip this command.

```sh
echo "
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: kong
spec:
  controller: ingress-controllers.konghq.com/kong
" | kubectl apply -f -
```

Response:

```sh
ingressclass.networking.k8s.io/kong configured
```

Kong Ingress Controller recognizes the `kong` IngressClass and `konghq.com/kic-gateway-controller` GatewayClass by default. Setting the `CONTROLLER_INGRESS_CLASS` or `CONTROLLER_GATEWAY_API_CONTROLLER_NAME` environment variable to another value overrides these defaults.

### Add routing configuration <a href="#add-routing-configuration" id="add-routing-configuration"></a>

Create routing configuration to proxy `/echo` requests to the echo server:

IngressGateway APIs

```sh
echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  annotations:
    konghq.com/strip-path: 'true'
spec:
  ingressClassName: kong
  rules:
  - host: kong.example
    http:
      paths:
      - path: /echo
        pathType: ImplementationSpecific
        backend:
          service:
            name: echo
            port:
              number: 1027
" | kubectl apply -f -
```

Response:

```sh
ingress.networking.k8s.io/echo created
```

Test the routing rule:

```sh
curl -i http://kong.example/echo --resolve kong.example:80:$PROXY_IP
```

Response:

```sh
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 140
Connection: keep-alive
Date: Fri, 21 Apr 2023 12:24:55 GMT
X-Kong-Upstream-Latency: 0
X-Kong-Proxy-Latency: 1
Via: kong/3.2.2

Welcome, you are connected to node docker-desktop.
Running on Pod echo-7f87468b8c-tzzv6.
In namespace default.
With IP address 10.1.0.237.
...
```

If everything is deployed correctly, you should see the above response. This verifies that Kong Gateway can correctly route traffic to an application running inside Kubernetes.

### Add TLS configuration <a href="#add-tls-configuration" id="add-tls-configuration"></a>

The routing configuration can include a certificate to present when clients connect over HTTPS. This is not required, as Kong Gateway will serve a default certificate if it cannot find another, but including TLS configuration along with routing configuration is typical.

First, create a test certificate for the `kong.example` hostname using one of the following commands:

OpenSSL 1.1.1OpenSSL 0.9.8

```sh
openssl req -subj '/CN=kong.example' -new -newkey rsa:2048 -sha256 \
  -days 365 -nodes -x509 -keyout server.key -out server.crt \
  -addext "subjectAltName = DNS:kong.example" \
  -addext "keyUsage = digitalSignature" \
  -addext "extendedKeyUsage = serverAuth" 2> /dev/null;
  openssl x509 -in server.crt -subject -noout
```

Response:

```sh
subject=CN = kong.example
```

Older OpenSSL versions, including the version provided with OS X Monterey, require using the alternative version of this command.

Then, create a Secret containing the certificate:

```shell
kubectl create secret tls kong.example --cert=./server.crt --key=./server.key
```

Response:

```shell
secret/kong.example created
```

Finally, update your routing configuration to use this certificate:

IngressGateway APIs

```sh
kubectl patch --type json ingress echo -p='[{
    "op":"add",
	"path":"/spec/tls",
	"value":[{
        "hosts":["kong.example"],
		"secretName":"kong.example"
    }]
}]'
```

Response:

```sh
ingress.networking.k8s.io/echo patched

```

After, requests will serve the configured certificate:

```sh
curl -ksv https://kong.example/echo --resolve kong.example:443:$PROXY_IP 2>&1 | grep -A1 "certificate:"
```

Response:

```sh
* Server certificate:
*  subject: CN=kong.example
```

### Using plugins in Kong <a href="#using-plugins-in-kong" id="using-plugins-in-kong"></a>

Setup a KongPlugin resource:

```sh
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: request-id
config:
  header_name: my-request-id
  echo_downstream: true
plugin: correlation-id
" | kubectl apply -f -
```

Response:

```shell
kongplugin.configuration.konghq.com/request-id created
```

Update your route configuration to use the new plugin:

IngressGateway APIs

```
kubectl annotate ingress echo konghq.com/plugins=request-id
```

Response:

```sh
ingress.networking.k8s.io/echo annotated
```

Requests that match the `echo` Ingress or HTTPRoute now include a `my-request-id` header with a unique ID in both their request headers upstream and their response headers downstream.

### Using plugins on Services <a href="#using-plugins-on-services" id="using-plugins-on-services"></a>

Kong can also apply plugins to Services. This allows you execute the same plugin configuration on all requests to that Service, without configuring the same plugin on multiple Ingresses.

Create a KongPlugin resource:

```sh
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rl-by-ip
config:
  minute: 5
  limit_by: ip
  policy: local
plugin: rate-limiting
" | kubectl apply -f -
```

Response:

```sh
kongplugin.configuration.konghq.com/rl-by-ip created
```

Next, apply the `konghq.com/plugins` annotation to the Kubernetes Service that needs rate-limiting:

```
kubectl annotate service echo konghq.com/plugins=rl-by-ip
```

Response:

```sh
service/echo annotated
```

Kong will now enforce a rate limit to requests proxied to this Service:

```
curl -i http://kong.example/echo --resolve kong.example:80:$PROXY_IP
```

Response:

```shell
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
X-RateLimit-Remaining-Minute: 4
RateLimit-Limit: 5
RateLimit-Remaining: 4
RateLimit-Reset: 13
X-RateLimit-Limit-Minute: 5
Date: Thu, 10 Nov 2022 22:47:47 GMT
Server: echoserver
my-request-id: ea87894d-7f97-4710-84ae-cbc608bb8107#3
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1



Hostname: echo-fc6fd95b5-6lqnc

Pod Information:
	node name:	kind-control-plane
	pod name:	echo-fc6fd95b5-6lqnc
	pod namespace:	default
	pod IP:	10.244.0.9
...
```
