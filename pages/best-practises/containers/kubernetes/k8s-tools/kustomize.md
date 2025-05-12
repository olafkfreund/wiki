# Kustomize

Kustomize is a command-line utility tool used to customize Kubernetes resources. It allows users to create and manage Kubernetes manifests in a more modular and maintainable way. Kustomize makes it easy to manage multiple environments and configurations, as well as to apply changes to existing resources.

Example Usage:

1. To create a base configuration: `kustomize create --resources=<directory>`
2. To apply a configuration: `kustomize build <directory> | kubectl apply -f -`
3. To apply a patch: `kustomize edit add patch <patch-file>`
4. To add a new resource: `kustomize edit add resource <resource-file>`
5. To add a label to resources: `kustomize edit add label <label-key>=<label-value>`
6. To add an annotation to resources: `kustomize edit add annotation <annotation-key>=<annotation-value>`
7. To generate a YAML file: `kustomize build <directory>`

Overall, Kustomize is a useful tool for managing Kubernetes deployments and configurations. By allowing users to manage and customize Kubernetes resources in a modular and maintainable way, Kustomize can simplify the process of deploying and managing applications in Kubernetes.

Suppose you have a directory named `my-app` with the following structure:

```plaintext
my-app/
├── base/
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── patch.yaml
    └── prod/
        ├── patch.yaml
        └── service.yaml
```plaintext

To build the `dev` overlay configuration, you can run:

```plaintext
cd my-app/overlays/dev
kustomize build
```plaintext

This will generate the Kubernetes YAML manifests for the `dev` environment by combining the base resources with the `dev` overlay patch file.

You can then apply these manifests to your Kubernetes cluster using `kubectl apply`:

```plaintext
kustomize build | kubectl apply -f -
```plaintext

This will apply the generated YAML manifests to your Kubernetes cluster.

Note that `kustomize build` can also be used to generate YAML manifests for other environments by changing the current directory to the corresponding overlay directory and running the `kustomize build` command.
