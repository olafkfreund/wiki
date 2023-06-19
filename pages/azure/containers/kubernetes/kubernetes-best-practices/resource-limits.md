# Resource limits

Resource limits are an important aspect of Kubernetes deployments that help ensure the stability and reliability of a Kubernetes cluster. Resource limits allow Kubernetes to control how much CPU, memory, and other resources are allocated to containers running in a cluster. By setting resource limits, Kubernetes can prevent a single container or pod from using up all of the available resources in a cluster and causing performance issues or outages.

Here are some examples of how resource limits can be used in real-life use cases:

1. Web server deployment:

Suppose you have a web server deployment running in a Kubernetes cluster. Without resource limits, the web server containers could potentially consume all of the CPU and memory resources available in the cluster, causing a performance degradation or even crashing the cluster. By setting resource limits for the web server containers, Kubernetes can ensure that the containers always have a set amount of resources available to them, preventing them from monopolizing the cluster's resources.

2. Machine learning deployment:

Suppose you have a machine learning deployment running in a Kubernetes cluster. Machine learning models can be computationally expensive, and without resource limits, the machine learning containers could consume all of the CPU and memory resources available in the cluster, causing other applications to suffer performance issues or crash. By setting resource limits for the machine learning containers, Kubernetes can ensure that the machine learning deployment runs without impacting other applications in the cluster.

3. High-performance computing deployment:

Suppose you have a high-performance computing deployment running in a Kubernetes cluster. High-performance computing workloads can be extremely resource-intensive, and without resource limits, the containers running the workload could consume all of the CPU, memory, and other resources available in the cluster. By setting resource limits for the containers running the high-performance computing workload, Kubernetes can ensure that the workload runs without impacting other applications in the cluster.

Overall, resource limits are an essential component of Kubernetes deployments that help ensure the stability and reliability of a Kubernetes cluster. By setting resource limits, Kubernetes can prevent individual containers or pods from monopolizing the resources available in the cluster, ensuring that all applications running in the cluster have access to the resources they need to function effectively.

Here are some examples of how to set resource limits for Kubernetes Deployments using YAML:

1. Setting CPU and memory resource limits for a Deployment:

```yaml
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
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
        ports:
        - containerPort: 80
```

In this example, the `resources` field is used to set the resource limits for the container. The `limits` field specifies the maximum amount of CPU and memory that the container is allowed to use. In this case, the container is limited to 1 CPU and 512 MB of memory.

2. Setting CPU, memory, and GPU resource limits for a Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-deployment
spec:
  selector:
    matchLabels:
      app: ml
  replicas: 1
  template:
    metadata:
      labels:
        app: ml
    spec:
      containers:
      - name: ml
        image: ml:latest
        resources:
          limits:
            cpu: "2"
            memory: "8Gi"
            nvidia.com/gpu: "1"
```

In this example, the `resources` field is used to set the CPU, memory, and GPU resource limits for the container. The `limits` field specifies the maximum amount of CPU and memory that the container is allowed to use, as well as the number of GPUs that can be used. In this case, the container is limited to 2 CPUs, 8 GB of memory, and 1 GPU.

3. Setting CPU and memory resource limits for a Deployment using shorthand notation:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  selector:
    matchLabels:
      app: myapp
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        resources:
          limits:
            cpu: 2
            memory: 4Gi
        ports:
        - containerPort: 80
```

In this example, the shorthand notation is used to set the resource limits for the container. The `limits` field specifies the maximum amount of CPU and memory that the container is allowed to use. In this case, the container is limited to 2 CPUs and 4 GB of memory.

Overall, setting resource limits for Kubernetes Deployments is an essential task that helps ensure that the Kubernetes cluster operates smoothly and efficiently. By setting resource limits, you can prevent individual containers or pods from monopolizing the resources available in the cluster and ensure that all applications running in the cluster have access to the resources they need to function effectively.

