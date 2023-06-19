# Kubernetes components

A Kubernetes cluster has several control plane components used to control the cluster, as well as node components that run on each worker node. Let’s get to know all these components and how they work together.

#### Control plane components <a href="#_idparadest-47" id="_idparadest-47"></a>

The control plane components can all run on one node, but in a highly available setup or a very large cluster, they may be spread across multiple nodes.

**API server**

The Kubernetes API server exposes the Kubernetes REST API. It can easily scale horizontally as it is stateless and stores all the data in the etcd cluster (or another data store in Kubernetes distributions like k3s). The API server is the embodiment of the Kubernetes control plane.

**etcd**

etcd is a highly reliable distributed data store. Kubernetes uses it to store the entire cluster state. In small, transient clusters a single instance of etcd can run on the same node with all the other control plane components. But, for more substantial clusters, it is typical to have a 3-node or even 5-node etcd cluster for redundancy and high availability.

**Kube controller manager**

The Kube controller manager is a collection of various managers rolled up into one binary. It contains the replica set controller, the pod controller, the service controller, the endpoints controller, and others. All these managers watch over the state of the cluster via the API, and their job is to steer the cluster into the desired state.

**Cloud controller manager**

When running in the cloud, Kubernetes allows cloud providers to integrate their platform for the purpose of managing nodes, routes, services, and volumes. The cloud provider code interacts with Kubernetes code. It replaces some of the functionality of the Kube controller manager. When running Kubernetes with a cloud controller manager you must set the Kube controller manager flag `--cloud-provider` to `external`. This will disable the control loops that the cloud controller manager is taking over.
