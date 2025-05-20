# Kubernetes components

A Kubernetes cluster has several control plane components used to control the cluster, as well as node components that run on each worker node. Let’s get to know all these components and how they work together.

---

## Control Plane Components <a href="#_idparadest-47" id="_idparadest-47"></a>

The control plane is responsible for the global decisions about the cluster (scheduling, scaling, health) and for detecting/responding to cluster events. In production, these components are often run on dedicated nodes for high availability.

### API Server
- **Role:** The API server is the front end for the Kubernetes control plane. All communication (kubectl, CI/CD, controllers, cloud integrations) goes through the API server.
- **How it works:** Stateless, can be scaled horizontally. Persists all cluster data in etcd.
- **Real-life tip:** In cloud-managed Kubernetes (EKS, AKS, GKE), the API server is managed by the provider. In self-managed clusters, always secure the API server with RBAC and network policies.

### etcd
- **Role:** Distributed, consistent key-value store for all cluster data (state, config, secrets).
- **How it works:** All control plane components read/write cluster state to etcd. Supports clustering for HA.
- **Best practice:** Always back up etcd regularly. For production, use an odd number of etcd nodes (3 or 5) for quorum and resilience.

### Kube Controller Manager
- **Role:** Runs controllers that regulate the state of the cluster (replicas, endpoints, jobs, nodes, etc.).
- **How it works:** Each controller watches the API server for changes and takes action to drive the cluster toward the desired state (e.g., scaling pods, replacing failed nodes).
- **Example:** If a node goes down, the node controller removes it from the cluster and reschedules pods.

### Cloud Controller Manager
- **Role:** Integrates Kubernetes with cloud provider APIs for managing cloud resources (load balancers, volumes, routes, etc.).
- **How it works:** Runs cloud-specific controllers. When enabled, set `--cloud-provider=external` on the kube-controller-manager to delegate cloud-specific logic.
- **Real-life scenario:** In AWS, the cloud controller manager provisions ELBs for Services of type LoadBalancer. In Azure, it manages Azure Disks for PersistentVolumes.

---

## Node Components

Node components run on every worker node and maintain running pods, provide the Kubernetes runtime environment, and report node status to the control plane.

### Kubelet
- **Role:** Agent that runs on each node. Ensures containers are running as specified in PodSpecs.
- **How it works:** Watches the API server for assigned pods, manages container lifecycle, reports node and pod status.
- **Best practice:** Monitor kubelet health and logs for troubleshooting node or pod issues.

### Kube Proxy
- **Role:** Maintains network rules on nodes for pod-to-pod and pod-to-service communication.
- **How it works:** Implements service discovery and load balancing using iptables, IPVS, or eBPF.
- **Real-life tip:** In cloud environments, kube-proxy may be replaced or supplemented by cloud-native networking plugins (e.g., AWS VPC CNI, Azure CNI).

### Container Runtime
- **Role:** Software responsible for running containers (e.g., containerd, CRI-O, Docker).
- **How it works:** Kubelet interacts with the container runtime via the Container Runtime Interface (CRI) to start/stop containers.
- **Best practice:** Use a supported, production-grade runtime (containerd is the default in most modern clusters).

---

## Real-Life Example: Cluster Startup Sequence
1. **API server** starts and connects to etcd.
2. **Controller managers** and **scheduler** start, connect to the API server.
3. **Cloud controller manager** (if enabled) provisions cloud resources.
4. **Worker nodes** start kubelet, kube-proxy, and container runtime.
5. Nodes register with the API server and are ready to run pods.

---

## References
- [Kubernetes Official Docs: Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Kubernetes Control Plane](https://kubernetes.io/docs/concepts/architecture/control-plane-node/)
- [Kubernetes Node Components](https://kubernetes.io/docs/concepts/architecture/nodes/)

> **Tip:** For production, always secure the control plane, use HA etcd, monitor node health, and automate backups. For cloud clusters, understand which components are managed by your provider and which you must operate yourself.
