# Kubernetes Best Practices

### Use Namespaces

By default, there are three different namespaces in Kubernetes in the beginning: default, kube-public and kube-system. Namespaces are very important in organizing your Kubernetes cluster and keeping it secured from other teams working on the same cluster. If your Kubernetes cluster is large (hundreds of nodes) and multiple teams are working on it, you need to have separate namespaces for each team. For example, you should create different namespaces for development, testing and production teams. This way, the developer having access to only the development namespace won’t be able to make any changes in the production namespace, even by mistake. If you do not do this separation, there is a high chance of accidental overwrites by well-meaning teammates.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: development
  namespace: development  
  labels:
    image: development01
spec: 
  containers:
    - name: development01
    image: nginx
```

### Use Labels

A Kubernetes cluster includes multiple elements like services, pods, containers, networks, etc. Maintaining all these resources and keeping track of how they interact with each other in a cluster is cumbersome. This is where labels come in. Kubernetes labels are key-value pairs that organize your cluster resources.

For example, let’s say you are running two instances of one type of application. Both are similarly named, but each application is used by different teams (e.g., development and testing). You can help your teams differentiate between the similar applications by defining a label which uses their team’s name to demonstrate ownership.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: ops-pod
 labels:
   environment: operations
   team: ops01
spec:
 containers:
   - name: ops01
     image: "Ubuntu"
     resources:
       limits:
        cpu: 1
```

### Readiness and Liveness Probes

Readiness and liveness probes are strongly recommended; it is almost always better to use them than to forego them. These probes are essentially health checks.

Readiness probeEnsures a given pod is up-and-running before allowing the load to get directed to that pod. If the pod is not ready, the requests are taken away from your service until the probe verifies the pod is up. Liveness probeVerifies if the application is still running or not. This probe tries to ping the pod for a response from it and then check its health. If there is no response, then the application is not running on the pod. The liveness probe launches a new pod and starts the application on it if the check fails.

In this example, the probe pings an application to check if it is still running. If it gets the HTTP response, it then marks the pod as healthy.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: prodContainer
spec:
 containers:
- image: nginx    
name: prodContainer    
livenessProbe:
       httpGet:
         path: /prodhealth
         port: 8080
```

### Security using RBAC and Firewall

Today, everything is hackable, and so is your Kubernetes cluster. Hackers often try to find vulnerabilities in the system in order to exploit them and gain access. So, keeping your Kubernetes cluster secure should be a high priority. The first thing to do is make sure you are using RBAC in Kubernetes. RBAC is role-based access control. Assign roles to each user in your cluster and each service account running in your cluster. Roles in RBAC contain several permissions that a user or service account can perform. You can assign the same role to multiple people and each role can have multiple permissions.

RBAC settings can also be applied on namespaces, so if you assign roles to a user allowed in one namespace, they will not have access to other namespaces in the cluster. Kubernetes provides RBAC properties such as role and cluster role to define security policies.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: read
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### Set Resource Requests & Limits

Occasionally deploying an application to a production cluster can fail due limited resources available on that cluster. This is a common challenge when working with a Kubernetes cluster and it’s caused when resource requests and limits are not set. Without resource requests and limits, pods in a cluster can start utilizing more resources than required. If the pod starts consuming more CPU or memory on the node, then the scheduler may not be able to place new pods, and even the node itself may crash.

* Resource requests specify the minimum amount of resources a container can use
* Resource limits specify the maximum amount of resources a container can use.

For both requests and limits, it’s typical to define CPU in millicores and memory is in megabytes or mebibytes. Containers in a pod do not run if the request of resources made is higher than the limit you set.

In this example, we have set the limit of CPU to 800 millicores and memory to 256 mebibytes. The maximum request which the container can make at a time is 400 millicores of CPU and 128 mebibyte of memory.

```yaml
containers:
- name: devContainer2
    image: ubuntu
    resources:
        requests:
            memory: "128Mi"
            cpu: "400m"
        limits:                              
            memory: "256Mi"
            cpu: "800m"
```

### Audit Your Logs Regularly

The logs of any system have a lot to tell, you just have to store and analyze them well. In Kubernetes, auditing the logs regularly is particularly important to identify any vulnerability or threat in the cluster. All the request data made on the Kubernetes API is stored in the audit.log file. This file is stored at /var/log/audit.log with the Kubernetes cluster's audit policy present at /etc/kubernetes/audit-policy.yaml

You need to pass the parameter mentioned below while stating the kube-apiserver if you want the cluster to have audit logging:

```yaml
--audit-policy-file=/etc/kubernetes/audit-policy.yaml --audit-log-path=/var/log/audit.log
```

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["pods"]
   - level: Metadata
     resources:
     - group: ""
      resources: ["pods/log", "pods/status"]
```

### Cloud-Native Security (2024+)

#### Pod Security Standards
* Enforce Pod Security Admission
* Use Security Contexts
* Implement Network Policies
* Runtime Security with Falco

#### Supply Chain Security
* Container Image Signing
* SBOM Management
* Admission Controllers
  * OPA/Gatekeeper
  * Kyverno
  * ValidatingWebhooks

#### GitOps Practices
* Declarative Deployments
* Automated Reconciliation
* Drift Detection
* Progressive Delivery

#### Modern Observability
* OpenTelemetry Integration
* Prometheus + Thanos
* Grafana Loki
* Jaeger/Tempo

### Platform Engineering

#### Developer Experience
* Internal Developer Platform
* Self-service Namespaces
* Service Catalogs
* Platform API

#### Multi-cluster Management
* Fleet Management
* Cluster API
* Virtual Clusters
* Cross-cluster Services

#### Cost Optimization
* Spot Instances
* Resource Quotas
* HPA/VPA
* FinOps Integration

### Production Readiness

#### High Availability
* Pod Disruption Budgets
* Topology Spread Constraints
* Anti-affinity Rules
* Load Balancing

#### Disaster Recovery
* Velero Backups
* State Management
* Cross-region Failover
* Data Replication

#### Compliance
* Pod Security Standards
* Network Policies
* Audit Logging
* RBAC/IAM Integration

### Implementation Examples

```yaml
# Pod Security Context
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: my-app:latest
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]

---
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              environment: production
```
