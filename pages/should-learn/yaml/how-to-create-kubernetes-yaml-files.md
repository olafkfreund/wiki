# How to create Kubernetes YAML files

### Create vs generate <a href="#6480" id="6480"></a>

Initially, you might be tempted to generate as much of the boilerplate as possible. My recommendation is, don’t! Especially if you are new to Kubernetes or YAML, experiment, copy-paste from [Kubernetes docs](https://kubernetes.io/), but don’t use generators on day one.

Once you are familiar with the basics, progressively add tools that will make your life easier. There is good news; you will understand the basics pretty fast.

A good way to know if you are familiar enough with the YAML content of a specific resource if it is getting, well … boring. From here now, you should dive headfirst into the world of generators and helpers to keep your sanity and make your life easier.

### 1 YQ <a href="#0e2a" id="0e2a"></a>

The first tool I want to talk about is [yq](https://mikefarah.gitbook.io/yq/). Yq is not a Kubernetes specific, it’s rather a “jack of all trades” of YAML. Learning this tool will help you query and manipulate YAML files directly from the command line. It helps with tasks, such as:

* filtering YAML file for a specific value, for example retrieving an image name from a deployment file

Selecting values from YAML files is useful, but mastering yq will help mostly with bulk operations on multiple files and more complex transformations.

### 2 Kubectl <a href="#5490" id="5490"></a>

It is easy to get started with generating YAML files for most of the resources with [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/). You can use “ — dry-run=client -oyaml > yaml\_file.yaml” flag on the “[kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create)” or “[kubectl run](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run)” commands to generate most of the resources.

For example, to generate a YAML file for an nginx pod you can run:

`kubectl run nginx — image=nginx — port=8080 — env=env=DEV — labels=app=nginx,owner=user — privileged=false — dry-run=client -oyaml > nginx-pod.yaml`

This command will generate the following YAML:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*EpfZuoar_dvKTmY4tdTVuQ.png" alt="" height="952" width="700"><figcaption><p>YAML generated with kubectl</p></figcaption></figure>

The file needs to be cleaned a bit, but it is a good starting point.

Now you could create a deployment using:

`kubectl create deployment my-dep — image=nginx — dry-run=client -oyaml > deployment.yaml`

and use yq to merge the two files.

This process can get complicated fast, but it’s easy to use shell scripts to automate most of the tasks.

Using the combination of kubectl and yq is great for starting a simple one-off project as well as help automate things in between.

If you are interested in kubectl tips & tricks, I have a growing list of useful commands in [this gist](https://gist.github.com/Piotr1215/443fb83c89958139f0c67ec70b111da2).

### 3 Docker-compose <a href="#a60f" id="a60f"></a>

Do you have a docker-compose.yaml file in your project? Generating Kubernetes manifests from the docker-compose file is possible using a tool called [kompose](https://kompose.io/).

Let’s see this in action. We will use a docker-compose file from the [awesome-compose repository](https://github.com/docker/awesome-compose.git).

Here is a sample docker-compose file:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*W3zj5z7VoWi5ExLeoO4okg.png" alt="" height="1323" width="700"><figcaption><p>Source: Awesome-Compose repo</p></figcaption></figure>

Now, let’s generate Kubernetes manifests using **kompose:**

This command takes the docker-compose as input and outputs generated Kubernetes YAML into the k8s-manifests folder.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*us9TWhvWm_3mD7D-hsqIvw.png" alt="" height="412" width="700"><figcaption><p>kompose generated files</p></figcaption></figure>

Using kompose is a good option if you already have a docker-compose file. There are often tweaks needed, but it takes you one step closer to having a decent starting point.

### 4 VS Code with plugins <a href="#b63a" id="b63a"></a>

VS Code has 2 plugins that help with creating YAML files. Big thanks to&#x20;

[Avi Nehama](https://medium.com/u/e64e9bb3065b?source=post\_page-----abb8426eeb45--------------------------------) for suggesting it.

[Kubernetes Templates](https://marketplace.visualstudio.com/items?itemName=lunuan.kubernetes-templates)

The template enables quick scaffolding of any Kubernetes resource.

Create yaml file, start typing the name of Kubernetes resource and hit TAB to insert a template. Keep cycling with TAB to fill the names in the required fields.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*LBCL0Fy99sLKHyj15TXwFg.png" alt="" height="684" width="700"><figcaption></figcaption></figure>

[YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)

This extension from Red Hat runs a YAML server in the background and adds context aware smart completion to any Kubernetes resource.

Remember to activate it in the settings and reload VS Code. Add this line to the settings to enable Kubernetes completion on all YAML files.

```yaml
"yaml.schemas": {
  "Kubernetes": "*.yaml"
}
```plaintext

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*ssv7K5es5evjKC6-DVHJUw.png" alt="" height="387" width="700"><figcaption></figcaption></figure>

### 5 CDK8s <a href="#74e3" id="74e3"></a>

Moving on from command line to programming territory. If you have to author a lot of YAML, but happen to know Python, Typescript, JavaScript, Java or Go, you can harness the power of a programming language to make the process of writing YAML much easier.

Introducing [CDK8s](https://cdk8s.io/)

> **cdk8s** is an open-source software development framework for defining Kubernetes applications and reusable abstractions using familiar programming languages and rich object-oriented APIs. **cdk8s** apps synthesize into standard Kubernetes manifests which can be applied to any Kubernetes cluster.

CDK8s works by exposing Kubernetes resources objects and using an object called constructs to further abstract and automate YAML files creation.

The real power behind this approach is the ability to:

* create reusable components and abstractions that capture your requirements
* use native programming language constructs to automate, test and validate the process of creating YAML

### 6 NAML <a href="#01dc" id="01dc"></a>

If you happen to know Go and don’t like YAML at all and want to avoid it at all costs, this project might be something for you!

A very interesting approach designed by&#x20;

[Kris Nova](https://medium.com/u/158602cec861?source=post\_page-----abb8426eeb45--------------------------------) ([Github profile](https://github.com/kris-nova)) is a Go-centric tool called naml which works by creating Kubernetes manifests directly in Go and installing them on the cluster via CLI install command.

This tool can produce YAML similarly to CKD8s but works only with Go.
