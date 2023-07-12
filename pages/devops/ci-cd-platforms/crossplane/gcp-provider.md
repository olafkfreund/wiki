# GCP provider

### Install the GCP provider  <a href="#install-the-gcp-provider" id="install-the-gcp-provider"></a>

Install the provider into the Kubernetes cluster with a Kubernetes configuration file.

```shell
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: upbound-provider-gcp
spec:
  package: xpkg.upbound.io/upbound/provider-gcp:v0.28.0
EOF
```

The `kind: Provider` uses the Crossplane `Provider` _Custom Resource Definition_ to connect your Kubernetes cluster to your cloud provider.

Verify the provider installed with `kubectl get providers`.

```shell
kubectl get providers
NAME                   INSTALLED   HEALTHY   PACKAGE                                        AGE
upbound-provider-gcp   True        True      xpkg.upbound.io/upbound/provider-gcp:v0.28.0   107s
```

A provider installs their own Kubernetes _Custom Resource Definitions_ (CRDs). These CRDs allow you to create GCP resources directly inside Kubernetes.

You can view the new CRDs with `kubectl get crds`. Every CRD maps to a unique GCP service Crossplane can provision and manage.

### Create a Kubernetes secret for GCP  <a href="#create-a-kubernetes-secret-for-gcp" id="create-a-kubernetes-secret-for-gcp"></a>

The provider requires credentials to create and manage GCP resources. Providers use a Kubernetes _Secret_ to connect the credentials to the provider.

First generate a Kubernetes _Secret_ from a Google Cloud service account JSON file and then configure the Provider to use it.

#### Generate a GCP service account JSON file  <a href="#generate-a-gcp-service-account-json-file" id="generate-a-gcp-service-account-json-file"></a>

For basic user authentication, use a Google Cloud service account JSON file.

Save this JSON file as `gcp-credentials.json`

#### Create a Kubernetes secret with the GCP credentials  <a href="#create-a-kubernetes-secret-with-the-gcp-credentials" id="create-a-kubernetes-secret-with-the-gcp-credentials"></a>

A Kubernetes generic secret has a name and contents. Use `kubectl create secret` to generate the secret object named `gcp-secret` in the `crossplane-system` namespace.\
Use the `--from-file=` argument to set the value to the contents of the\
`gcp-credentials.json` file.

```shell
kubectl create secret \
generic gcp-secret \
-n crossplane-system \
--from-file=creds=./gcp-credentials.json
```

View the secret with `kubectl describe secret`

```shell
kubectl describe secret gcp-secret -n crossplane-system
Name:         gcp-secret
Namespace:    crossplane-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
creds:  2330 bytes
```

### Create a ProviderConfig  <a href="#create-a-providerconfig" id="create-a-providerconfig"></a>

A `ProviderConfig` customizes the settings of the GCP Provider.

Apply the `ProviderConfig` . Include your `GCP project ID` in the _ProviderConfig_ settings.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: 
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: gcp-secret
      key: creds
EOF
```

This attaches the GCP credentials, saved as a Kubernetes secret, as a `secretRef` .

The `spec.credentials.secretRef.name` value is the name of the Kubernetes secret containing the GCP credentials in the `spec.credentials.secretRef.namespace` .
