# Azure provider

### Install the Azure provider  <a href="#install-the-azure-provider" id="install-the-azure-provider"></a>

Install the provider into the Kubernetes cluster with a Kubernetes configuration file.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: upbound-provider-azure
spec:
  package: xpkg.upbound.io/upbound/provider-azure:v0.32.0
EOF
```

The Crossplane `Provider` Custom Resource Definitions tells Kubernetes how to connect to the provider.

Verify the provider installed with `kubectl get providers`.

TipIt may take up to five minutes for the provider to list `HEALTHY` as `True`.

```shell
kubectl get providers
NAME                     INSTALLED   HEALTHY   PACKAGE                                          AGE
upbound-provider-azure   True        True      xpkg.upbound.io/upbound/provider-azure:v0.32.0   22m
```

A provider installs their own Kubernetes _Custom Resource Definitions_ (CRDs). These CRDs allow you to create Azure resources directly inside Kubernetes.

You can view the new CRDs with `kubectl get crds`. Every CRD maps to a unique Azure service Crossplane can provision and manage.

### Create a Kubernetes secret for Azure  <a href="#create-a-kubernetes-secret-for-azure" id="create-a-kubernetes-secret-for-azure"></a>

The provider requires credentials to create and manage Azure resources. Providers use a Kubernetes _Secret_ to connect the credentials to the provider.

This guide generates an Azure service principal JSON file and saves it as a Kubernetes _Secret_.

TipOther authentication methods exist and are beyond the scope of this guide. The [Provider documentation](https://github.com/upbound/provider-azure/blob/main/AUTHENTICATION.md) contains information on alternative authentication methods.

#### Install the Azure command-line  <a href="#install-the-azure-command-line" id="install-the-azure-command-line"></a>

Generating an [authentication file](https://docs.microsoft.com/en-us/azure/developer/go/azure-sdk-authorization#use-file-based-authentication) requires the Azure command-line.\
Follow the documentation from Microsoft to [Download and install the Azure command-line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

Log in to the Azure command-line.

```command
az login
```

#### Create an Azure service principal  <a href="#create-an-azure-service-principal" id="create-an-azure-service-principal"></a>

Follow the Azure documentation to [find your Subscription ID](https://docs.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id) from the Azure Portal.

Using the Azure command-line and provide your Subscription ID create a service principal and authentication file.

```console
az ad sp create-for-rbac \
--sdk-auth \
--role Owner \
--scopes /subscriptions/$$<subscription_id>$$
```

Save your Azure JSON output as `azure-credentials.json`.

#### Create a Kubernetes secret with the Azure credentials  <a href="#create-a-kubernetes-secret-with-the-azure-credentials" id="create-a-kubernetes-secret-with-the-azure-credentials"></a>

A Kubernetes generic secret has a name and contents. Use `kubectl create secret` to generate the secret object named `azure-secret` in the `crossplane-system` namespace.

Use the `--from-file=` argument to set the value to the contents of the `azure-credentials.json` file.

```shell
kubectl create secret \
generic azure-secret \
-n crossplane-system \
--from-file=creds=./azure-credentials.json
```

View the secret with `kubectl describe secret`

```shell
kubectl describe secret azure-secret -n crossplane-system
Name:         azure-secret
Namespace:    crossplane-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
creds:  629 bytes
```

### Create a ProviderConfig  <a href="#create-a-providerconfig" id="create-a-providerconfig"></a>

A `ProviderConfig` customizes the settings of the Azure Provider.

Apply the `ProviderConfig` with the command:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: azure.upbound.io/v1beta1
metadata:
  name: default
kind: ProviderConfig
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: azure-secret
      key: creds
EOF
```

This attaches the Azure credentials, saved as a Kubernetes secret, as a `secretRef` .

The `spec.credentials.secretRef.name` value is the name of the Kubernetes secret containing the Azure credentials in the `spec.credentials.secretRef.namespace` .
