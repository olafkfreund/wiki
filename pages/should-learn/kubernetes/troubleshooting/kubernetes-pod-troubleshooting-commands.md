# Kubernetes Pod Troubleshooting Commands (2025)

This guide provides actionable commands and best practices for troubleshooting pods in Kubernetes clusters (AKS, EKS, GKE, and on-prem). Use these steps for real-life incident response and GitOps workflows.

---

## Common Troubleshooting Commands

**List all Pods in all Namespaces:**

```sh
kubectl get pods --all-namespaces
```

**Check Resource Consumption:**

```sh
kubectl top pods --all-namespaces
```

**Describe a Pod:**

```sh
kubectl describe pod <pod-name> -n <namespace>
```

**View Pod Logs:**

```sh
kubectl logs <pod-name> -n <namespace>
```

**Follow Pod Logs (stream in real-time):**

```sh
kubectl logs -f <pod-name> -n <namespace>
```

**Exec into a Pod:**

```sh
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

**Get Events for a Pod:**

```sh
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>
```

**Check Pod Health (Readiness/Liveness):**

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i 'readiness\|liveness\|conditions'
```

**Retrieve Pod IP and Node:**

```sh
kubectl get pod <pod-name> -n <namespace> -o wide
```

**Restart a Pod:**

```sh
kubectl delete pod <pod-name> -n <namespace>
```

**Check Pod Status:**

```sh
kubectl get pod <pod-name> -n <namespace> -o wide
```

**List Pod Events (sorted):**

```sh
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace> --sort-by='.metadata.creationTimestamp'
```

**Verify Pod Affinity/Anti-Affinity:**

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i nodeaffinity
```

**Check Resource Requests and Limits:**

```sh
kubectl describe pod <pod-name> -n <namespace> | grep -i resources
```

**Identify Stuck Pods:**

```sh
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace> --sort-by='.metadata.creationTimestamp' | tail -n 1
```

---

## Real-Life Troubleshooting Workflow

1. **Identify the failing pod:**

   ```sh
   kubectl get pods -A | grep -i error
   ```

2. **Check pod status and events:**

   ```sh
   kubectl describe pod <pod-name> -n <namespace>
   kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>
   ```

3. **Inspect logs:**

   ```sh
   kubectl logs <pod-name> -n <namespace>
   ```

4. **Check resource usage:**

   ```sh
   kubectl top pod <pod-name> -n <namespace>
   ```

5. **Exec into the pod for deeper inspection:**

   ```sh
   kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
   ```

6. **Review affinity, resource limits, and node assignment:**

   ```sh
   kubectl describe pod <pod-name> -n <namespace> | grep -i 'affinity\|resources\|node'
   ```

7. **If using GitOps:** Check if the manifest in Git matches the running pod. If not, investigate drift or failed syncs (ArgoCD/Flux dashboards).

---

## Best Practices (2025)

- Always check pod events and logs before restarting or deleting pods
- Use `kubectl get events` sorted by timestamp for recent issues
- Validate resource requests/limits to avoid OOMKilled or throttling
- Use LLMs (Copilot, Claude) to generate troubleshooting scripts or analyze logs
- Document recurring issues and solutions in your team knowledge base

## Common Pitfalls

- Ignoring events (often contain the root cause)
- Restarting pods without root cause analysis
- Not checking for node-level issues (disk, network, taints)
- Manual changes outside Git in GitOps-managed clusters

---

## References

- [Kubernetes Troubleshooting Docs](https://kubernetes.io/docs/tasks/debug/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [ArgoCD Troubleshooting](https://argo-cd.readthedocs.io/en/stable/operator-manual/troubleshooting/)
- [Flux Troubleshooting](https://fluxcd.io/docs/faq/)

---

## Related Topics

- [Pod Troubleshooting Commands](kubernetes-pod-troubleshooting-commands.md) - Specific tools for debugging pods
- [Kubernetes Core Concepts](../../../need-to-know/kubernetes/kubernetes-concepts.md) - Understanding fundamentals helps troubleshooting
- [Logging](../../../devops/observability/logging/README.md) - Collecting logs from Kubernetes
- [Metrics](../../../devops/observability/metrics.md) - Monitoring Kubernetes performance
