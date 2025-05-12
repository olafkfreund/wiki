# Using Nix with Devbox for Kubernetes Development and Deployment

[Devbox](https://www.jetpack.io/devbox/) is a tool that leverages Nix to create reproducible development environments. It is ideal for Kubernetes workflows, enabling you to develop locally (e.g., with Minikube) and deploy to cloud clusters like AKS with the same tooling and configuration.

---

## Why use Devbox + Nix for Kubernetes?
- **Reproducibility**: Every developer and CI job gets the same environment.
- **Portability**: Works on Linux, macOS, and WSL.
- **Easy onboarding**: `devbox shell` gives you all tools instantly.
- **Consistent CI/CD**: Use the same config for local and cloud deployments.

---

## Example: Local Minikube to AKS Deployment

### 1. Project Structure
```
k8s-devbox-demo/
├── devbox.json
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── README.md
```

### 2. Example `devbox.json`
```json
{
  "packages": [
    "kubectl",
    "minikube",
    "kubernetes-helm",
    "azure-cli"
  ]
}
```

### 3. Example Kubernetes Deployment (`k8s/deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-devbox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-devbox
  template:
    metadata:
      labels:
        app: hello-devbox
    spec:
      containers:
      - name: hello-devbox
        image: nginx:alpine
        ports:
        - containerPort: 80
```

### 4. Example Kubernetes Service (`k8s/service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-devbox
spec:
  type: NodePort
  selector:
    app: hello-devbox
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

---

## Local Development with Minikube

1. **Start Devbox shell:**
   ```bash
   devbox shell
   ```
2. **Start Minikube:**
   ```bash
   minikube start
   ```
3. **Deploy to Minikube:**
   ```bash
   kubectl apply -f k8s/
   kubectl get pods
   minikube service hello-devbox
   ```

---

## Deploying to AKS

1. **Login and set context:**
   ```bash
   az login
   az aks get-credentials --resource-group <your-rg> --name <your-aks-cluster>
   kubectl config use-context <your-aks-cluster>
   ```
2. **Deploy to AKS:**
   ```bash
   kubectl apply -f k8s/
   kubectl get pods
   kubectl get service hello-devbox
   ```

---

## Automating with just and Shell Hooks

You can use [just](https://just.systems/) (a modern command runner) or shell hooks in your Nix/devbox environment to automate common tasks when entering the dev shell.

### Using just
1. **Add just to your environment:**
   - For Nix/devbox, add `just` to your packages list.
2. **Create a `justfile` in your project root:**
   ```makefile
   # justfile
   start-minikube:
       minikube start

   deploy-local:
       kubectl apply -f k8s/

   deploy-aks:
       az aks get-credentials --resource-group <your-rg> --name <your-aks-cluster>
       kubectl apply -f k8s/
   ```
3. **Usage:**
   ```bash
   just start-minikube
   just deploy-local
   just deploy-aks
   ```

### Using Shell Hooks (Nix/devbox)
- In `devbox.json` or `devenv.nix`, you can define shell hooks to run commands automatically when entering the shell:

**devbox.json example:**
```json
{
  "packages": ["kubectl", "minikube", "just"],
  "shell": {
    "init_hook": "echo 'Welcome to your dev environment!'; just --list"
  }
}
```

**devenv.nix example:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.just pkgs.kubectl pkgs.minikube ];
  enterShell = ''
    echo "Welcome to your dev shell!"
    just --list
  '';
}
```

This way, you can automate environment setup, reminders, or even start services as soon as you enter your dev shell.

---

## Summary
- Use Devbox + Nix for a reproducible, portable Kubernetes dev environment.
- Develop and test locally with Minikube, then deploy to AKS with the same tools and manifests.
- All dependencies are managed declaratively in `devbox.json`.

---

## References
- [Devbox Documentation](https://www.jetpack.io/devbox/docs/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
