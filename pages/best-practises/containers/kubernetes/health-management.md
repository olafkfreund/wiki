# Kubernetes Health Management & Monitoring

Enterprise Kubernetes deployments require robust health management strategies to ensure reliability, performance, and availability. This guide covers advanced techniques for maintaining healthy Kubernetes clusters at scale.

---

## Real-Life Health Management Strategies

- **Multi-cluster Health Dashboards:** Implement centralized observability platforms (Grafana/Prometheus) that aggregate health metrics across all clusters in your fleet.
- **Capacity Forecasting:** Use historical resource consumption data to predict future capacity needs and automate scaling operations before constraints impact performance.
- **Kubernetes Control Plane Monitoring:** Implement dedicated monitoring for API server, etcd, scheduler, and controller-manager components with automated alerting.
- **Failure Domain Isolation:** Design clusters to withstand the failure of entire regions, availability zones, or control plane components.

---

## Advanced Monitoring Setup

1. **Comprehensive Metric Collection:**

   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PodMonitor
   metadata:
     name: app-metrics
     namespace: monitoring
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/component: backend
     podMetricsEndpoints:
     - port: metrics
       interval: 15s
       scrapeTimeout: 10s
     namespaceSelector:
       matchNames:
       - production
       - staging
   ```

2. **Control Plane Health Checks:**

   ```sh
   # Monitor etcd health
   kubectl -n kube-system exec etcd-master -- etcdctl --endpoints=https://127.0.0.1:2379 \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key \
     endpoint health
   
   # Check API server health
   kubectl get --raw='/healthz'
   
   # Check all component statuses
   kubectl get componentstatuses
   ```

3. **Extended Node Problem Detection:**

   ```yaml
   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     name: node-problem-detector
     namespace: kube-system
   spec:
     selector:
       matchLabels:
         app: node-problem-detector
     template:
       metadata:
         labels:
           app: node-problem-detector
       spec:
         containers:
         - name: node-problem-detector
           image: k8s.gcr.io/node-problem-detector:v0.8.7
           securityContext:
             privileged: true
           volumeMounts:
           - name: log
             mountPath: /var/log
             readOnly: true
         volumes:
         - name: log
           hostPath:
             path: /var/log
   ```

---

## Proactive Health Maintenance

- **Regular etcd Defragmentation:**

  ```sh
  # Run etcd defragmentation to reclaim space
  kubectl -n kube-system exec etcd-master -- etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    defrag
  ```

- **Automated Certificate Rotation:**

  ```sh
  # Check certificate expiration
  kubeadm certs check-expiration
  
  # Rotate certificates
  kubeadm certs renew all
  ```

- **Cluster Upgrade Validation:**

  ```sh
  # Pre-upgrade validation
  kubeadm upgrade plan
  
  # Apply upgrades in controlled manner
  kubeadm upgrade apply v1.27.x
  ```

---

## Cluster Recovery Procedures

1. **API Server Recovery:**

   ```sh
   # Check logs
   journalctl -u kubelet -f
   
   # Restart kubelet
   systemctl restart kubelet
   
   # Check API server pod
   kubectl -n kube-system get pod kube-apiserver-master -o yaml
   ```

2. **etcd Backup and Restore:**

   ```sh
   # Create etcd snapshot
   ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key \
     snapshot save /backup/etcd-snapshot-$(date +%Y-%m-%d).db
   
   # Restore from snapshot
   ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key \
     snapshot restore /backup/etcd-snapshot.db
   ```

3. **Node Draining and Recovery:**

   ```sh
   # Drain a node for maintenance
   kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data
   
   # Mark node as unschedulable
   kubectl cordon node-1
   
   # Re-enable scheduling after maintenance
   kubectl uncordon node-1
   ```

---

## Advanced Autoscaling

1. **Multi-dimensional Pod Autoscaling:**

   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: advanced-hpa
     namespace: production
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: web-app
     minReplicas: 3
     maxReplicas: 100
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
     - type: Resource
       resource:
         name: memory
         target:
           type: Utilization
           averageUtilization: 80
     - type: External
       external:
         metric:
           name: queue_messages_ready
           selector:
             matchLabels:
               queue: "worker"
         target:
           type: AverageValue
           averageValue: 30
   ```

2. **Cluster Autoscaler with Node Affinity:**

   ```yaml
   apiVersion: cluster.k8s.io/v1
   kind: MachineDeployment
   metadata:
     name: gpu-workers
     namespace: kube-system
   spec:
     replicas: 1
     selector:
       matchLabels:
         node-pool: gpu-accelerated
     template:
       spec:
         providerSpec:
           value:
             machineType: g4dn.xlarge
             diskSizeGb: 100
             labels:
               node-pool: gpu-accelerated
   ```

---

## Best Practices

- **Implement Pod Disruption Budgets** for all critical workloads to maintain availability during node maintenance.
- **Use multiple Prometheus instances** with hierarchical federation for large clusters.
- **Employ dedicated infrastructure** for monitoring stack to avoid monitoring failure during cluster issues.
- **Utilize Custom Resource Metrics** for application-specific scaling decisions.
- **Implement regular cluster audits** for security, resource allocation, and configuration drift.
- **Run chaos experiments** to validate resilience and recovery procedures.

---

## Cross-Cloud Health Management

- **Unified Monitoring Plane:** Implement tools like Thanos or Cortex for cross-cluster, cross-cloud Prometheus federation.
- **Standard Health Metrics:** Develop organization-wide standard health metrics and SLIs across all clusters.
- **Automated Recovery Playbooks:** Create cloud-specific but standardized recovery procedures.
- **Cross-Cluster Service Discovery:** Implement mechanisms for service discovery across multiple clusters.

---

## References

- [Kubernetes SIG Instrumentation](https://github.com/kubernetes/community/tree/master/sig-instrumentation)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [etcd Operations Guide](https://etcd.io/docs/v3.5/op-guide/)
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [SIG Cluster Lifecycle](https://github.com/kubernetes/community/tree/master/sig-cluster-lifecycle)
