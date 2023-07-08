# Kubernetes kubectl

**Kubectl** is the command line configuration tool to interact with Kubernetes clusters using Kubernetes API server. kubectl allows users to create, inspect, update, and delete Kubernetes objects.

**Kubectl Characteristics**

* Kubectl can be pronounced as “cube CTL”, “kube control”, “cube cuttle”
* It is a is a robust CLI that runs commands against the Kubernetes cluster and controls the cluster manager
* kubectl is known as the swiss army knife of container orchestration and management
* kubectl is designed to make this process more comfortable and straightforward
* kubectl allows users to create, inspect, update, and delete Kubernetes objects
* Every Kubernetes command has an API endpoint, and kubectl’s primary purpose is to carry out HTTP requests to the API.

**Most Common Kubectl Commands:**

**Cluster Management:** A Kubernetes cluster is a set of nodes that run containerized applications. It allows containers to run across multiple machines and environments: virtual, physical, cloud-based, and on-premises. Following kubectl commands can be used to manage a cluster

* **kubectl cluster-info** : Display endpoint information about the master and services in the cluster
* **kubectl version** : Display the Kubernetes version running on the client and server
* **kubectl config view** : Get the configuration of the cluster
* **kubectl api-resource** : List the API resources that are available
* **kubectl api-versions** : List the API versions that are available
* **kubectl get all –all -namespaces :** List everything

**Listing Resources:** Kubernetes resources also known as Kubernetes objects associated to a specific namespace, you can either use individual kubectl get command to list down each resource one by one, or you can list down all the resources in a Kubernetes namespace by running a single command. Following are the list of commands to get the resources information.

* **kubectl get namespaces** : Generate a plain-text list of all namespaces:
* **kubectl get pods** : Generate a plain-text list of all pods
* **kubectl get pods -o wide** : Generate a detailed plain-text list of all pods
* **kubectl get pods–field-selector=spec. nodeName=\[server-name]** : Generate a list of all pods running on a particular node server
* **kubectl get replicationcontroller \[replication-controller-name]** : List a specific replication controller in plain text
* **kubectl get replicationcontroller, services :** Generate a plain-text list of all replication controllers and services

**Daemonsets :** A Daemonset ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a **DaemonSet** will clean up the Pods it created.

* **kubectl get daemonset** : List one or more daemonsets
* **kubectl edit daemonset \<daemonset\_name**> : Edit and update the definition of one or more daemonset
* **kubectl delete daemonset \<daemonset\_name>** : Delete a daemonset
* **kubectl create daemonset \<daemonset\_name>** : Create a new daemonset
* **kubectl rollout daemonset** : Manage the rollout of a daemonset
* **kubectl describe ds \<daemonset\_name> -n \<namespace\_name>** : Display the detailed state of daemonsets within a namespace

**Deployments :** A **Kubernetes Deployment** is used to tell **Kubernetes** how to create or modify instances of the pods that hold a containerized application. **Deployments** can scale the number of replica pods, enable rollout of updated code in a controlled manner, or roll back to an earlier **deployment** version if necessary.

* **kubectl get deployment** : List one or more deployments
* **kubectl describe deployment \<deployment\_name>** : Display the detailed state of one or more deployments
* **kubectl edit deployment \<deployment\_name>** : Edit and update the definition of one or more deployment on the server
* **kubectl create deployment \<deployment\_name>** : Create one a new deployment
* **kubectl delete deployment \<deployment\_name>** : Delete deployments
* **kubectl rollout status deployment \<deployment\_name>** : See the rollout status of a deployment

**Events:** Kubernetes **events** are objects that show you what is happening inside a cluster, such as what decisions were made by the scheduler or why some pods were evicted from the node. **Events** are the first thing to look at for application, as well as infrastructure operations when something is not working as expected. Following are the kubectl commands to get the events.

* **kubectl get events** : List recent events for all resources in the system
* **kubectl get events –field-selector type=Warning** : List Warnings only
* **kubectl get events –field-selector involvedObject.kind!=Pod** : List events but exclude Pod events
* **kubectl get events –field-selector involvedObject.kind=Node, involvedObject.name=\<node\_name>** : Pull events for a single node with a specific name
* **kubectl get events –field-selector type!=Normal** : Filter out normal events from a list of events

**Logs :** Kubernets logs commands can be used to monitor, logging and debugging the pods.

* **kubectl logs \<pod\_name>** : Print the logs for a pod
* **kubectl logs –since=1h \<pod\_name>** : Print the logs for the last hour for a pod
* **kubectl logs –tail=20 \<pod\_name>** : Get the most recent 20 lines of logs
* **kubectl logs -f \<service\_name> \[-c <$container>]** : Get logs from a service and optionally select which container
* **kubectl logs -f \<pod\_name>** : Print the logs for a pod and follow new logs
* **kubectl logs -c \<container\_name> \<pod\_name>** : Print the logs for a container in a pod
* **kubectl logs \<pod\_name> pod.log** : Output the logs for a pod into a file named ‘pod.log’
* **kubectl logs –previous \<pod\_name>** : View the logs for a previously failed pod

**Namespaces :** Namespaces are **Kubernetes objects** which partition a single Kubernetes cluster into multiple **virtual clusters**. Each **Kubernetes namespace** provides the scope for Kubernetes Names it contains; which means that using the combination of an object name and a Namespace, each object gets an **unique identity** across the cluster.

* **kubectl create namespace \<namespace\_name>** : Create namespace \<name>
* **kubectl get namespace \<namespace\_name>** : List one or more namespaces
* **kubectl describe namespace \<namespace\_name>** : Display the detailed state of one or more namespace
* **kubectl delete namespace \<namespace\_name>** : Delete a namespace
* **kubectl edit namespace \<namespace\_name>** : Edit and update the definition of a namespace
* **kubectl top namespace \<namespace\_name>** : Display Resource (CPU/Memory/Storage) usage for a namespace

**Node Operations:** A Node is a **worker machine** in Kubernetes and may be either a virtual or a physical machine, depending on the cluster. Each **Node** is managed by the control plane. A Node can have **multiple pods**, and the Kubernetes control plane automatically handles scheduling the pods across the Nodes in the **cluster**. Following commands can be used for Node Operations.

* **kubectl taint node \<node\_name>** : Update the taints on one or more nodes
* **kubectl get node** : List one or more nodes
* **kubectl delete node \<node\_name>** : Delete a node or multiple nodes
* **kubectl top node** : Display Resource usage (CPU/Memory/Storage) for nodes
* **kubectl describe nodes | grep Allocated -A 5** : Resource allocation per node
* **kubectl get pods -o wide | grep \<node\_name>** : Pods running on a node
* **kubectl annotate node \<node\_name>** : Annotate a node
* **kubectl cordon node \<node\_name>** : Mark a node as unschedulable
* **kubectl uncordon node \<node\_name>** : Mark node as schedulable
* **kubectl drain node \<node\_name>** : Drain a node in preparation for maintenance
* **kubectl label node** : Add or update the labels of one or more nodes

**Pods :** Pods are the atomic unit on the Kubernetes platform. When we create a Deployment on Kubernetes, it creates Pods with containers inside them. Each Pod is tied to the Node where it is scheduled and remains there until termination or deletion or restarted. Following kubectl command can be used for Pods Operations.

* **kubectl get pod** : List one or more pods
* **kubectl delete pod \<pod\_name>** : Delete a pod
* **kubectl create pod \<pod\_name>** : Create a pod
* **kubectl exec \<pod\_name> -c \<container\_name> \<command>** : Execute a command against a container in a pod
* **kubectl exec -it \<pod\_name> /bin/sh** : Get interactive shell on a a single-container pod
* **kubectl top pod** : Display Resource usage (CPU/Memory/Storage) for pods
* **kubectl describe pod \<pod\_name>** : Display the detailed state of a pods
* **kubectl annotate pod \<pod\_name> \<annotation>** : Add or update the annotations of a pod
* **kubectl label pod \<pod\_name>** : Add or update the label of a pod

**Replication Controllers and ReplicaSets**

* **kubectl get rc** : List the replication controllers
* **kubectl get rc –namespace=”\<namespace\_name>”** : List the replication controllers by namespace
* **kubectl get replicasets** : List ReplicaSets
* **kubectl describe replicasets \<replicaset\_name>** : Display the detailed state of one or more ReplicaSets
* **kubectl scale –replicas=\[x]** : Scale a ReplicaSet

**Secrets:** A **Kubernets Secret** is an object that contains a small amount of sensitive data such as a **password**, a token, or **a key**. Such information might otherwise be put in a Pod specification or in an image. Users can create Secrets and the system also creates some Secrets using following kubectl commands.

* **kubectl create secret** : Create a secret
* **kubectl get secrets** : List secrets
* **kubectl describe secrets** : List details about secrets
* **kubectl delete secret \<secret\_name>** : Delete a secret

**Services and Service Accounts:** A **Kubernetes service** is a logical abstraction for a deployed group of pods in a cluster (which all perform the same function) and Service accounts are used to provide an identity for pods. Pods that want to interact with the API server will authenticate with a particular service account.

* **kubectl get services :** List one or more services
* **kubectl describe services :** Display the detailed state of a service
* **kubectl expose deployment \[deployment\_name] :** Expose a replication controller, service, deployment or pod as a new Kubernetes service
* **kubectl edit services :** Edit and update the definition of one or more services
* **kubectl get serviceaccounts :** List service accounts
* **kubectl describe serviceaccounts :** Display the detailed state of one or more service accounts
* **kubectl replace serviceaccount :** Replace a service account
* **kubectl delete serviceaccount \<service\_account\_name> :** Delete a service account
* **kubectl get pod |grep -P ‘\s+(\[1–9]+)\\/\1\s+’** : List Pods in Ready Status
* **kubectl get pod |grep -Pv ‘\s+(\[1–9]+)\\/\1\s+’** : List Pods which are not Ready/Pending status
* **kubectl get pods -n namespacesort - -sort by=.metadata.creationTimestamp** : List Pods by Deployment timestamp (add -A for live listing)
* **kubectl get deployment -n namespace -o=jsonpath=”{range .items\[\*]}{‘\n’}{.metadata.name}{‘:\t’}{range .spec.template.spec.containers\[\*]}{.image}{‘, ‘}{end}{end}”** : List deployment Artifact/ Images in current namespace.
* **kubectl get deployment \<deployment\_name> -o=jsonpath=’{$.spec.template.spec.containers\[:1].image}’ :** Get Image version of current deployment.
* **kubectl get pod \<mutlti\_conatiner\_pod> -o go-template=’\{{range .status.containerStatuses\}}\{{printf “%s:\n%s\n\n” .name .lastState.terminated.message\}}\{{end\}}’** : List last terminated Status
* **kubectl logs \<pod\_name> \<conatiner\_name> -n namespace - -previous / kubectl logs - -previous ${POD\_NAME} ${CONTAINER\_NAME}** **:** List logs of previous state
* **kubectl logs - -selector app=\<app\_name> - -container \<conatiner\_name>** : Multi Pod logs
* **kubectl -n logs -f deployment/ - -all-containers=true - -since=10m** : list logs for last 10 mis
* **kubectl rollout history deployment/app** : Inspect the history of your Deployment
* **kubectl rollout undo deployment/app - -to-revision=2** : Rollback to a specific version
* **kubectl rollout undo deployment/\<deployment\_name>** : Rollback deployment to last version.
* **kubectl rollout restart -n namespace deployment/\<deployment\_name>:** Restart deployment.
* **kubectl describe pod | grep ‘Name:\\| Limits\\| Requests\\| cpu:\\| memory’** : List Memory and CPU limit of pod, replace pod with deployment to list deployment wise resource limits.
* **kubectl delete pod - -selector=project.app=\<app\_name> -n namespace** : Delete multiple pods with single command for a deployment.
* **kubectl delete pod \<pod\_name> -n namespace - -grace-period=0 - -force** : Force delete the pod
* **Kubectl top pod** : List down Pod resources CPU and Memory
* **kubectl top pod \<pod\_name> - -containers** : List Container wise resource usage
* **Kubectl top node** : List Node resource usage.
* **kubectl exec -it \<pod\_name> sh :** Shell into the pod
* **kubectl exec -it \<pod\_name> - -/bin/bash** : bash into the pod
* **kubectl edit ingress \<ingress\_name>** -n namespace : edit ingress file
* **kubectl create secret generic \<secret\_name> - -from-literal=Key=value - -from-literal=Key=User:** create a secret file at cluster level and keep adding - -from=literal for all Key values. example **kubectl create secret generic \<secret\_name> - -from-literal=DB\_name=ExampleDB - -from-literal=DB\_password=Ahdgakah**
