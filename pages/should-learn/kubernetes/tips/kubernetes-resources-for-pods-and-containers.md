# Kubernetes: Resources for Pods and Containers

> Kubernetes uses YAML files to specify **resource requirements** for pods and containers, including **CPU and memory** resources. CPU resources are allocated using CPU requests and CPU limits in millicores. If a container **exceeds the CPU limit,** it will be **throttled by the kernel**. Memory resources are allocated using memory requests and memory limits in units such as bytes, kilobytes, megabytes, or gigabytes. If a container **exceeds its memory limit, Kubernetes will terminate and restart it**, which is known as an **OOMKilled event**. Properly configuring memory limits is important to avoid degraded performance and downtime.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*u5Qa0dHS6QHp0ks1KCuujw.png" alt="" height="525" width="700"><figcaption><p>Kubernetes: Resources for Pods and Containers</p></figcaption></figure>

---

## Table of Contents

- [CPU Resources](#b19a)
- [Memory Resources](#b0f6)
- [Commands](#6902)
- [Real-Life Examples](#real-life-examples)
- [Best Practices](#best-practices)
- [References](#references)

**Resource requirements** for pods and containers in Kubernetes can be specified in the YAML file. Kubernetes **uses this information to schedule and manage the deployment of the pod or container** across the available nodes in the cluster.

## CPU Resources <a href="#b19a" id="b19a"></a>

In Kubernetes, CPU resources can be allocated to Pods and containers to ensure that they have the **required processing power to run their applications**. CPU resources are defined using the **CPU resource units (millicores or milliCPU)** and can be specified as CPU requests and CPU limits.

### CPU Requests and Limits with YAML <a href="#57b8" id="57b8"></a>

pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    resources:
      requests:
        cpu: "100m"
      limits:
        cpu: "200m"
```

This example specifies a pod with a single container that has a CPU request of 100 millicores (100m) and a CPU limit of 200 millicores (200m):

### Impact of Exceeding CPU Limits <a href="#effb" id="effb"></a>

If a container tries to **exceed its CPU request**, it will be **scheduled on a node that has enough CPU resources** to satisfy the request. However, if a container tries to **exceed its CPU limit**, it will be **throttled by the kernel**. This can cause the container to become unresponsive, leading to degraded performance and potentially impacting other containers running on the same node.

## Memory Resources <a href="#b0f6" id="b0f6"></a>

In Kubernetes, memory resources can be allocated to Pods and containers to ensure that they have the **required memory** to run their applications. Memory resources are defined using the **memory resource units** (such as **bytes, kilobytes, megabytes, or gigabytes**) and can be specified as memory requests and memory limits.

### Memory Requests and Limits with YAML <a href="#9874" id="9874"></a>

pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    resources:
      requests:
        memory: "64Mi"
      limits:
        memory: "128Mi"
```

This example specifies a pod with a single container that has a memory request of 64 megabytes (64Mi) and a memory limit of 128 megabytes (128Mi).

### Impact of Exceeding Memory Limits <a href="#7ae5" id="7ae5"></a>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*nczJHKct1Gg5gl4C6eAktw.png" alt="" height="409" width="700"><figcaption><p>OOMKilled</p></figcaption></figure>

When a container **exceeds its memory limit** in Kubernetes, it is **terminated and restarted** by Kubernetes. This event is known as **OOMKilled**, which stands for **Out Of Memory Killed**. This happens when a container or a pod consumes all the available memory resources allocated to it, and the kernel terminates it to prevent it from consuming more memory and impacting the stability of the node. It is important to properly configure memory limits for containers and pods to avoid OOMKilled events, as they can lead to degraded performance and downtime.

## Commands <a href="#6902" id="6902"></a>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*3QEUiPb8jSMAvuqsAaVWTw.png" alt="" height="350" width="700"><figcaption><p>commands</p></figcaption></figure>

1. Check the CPU and memory usage for all Pods

```bash
kubectl top pods -A
```

Output columns:

```plaintext
NAMESPACE     NAME    CPU(cores)   MEMORY(bytes)
```

2. Find the pod that consumes the most **CPU** resources

```bash
kubectl top pods -A --no-headers | sort --reverse --key 3 | head -n 1
kubectl top pods -A --no-headers | sort -nr -k3 | head -1
```

3. Find the pod that consumes the most **memory** resources

```bash
kubectl top pods -A --no-headers | sort --reverse --key 4 | head -n 1
kubectl top pods -A --no-headers | sort -nr -k4 | head -1
```

4. Check the CPU and memory usage of Nodes

```bash
kubectl top nodes
```

Output columns:

```plaintext
NAME    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
```

---

## Real-Life Examples <a id="real-life-examples"></a>

### Example 1: Setting Resource Requests and Limits for a Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.25
        resources:
          requests:
            cpu: "250m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
```

### Example 2: Observing OOMKilled Events

If a container exceeds its memory limit, it will be restarted with an OOMKilled event. To check for this:

```bash
kubectl get pods --all-namespaces | grep OOMKilled
kubectl describe pod <pod-name> | grep -A5 State
```

### Example 3: Troubleshooting High Resource Usage

Find the top CPU and memory consumers:

```bash
kubectl top pods -A --sort-by=cpu | head -n 10
kubectl top pods -A --sort-by=memory | head -n 10
```

### Example 4: Enforcing Resource Quotas (Namespace Level)

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: devops-quota
  namespace: devops-tools
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
```

Apply with:

```bash
kubectl apply -f resource-quota.yaml
```

---

## Best Practices <a id="best-practices"></a>

- Always set both requests and limits for CPU and memory in production workloads.
- Use `kubectl top` and monitoring tools (Prometheus, Grafana, Datadog) to observe real usage.
- Set namespace-level ResourceQuotas to prevent noisy neighbor problems.
- Avoid setting limits too low (causes throttling/OOMKilled) or too high (wastes resources).
- Use [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) for dynamic resource tuning.
- Document resource requirements in your Git repository for reproducibility.

---

## References <a id="references"></a>

- [Kubernetes Resource Management Docs](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [kubectl top Reference](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)
- [OOMKilled Troubleshooting](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#oomkill)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

> **Tip:** Use CI/CD (GitHub Actions, GitLab CI, Azure Pipelines) to validate resource settings and catch misconfigurations before deploying to production.
