# Kubernetes: Resources for Pods and Containers

> Kubernetes uses YAML files to specify **resource requirements** for pods and containers, including **CPU and memory** resources. CPU resources are allocated using CPU requests and CPU limits in millicores. If a container **exceeds the CPU limit,** it will be **throttled by the kernel**. Memory resources are allocated using memory requests and memory limits in units such as bytes, kilobytes, megabytes, or gigabytes. If a container **exceeds its memory limit, Kubernetes will terminate and restart it**, which is known as an **OOMKilled event**. Properly configuring memory limits is important to avoid degraded performance and downtime.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*u5Qa0dHS6QHp0ks1KCuujw.png" alt="" height="525" width="700"><figcaption><p>Kubernetes: Resources for Pods and Containers</p></figcaption></figure>

<pre><code><strong>Table of Contents
</strong>
· 
  ∘ 
  ∘ 
· 
  ∘ 
  ∘ 
· 
</code></pre>

**Resource** **requirements** for pods and containers in Kubernetes can be specified in the YAML file. Kubernetes **uses this information to schedule and manage the deployment of the pod or container** across the available nodes in the cluster.

## CPU Resources <a href="#b19a" id="b19a"></a>

In Kubernetes, CPU resources can be allocated to Pods and containers to ensure that they have the **required processing power to run their applications**. CPU resources are defined using the **CPU resource units (millicores or milliCPU)** and can be specified as CPU requests and CPU limits.

### CPU Requests and Limits with YAML <a href="#57b8" id="57b8"></a>

pod.yaml

```
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

```
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

```
$ kubectl top pods -A
```

Output columns:

```
NAMESPACE     NAME    CPU(cores)   MEMORY(bytes)
```

2\. Find the pod that consumes the most **CPU** resources

```
$ kubectl top pods -A --no-headers | sort --reverse --key 3 | head -n 1
$ kubectl top pods -A --no-headers | sort -nr -k3 | head -1
```

3\. Find the pod that consumes the most **memory** resources

```
$ kubectl top pods -A --no-headers | sort --reverse --key 4 | head -n 1
$ kubectl top pods -A --no-headers | sort -nr -k4 | head -1
```

4\. Check the CPU and memory usage of Nodes

```
$ kubectl top nodes
```

Output columns:

```
NAME    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
```

\
