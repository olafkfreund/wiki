# Deploy Phase

### Kubernetes Security Best Practices: Deploy Phase[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes-security-best-practices-deploy-phase) <a href="#kubernetes-security-best-practices-deploy-phase" id="kubernetes-security-best-practices-deploy-phase"></a>

Kubernetes infrastructure should be configured securely prior to workloads being deployed. From a security perspective, you first need visibility into what you’re deploying – and how. Then you can identify and respond to security policy violations. At a minimum, you need to know:

* What is being deployed - including information about the image being used, such as components or vulnerabilities, and the pods that will be deployed
* Where it is going to be deployed - which clusters, namespaces, and nodes
* How it is deployed - whether it runs privileged, what other deployments it can communicate with, the pod security context that is applied, if any
* What it can access - including secrets, volumes, and other infrastructure components such as the host or orchestrator API
* Is it compliant - whether it complies with your policies and security requirements

#### Use Kubernetes namespaces to properly isolate your Kubernetes resources[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-kubernetes-namespaces-to-properly-isolate-your-kubernetes-resources) <a href="#use-kubernetes-namespaces-to-properly-isolate-your-kubernetes-resources" id="use-kubernetes-namespaces-to-properly-isolate-your-kubernetes-resources"></a>

Namespaces give you the ability to create logical partitions and enforce separation of your resources as well as limit the scope of user permissions.

**Setting the namespace for a request**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#setting-the-namespace-for-a-request)

To set the namespace for a current request, use the --namespace flag. Refer to the following examples:

```plaintext
kubectl run nginx --image=nginx --namespace=<insert-namespace-name-here>
kubectl get pods --namespace=<insert-namespace-name-here>
```plaintext

**Setting the namespace preference**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#setting-the-namespace-preference)

You can permanently save the namespace for all subsequent kubectl commands in that context.

```plaintext
kubectl config set-context --current --namespace=<insert-namespace-name-here>
```plaintext

Validate it with the following command.

```plaintext
kubectl config view --minify | grep namespace:
```plaintext

Learn more about namespaces at [https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces)

#### Create policies to govern image provenance using the ImagePolicyWebhook[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#create-policies-to-govern-image-provenance-using-the-imagepolicywebhook) <a href="#create-policies-to-govern-image-provenance-using-the-imagepolicywebhook" id="create-policies-to-govern-image-provenance-using-the-imagepolicywebhook"></a>

Prevent unapproved images from being used with the admission controller ImagePolicyWebhook to reject pods that use unapproved images including:

* Images that haven’t been scanned recently
* Images that use a base image that’s not explicitly allowed
* Images from insecure registries Learn more about webhook at [https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook)

#### Implement Continuous Security Vulnerability Scanning[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#implement-continuous-security-vulnerability-scanning) <a href="#implement-continuous-security-vulnerability-scanning" id="implement-continuous-security-vulnerability-scanning"></a>

New vulnerabilities are published every day and containers might include outdated packages with recently-disclosed vulnerabilities (CVEs). A strong security posture will include regular production scanning, covering first-party containers (applications you have built and previously scanned) and third-party containers (sourced from trusted repository and vendors).

Open Source projects such as [ThreatMapper](https://github.com/deepfence/ThreatMapper) can assist in identifying and prioritizing vulnerabilities.

#### Regularly Apply Security Updates to Your Environment[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#regularly-apply-security-updates-to-your-environment) <a href="#regularly-apply-security-updates-to-your-environment" id="regularly-apply-security-updates-to-your-environment"></a>

In case vulnerabilities are found in running containers, it is recommended to always update the source image and redeploy the containers.

**NOTE**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#note)

Try to avoid direct updates to the running containers as this can break the image-container relationship.

```plaintext
Example: apt-update  
```plaintext

Upgrading containers is extremely easy with the Kubernetes rolling updates feature - this allows gradually updating a running application by upgrading its images to the latest version.

#### Assess the privileges used by containers[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#assess-the-privileges-used-by-containers) <a href="#assess-the-privileges-used-by-containers" id="assess-the-privileges-used-by-containers"></a>

The set of capabilities, role bindings, and privileges given to containers can greatly impact your security risk. The goal here is to adhere to the principle of least privilege and provide the minimum privileges and capabilities that would allow the container to perform its intended function.

Pod Security Policies are one way to control the security-related attributes of pods, including container privilege levels. These can allow an operator to specify the following:

* Do not run application processes as root.
* Do not allow privilege escalation.
* Use a read-only root filesystem.
* Use the default (masked) /proc filesystem mount
* Do not use the host network or process space - using "hostNetwork:true" will cause NetworkPolicies to be ignored since the Pod will use its host network.
* Drop unused and unnecessary Linux capabilities.
* Use SELinux options for more fine-grained process controls.
* Give each application its own Kubernetes Service Account.
* Do not mount the service account credentials in a container if it does not need to access the Kubernetes API.

For more information on Pod security policies, refer to the documentation at [https://kubernetes.io/docs/concepts/policy/pod-security-policy/](https://kubernetes.io/docs/concepts/policy/pod-security-policy/).

#### Apply Security Context to Your Pods and Containers[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#apply-security-context-to-your-pods-and-containers) <a href="#apply-security-context-to-your-pods-and-containers" id="apply-security-context-to-your-pods-and-containers"></a>

A security context is a property defined in the deployment yaml. It controls the security parameters that will be assigned to the pod/container/volume. These controls can eliminate entire classes of attacks that depend on privileged access. Read-only root file systems, for example, can prevent any attack that depends on installing software or writing to the file system.

When designing your containers and pods, make sure that you configure the security context for your pods, containers and volumes to grant only the privileges needed for the resource to function. Some of the important parameters are as follows:

| Security Context Setting                | Description                                                                  |
| --------------------------------------- | ---------------------------------------------------------------------------- |
| SecurityContext->runAsNonRoot           | Indicates that containers should run as non-root user                        |
| SecurityContext->Capabilities           | Controls the Linux capabilities assigned to the container.                   |
| SecurityContext->readOnlyRootFilesystem | Controls whether a container will be able to write into the root filesystem. |
| PodSecurityContext->runAsNonRoot        | Prevents running a container with 'root' user as part of the pod             |

Here is an example for pod definition with security context parameters:

```plaintext
apiVersion: v1  
kind: Pod  
metadata:  
  name: hello-world  
spec:  
  containers:  
  # specification of the pod’s containers  
  # ...
  # ...
  # Security Context
  securityContext:  
    readOnlyRootFilesystem: true  
    runAsNonRoot: true
```plaintext

For more information on security context for Pods, refer to the documentation at [https://kubernetes.io/docs/tasks/configure-pod-container/security-context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context)

#### Implement Service Mesh[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#implement-service-mesh) <a href="#implement-service-mesh" id="implement-service-mesh"></a>

A service mesh is an infrastructure layer for microservices applications that can help reduce the complexity of managing microservices and deployments by handling infrastructure service communication quickly, securely and reliably. Service meshes are great at solving operational challenges and issues when running containers and microservices because they provide a uniform way to secure, connect and monitor microservices. Service mesh provides the following advantages:

**Observability**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#observability)

Service Mesh provides tracing and telemetry metrics that make it easy to understand your system and quickly root cause any problems.

**Security**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#security)

A service mesh provides security features aimed at securing the services inside your network and quickly identifying any compromising traffic entering your cluster. A service mesh can help you more easily manage security through mTLS, ingress and egress control, and more.

* mTLS and Why it Matters

Securing microservices is hard. There are a multitude of tools that address microservices security, but service mesh is the most elegant solution for addressing encryption of on-the-wire traffic within the network.

Service mesh provides defense with mutual TLS (mTLS) encryption of the traffic between your services. The mesh can automatically encrypt and decrypt requests and responses, removing that burden from the application developer. It can also improve performance by prioritizing the reuse of existing, persistent connections, reducing the need for the computationally expensive creation of new ones. With service mesh, you can secure traffic over the wire and also make strong identity-based authentication and authorizations for each microservice.

We see a lot of value in this for enterprise companies. With a good service mesh, you can see whether mTLS is enabled and working between each of your services and get immediate alerts if security status changes.

* Ingress & Egress Control

Service mesh adds a layer of security that allows you to monitor and address compromising traffic as it enters the mesh. Istio integrates with Kubernetes as an ingress controller and takes care of load balancing for ingress. This allows you to add a level of security at the perimeter with ingress rules. Egress control allows you to see and manage external services and control how your services interact with them.

**Operational Control**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#operational-control)

A service mesh allows security and platform teams to set the right macro controls to enforce access controls, while allowing developers to make customizations they need to move quickly within these guardrails.

**RBAC**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#rbac)

A strong Role Based Access Control (RBAC) system is arguably one of the most critical requirements in large engineering organizations, since even the most secure system can be easily circumvented by overprivileged users or employees. Restricting privileged users to least privileges necessary to perform job responsibilities, ensuring access to systems are set to “deny all” by default, and ensuring proper documentation detailing roles and responsibilities are in place is one of the most critical security concerns in the enterprise.

**Disadvantages**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#disadvantages)

Along with the many advantages, Service mesh also brings in its set of challenges, few of them are listed below:

* Added Complexity: The introduction of proxies, sidecars and other components into an already sophisticated environment dramatically increases the complexity of development and operations.
* Required Expertise: Adding a service mesh such as Istio on top of an orchestrator such as Kubernetes often requires operators to become experts in both technologies.
* Slowness: Service meshes are an invasive and intricate technology that can add significant slowness to an architecture.
* Adoption of a Platform: The invasiveness of service meshes force both developers and operators to adapt to a highly opinionated platform and conform to its rules.

#### Implementing centralized policy management[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#implementing-centralized-policy-management) <a href="#implementing-centralized-policy-management" id="implementing-centralized-policy-management"></a>

There are numerous projects which are able to provide centralized policy management for a Kubernetes cluster, most predominantly the [Open Policy Agent](https://www.openpolicyagent.org/) (OPA) project, [Kyverno](https://kyverno.io/), or [Validating Admission Policy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) (a built-in, yet alpha (aka off by default) feature as of 1.26). In order to provide some depth, we will focus on OPA for the remainder of this cheat sheet.

OPA is a project that started in 2016 aimed at unifying policy enforcement across different technologies and systems. It can be used to enforce policies on their platforms (like Kubernetes clusters). When it comes to Kubernetes, RBAC and Pod security policies to impose fine-grained control over the cluster. But again, this will only apply to the cluster but not outside the cluster. That’s where Open Policy Agent (OPA) comes into play. OPA was introduced to create a unified method of enforcing security policy in the stack.

OPA is a general-purpose, domain-agnostic policy enforcement tool. It can be integrated with APIs, the Linux SSH daemon, an object store like CEPH, etc. OPA designers purposefully avoided basing it on any other project. Accordingly, the policy query and decision do not follow a specific format. That is, you can use any valid JSON data as request attributes as long as it provides the required data. Similarly, the policy decision coming from OPA can also be any valid JSON data. You choose what gets input and what gets output. For example, you can opt to have OPA return a True or False JSON object, a number, a string, or even a complex data object. Currently, OPA is part of CNCF as an incubating project.

Most common use cases of OPA:

* Application authorization

OPA enables you to accelerate time to market by providing pre-cooked authorization technology so you don’t have to develop it from scratch. It uses a declarative policy language purpose built for writing and enforcing rules such as, “Alice can write to this repository,” or “Bob can update this account.” It comes with a rich suite of tooling to help developers integrate those policies into their applications and even allow the application’s end users to contribute policy for their tenants as well.

If you have homegrown application authorization solutions in place, you may not want to rip them out to swap in OPA. At least not yet. But if you are going to be decomposing those monolithic apps and moving to microservices to scale and improve developer efficiency, you’re going to need a distributed authorization system and OPA (or one of the related competitors) could be the answer.

* Kubernetes admission control

Kubernetes has given developers tremendous control over the traditional silos of compute, networking and storage. Developers today can set up the network the way they want and set up storage the way they want. Administrators and security teams responsible for the well-being of a given container cluster need to make sure developers don’t shoot themselves (or their neighbors) in the foot.

OPA can be used to build policies that require, for example, all container images to be from trusted sources, that prevent developers from running software as root, that make sure storage is always marked with the encrypt bit, that storage does not get deleted just because a pod gets restarted, that limits internet access, etc.

OPA integrates directly into the Kubernetes API server, so it has complete authority to reject any resource—whether compute, networking, storage, etc.—that policy says doesn’t belong in a cluster. Moreover, you can expose those policies earlier in the development lifecycle (e.g. the CICD pipeline or even on developer laptops) so that developers can receive feedback as early as possible. You can even run policies out-of-band to monitor results so that administrators can ensure policy changes don’t inadvertently do more damage than good.

* Service mesh authorization

And finally, many organizations are using OPA to regulate use of service mesh architectures. So, even if you’re not embedding OPA to implement application authorization logic (the top use case discussed above), you probably still want control over the APIs microservices. You can execute and achieve that by putting authorization policies into the service mesh. Or, you may be motivated by security, and implement policies in the service mesh to limit lateral movement within a microservice architecture. Another common practice is to build policies into the service mesh to ensure your compliance regulations are satisfied even when modification to source code is involved.

#### Limiting resource usage on a cluster[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#limiting-resource-usage-on-a-cluster) <a href="#limiting-resource-usage-on-a-cluster" id="limiting-resource-usage-on-a-cluster"></a>

Resource quota limits the number or capacity of resources granted to a namespace. This is most often used to limit the amount of CPU, memory, or persistent disk a namespace can allocate, but can also control how many pods, services, or volumes exist in each namespace.

Limit ranges restrict the maximum or minimum size of some of the resources above, to prevent users from requesting unreasonably high or low values for commonly reserved resources like memory, or to provide default limits when none are specified

An option of running resource-unbound containers puts your system in risk of DoS or “noisy neighbor” scenarios. To prevent and minimize those risks you should define resource quotas. By default, all resources in Kubernetes cluster are created with unbounded CPU and memory requests/limits. You can create resource quota policies, attached to Kubernetes namespace, in order to limit the CPU and memory a pod is allowed to consume.

The following is an example for namespace resource quota definition that will limit number of pods in the namespace to 4, limiting their CPU requests between 1 and 2 and memory requests between 1GB to 2GB.

compute-resources.yaml:

```plaintext
apiVersion: v1  
kind: ResourceQuota  
metadata:  
  name: compute-resources  
spec:  
  hard:  
    pods: "4"  
    requests.cpu: "1"  
    requests.memory: 1Gi  
    limits.cpu: "2"  
    limits.memory: 2Gi
```plaintext

Assign a resource quota to namespace:

```plaintext
kubectl create -f ./compute-resources.yaml --namespace=myspace
```plaintext

For more information on configuring resource quotas, refer to the Kubernetes documentation at [https://kubernetes.io/docs/concepts/policy/resource-quotas/](https://kubernetes.io/docs/concepts/policy/resource-quotas/).

#### Use Kubernetes network policies to control traffic between pods and clusters[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-kubernetes-network-policies-to-control-traffic-between-pods-and-clusters) <a href="#use-kubernetes-network-policies-to-control-traffic-between-pods-and-clusters" id="use-kubernetes-network-policies-to-control-traffic-between-pods-and-clusters"></a>

Running different applications on the same Kubernetes cluster creates a risk of one compromised application attacking a neighboring application. Network segmentation is important to ensure that containers can communicate only with those they are supposed to.

By default, Kubernetes allows every pod to contact every other pod. Traffic to a pod from an external network endpoint outside the cluster is allowed if ingress from that endpoint is allowed to the pod. Traffic from a pod to an external network endpoint outside the cluster is allowed if egress is allowed from the pod to that endpoint.

Network segmentation policies are a key security control that can prevent lateral movement across containers in the case that an attacker breaks in. One of the challenges in Kubernetes deployments is creating network segmentation between pods, services and containers. This is a challenge due to the “dynamic” nature of container network identities (IPs), along with the fact that containers can communicate both inside the same node or between nodes.

Users of Google Cloud Platform can benefit from automatic firewall rules, preventing cross-cluster communication. A similar implementation can be deployed on-premises using network firewalls or SDN solutions. There is work being done in this area by the Kubernetes Network SIG, which will greatly improve the pod-to-pod communication policies. A new network policy API should address the need to create firewall rules around pods, limiting the network access that a containerized can have.

The following is an example of a network policy that controls the network for “backend” pods, only allowing inbound network access from “frontend” pods:

```plaintext
POST /apis/net.alpha.kubernetes.io/v1alpha1/namespaces/tenant-a/networkpolicys  
{  
  "kind": "NetworkPolicy",
  "metadata": {
    "name": "pol1"
  },
  "spec": {
    "allowIncoming": {
      "from": [{
        "pods": { "segment": "frontend" }
      }],
      "toPorts": [{
        "port": 80,
        "protocol": "TCP"
      }]
    },
    "podSelector": {
      "segment": "backend"
    }
  }
}
```plaintext

For more information on configuring network policies, refer to the Kubernetes documentation at [https://kubernetes.io/docs/concepts/services-networking/network-policies](https://kubernetes.io/docs/concepts/services-networking/network-policies).

#### Securing data[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#securing-data) <a href="#securing-data" id="securing-data"></a>

**Keep secrets as secrets**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#keep-secrets-as-secrets)

In Kubernetes, a Secret is a small object that contains sensitive data, like a password or token. It is important to understand how sensitive data such as credentials and keys are stored and accessed. Even though a pod is not able to access the secrets of another pod, it is crucial to keep the secret separate from an image or pod. Otherwise, anyone with access to the image would have access to the secret as well. Complex applications that handle multiple processes and have public access are especially vulnerable in this regard. It is best for secrets to be mounted into read-only volumes in your containers, rather than exposing them as environment variables.

**Encrypt secrets at rest**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#encrypt-secrets-at-rest)

The etcd database in general contains any information accessible via the Kubernetes API and may grant an attacker significant visibility into the state of your cluster.

Always encrypt your backups using a well reviewed backup and encryption solution, and consider using full disk encryption where possible.

Kubernetes supports encryption at rest, a feature introduced in 1.7, and v1 beta since 1.13. This will encrypt Secret resources in etcd, preventing parties that gain access to your etcd backups from viewing the content of those secrets. While this feature is currently beta, it offers an additional level of defense when backups are not encrypted or an attacker gains read access to etcd.

**Alternatives to Kubernetes Secret resources**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#alternatives-to-kubernetes-secret-resources)

You may want to consider using an external secrets manager to store and manage your secrets rather than storing them in Kubernetes Secrets. This provides a number of benefits over using Kubernetes Secrets, including the ability to manage secrets across multiple clusters (or clouds), and the ability to manage and rotate secrets centrally.

For more information on Secrets and their alternatives, refer to the documentation at [https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/).

Also see the [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets\_Management\_Cheat\_Sheet.html) cheat sheet for more details and best practices on managing secrets.

**Finding exposed secrets**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#finding-exposed-secrets)

Open-source tools such as [SecretScanner](https://github.com/deepfence/SecretScanner) and [ThreatMapper](https://github.com/deepfence/ThreatMapper) can scan container filesystems for sensitive resources, such as API tokens, passwords, and keys. Such resources would be accessible to any user who had access to the unencrypted container filesystem, whether during build, at rest in a registry or backup, or running.

Review the secret material present on the container against the principle of 'least priviledge', and to assess the risk posed by a compromise.
