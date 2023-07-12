# Traefik

,

Traefik can be installed in Kubernetes using the Helm chart from [https://github.com/traefik/traefik-helm-chart](https://github.com/traefik/traefik-helm-chart).

Ensure that the following requirements are met:

* Kubernetes 1.16+
* Helm version 3.9+ is [installed](https://helm.sh/docs/intro/install/)

Add Traefik Labs chart repository to Helm:

```bash
helm repo add traefik https://traefik.github.io/charts
```

You can update the chart repository by running:

```bash
helm repo update
```

And install it with the `helm` command line:

```bash
helm install traefik traefik/traefik
```

Helm Features

All [Helm features](https://helm.sh/docs/intro/using\_helm/) are supported.

Examples are provided [here](https://github.com/traefik/traefik-helm-chart/blob/master/EXAMPLES.md).

For instance, installing the chart in a dedicated namespace:

Install in a Dedicated Namespace

```bash
kubectl create ns traefik-v2
# Install in the namespace "traefik-v2"
helm install --namespace=traefik-v2 \
    traefik traefik/traefik
```

#### Exposing the Traefik dashboard

This HelmChart does not expose the Traefik dashboard by default, for security concerns. Thus, there are multiple ways to expose the dashboard. For instance, the dashboard access could be achieved through a port-forward:

```shell
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```

It can then be reached at: `http://127.0.0.1:9000/dashboard/`

Another way would be to apply your own configuration, for instance, by defining and applying an IngressRoute CRD (`kubectl apply -f dashboard.yaml`):

```yaml
# dashboard.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.localhost`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```

Dynamic configuration:

YAML

```yaml
# http routing section
http:
  routers:
    # Define a connection between requests and services
    to-whoami:
      rule: "Host(`example.com`) && PathPrefix(`/whoami/`)"
       # If the rule matches, applies the middleware
      middlewares:
      - test-user
      # If the rule matches, forward to the whoami service (declared below)
      service: whoami

  middlewares:
    # Define an authentication mechanism
    test-user:
      basicAuth:
        users:
        - test:$apr1$H6uskkkW$IgXLP6ewTrSuBkTrqE8wj/

  services:
    # Define how to reach an existing service on our infrastructure
    whoami:
      loadBalancer:
        servers:
        - url: http://private/whoami-service
```
