# Gloo Edge

Gloo Edge is a powerful, cloud-native API gateway and ingress controller for Kubernetes, supporting advanced routing, transformation, and security features. It is widely used in AWS, Azure, GCP, and hybrid environments for managing north-south traffic and integrating legacy and modern workloads.

---

## Installation (Helm)

1. **Add the Helm repository for Gloo Edge:**

    ```shell
    helm repo add gloo https://storage.googleapis.com/solo-public-helm
    helm repo update
    ```

2. **Install the Helm chart:**
   This command creates the `gloo-system` namespace and installs the Gloo Edge components into it.

    ```shell
    helm install gloo gloo/gloo --namespace gloo-system --create-namespace
    ```

---

## Real-Life Example: Exposing a Microservice with Gloo Edge

### 1. Deploy Example Application (Pet Store)

Deploy the Pet Store application and expose its API via a Kubernetes service:

```shell
kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/v1.13.x/example/petstore/petstore.yaml
```

Expected output:
```console
deployment.extensions/petstore created
service/petstore created
```

### 2. Verify Application and Service

Check that the pod is running:
```shell
kubectl -n default get pods
```

Check the service:
```shell
kubectl -n default get svc petstore
```

Output:
```console
NAME      TYPE       CLUSTER-IP   EXTERNAL-IP  PORT(S)   AGE
petstore  ClusterIP  10.XX.XX.XX  <none>       8080/TCP  1m
```

### 3. Discover Upstreams with glooctl

List all upstreams Gloo Edge has discovered:
```shell
glooctl get upstreams
```

Look for `default-petstore-8080` in the output. To inspect the upstream:
```shell
glooctl get upstream default-petstore-8080 --output kube-yaml
```

If you want Gloo Edge to auto-discover REST endpoints (using OpenAPI/Swagger), enable function discovery:
```shell
kubectl label namespace default discovery.solo.io/function_discovery=enabled
```

Check discovered functions:
```shell
glooctl get upstream default-petstore-8080
```

### 4. Add a Routing Rule (Virtual Service)

Create a route to expose the Pet Store API externally:
```shell
glooctl add route \
  --path-exact /all-pets \
  --dest-name default-petstore-8080 \
  --prefix-rewrite /api/pets
```

Check the virtual service:
```shell
glooctl get virtualservice default
```

Inspect the virtual service YAML:
```shell
glooctl get virtualservice default --output kube-yaml
```

### 5. Test the Route

Get the Gloo Edge proxy URL and test the route:
```shell
curl $(glooctl proxy url)/all-pets
```

Expected output:
```json
[{"id":1,"name":"Dog","status":"available"},{"id":2,"name":"Cat","status":"pending"}]
```

---

## Best Practices
- Use Helm for repeatable, versioned Gloo Edge deployments
- Enable function discovery only for namespaces that need it (for performance)
- Use Virtual Services and routing rules to control external access
- Monitor upstream and virtual service status with `glooctl`
- Store all configuration (Helm values, CRDs) in Git for GitOps workflows

---

## References
- [Gloo Edge Docs](https://docs.solo.io/gloo-edge/latest/)
- [Gloo Edge GitHub](https://github.com/solo-io/gloo)
- [Glooctl CLI Reference](https://docs.solo.io/gloo-edge/latest/reference/cli/glooctl/)
- [Kubernetes Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

> **Tip:** Integrate Gloo Edge with CI/CD (GitHub Actions, ArgoCD, Flux) for automated API gateway and ingress management in multi-cloud environments.
