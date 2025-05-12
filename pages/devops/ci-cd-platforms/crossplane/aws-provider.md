# AWS provider

### Install the AWS provider  <a href="#install-the-aws-provider" id="install-the-aws-provider"></a>

Install the provider into the Kubernetes cluster with a Kubernetes configuration file.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: upbound-provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.27.0
EOF
```plaintext

The Crossplane `Provider` Custom Resource Definition tells Kubernetes how to connect to the provider.

Verify the provider installed with `kubectl get providers`.

```shell
kubectl get providers
NAME                   INSTALLED   HEALTHY   PACKAGE                                        AGE
upbound-provider-aws   True        True      xpkg.upbound.io/upbound/provider-aws:v0.27.0   12m
```plaintext

A provider installs their own Kubernetes _Custom Resource Definitions_ (CRDs). These CRDs allow you to create AWS resources directly inside Kubernetes.

You can view the new CRDs with `kubectl get crds`. Every CRD maps to a unique AWS service Crossplane can provision and manage.

### Create a Kubernetes secret for AWS  <a href="#create-a-kubernetes-secret-for-aws" id="create-a-kubernetes-secret-for-aws"></a>

The provider requires credentials to create and manage AWS resources. Providers use a Kubernetes _Secret_ to connect the credentials to the provider.

First generate a Kubernetes _Secret_ from your AWS key-pair and then configure the Provider to use it.

#### Generate an AWS key-pair file  <a href="#generate-an-aws-key-pair-file" id="generate-an-aws-key-pair-file"></a>

For basic user authentication, use an AWS Access keys key-pair file.

Create a text file containing the AWS account `aws_access_key_id` and `aws_secret_access_key`.

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```plaintext

Save this text file as `aws-credentials.txt`.

#### Create a Kubernetes secret with the AWS credentials  <a href="#create-a-kubernetes-secret-with-the-aws-credentials" id="create-a-kubernetes-secret-with-the-aws-credentials"></a>

A Kubernetes generic secret has a name and contents. Use `kubectl create secret` to generate the secret object named `aws-secret` in the `crossplane-system` namespace.\
Use the `--from-file=` argument to set the value to the contents of the `aws-credentials.txt` file.

```shell
kubectl create secret \
generic aws-secret \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt
```plaintext

View the secret with `kubectl describe secret`

```shell
kubectl describe secret aws-secret -n crossplane-system
Name:         aws-secret
Namespace:    crossplane-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
creds:  114 bytes
```plaintext

### Create a ProviderConfig  <a href="#create-a-providerconfig" id="create-a-providerconfig"></a>

A `ProviderConfig` customizes the settings of the AWS Provider.

Apply the `ProviderConfig` with the command:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-secret
      key: creds
EOF
```plaintext

This attaches the AWS credentials, saved as a Kubernetes secret, as a `secretRef` .

The `spec.credentials.secretRef.name` value is the name of the Kubernetes secret containing the AWS credentials in the `spec.credentials.secretRef.namespace` .
