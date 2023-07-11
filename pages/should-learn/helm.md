# Helm

## Get started with Helm Chart <a href="#c233" id="c233"></a>

Helm charts are packages of Kubernetes YAML manifest files that define a set of Kubernetes resources needed to deploy and run an application or service on a Kubernetes cluster. Helm is a package manager for Kubernetes that allows you to define, install, and manage complex applications on Kubernetes clusters.

Let’s imagine we have an nginx project that consists of four different environments: Development, Quality Assurance (QA), Staging, and Production.

In each of these environments, the parameters required for deploying Nginx may vary.

For instance, the number of replicas needed for Nginx deployment may differ, as well as the ingress routing rules, configuration and secret parameters, and other environment-specific settings.

Due to the variations in configuration and deployment parameters required for each environment, it can become cumbersome to manage multiple nginx deployment files for each environment.

Alternatively, we could use a single deployment file and create a custom shell or Python script to update values based on the environment. However, this approach is not scalable and can lead to inefficiencies.

This is where Helm charts come in. Helm charts are a package of Kubernetes YAML manifest templates and Helm-specific files that allow for templating. By using a Helm chart, we only need to maintain one file that can be customized for each environment through a single values file.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/0*FGtqoJddwEHKtVaO.png" alt="" height="394" width="700"><figcaption></figcaption></figure>

## Helm Chart tree structure <a href="#5cb9" id="5cb9"></a>

Below is a typical tree structure of the Helm Chart repository:

```sh
nginx/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

The `nginx/` directory is the root directory of the Helm chart. The `Chart.yaml` file describes the chart, including its version, name, and other metadata. The `values.yaml` file contains the default configuration values for the chart.

The `templates/` directory contains the Kubernetes YAML manifest templates that define the resources and configurations needed to deploy Nginx on a Kubernetes cluster. These templates are processed by Helm during the deployment process.

The `deployment.yaml` file defines the nginx deployment, including the container image, replicas, and other deployment-related parameters.

The `service.yaml` file defines the Kubernetes service for the Nginx deployment, which allows other pods within the cluster to access the nginx deployment.

## Hands-on: Creation of a Custom Helm Chart <a href="#1bc5" id="1bc5"></a>

To gain practical experience with creating Helm charts, we will create an Nginx chart from scratch.

We can start by using the following command to generate the chart. This will create a chart named `nginx-demo` with the default files and folders.

```sh
helm create nginx-demo
```

This will create the following files and directories:

```sh
nginx-demo/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml

3 directories, 10 files
```

Now let’s customize the necessary file.

### Chart.yaml <a href="#e2a0" id="e2a0"></a>

`Chart.yaml` is a YAML file that contains metadata about the Helm chart. This file is located in the root directory of the chart and is required for every chart.

```yaml
apiVersion: v2
name: nginx-demo
description: My First Helm Chart
type: application
version: 0.1.0
appVersion: "1.0.0"
maintainers:
- email: rajhiseif@gmail.com
  name: Saif the Containernerd
```

Where the fields in `Chart.yaml` are mainly:

* `name`: the name of the chart.
* `version`: the version of the chart.
* `description`: a brief description of the chart.
* `apiVersion`: the version of the Helm API that the chart is built for.
* `appVersion`: the version of the application that the chart is deploying.
* `maintainers`: a list of maintainers and their contact information.

We should increment the `version` and `appVersion` each time we make changes to the application. There are some other fields also like dependencies, etc.

## templates <a href="#05c8" id="05c8"></a>

We will delete all the default files in the `templates` directory by using the command `rm templates/*`, leaving an empty directory ready for you to add your own templates.

To improve comprehension, we will convert our nginx YAML files into templates. To do so, start by creating a `deployment.yaml` file and then paste the following content into it.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

The YAML file above has static values. Helm charts allow for templating of YAML files, enabling reuse across multiple environments with a dynamic value assignment. To template a value, add the object parameter in curly braces as a template directive, using syntax specific to the `Go templating`.

When working with Helm, there are three main keywords that you will encounter frequently: `Release`, `Chart`, and `Values`. Understanding the purpose and functionality of each of these keywords is essential for creating and managing Helm charts effectively.

1. _**Release:**_ A release is an instance of a chart running in a Kubernetes cluster. It is a specific version of a chart that has been installed with a unique name and set of configuration options.
2. _**Chart:**_ A chart is a collection of files that describe a set of Kubernetes resources. It includes templates for YAML files, default configuration values, and metadata such as the chart name and version.
3. _**Values:**_ Values are the configuration options that are used to configure a chart. They are defined in a values.yaml file and can be overridden when installing or upgrading a release. Values can also be passed to a chart through the command line or environment variables.

For more information on supported objects, refer to the [Helm Builtin Object document](https://helm.sh/docs/chart\_template\_guide/builtin\_objects/).

The built-in objects are substituted in a template, as shown in the image below:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*Ygh96B5lBQOo6j3a9uWDiw.png" alt="" height="557" width="700"><figcaption></figcaption></figure>

First, identify which values in your YAML file could potentially change or that you want to templatize.

In this example, we will templatize

* _**the name:**_ `name: {{ .Release.Name }}-nginx` In order to avoid the installation of releases with the same name, we need to templatize the deployment name with the release name and interpolate `-nginx` along with it. This guarantees unique deployment names.
* _**container name:**_ `{{ .Chart.Name }}`: to name the container, we will make use of the Chart object and assign the chart name from the chart.yaml file.
* _**replicas:**_ `{{ .Values.replicaCount }}` We will access the replica value from the **values.yaml** file.
* _**image:**_ `"{{ .Values.image.repository }}:{{ .Values.image.tag }}"`: in this case, we are using multiple template directives in a single line to obtain both the repository and tag information from the `Values` file, specifically under the `image` key.

By using the release name and chart object, we can ensure unique deployment names and container names. We can also access the replica count from the `values.yaml` file and use multiple template directives to access the repository and tag information for the image.

The final result should look like this :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Below is the YAML content for the `service.yaml` file that we need to create in the same way as the `deployment.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  selector:
    app.kubernetes.io/instance: {{ .Release.Name }}
  type: {{ .Values.service.type }}
  ports:
    - protocol: {{ .Values.service.protocol | default "TCP" }}
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
```

Notice the `protocol template directive`, where you may have noticed a pipe `(|)`being used to set the default protocol value to TCP. Therefore, if the protocol value is not defined in the `values.yaml` file or is left empty, the protocol value will be automatically set as TCP.

In the below step, we will spice up the flavor of our nginx server by replacing the default `index.html` page with a customized HTML page.

To take it a step further, we will use a template directive to replace the environment name in the HTML file. So, let’s create a `configmap.yaml` file and add the following contents to give our nginx a personal touch!

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-html-configmap
  namespace: default
data:
  index.html: |
    <html>
    <h1>Welcome</h1>
    </br>
    <h1>Hi! I got deployed in {{ .Values.env.name }} Environment using Helm Chart </h1>
    </html
```

### values.yaml <a href="#a095" id="a095"></a>

In the `values.yaml` file, we specify the values that are used to replace the template directives in the templates.

The `deployment.yaml` template, for instance, includes a template directive that retrieves the image repository, tag, and pullPolicy from the values.yaml file.

By examining the values.yaml file below, we can see that we have nested repository, tag, and pullPolicy key-value pairs under the image key. As a result, we used Values.image.repository.

The final `values.yaml` should be like this:

```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.16.0"
  pullPolicy: IfNotPresent

service:
  name: nginx-service
  type: ClusterIP
  port: 80
  targetPort: 9000

env:
  name: dev
```

The Nginx helm chart is now complete, and the final structure of the chart appears as follows:

```sh
nginx-demo
├── Chart.yaml
├── charts
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml
```

### **Verify the Helm chart’s configuration** <a href="#85b5" id="85b5"></a>

To confirm that our chart is valid and that all the indentations are correct, we can run the following command while inside the chart directory.

```sh
helm lint .
```

To ensure that the values are correctly substituted in the templates, we can use the following command to render the templated YAML files with the values. This will generate and display all the manifest files with the substituted values.

```sh
helm template .
```

Using the `--dry-run` is also a helpful way to check for errors before actually installing the chart on the cluster. It simulates the installation process and can catch any issues that may arise.

```sh
helm install --dry-run my-nginx-release nginx-demo
```

### Deploying the Helm Chart to the Kubernetes Cluster <a href="#aa95" id="aa95"></a>

After we have initiated the deployment of the chart, Helm will retrieve both the chart and configuration values from the `values.yaml` file and use them to generate the necessary manifest files.

These files will then be transmitted to the Kubernetes API server, which in turn will generate the desired resources within the cluster.

At this point, we are set to proceed with installing the chart. To do so, enter the following command

This will install the nginx-demo within the default namespace.

```sh
helm install helm-demo nginx-demo
```

Now we can check the release list by using this command:

```sh
helm list
```

Run the kubectl commands to check the deployment, services, and pods.

```sh
kubectl get deployment
kubectl get services
kubectl get configmap
kubectl get pods
```

We discussed how a single helm chart can be used for multiple environments using different `values.yaml` files.

To overwrite the default values file and install a helm chart with external `values.yaml` file, we can use the following command with the `--values` flag and path of the values file.

```sh
helm install helm-demo nginx-demo --values env/prod-values.yaml
```

**Upgrade & revert releases with Helm:**

Assuming that we want to update the chart and apply the changes, we can utilize the following command:

```
helm upgrade helm-demo nginx-demo
```

For instance, if we have decreased the number of replicas from 2 to 1, we will observe that the revision number is now 2, and only one pod is currently operational.

In case we wish to undo the changes made earlier and redeploy the previous version, we can employ the rollback command:

```sh
helm rollback helm-demo
```

By executing the above command, the helm release will revert to the previous version.

Following the rollback process, two pods should be active again. It is important to note that Helm treats the rollback action as a new revision, which is why the revision number displayed is incremented by 1.

If we intend to rollback to a specific version, you can include the revision number as shown below:

```sh
helm rollback <release-name> <revision-number>
```

As an example, to rollback the _**“helm-demo**_” release to revision number`2` , we can use the following command:

```sh
helm rollback helm-demo 2
```

Uninstall the Helm release

We can use the _**“uninstall”**_ command, which will eliminate all resources connected with the last chart release:

```shell
helm uninstall frontend
```

Additionally, we can create a package of the chart and deploy it to various platforms such as Github or S3 by executing the following command:

```sh
helm package frontend
```

You can find the source code of the project on my Github.
