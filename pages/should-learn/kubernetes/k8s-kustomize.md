# K8s — Kustomize

Kustomize is a native Kubernetes configuration management tool that enables DevOps engineers to customize raw, template-free YAML files for multiple environments (dev, staging, prod) without duplicating or forking manifests. It is built into `kubectl` (v1.14+) and is widely used across AWS, Azure, GCP, NixOS, and CI/CD pipelines.

---

## Why Use Kustomize?

- **Declarative overlays:** Manage environment-specific changes (replicas, image tags, labels) without editing base YAML files.
- **No templates:** Works directly with YAML, avoiding the complexity of templating engines.
- **Built-in to kubectl:** No extra dependencies for most Kubernetes users.
- **Cloud-native:** Used in GitOps, ArgoCD, Flux, and CI/CD workflows.

---

## Installation

**kubectl (v1.14+):**
Kustomize is built-in:

```sh
kubectl kustomize ./path/to/overlay
```

**Standalone (Linux/macOS/NixOS):**

- [Official releases](https://github.com/kubernetes-sigs/kustomize/releases)
- **NixOS (declarative):**
  Add to `/etc/nixos/configuration.nix`:

  ```nix
  environment.systemPackages = with pkgs; [ kustomize ];
  ```

  Then run:

  ```sh
  sudo nixos-rebuild switch
  ```

---

## Basic Example: Image Tag Overlay

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

---

## Multi-Environment Overlays (Dev, Prod, etc.)

kustomize encourages defining multiple variants - e.g. dev, staging and prod, as overlays on a common base. It’s possible to create an additional overlay to compose these variants together — just declare the overlays as the bases of a new kustomization.

This is also a means to apply a common label or annotation across the variants, if for some reason the base isn’t under your control. It also allows one to define a left-most namePrefix across the variants — something that cannot be done by modifying the common base.

Let’s demo how to use kustomize in overlays. First, still in our `sample-app` folder, let’s define a common base directory:

```sh
pwd
/home/txu/sample-app
mkdir base
cd base
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

### Dev Overlay

Let’s make a `dev` variant overlaying `base` :

```sh
mkdir dev
cd dev
```

Create a kustomize file in `dev` :

```yaml
$ vim kustomization.yml 
# kustomization.yaml contents
resources:
- ./../base
namePrefix: dev-
```

### Production Overlay

Similar to `dev` overlaying, let’s create a `prod` variant overlaying `base` :

```sh
mkdir prod
cd prod
```

Create a kustomize file in `prod` :

```sh
$ vim kustomization.yml 
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
- ./prod
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

---

## Real-World DevOps Example: Multi-Cloud GitOps

Suppose you manage clusters in AWS EKS, Azure AKS, and GCP GKE. Use Kustomize overlays for each environment:

```
├── base
│   ├── deployment.yaml
│   └── kustomization.yaml
├── overlays
│   ├── aws
│   │   └── kustomization.yaml
│   ├── azure
│   │   └── kustomization.yaml
│   └── gcp
│       └── kustomization.yaml
```

Each overlay can patch image tags, resource limits, or add cloud-specific labels. Deploy with:

```sh
kubectl apply -k overlays/aws
kubectl apply -k overlays/azure
kubectl apply -k overlays/gcp
```

---

## Kustomize vs Helm

- **Kustomize:** Overlay engine, no templates, built into kubectl, great for environment overlays and GitOps.
- **Helm:** Templating engine, supports variables and charts, better for complex parameterization and packaging.

**Best Practice:** Use Kustomize for overlays and environment-specific changes; use Helm for reusable application packaging.

---

## Best Practices

- Store base and overlays in version control (Git)
- Use overlays for environment-specific changes (replicas, image tags, secrets)
- Integrate Kustomize with CI/CD (GitHub Actions, ArgoCD, Flux)
- Validate output with `kubectl kustomize` before applying
- Avoid duplicating YAML—use patches and generators

---

## References

- [Kustomize Official Docs](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [Kustomize GitHub](https://github.com/kubernetes-sigs/kustomize)
- [Kustomize on NixOS](https://search.nixos.org/packages?channel=unstable&show=kustomize)
- [Kustomize vs Helm](https://kubectl.docs.kubernetes.io/guides/config_management/)

> **Tip:** Use Kustomize overlays for safe, repeatable multi-environment deployments in cloud-native and GitOps workflows.
