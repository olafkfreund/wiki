# kubectx | kubens

When you work on Kubernetes projects, there is a high chance of working with multiple kubernetes cluster contexts.

You might work on a local [kubernetes kubeadm setup](https://devopscube.com/setup-kubernetes-cluster-kubeadm/) and other project clusters of different environments.

Working with different cluster contexts with kubectl is not a great experience. Here is where you can make use of `kubectx` and `kubens` utilities.

`kubectx` utility helps you switch between Multiple kubernetes cluster contexts with one command.

For example,

```bash
kubectx demo-clsuter
```

By default, when you use kubectl without the `--namespace` flag, it lists all the resources in the default namespace.

Similarly, to set a custom namespace a default, you can use `kubens` utility.

For example, If I have a namespace named `devops-tools` I can set it as default using `kubens` as shown below.

```bash
kubens devops-tools
```

Now, if you run kubectl to list pods or any resources, it will use the `devops-tools` namespace by default without adding `--namepsace` flag to the `kubectl`command.

**Try Kubectl:** [https://github.com/ahmetb/kubectx](https://github.com/ahmetb/kubectx)

Now, if you say, I don’t want to install a separate plugin for this. Then, do the following.

```bash
alias kubens='kubectl config set-context --current --namespace '
alias kubectx='kubectl config use-context '
```

An alias will also do the trick!
