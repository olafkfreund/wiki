# kubectl

`kubectl` is the primary command-line tool for interacting with Kubernetes clusters. It allows you to deploy applications, inspect and manage cluster resources, and view logs. Mastery of `kubectl` is essential for DevOps engineers working with AWS EKS, Azure AKS, GCP GKE, NixOS, and WSL environments.

---

## Installation

**macOS (Homebrew):**

```bash
brew install kubectl
```

**Linux (Debian/Ubuntu):**

```bash
sudo apt-get update && sudo apt-get install -y kubectl
```

**NixOS (declarative):**
Add to your `/etc/nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [ kubectl ];
```

Then run:

```sh
sudo nixos-rebuild switch
```

**Windows (WSL):**
Install via Chocolatey or manually download the binary from the [official docs](https://kubernetes.io/docs/tasks/tools/).

---

## Quick Reference: Common kubectl Commands

### Cluster Management

- `kubectl cluster-info` – Show cluster endpoints
- `kubectl version` – Show client/server versions
- `kubectl config view` – Show kubeconfig
- `kubectl get all --all-namespaces` – List all resources in all namespaces

### Resource Listing

- `kubectl get namespaces` – List all namespaces
- `kubectl get pods` – List all pods in current namespace
- `kubectl get pods -o wide` – Detailed pod info
- `kubectl get pods --field-selector=spec.nodeName=<node>` – Pods on a node
- `kubectl get rc,services` – List replication controllers and services

### Deployments & Rollouts

- `kubectl get deployment` – List deployments
- `kubectl describe deployment <name>` – Deployment details
- `kubectl edit deployment <name>` – Edit deployment
- `kubectl create deployment <name> --image=<image>` – Create deployment
- `kubectl delete deployment <name>` – Delete deployment
- `kubectl rollout status deployment <name>` – Rollout status
- `kubectl rollout history deployment/<name>` – Rollout history
- `kubectl rollout undo deployment/<name>` – Rollback deployment
- `kubectl rollout restart deployment/<name>` – Restart deployment

### Pods

- `kubectl get pod` – List pods
- `kubectl describe pod <name>` – Pod details
- `kubectl logs <pod>` – Pod logs
- `kubectl logs -f <pod>` – Follow logs
- `kubectl exec -it <pod> -- /bin/sh` – Shell into pod
- `kubectl delete pod <name>` – Delete pod

### Namespaces

- `kubectl create namespace <name>` – Create namespace
- `kubectl get namespace` – List namespaces
- `kubectl describe namespace <name>` – Namespace details
- `kubectl delete namespace <name>` – Delete namespace

### Nodes

- `kubectl get nodes` – List nodes
- `kubectl describe node <name>` – Node details
- `kubectl cordon <node>` – Mark node unschedulable
- `kubectl drain <node>` – Prepare node for maintenance
- `kubectl uncordon <node>` – Mark node schedulable
- `kubectl top node` – Node resource usage

### DaemonSets

- `kubectl get daemonset` – List daemonsets
- `kubectl describe ds <name> -n <namespace>` – DaemonSet details
- `kubectl edit daemonset <name>` – Edit DaemonSet
- `kubectl delete daemonset <name>` – Delete DaemonSet

### Events

- `kubectl get events` – List events
- `kubectl get events --field-selector type=Warning` – List warnings

### Logs

- `kubectl logs <pod>` – Pod logs
- `kubectl logs -c <container> <pod>` – Container logs
- `kubectl logs --since=1h <pod>` – Last hour logs
- `kubectl logs --tail=20 <pod>` – Last 20 lines
- `kubectl logs --previous <pod>` – Previous pod logs

### Services & Service Accounts

- `kubectl get services` – List services
- `kubectl describe service <name>` – Service details
- `kubectl expose deployment <name>` – Expose as service
- `kubectl get serviceaccounts` – List service accounts
- `kubectl describe serviceaccount <name>` – Service account details

### Secrets

- `kubectl create secret generic <name> --from-literal=key=value` – Create secret
- `kubectl get secrets` – List secrets
- `kubectl describe secret <name>` – Secret details
- `kubectl delete secret <name>` – Delete secret

---

## Real-World DevOps Example: Rolling Update

```bash
kubectl set image deployment/myapp myapp=nginx:1.25.0
kubectl rollout status deployment/myapp
kubectl rollout undo deployment/myapp
```

---

## Best Practices

- Use `kubectl --context` and `--namespace` to avoid mistakes in multi-cluster/multi-namespace environments
- Use `kubectl explain <resource>` to discover resource fields
- Use `kubectl apply -f <file.yaml>` for declarative resource management
- Integrate `kubectl` with CI/CD (GitHub Actions, Azure Pipelines, GitLab CI)
- Use [kubectx/kubens](./kubectx-or-kubens.md) for fast context/namespace switching
- Never run destructive commands (`delete`, `drain`) without double-checking the context/namespace

---

## References

- [kubectl Cheat Sheet (Kubernetes.io)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl Official Docs](https://kubernetes.io/docs/reference/generated/kubectl/)
- [kubectl on NixOS](https://search.nixos.org/packages?channel=unstable&show=kubectl)

> **Tip:** Use shell aliases and prompt tools (e.g., kube-ps1) to display current context/namespace and avoid costly mistakes.
