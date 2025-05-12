# Kubecfg

Kubecfg is a command-line tool used to deploy Kubernetes resources using configuration files. It allows users to define Kubernetes resources in a YAML or JSON file format and apply them to a Kubernetes cluster.

Here are some examples of how to use Kubecfg in real-life Azure Pipelines:

1. Deploying a Kubernetes Deployment:

```plaintext
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```plaintext

To deploy this deployment using Kubecfg in Azure Pipelines, you can use the following command:

```plaintext
kubecfg apply mydeployment.yaml
```plaintext

2. Deploying a Kubernetes Service:

```plaintext
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```plaintext

To deploy this service using Kubecfg in Azure Pipelines, you can use the following command:

```plaintext
kubecfg apply myservice.yaml
```plaintext

3. Rolling out a Kubernetes Deployment:

```plaintext
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```plaintext

To roll out this deployment using Kubecfg in Azure Pipelines, you can use the following command:

```plaintext
kubecfg diff --diff-strategy=rolling mydeployment.yaml | kubectl apply -f -
```plaintext

Overall, Kubecfg is a powerful tool that can be used to deploy Kubernetes resources in a declarative and efficient way. By using Kubecfg in Azure Pipelines, users can automate their deployment process and ensure that their Kubernetes resources are deployed consistently and reliably.
