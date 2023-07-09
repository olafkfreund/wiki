# Runtime Phase

### Kubernetes Security Best Practices: Runtime Phase[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes-security-best-practices-runtime-phase) <a href="#kubernetes-security-best-practices-runtime-phase" id="kubernetes-security-best-practices-runtime-phase"></a>

The runtime phase exposes containerized applications to a slew of new security challenges. Your goal here is to both gain visibility into your running environment and detect and respond to threats as they arise.

Proactively securing your containers and Kubernetes deployments at the build and deploy phases can greatly reduce the likelihood of security incidents at runtime and the subsequent effort needed to respond to them.

First, you must monitor the most security-relevant container activities, including:

* Process activity
* Network communications among containerized services
* Network communications between containerized services and external clients and servers

Observing container behavior to detect anomalies is generally easier in containers than in virtual machines because of the declarative nature of containers and Kubernetes. These attributes allow easier introspection into what you have deployed and its expected activity.

#### Use Pod Security Policies to prevent risky containers/Pods from being used[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-pod-security-policies-to-prevent-risky-containerspods-from-being-used) <a href="#use-pod-security-policies-to-prevent-risky-containerspods-from-being-used" id="use-pod-security-policies-to-prevent-risky-containerspods-from-being-used"></a>

PodSecurityPolicy is a cluster-level resources available in Kubernetes (via kubectl) that is highly recommended. You must enable the PodSecurityPolicy admission controller to use it. Given the nature of admission controllers, you must authorize at least one policy - otherwise no pods will be allowed to be created in the cluster.

Pod Security Policies address several critical security use cases, including:

* Preventing containers from running with privileged flag - this type of container will have most of the capabilities available to the underlying host. This flag also overwrites any rules you set using CAP DROP or CAP ADD.
* Preventing sharing of host PID/IPC namespace, networking, and ports - this step ensures proper isolation between Docker containers and the underlying host
* Limiting use of volume types - writable hostPath directory volumes, for example, allow containers to write to the filesystem in a manner that allows them to traverse the host filesystem outside the pathPrefix, so readOnly: true must be used
* Putting limits on host filesystem use
* Enforcing read only for root file system via the ReadOnlyRootFilesystem
* Preventing privilege escalation to root privileges
* Rejecting containers with root privileges
* Restricting Linux capabilities to bare minimum in adherence with least privilege principles

For more information on Pod security policies, refer to the documentation at [https://kubernetes.io/docs/concepts/policy/pod-security-policy/](https://kubernetes.io/docs/concepts/policy/pod-security-policy/).

#### Container Runtime Security[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#container-runtime-security) <a href="#container-runtime-security" id="container-runtime-security"></a>

Hardening containers at runtime gives security teams the ability to detect and respond to threats and anomalies while the containers or workloads are in a running state. This is typically carried out by intercepting the low-level system calls and looking for events that may indicate compromise. Some examples of events that should trigger an alert would include:

* A shell is run inside a container
* A container mounts a sensitive path from the host such as /proc
* A sensitive file is unexpectedly read in a running container such as /etc/shadow
* An outbound network connection is established
* Open source tools such as Falco from Sysdig are available to help operators get up an running with container runtime security by providing a large number of out-of-the-box detections as well as the flexibility to create custom rules.

#### Container Sandboxing[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#container-sandboxing) <a href="#container-sandboxing" id="container-sandboxing"></a>

Container runtimes typically are permitted to make direct calls to the host kernel then the kernel interacts with hardware and devices to respond to the request. Cgroups and namespaces exist to give containers a certain amount of isolation but the still kernel presents a large attack surface area. Often times in multi-tenant and highly untrusted clusters an additional layer of sandboxing is required to ensure container breakout and kernel exploits are not present. Below we will explore a few OSS technologies that help further isolate running containers from the host kernel:

* Kata Containers: Kata Containers is OSS project that uses stripped-down VMs to keep the resource footprint minimal and maximize performance to ultimately isolate containers further.
* gVisor : gVisor is a more lightweight than a VM (even stripped down). gVisor is its own independent kernel written in Go to sit in the middle of a container and the host kernel. Strong sandbox. gVisor supports \~70% of the linux system calls from the container but ONLY uses about 20 system calls to the host kernel.
* Firecracker: Firecracker super lightweight VM that runs in user space. Locked down by seccomp, cgroup and namespace policies so system calls are very limited. Firecracker is built with security in mind but may not support all Kubernetes or container runtime deployments.

#### Preventing containers from loading unwanted kernel modules[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#preventing-containers-from-loading-unwanted-kernel-modules) <a href="#preventing-containers-from-loading-unwanted-kernel-modules" id="preventing-containers-from-loading-unwanted-kernel-modules"></a>

The Linux kernel automatically loads kernel modules from disk if needed in certain circumstances, such as when a piece of hardware is attached or a filesystem is mounted. Of particular relevance to Kubernetes, even unprivileged processes can cause certain network-protocol-related kernel modules to be loaded, just by creating a socket of the appropriate type. This may allow an attacker to exploit a security hole in a kernel module that the administrator assumed was not in use.

To prevent specific modules from being automatically loaded, you can uninstall them from the node, or add rules to block them. On most Linux distributions, you can do that by creating a file such as /etc/modprobe.d/kubernetes-blacklist.conf with contents like:

```
# DCCP is unlikely to be needed, has had multiple serious
# vulnerabilities, and is not well-maintained.
blacklist dccp

# SCTP is not used in most Kubernetes clusters, and has also had
# vulnerabilities in the past.
blacklist sctp
```

To block module loading more generically, you can use a Linux Security Module (such as SELinux) to completely deny the module\_request permission to containers, preventing the kernel from loading modules for containers under any circumstances. (Pods would still be able to use modules that had been loaded manually, or modules that were loaded by the kernel on behalf of some more-privileged process.

#### Compare and analyze different runtime activity in pods of the same deployments[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#compare-and-analyze-different-runtime-activity-in-pods-of-the-same-deployments) <a href="#compare-and-analyze-different-runtime-activity-in-pods-of-the-same-deployments" id="compare-and-analyze-different-runtime-activity-in-pods-of-the-same-deployments"></a>

Containerized applications are replicated for high availability, fault tolerance, or scale reasons. Replicas should behave nearly identically; replicas with significant deviations from the others warrant further investigation. Integrate your Kubernetes security tool with other external systems (email, PagerDuty, Slack, Google Cloud Security Command Center, SIEMs \[security information and event management], etc.) and leverage deployment labels or annotations to alert the team responsible for a given application when a potential threat is detected. Commercial Kubernetes security vendors should support a wide array of integrations with external tools

#### Monitor network traffic to limit unnecessary or insecure communication[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#monitor-network-traffic-to-limit-unnecessary-or-insecure-communication) <a href="#monitor-network-traffic-to-limit-unnecessary-or-insecure-communication" id="monitor-network-traffic-to-limit-unnecessary-or-insecure-communication"></a>

Observe your active network traffic and compare that traffic to what is allowed based on your Kubernetes network policies. Containerized applications typically make extensive use of cluster networking, and observing active networking traffic is a good way to understand how applications interact with each other and identify unexpected communication.

At the same time, comparing the active traffic with what’s allowed gives you valuable information about what isn’t happening but is allowed. With that information, you can further tighten your allowed network policies so that it removes superfluous connections and decreases your attack surface.

Open source projects like [https://github.com/kinvolk/inspektor-gadget](https://github.com/kinvolk/inspektor-gadget) or [https://github.com/deepfence/PacketStreamer](https://github.com/deepfence/PacketStreamer) may help with this, and commercial security solutions provide varying degrees of container network traffic analysis.

#### If breached, scale suspicious pods to zero[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#if-breached-scale-suspicious-pods-to-zero) <a href="#if-breached-scale-suspicious-pods-to-zero" id="if-breached-scale-suspicious-pods-to-zero"></a>

Use Kubernetes native controls to contain a successful breach by automatically instructing Kubernetes to scale suspicious pods to zero or kill then restart instances of breached applications.

#### Rotate infrastructure credentials frequently[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#rotate-infrastructure-credentials-frequently) <a href="#rotate-infrastructure-credentials-frequently" id="rotate-infrastructure-credentials-frequently"></a>

The shorter the lifetime of a secret or credential the harder it is for an attacker to make use of that credential. Set short lifetimes on certificates and automate their rotation. Use an authentication provider that can control how long issued tokens are available and use short lifetimes where possible. If you use service account tokens in external integrations, plan to rotate those tokens frequently. For example, once the bootstrap phase is complete, a bootstrap token used for setting up nodes should be revoked or its authorization removed.

#### Receiving alerts for security updates and reporting vulnerabilities[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#receiving-alerts-for-security-updates-and-reporting-vulnerabilities) <a href="#receiving-alerts-for-security-updates-and-reporting-vulnerabilities" id="receiving-alerts-for-security-updates-and-reporting-vulnerabilities"></a>

Join the kubernetes-announce group (<[https://kubernetes.io/docs/reference/issues-security/security/](https://kubernetes.io/docs/reference/issues-security/security/)) for emails about security announcements. See the security reporting page ([https://kubernetes.io/docs/reference/issues-security/security](https://kubernetes.io/docs/reference/issues-security/security)) for more on how to report vulnerabilities.

#### Logging[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#logging) <a href="#logging" id="logging"></a>

Kubernetes supplies cluster-based logging, allowing to log container activity into a central log hub. When a cluster is created, the standard output and standard error output of each container can be ingested using a Fluentd agent running on each node into either Google Stackdriver Logging or into Elasticsearch and viewed with Kibana.

**Enable audit logging**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#enable-audit-logging)

The audit logger is a beta feature that records actions taken by the API for later analysis in the event of a compromise. It is recommended to enable audit logging and archive the audit file on a secure server

Ensure logs are monitoring for anomalous or unwanted API calls, especially any authorization failures (these log entries will have a status message “Forbidden”). Authorization failures could mean that an attacker is trying to abuse stolen credentials.

Managed Kubernetes providers, including GKE, provide access to this data in their cloud console and may allow you to set up alerts on authorization failures.

**AUDIT LOGS**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#audit-logs)

Audit logs can be useful for compliance as they should help you answer the questions of what happened, who did what and when. Kubernetes provides flexible auditing of kube-apiserver requests based on policies. These help you track all activities in chronological order.

Here is an example of an audit log:

```
{
  "kind":"Event",
  "apiVersion":"audit.k8s.io/v1beta1",
  "metadata":{ "creationTimestamp":"2019-08-22T12:00:00Z" },
  "level":"Metadata",
  "timestamp":"2019-08-22T12:00:00Z",
  "auditID":"23bc44ds-2452-242g-fsf2-4242fe3ggfes",
  "stage":"RequestReceived",
  "requestURI":"/api/v1/namespaces/default/persistentvolumeclaims",
  "verb":"list",
  "user": {
    "username":"user@example.org",
    "groups":[ "system:authenticated" ]
  },
  "sourceIPs":[ "172.12.56.1" ],
  "objectRef": {
    "resource":"persistentvolumeclaims",
    "namespace":"default",
    "apiVersion":"v1"
  },
  "requestReceivedTimestamp":"2019-08-22T12:00:00Z",
  "stageTimestamp":"2019-08-22T12:00:00Z"
}
```

**Define Audit Policies**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#define-audit-policies)

Audit policy defines rules about what events should be recorded and what data they should include. The audit policy object structure is defined in the audit.k8s.io API group. When an event is processed, it's compared against the list of rules in order. The first matching rule sets the "audit level" of the event.

The known audit levels are as follows:

* None - don't log events that match this rule.
* Metadata - log request metadata (requesting user, timestamp, resource, verb, etc.) but not request or response body.
* Request - log event metadata and request body but not response body. This does not apply for non-resource requests.
* RequestResponse - log event metadata, request and response bodies. This does not apply for non-resource requests.

You can pass a file with the policy to kube-apiserver using the --audit-policy-file flag. If the flag is omitted, no events are logged. Note that the rules field must be provided in the audit policy file. A policy with no (0) rules is treated as illegal.

**Understanding Logging**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#understanding-logging)

One main challenge with logging Kubernetes is understanding what logs are generated and how to use them. Let’s start by examining the Kubernetes logging architecture from a birds eye view.

**CONTAINER LOGGING**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#container-logging)

The first layer of logs that can be collected from a Kubernetes cluster are those being generated by your containerized applications.

* The easiest method for logging containers is to write to the standard output (stdout) and standard error (stderr) streams.

Manifest is as follows.

```
apiVersion: v1
kind: Pod
metadata:
name: example
spec:
containers:
  - name: example
image: busybox
args: [/bin/sh, -c, 'while true; do echo $(date); sleep 1; done']
```

To apply the manifest, run:

```
kubectl apply -f example.yaml
```

To take a look the logs for this container, run:

```
kubectl log <container-name> command.
```

* For persisting container logs, the common approach is to write logs to a log file and then use a sidecar container. As shown below in the pod configuration above, a sidecar container will run in the same pod along with the application container, mounting the same volume and processing the logs separately.

Pod Manifest is as follows:

```
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
  - name: example
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      while true;
      do
        echo "$(date)\n" >> /var/log/example.log;
        sleep 1;
      done
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  - name: sidecar
    image: busybox
    args: [/bin/sh, -c, 'tail -f /var/log/example.log']
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    emptyDir: {}
```

**NODE LOGGING**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#node-logging)

When a container running on Kubernetes writes its logs to stdout or stderr streams, the container engine streams them to the logging driver configured in Kubernetes.

In most cases, these logs will end up in the /var/log/containers directory on your host. Docker supports multiple logging drivers but unfortunately, driver configuration is not supported via the Kubernetes API.

Once a container is terminated or restarted, kubelet stores logs on the node. To prevent these files from consuming all of the host’s storage, the Kubernetes node implements a log rotation mechanism. When a container is evicted from the node, all containers with corresponding log files are evicted.

Depending on what operating system and additional services you’re running on your host machine, you might need to take a look at additional logs. For example, systemd logs can be retrieved using the following command:

```
journalctl -u
```

**CLUSTER LOGGING**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#cluster-logging)

On the level of the Kubernetes cluster itself, there is a long list of cluster components that can be logged as well as additional data types that can be used (events, audit logs). Together, these different types of data can give you visibility into how Kubernetes is performing as a ystem.

Some of these components run in a container, and some of them run on the operating system level (in most cases, a systemd service). The systemd services write to journald, and components running in containers write logs to the /var/log directory, unless the container engine has been configured to stream logs differently.

**Events**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#events)

Kubernetes events can indicate any Kubernetes resource state changes and errors, such as exceeded resource quota or pending pods, as well as any informational messages. Kubernetes events can indicate any Kubernetes resource state changes and errors, such as exceeded resource quota or pending pods, as well as any informational messages.

The following command returns all events within a specific namespace:

```
kubectl get events -n <namespace>

NAMESPACE LAST SEEN TYPE   REASON OBJECT MESSAGE
kube-system  8m22s  Normal   Scheduled            pod/metrics-server-66dbbb67db-lh865                                       Successfully assigned kube-system/metrics-server-66dbbb67db-lh865 to aks-agentpool-42213468-1
kube-system     8m14s               Normal    Pulling                   pod/metrics-server-66dbbb67db-lh865                                       Pulling image "aksrepos.azurecr.io/mirror/metrics-server-amd64:v0.2.1"
kube-system     7m58s               Normal    Pulled                    pod/metrics-server-66dbbb67db-lh865                                       Successfully pulled image "aksrepos.azurecr.io/mirror/metrics-server-amd64:v0.2.1"
kube-system     7m57s               Normal     Created                   pod/metrics-server-66dbbb67db-lh865                                       Created container metrics-server
kube-system     7m57s               Normal    Started                   pod/metrics-server-66dbbb67db-lh865                                       Started container metrics-server
kube-system     8m23s               Normal    SuccessfulCreate          replicaset/metrics-server-66dbbb67db             Created pod: metrics-server-66dbbb67db-lh865
```

The following command will show the latest events for this specific Kubernetes resource:

```
kubectl describe pod <pod-name>

Events:
  Type    Reason     Age   From                               Message
  ----    ------     ----  ----                               -------
  Normal  Scheduled  14m   default-scheduler                  Successfully assigned kube-system/coredns-7b54b5b97c-dpll7 to aks-agentpool-42213468-1
  Normal  Pulled     13m   kubelet, aks-agentpool-42213468-1  Container image "aksrepos.azurecr.io/mirror/coredns:1.3.1" already present on machine
  Normal  Created    13m   kubelet, aks-agentpool-42213468-1  Created container coredns
  Normal  Started    13m   kubelet, aks-agentpool-42213468-1  Started container coredns
```

### Final thoughts[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#final-thoughts) <a href="#final-thoughts" id="final-thoughts"></a>

#### Embed security earlier into the container lifecycle[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#embed-security-earlier-into-the-container-lifecycle) <a href="#embed-security-earlier-into-the-container-lifecycle" id="embed-security-earlier-into-the-container-lifecycle"></a>

You must integrate security earlier into the container lifecycle and ensure alignment and shared goals between security and DevOps teams. Security can (and should) be an enabler that allows your developers and DevOps teams to confidently build and deploy applications that are production-ready for scale, stability and security.

#### Use Kubernetes-native security controls to reduce operational risk[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-kubernetes-native-security-controls-to-reduce-operational-risk) <a href="#use-kubernetes-native-security-controls-to-reduce-operational-risk" id="use-kubernetes-native-security-controls-to-reduce-operational-risk"></a>

Leverage the native controls built into Kubernetes whenever available in order to enforce security policies so that your security controls don’t collide with the orchestrator. Instead of using a third-party proxy or shim to enforce network segmentation, as an example, use Kubernetes network policies to ensure secure network communication.

#### Leverage the context that Kubernetes provides to prioritize remediation efforts[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#leverage-the-context-that-kubernetes-provides-to-prioritize-remediation-efforts) <a href="#leverage-the-context-that-kubernetes-provides-to-prioritize-remediation-efforts" id="leverage-the-context-that-kubernetes-provides-to-prioritize-remediation-efforts"></a>

In sprawling Kubernetes environments, manually triaging security incidents and policy violations is time consuming.

For example, a deployment containing a vulnerability with severity score of 7 or greater should be moved up in remediation priority if that deployment contains privileged containers and is open to the Internet but moved down if it’s in a test environment and supporting a non-critical app.
