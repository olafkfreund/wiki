# Chaos Engineering Implementation Guide (2024+)

## Automated Experiments

### Chaos Mesh Configuration

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: multi-cloud-latency
spec:
  action: delay
  mode: one
  selector:
    namespaces:
      - default
    labelSelectors:
      'app': 'payment-service'
  delay:
    latency: '100ms'
    correlation: '100'
    jitter: '0ms'
```

## Multi-Cloud Resilience

### AWS Fault Injection

```yaml
apiVersion: fis.aws.k8s.aws/v1alpha1
kind: Experiment
metadata:
  name: availability-zone-failure
spec:
  description: "Simulate AZ failure"
  targets:
    - name: instances
      resourceType: aws:ec2:instance
      selectionMode: ALL
      filters:
        - path: Placement.AvailabilityZone
          values:
            - us-west-2a
  actions:
    - name: stop-instances
      actionId: aws:ec2:stop-instances
  stopConditions:
    - source: none
```

## Service Resilience Testing

### LitmusChaos Experiments

```yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: service-disruption
spec:
  appinfo:
    appns: 'default'
    applabel: 'app=payment'
    appkind: 'deployment'
  chaosServiceAccount: chaos-admin
  monitoring: true
  jobCleanUpPolicy: 'delete'
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '30'
            - name: CHAOS_INTERVAL
              value: '10'
            - name: FORCE
              value: 'false'
```

## Metrics Collection

### Prometheus Rules

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: chaos-metrics
spec:
  groups:
    - name: chaos.rules
      rules:
        - record: chaos_experiment_status
          expr: sum(rate(chaos_experiment_complete[5m])) by (result, experiment)
        - alert: ChaosExperimentFailure
          expr: chaos_experiment_status{result="failed"} > 0
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Chaos experiment failed"
```

## Best Practices

1. **Experiment Design**
   - Start small
   - Hypothesis-driven
   - Blast radius control
   - Automated rollback

2. **Monitoring**
   - Real-time metrics
   - Business KPIs
   - User impact
   - System resilience

3. **Documentation**
   - Experiment results
   - Lessons learned
   - Remediation steps
   - System improvements

4. **Team Culture**
   - Blameless postmortems
   - Regular gamedays
   - Knowledge sharing
   - Continuous learning
