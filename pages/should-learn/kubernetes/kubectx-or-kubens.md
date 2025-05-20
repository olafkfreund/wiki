# kubectx | kubens

Efficient context and namespace switching is essential for DevOps engineers working with multiple Kubernetes clusters across AWS, Azure, GCP, or hybrid environments. `kubectx` and `kubens` streamline this workflow, making it easy to manage clusters and namespaces from the command line.

---

## What are kubectx and kubens?

- **kubectx**: Quickly switch between multiple Kubernetes cluster contexts with a single command.
- **kubens**: Instantly switch the active namespace for your current context.

Both tools are invaluable for engineers managing dev, staging, and production clusters, or working with multiple cloud providers.

---

## Installation

**macOS (Homebrew):**

```bash
brew install kubectx
```

**Linux (Debian/Ubuntu):**

```bash
sudo apt-get install kubectx
```

Or install via GitHub:

```bash
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
sudo ln -s ~/.kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s ~/.kubectx/kubens /usr/local/bin/kubens
```

**NixOS (declarative):**
Add to your `/etc/nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [ kubectx kubens ];
```

Then run:

```sh
sudo nixos-rebuild switch
```

---

## Usage Examples

### Switch Kubernetes Context

```bash
kubectx dev-cluster
```

### Switch Namespace

```bash
kubens devops-tools
```

Now, all `kubectl` commands will use the selected context and namespace by default, without needing `--context` or `--namespace` flags.

---

## Real-World DevOps Example

**Scenario:** You manage multiple clusters (dev, staging, prod) across AWS EKS and GCP GKE. Use `kubectx` and `kubens` to quickly switch between them:

```bash
kubectx aws-prod
kubens monitoring
kubectl get pods
```

---

## Aliases (if you don't want to install extra tools)

You can achieve similar functionality with bash aliases:

```bash
alias kubens='kubectl config set-context --current --namespace '
alias kubectx='kubectl config use-context '
```

---

## Best Practices

- Use `kubectx` and `kubens` to avoid mistakes when working with multiple clusters/namespaces.
- Add context/namespace info to your shell prompt for safety (see [kube-ps1](https://github.com/jonmosco/kube-ps1)).
- Store your kubeconfigs securely and use tools like [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) for cloud auth.

---

## References

- [kubectx & kubens GitHub](https://github.com/ahmetb/kubectx)
- [Kubernetes Contexts](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

> **Tip:** Integrate `kubectx` and `kubens` into your shell profile or tmux for even faster context switching in cloud-native workflows.
