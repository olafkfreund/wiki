# AKS Cluster for Regulated Workloads

[GitHub: Azure Kubernetes Service (AKS) Baseline Cluster for Regulated Workloads](https://github.com/mspnp/aks-baseline-regulated) demonstrates the regulated infrastructure. This implementation provides a microservices application. It's included to help you experience the infrastructure and illustrate the network and security controls. The application does _not_ represent or implement an actual PCI DSS workload

**Network topology**

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-pci/images/network-topology.svg" alt=""><figcaption></figcaption></figure>

#### TLS encryption <a href="#tls-encryption" id="tls-encryption"></a>

The baseline architecture provides TLS-encrypted traffic until the ingress controller in the cluster, but pod-to-pod communication is in the clear. In this architecture, TLS extends to pods-to-pod traffic, with Certificate Authority (CA) validation. That TLS is provided by a service mesh, which enforces mTLS connections and verification before allowing communication.

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-pci/images/flow.svg" alt=""><figcaption></figcaption></figure>

### Kubernetes API Server operational access <a href="#kubernetes-api-server-operational-access" id="kubernetes-api-server-operational-access"></a>

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-pci/images/aks-jumpbox.svg" alt=""><figcaption></figcaption></figure>

You can limit commands executed against the cluster, without necessarily building an operational process based around jump boxes.
