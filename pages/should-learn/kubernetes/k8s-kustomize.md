# K8s — Kustomize

## What is Kustomize <a href="#2561" id="2561"></a>

Kustomize provides a solution for customizing K8s resource configuration free from templates and DSLs. It lets you customize raw, template-free YAML files for multiple purposes, leaving the original YAML untouched and usable as is. Kustomize can also patch `kubernetes style` API objects.

Kustomize uses overlays for K8s manifests to add, remove, or update configuration options without forking. What Kustomize does is take a K8s template, patch it with specified changes in **`kustomization.yaml`**, and then deploy it to Kubernetes.

### Features of Kustomize: <a href="#e600" id="e600"></a>

* Helps customizing config files in a template free way.
* Provides a number of handy methods like generators to make customization easier.
* Uses patches to introduce environment specific changes on existing standard config file without disturbing it.

## Kustomize Example <a href="#04fc" id="04fc"></a>

Let’s first take a look at one example of how to use Kustomize, to give a taste of how it works and why we need it.

Assuming you have the following application structure:

```sh
$ tree
./sample-app
└── base
    ├── kustomization.yml
    ├── nginx_deploy.yml
    └── nginx_service.yml

1 directory, 3 files

0 directories, 2 files
```

We already familiar with the `nginx` Deployment and Service file, let’s focus on the `kustomization.yml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

images:
- name: nginx
  newTag: 1.21.0

resources:
- nginx_deploy.yml
- nginx_service.yml
```

As you can see from the above file content, we set a new tag for the **nginx** image, and sets which **`resources`** to apply the settings to. As `Service` does not have images, `Kustomize` will only apply to the `Deployment`, but since we will need `Service` in the later steps, so we are setting it anyway.

Now let’s run the `kubectl kustomize base` command:

```sh
$ kubectl kustomize base
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
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
      - image: nginx:1.21.0
        imagePullPolicy: IfNotPresent
        name: nginx
```

As you can see from the above output, Kustomize generated `Service` and `Deployment` content. If you pay attention, the contents of **`Service`** did not change, but the contents of Deployment changed.

The `containers` definition in `nginx_deploy.yml` file:

```yaml
containers:
- name: nginx
  image: nginx:1.20.0
  imagePullPolicy: IfNotPresent
```

compare with the output from `kustomize` command output:

```yaml
containers:
- name: nginx
  image: nginx:1.21.0
  imagePullPolicy: IfNotPresent
```

we see that **`image: nginx:1.20.0`** got changed to **`— image: nginx:1.21.0`**, as was specified in the **kustomization.yml** file. Without updating the `nginx_deploy.yml` file, we can change the image tag during deployment.

## Deploy to Multi Envs <a href="#bd69" id="bd69"></a>

kustomize encourages defining multiple variants - e.g. dev, staging and prod, as overlays on a common base. It’s possible to create an additional overlay to compose these variants together — just declare the overlays as the bases of a new kustomization.

This is also a means to apply a common label or annotation across the variants, if for some reason the base isn’t under your control. It also allows one to define a left-most namePrefix across the variants — something that cannot be done by modifying the common base.

Let’s demo how to use kustomize in overlays. First, still in our `sample-app` folder, let’s define a common base directory:

```sh
$ pwd
$ /home/txu/sample-app
$ mkdir base
$ cd base
```

Now in the `base` directory, let’s create `kustomization.yml` with the following content:

```sh
$ vim kustomization.yaml
# kustomization.yaml contents
resources:
- pod.yml
```

The `pod.yml` file:

```yaml
# pod.yaml contents
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

### Dev Overlay <a href="#27d5" id="27d5"></a>

Let’s make a `dev` variant overlaying `base` :

```sh
$ mkdir dev
$ cd dev
```

Create a kustomize file in `dev` :

```yaml
$ vim kustomization.yml 
# kustomization.yaml contents
resources:
- ./../base
namePrefix: dev-
```

### Production Overlay <a href="#c4c0" id="c4c0"></a>

Similar to `dev` overlaying, let’s create a `prod` variant overlaying `base` :

```sh
$ mkdir prod
$ cd prod
```

Create a kustomize file in `dev` :

```sh
$ vim kustomization.yal 
# kustomization.yaml contents
resources:
- ./../base
namePrefix: prod-
```

Now at project root level, define a kustomize file:

```sh
# kustomization.yaml contents
resources:
- ./dev
- ./production
namePrefix: cluster-a-
```

The entire app structure looks like:

```sh
$ tree
.
├── base
│   ├── kustomization.yml
│   └── pod.yml
├── dev
│   └── kustomization.yml
├── kustomization.yml
└── prod
    └── kustomization.yml

3 directories, 5 files
```

Now let’s build the final output:

```yaml
$ kubectl kustomize
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: myapp
  name: cluster-a-dev-myapp-pod
spec:
  containers:
  - image: nginx:latest
    name: nginx
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: myapp
  name: cluster-a-prod-myapp-pod
spec:
  containers:
  - image: nginx:latest
    name: nginx
```

## Kustomize vs Helm <a href="#df8e" id="df8e"></a>

Compare the Helm, which is a “Templating Engine”, kustomize is an “Overlay Engine”. With Helm (templating engine) you create a boilerplate example of your application, then you abstract away contents with known filters and within these abstractions you provide references to variables.

Kustomize built into kubectl as of version 1.14, which means it is native in K8s. However, you can also install it independently. With Kustomize users can manage any number of K8s configurations, each with its distinct customization, using the declarative approach. It allows developers to define multiple versions of an application and manage them in sub-directories. The base directory contains the common configurations, while sub-directories contain version-specific patches.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/0*eJefeGKJ20PH-_52.png" alt="" height="483" width="700"><figcaption></figcaption></figure>

\
