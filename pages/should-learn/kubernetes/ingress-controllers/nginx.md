# Nginx

**f you have Helm,** you can deploy the ingress controller with the following command:

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```plaintext

It will install the controller in the `ingress-nginx` namespace, creating that namespace if it doesn't already exist.

Info

This command is _idempotent_:

* if the ingress controller is not installed, it will install it,
* if the ingress controller is already installed, it will upgrade it.

**If you want a full list of values that you can set, while installing with Helm,** then run:

```shell
helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
```plaintext

**If you don't have Helm** or if you prefer to use a YAML manifest, you can run the following command instead:

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```plaintext

Info

The YAML manifest in the command above was generated with `helm template`, so you will end up with almost the same resources as if you had used Helm to install the controller.

Attention

If you are running an old version of Kubernetes (1.18 or earlier), please read [this paragraph](https://kubernetes.github.io/ingress-nginx/deploy/#running-on-Kubernetes-versions-older-than-1.19) for specific instructions. Because of api deprecations, the default manifest may not work on your cluster. Specific manifests for supported Kubernetes versions are available within a sub-folder of each provider.

#### Pre-flight check[¶](https://kubernetes.github.io/ingress-nginx/deploy/#pre-flight-check) <a href="#pre-flight-check" id="pre-flight-check"></a>

A few pods should start in the `ingress-nginx` namespace:

```sh
kubectl get pods --namespace=ingress-nginx
```plaintext

After a while, they should all be running. The following command will wait for the ingress controller pod to be up, running, and ready:

```sh
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```plaintext

#### Local testing[¶](https://kubernetes.github.io/ingress-nginx/deploy/#local-testing) <a href="#local-testing" id="local-testing"></a>

Let's create a simple web server and the associated service:

```shell
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
```plaintext

Then create an ingress resource. The following example uses a host that maps to `localhost`:

```sh
kubectl create ingress demo-localhost --class=nginx \
  --rule="demo.localdev.me/*=demo:80"
```plaintext

Now, forward a local port to the ingress controller:

```shell
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```plaintext

Info

A note on DNS & network-connection. This documentation assumes that a user has awareness of the DNS and the network routing aspects involved in using ingress. The port-forwarding mentioned above, is the easiest way to demo the working of ingress. The "kubectl port-forward..." command above has forwarded the port number 8080, on the localhost's tcp/ip stack, where the command was typed, to the port number 80, of the service created by the installation of ingress-nginx controller. So now, the traffic sent to port number 8080 on localhost will reach the port number 80, of the ingress-controller's service. Port-forwarding is not for a production environment use-case. But here we use port-forwarding, to simulate a HTTP request, originating from outside the cluster, to reach the service of the ingress-nginx controller, that is exposed to receive traffic from outside the cluster.

[This issue](https://github.com/kubernetes/ingress-nginx/issues/10014#issuecomment-1567791549described) shows a typical DNS problem and its solution.

At this point, you can access your deployment using curl ;

```sh
curl --resolve demo.localdev.me:8080:127.0.0.1 http://demo.localdev.me:8080
```plaintext

You should see a HTML response containing text like **"It works!"**.

#### Online testing[¶](https://kubernetes.github.io/ingress-nginx/deploy/#online-testing) <a href="#online-testing" id="online-testing"></a>

If your Kubernetes cluster is a "real" cluster that supports services of type `LoadBalancer`, it will have allocated an external IP address or FQDN to the ingress controller.

You can see that IP address or FQDN with the following command:

```shell
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```plaintext

It will be the `EXTERNAL-IP` field. If that field shows `<pending>`, this means that your Kubernetes cluster wasn't able to provision the load balancer (generally, this is because it doesn't support services of type `LoadBalancer`).

Once you have the external IP address (or FQDN), set up a DNS record pointing to it. Then you can create an ingress resource. The following example assumes that you have set up a DNS record for `www.demo.io`:

```shell
kubectl create ingress demo --class=nginx \
  --rule="www.demo.io/*=demo:80"
```plaintext

Alternatively, the above command can be rewritten as follows for the `--rule` command and below.

```sh
kubectl create ingress demo --class=nginx \
  --rule www.demo.io/=demo:80
```plaintext

You should then be able to see the "It works!" page when you connect to http://www.demo.io/. Congratulations, you are serving a public website hosted on a Kubernetes cluster! 🎉
