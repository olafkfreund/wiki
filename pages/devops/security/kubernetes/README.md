# Kubernetes

## Kubernetes Security Cheat Sheet[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes-security-cheat-sheet) <a href="#kubernetes-security-cheat-sheet" id="kubernetes-security-cheat-sheet"></a>

### Kubernetes[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes) <a href="#kubernetes" id="kubernetes"></a>

Kubernetes is an open source container orchestration engine for automating deployment, scaling, and management of containerized applications. The open source project is hosted by the Cloud Native Computing Foundation (CNCF).

When you deploy Kubernetes, you get a cluster. A Kubernetes cluster consists of a set of worker machines, called nodes that run containerized applications. The control plane manages the worker nodes and the Pods in the cluster.

#### Control Plane Components[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#control-plane-components) <a href="#control-plane-components" id="control-plane-components"></a>

The control plane's components make global decisions about the cluster, as well as detecting and responding to cluster events. It consists of components such as kube-apiserver, etcd, kube-scheduler, kube-controller-manager and cloud-controller-manager

| Component                | Description                                                                                                                                                                                                           |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| kube-apiserver           | kube-apiserver exposes the Kubernetes API. The API server is the front end for the Kubernetes control plane.                                                                                                          |
| etcd                     | etcd is a consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.                                                                                                     |
| kube-scheduler           | kube-scheduler watches for newly created Pods with no assigned node, and selects a node for them to run on.                                                                                                           |
| kube-controller-manager  | kube-controller-manager runs controller processes. Logically, each controller is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.                |
| cloud-controller-manager | The cloud controller manager lets you link your cluster into your cloud provider's API, and separates out the components that interact with that cloud platform from components that just interact with your cluster. |

#### Node Components[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#node-components) <a href="#node-components" id="node-components"></a>

Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment. It consists of components such as kubelet, kube-proxy and container runtime.

| Component         | Description                                                                                                               |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------- |
| kubelet           | kubelet is an agent that runs on each node in the cluster. It makes sure that containers are running in a Pod             |
| kube-proxy        | kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept |
| Container runtime | The container runtime is the software that is responsible for running containers.                                         |

![Kubernetes Architecture](https://cheatsheetseries.owasp.org/assets/Kubernetes\_Architecture.png)

This cheatsheet provides a starting point for securing Kubernetes cluster. It is divided into the following categories:

* Securing Kubernetes hosts
* Securing Kubernetes components
* Kubernetes Security Best Practices: Build Phase
* Kubernetes Security Best Practices: Deploy Phase
* Kubernetes Security Best Practices: Runtime Phase

### Securing Kubernetes hosts[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#securing-kubernetes-hosts) <a href="#securing-kubernetes-hosts" id="securing-kubernetes-hosts"></a>

There are several options available to deploy Kubernetes: on bare metal, on-premise, and in the public cloud (custom Kubernetes build on virtual machines OR use a managed service). Kubernetes was designed to be highly portable and customers can easily switch between these installations, migrating their workloads.

All of this potential customisation of Kubernetes means it can be designed to fit a large variety of scenarios; however, this is also its greatest weakness when it comes to security. Kubernetes is designed out of the box to be customizable and users must turn on certain functionality to secure their cluster. This means that the engineers responsible for deploying the Kubernetes platform need to know about all the potential attack vectors and vulnerabilities poor configuration can lead to.

It is recommended to harden the underlying hosts by installing the latest version of operating system, hardening the operating system, implement necessary patch management and configuration management system, implementing essential firewall rules and undertake specific security measures depending on the datacenter environment.

#### Kubernetes Version[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes-version) <a href="#kubernetes-version" id="kubernetes-version"></a>

It has become impossible to track all potential attack vectors. This fact is unfortunate as there is nothing more vital than to be aware and on top of potential threats. The best defense is to make sure that you are running the latest available version of Kubernetes.

The Kubernetes project maintains release branches for the most recent three minor releases and it backports the applicable fixes, including security fixes, to those three release branches, depending on severity and feasibility. Patch releases are cut from those branches at a regular cadence, plus additional urgent releases, when required. Hence it is always recommended to upgrade the Kubernetes cluster to the latest available stable version. It is recommended to refer to the version skew policy for further details [https://kubernetes.io/docs/setup/release/version-skew-policy/](https://kubernetes.io/docs/setup/release/version-skew-policy/).

There are several techniques such as rolling updates, and node pool migrations that allow you to complete an update with minimal disruption and downtime.

### Securing Kubernetes components[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#securing-kubernetes-components) <a href="#securing-kubernetes-components" id="securing-kubernetes-components"></a>

#### Control network access to sensitive ports[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#control-network-access-to-sensitive-ports) <a href="#control-network-access-to-sensitive-ports" id="control-network-access-to-sensitive-ports"></a>

Kubernetes clusters usually listen on a range of well-defined and distinctive ports which makes it easier identify the clusters and attack them. Hence it is highly recommended to configure authentication and authorization on the cluster and cluster nodes.

Here is an overview of the default ports used in Kubernetes. Make sure that your network blocks access to ports and consider limiting access to the Kubernetes API server except from trusted networks.

**Master node(s):**

| Protocol | Port Range | Purpose                 |
| -------- | ---------- | ----------------------- |
| TCP      | 6443-      | Kubernetes API Server   |
| TCP      | 2379-2380  | etcd server client API  |
| TCP      | 10250      | Kubelet API             |
| TCP      | 10251      | kube-scheduler          |
| TCP      | 10252      | kube-controller-manager |
| TCP      | 10255      | Read-Only Kubelet API   |

**Worker nodes:**

| Protocol | Port Range  | Purpose               |
| -------- | ----------- | --------------------- |
| TCP      | 10250       | Kubelet API           |
| TCP      | 10255       | Read-Only Kubelet API |
| TCP      | 30000-32767 | NodePort Services     |

### Limit Direct Access to Kubernetes Nodes[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#limit-direct-access-to-kubernetes-nodes) <a href="#limit-direct-access-to-kubernetes-nodes" id="limit-direct-access-to-kubernetes-nodes"></a>

You should limit SSH access to Kubernetes nodes, reducing the risk for unauthorized access to host resource. Instead you should ask users to use "kubectl exec", which will provide direct access to the container environment without the ability to access the host.

You can use Kubernetes Authorization Plugins to further control user access to resources. This allows defining fine-grained-access control rules for specific namespace, containers and operations.

#### Controlling access to the Kubernetes API[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#controlling-access-to-the-kubernetes-api) <a href="#controlling-access-to-the-kubernetes-api" id="controlling-access-to-the-kubernetes-api"></a>

The Kubernetes platform is controlled using API requests and as such is the first line of defense against attackers. Controlling who has access and what actions they are allowed to perform is the primary concern. For more information, refer to the documentation at [https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/](https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/).

#### Use Transport Layer Security[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-transport-layer-security) <a href="#use-transport-layer-security" id="use-transport-layer-security"></a>

Communication in the cluster between services should be handled using TLS, encrypting all traffic by default. This, however, is often overlooked with the thought being that the cluster is secure and there is no need to provide encryption in transit within the cluster.

Advances in network technology, such as the service mesh, have led to the creation of products like LinkerD and Istio which can enable TLS by default while providing extra telemetry information on transactions between services.

Kubernetes expects that all API communication in the cluster is encrypted by default with TLS, and the majority of installation methods will allow the necessary certificates to be created and distributed to the cluster components. Note that some components and installation methods may enable local ports over HTTP and administrators should familiarize themselves with the settings of each component to identify potentially unsecured traffic.

To learn more on usage of TLS in Kubernetes cluster, refer to the documentation at [https://kubernetes.io/blog/2018/07/18/11-ways-not-to-get-hacked/#1-tls-everywhere](https://kubernetes.io/blog/2018/07/18/11-ways-not-to-get-hacked/#1-tls-everywhere).

#### API Authentication[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#api-authentication) <a href="#api-authentication" id="api-authentication"></a>

Kubernetes provides a number of in-built mechanisms for API server authentication, however these are likely only suitable for non-production or small clusters.

* [Static Token File](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#static-token-file) authentication makes use of clear text tokens stored in a CSV file on API server node(s). Modifying credentials in this file requires an API server re-start to be effective.
* [X509 Client Certs](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs) are available as well however these are unsuitable for production use, as Kubernetes does [not support certificate revocation](https://github.com/kubernetes/kubernetes/issues/18982) meaning that user credentials cannot be modified or revoked without rotating the root certificate authority key and re-issuing all cluster certificates.
* [Service Accounts Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens) are also available for authentication. Their primary intended use is to allow workloads running in the cluster to authenticate to the API server, however they can also be used for user authentication.

The recommended approach for larger or production clusters, is to use an external authentication method:

* [OpenID Connect](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens) (OIDC) lets you externalize authentication, use short lived tokens, and leverage centralized groups for authorization.
* Managed Kubernetes distributions such as GKE, EKS and AKS support authentication using credentials from their respective IAM providers.
* [Kubernetes Impersonation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation) can be used with both managed cloud clusters and on-prem clusters to externalize authentication without having to have access to the API server configuration parameters.

In addition to choosing the appropriate authentication system, API access should be considered privileged and use Multi-Factor Authentication (MFA) for all user access.

For more information, consult Kubernetes authentication reference document at [https://kubernetes.io/docs/reference/access-authn-authz/authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication)

#### API Authorization - Implement role-based access control[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#api-authorization-implement-role-based-access-control) <a href="#api-authorization-implement-role-based-access-control" id="api-authorization-implement-role-based-access-control"></a>

In Kubernetes, you must be authenticated (logged in) before your request can be authorized (granted permission to access). Kubernetes expects attributes that are common to REST API requests. This means that Kubernetes authorization works with existing organization-wide or cloud-provider-wide access control systems which may handle other APIs besides the Kubernetes API.

Kubernetes authorizes API requests using the API server. It evaluates all of the request attributes against all policies and allows or denies the request. All parts of an API request must be allowed by some policy in order to proceed. This means that permissions are denied by default.

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within your organization.

Kubernetes ships an integrated Role-Based Access Control (RBAC) component that matches an incoming user or group to a set of permissions bundled into roles. These permissions combine verbs (get, create, delete) with resources (pods, services, nodes) and can be namespace or cluster scoped. A set of out of the box roles are provided that offer reasonable default separation of responsibility depending on what actions a client might want to perform. It is recommended that you use the Node and RBAC authorizers together, in combination with the NodeRestriction admission plugin.

RBAC authorization uses the rbac.authorization.k8s.io API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API. To enable RBAC, start the API server with the --authorization-mode flag set to a comma-separated list that includes RBAC; for example:

```
kube-apiserver --authorization-mode=Example,RBAC --other-options --more-options
```

For detailed examples of utilizing RBAC, refer to Kubernetes documentation at [https://kubernetes.io/docs/reference/access-authn-authz/rbac](https://kubernetes.io/docs/reference/access-authn-authz/rbac)

#### Restrict access to etcd[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#restrict-access-to-etcd) <a href="#restrict-access-to-etcd" id="restrict-access-to-etcd"></a>

etcd is a critical Kubernetes component which stores information on state and secrets, and it should be protected differently from the rest of your cluster. Write access to the API server's etcd is equivalent to gaining root on the entire cluster, and even read access can be used to escalate privileges fairly easily.

The Kubernetes scheduler will search etcd for pod definitions that do not have a node. It then sends the pods it finds to an available kubelet for scheduling. Validation for submitted pods is performed by the API server before it writes them to etcd, so malicious users writing directly to etcd can bypass many security mechanisms - e.g. PodSecurityPolicies.

Administrators should always use strong credentials from the API servers to their etcd server, such as mutual auth via TLS client certificates, and it is often recommended to isolate the etcd servers behind a firewall that only the API servers may access.

**Caution**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#caution)

Allowing other components within the cluster to access the master etcd instance with read or write access to the full keyspace is equivalent to granting cluster-admin access. Using separate etcd instances for non-master components or using etcd ACLs to restrict read and write access to a subset of the keyspace is strongly recommended.

#### Controlling access to the Kubelet[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#controlling-access-to-the-kubelet) <a href="#controlling-access-to-the-kubelet" id="controlling-access-to-the-kubelet"></a>

Kubelets expose HTTPS endpoints which grant powerful control over the node and containers. By default Kubelets allow unauthenticated access to this API. Production clusters should enable Kubelet authentication and authorization.

For more information, refer to Kubelet authentication/authorization documentation at [https://kubernetes.io/docs/reference/access-authn-authz/kubelet-authn-authz/](https://kubernetes.io/docs/reference/access-authn-authz/kubelet-authn-authz/)

#### Securing Kubernetes Dashboard[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#securing-kubernetes-dashboard) <a href="#securing-kubernetes-dashboard" id="securing-kubernetes-dashboard"></a>

The Kubernetes dashboard is a webapp for managing your cluster. It is not a part of the Kubernetes cluster itself, it has to be installed by the owners of the cluster. Thus, there are a lot of tutorials on how to do this. Unfortunately, most of them create a service account with very high privileges. This caused Tesla and some others to be hacked via such a poorly configured K8s dashboard. (Reference: Tesla cloud resources are hacked to run cryptocurrency-mining malware - [https://arstechnica.com/information-technology/2018/02/tesla-cloud-resources-are-hacked-to-run-cryptocurrency-mining-malware/](https://arstechnica.com/information-technology/2018/02/tesla-cloud-resources-are-hacked-to-run-cryptocurrency-mining-malware/))

To prevent attacks via the dashboard, you should follow some tips:

* Do not expose the dashboard without additional authentication to the public. There is no need to access such a powerful tool from outside your LAN
* Turn on RBAC, so you can limit the service account the dashboard uses
* Do not grant the service account of the dashboard high privileges
* Grant permissions per user, so each user only can see what they are supposed to see
* If you are using network policies, you can block requests to the dashboard even from internal pods (this will not affect the proxy tunnel via kubectl proxy)
* Before version 1.8, the dashboard had a service account with full privileges, so check that there is no role binding for cluster-admin left.
* Deploy the dashboard with an authenticating reverse proxy, with multi-factor authentication enabled. This can be done with either embedded OIDC `id_tokens` or using Kubernetes Impersonation. This allows you to use the dashboard with the user's credentials instead of using a privileged `ServiceAccount`. This method can be used on both on-prem and managed cloud clusters.
