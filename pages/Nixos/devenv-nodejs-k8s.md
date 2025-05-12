# Using devenv to Build, Test, and Deploy Node.js Pods (Local & AWS)

devenv makes it easy to create reproducible development environments for Node.js applications, including Kubernetes pod deployment and local testing before pushing to AWS (EKS).

---

## Why devenv for Node.js + Kubernetes?
- **Reproducibility**: Same environment for all developers and CI.
- **Easy onboarding**: `devenv up` and you’re ready to code.
- **Kubernetes ready**: Includes kubectl, minikube, and other tools.
- **Portable**: Works on Linux, macOS, and WSL.

---

## Example Project Structure
```
nodejs-k8s-demo/
├── devenv.nix
├── justfile
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── src/
│   └── index.js
├── package.json
└── Dockerfile
```

---

## Example `devenv.nix`
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.nodejs pkgs.kubectl pkgs.minikube pkgs.just pkgs.docker ];
  enterShell = ''
    echo "Welcome to your Node.js + Kubernetes dev shell!"
    just --list
  '';
}
```

---

## Example `justfile`
```makefile
# justfile
start-minikube:
    minikube start

build-image:
    docker build -t nodejs-k8s-demo:latest .

load-image:
    minikube image load nodejs-k8s-demo:latest

deploy-local:
    kubectl apply -f k8s/
    kubectl get pods
    minikube service nodejs-k8s-demo

deploy-aws:
    aws eks update-kubeconfig --region <region> --name <cluster>
    kubectl apply -f k8s/
    kubectl get pods
```

---

## Example `Dockerfile`
```Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["node", "src/index.js"]
```

---

## Example Kubernetes Deployment (`k8s/deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-k8s-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-k8s-demo
  template:
    metadata:
      labels:
        app: nodejs-k8s-demo
    spec:
      containers:
      - name: nodejs-k8s-demo
        image: nodejs-k8s-demo:latest
        ports:
        - containerPort: 3000
```

---

## Example Kubernetes Service (`k8s/service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-k8s-demo
spec:
  type: NodePort
  selector:
    app: nodejs-k8s-demo
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
```

---

## Local Development & Testing
1. Enter the dev shell:
   ```bash
   nix develop # or devenv up
   ```
2. Start Minikube:
   ```bash
   just start-minikube
   ```
3. Build and load the Docker image:
   ```bash
   just build-image
   just load-image
   ```
4. Deploy to local Minikube:
   ```bash
   just deploy-local
   ```
5. Access your app:
   ```bash
   minikube service nodejs-k8s-demo
   ```

---

## Deploy to AWS (EKS)
1. Authenticate to EKS:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster>
   ```
2. Push your image to ECR or another registry, update the image reference in `deployment.yaml`.
3. Deploy to EKS:
   ```bash
   just deploy-aws
   ```

---

## References
- [devenv.sh](https://devenv.sh/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [AWS EKS](https://docs.aws.amazon.com/eks/)
- [just](https://just.systems/)

With devenv, you can build, test, and deploy Node.js Kubernetes pods locally and to AWS with a single, reproducible environment.
