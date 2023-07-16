# Kubernetes Pod Troubleshooting Commands

**List all Pods in all Namespaces:** To get an overview of all pods across all namespaces, use the following command:

```sh
kubectl get pods --all-namespaces
```

**Check Resource Consumption:** To identify which pod is consuming the most memory or CPU resources, you can utilize the `kubectl top` command:

```sh
kubectl top pods --all-namespaces
```

**Describe a Pod:** To obtain detailed information about a specific pod, including its current status, events, and conditions, use the `kubectl describe pod` command:

```sh
kubectl describe pod <pod-name> -n <namespace>
```

**View Pod Logs:** To view the logs of a specific pod, you can employ the `kubectl logs` command:

```shell
kubectl logs <pod-name> -n <namespace>
```

**Follow Pod Logs:** If you want to continuously stream the logs of a pod in real-time, use the `-f` flag:

```sh
kubectl logs -f <pod-name> -n <namespace>
```

**Exec into a Pod:** To execute a command directly within a running pod container, use the `kubectl exec` command:

```shell
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

**Get Events for a Pod:** To view the events associated with a particular pod, including creation, scheduling, and error events, use the `kubectl describe pod` command along with the `--events` flag:

```shell
kubectl describe pod <pod-name> -n <namespace> --events
```

**Check Pod Health:** To check the readiness and liveness probe status of a pod, you can inspect the `Conditions` section of the pod's description:

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i conditions
```

**Retrieve Pod IP and Node:** To obtain the IP address and node assignment of a pod, you can execute the following command:

```sh
kubectl get pod <pod-name> -n <namespace> -o wide
```

**Restart a Pod:** To restart a pod, you can delete and recreate it using the

```sh
kubectl delete pod <pod-name> -n <namespace>
```

**Check Pod Status:** To check the status of a pod, use the `kubectl get pod` command:

```shell
kubectl get pod <pod-name> -n <namespace> -o wide
```

**List Pod Events:** To list the events related to a pod, use the `kubectl get events` command and filter by the pod's name

```sh
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>
```

**Verify Pod Affinity/Anti-Affinity:** To validate if a pod is scheduled on a node based on affinity or anti-affinity rules, use the `kubectl describe pod` command and examine the `Node Affinity` section:

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i nodeaffinity
```

**Check Resource Requests and Limits:** To view the resource requests and limits of a pod, inspect the `Resources` section of the pod's description:

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i resources
```

**Identify Stuck Pods:** To identify stuck pods that are not transitioning to the desired state, use the following command to retrieve the pod’s events and examine the last event’s message:

```sh
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace> --sort-by='.metadata.creationTimestamp' | tail -n 1
```

**Conclusion:** Effectively troubleshooting Kubernetes pods is crucial for maintaining a healthy and stable cluster.
