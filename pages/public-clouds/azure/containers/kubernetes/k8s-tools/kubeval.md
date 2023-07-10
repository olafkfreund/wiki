# Kubeval

`kubeval` is a command-line tool that validates Kubernetes configuration files against the Kubernetes API schema. It can be used to validate Kubernetes manifests in a CI/CD pipeline or as part of a local development workflow. In this wiki page, we will provide an introduction to `kubeval` and how it can be used in real-life Azure deployment pipelines.

### Introduction to Kubeval

`kubeval` is a tool that validates Kubernetes manifests against the Kubernetes API schema. It checks that the configuration files are valid and will work as expected when deployed to a Kubernetes cluster. `kubeval` is useful for catching configuration errors early in the development cycle and ensuring that Kubernetes manifests are valid before deployment.

`kubeval` uses the OpenAPI schema to validate Kubernetes manifests, which means that it can validate manifests against any version of the Kubernetes API. It can also be used to validate custom resources and third-party Kubernetes resources.

### Using Kubeval in Real-Life Azure Deployment Pipelines

`kubeval` can be used in Azure deployment pipelines to validate Kubernetes manifests before deployment. By using `kubeval` in your deployment pipeline, you can ensure that your Kubernetes manifests are valid and will work as expected when deployed to a Kubernetes cluster.

Here are some examples of how to use `kubeval` in real-life Azure deployment pipelines:

#### Example 1: Validating Kubernetes Manifests in a CI/CD Pipeline

Suppose you have a CI/CD pipeline that deploys Kubernetes manifests to a production environment. You can use `kubeval` to validate the manifests before deployment:

```yaml
- name: Validate Kubernetes manifest
  run: |
    curl -sL https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar xz
    ./kubeval --strict --ignore-missing-schemas deployment.yaml
```

This command downloads the latest version of `kubeval`, validates the `deployment.yaml` file against the Kubernetes API schema, and fails the build if the manifest is invalid.

#### Example 2: Validating Custom Resources

Suppose you have a custom resource that needs to be validated before deployment. You can use `kubeval` to validate the custom resource against the custom resource definition (CRD):

```yaml
- name: Validate Custom Resource
  run: |
    curl -sL https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar xz
    ./kubeval --strict --ignore-missing-schemas --crd my-crd.yaml custom-resource.yaml
```

This command validates the `custom-resource.yaml` file against the custom resource definition `my-crd.yaml`. It ensures that the custom resource is valid and will work as expected when deployed to a Kubernetes cluster.

#### Example 3: Validating Third-Party Resources

Suppose you are using a third-party Kubernetes resource that needs to be validated before deployment. You can use `kubeval` to validate the resource against the third-party resource definition:

```yaml
- name: Validate Third-Party Resource
  run: |
    curl -sL https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar xz
    ./kubeval --strict --ignore-missing-schemas --schema-location https://raw.githubusercontent.com/third-party/resource/main/schema.yaml
third-party-resource.yaml
```

This command validates the `third-party-resource.yaml` file against the third-party resource definition located at `https://raw.githubusercontent.com/third-party/resource/main/schema.yaml`. It ensures that the third-party resource is valid and will work as expected when deployed to a Kubernetes cluster.

### Conclusion

`kubeval` is a powerful tool that can be used to validate Kubernetes manifests against the Kubernetes API schema. It is particularly useful in Azure deployment pipelines where it can ensure that Kubernetes manifests are valid before they are deployed to a Kubernetes cluster. By using `kubeval` in your deployment pipeline, you can catch configuration errors early in the development cycle and ensure that your Kubernetes manifests are valid and will work as expected.
