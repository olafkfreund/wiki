# Kubernetes Security Monitoring (2024+)

## Dynamic Security Controls

### Falco Runtime Security

```yaml
apiVersion: falco.security.dev/v1beta1
kind: FalcoRule
metadata:
  name: detect-privilege-escalation
spec:
  output: Privilege escalation detected (user=%user.name container=%container.name command=%proc.cmdline)
  rule: >
    spawned_process and container and
    proc.name in (sudo, su) and
    not proc.name in (usermod, groupmod, chown)
```

### Audit Policy Configuration

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods", "services", "secrets"]
- level: Metadata
  resources:
  - group: "rbac.authorization.k8s.io"
    resources: ["roles", "clusterroles"]
```

## Monitoring Stack Integration

### Prometheus Rules

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: security-alerts
spec:
  groups:
  - name: security
    rules:
    - alert: PodPrivilegedMode
      expr: kube_pod_container_status_running{container!=""} * on(pod,namespace) group_left kube_pod_security_context{privileged="true"} > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Pod running in privileged mode detected
```

### Grafana Dashboard Example

```json
{
  "title": "Kubernetes Security Overview",
  "panels": [
    {
      "title": "Failed Authentication Attempts",
      "type": "timeseries",
      "targets": [
        {
          "expr": "sum(rate(apiserver_failed_auth_count[5m])) by (reason)"
        }
      ]
    }
  ]
}
```

## Security Response Automation

### Automated Response with Kubectl-Kuberhealthy

```yaml
apiVersion: comcast.github.io/v1
kind: KuberhealthyCheck
metadata:
  name: security-response
spec:
  runInterval: 5m
  timeout: 10m
  podSpec:
    containers:
    - name: security-check
      image: security-checker:latest
      env:
      - name: CHECK_NAMESPACE
        value: "kube-system"
```

## Best Practices

1. **Real-time Monitoring**
   - Enable Kubernetes audit logging
   - Use Falco for runtime security
   - Implement automated responses

2. **Compliance Controls**
   - Regular compliance scans
   - Automated policy enforcement
   - Audit trail maintenance

3. **Incident Response**
   - Automated containment
   - Evidence collection
   - Playbook automation

4. **Metrics Collection**
   - Security KPIs
   - Compliance metrics
   - Performance impact
