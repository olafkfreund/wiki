# Metric Templates for Progressive Delivery

## Prometheus Templates

### Success Rate Template
```yaml
apiVersion: flagger.app/v1beta1
kind: MetricTemplate
metadata:
  name: request-success-rate
  namespace: flux-system
spec:
  provider:
    type: prometheus
    address: http://prometheus.monitoring:9090
  query: |
    rate(
      http_request_total{
        namespace="{{ namespace }}",
        service="{{ target }}",
        status!~"5.*"
      }[1m]
    ) 
    / 
    rate(
      http_request_total{
        namespace="{{ namespace }}",
        service="{{ target }}"
      }[1m]
    ) * 100

```

### Latency Template
```yaml
apiVersion: flagger.app/v1beta1
kind: MetricTemplate
metadata:
  name: request-duration
  namespace: flux-system
spec:
  provider:
    type: prometheus
    address: http://prometheus.monitoring:9090
  query: |
    histogram_quantile(0.99,
      sum(
        rate(
          http_request_duration_seconds_bucket{
            namespace="{{ namespace }}",
            service="{{ target }}"
          }[1m]
        )
      ) by (le)
    )
```

## Alert Configurations

### Slack Alerts
```yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Alert
metadata:
  name: on-call-slack
  namespace: flux-system
spec:
  providerRef:
    name: slack
  eventSeverity: error
  eventSources:
    - kind: Canary
      name: '*'
  suspend: false
---
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Provider
metadata:
  name: slack
  namespace: flux-system
spec:
  type: slack
  channel: progressive-delivery
  address: https://hooks.slack.com/services/YOUR-WEBHOOK-URL
  secretRef:
    name: slack-url
```

### PagerDuty Integration
```yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Provider
metadata:
  name: pagerduty
  namespace: flux-system
spec:
  type: pagerduty
  address: https://events.pagerduty.com/v2/enqueue
  secretRef:
    name: pagerduty-token
---
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Alert
metadata:
  name: production-alerts
  namespace: flux-system
spec:
  providerRef:
    name: pagerduty
  eventSeverity: error
  eventSources:
    - kind: Canary
      name: '*'
      namespace: production
```

## Custom Metrics

### Business Metrics
```yaml
apiVersion: flagger.app/v1beta1
kind: MetricTemplate
metadata:
  name: business-success-rate
  namespace: flux-system
spec:
  provider:
    type: prometheus
    address: http://prometheus.monitoring:9090
  query: |
    sum(
      rate(
        business_transaction_status{
          namespace="{{ namespace }}",
          service="{{ target }}",
          status="success"
        }[2m]
      )
    )
    /
    sum(
      rate(
        business_transaction_status{
          namespace="{{ namespace }}",
          service="{{ target }}"
        }[2m]
      )
    ) * 100
```

## Best Practices

1. **Metric Selection**
   - Use relevant SLIs
   - Include business metrics
   - Monitor dependencies
   - Track error budgets

2. **Alert Configuration**
   - Define severity levels
   - Set appropriate thresholds
   - Configure notification channels
   - Include runbooks

3. **Template Management**
   - Version control
   - Documentation
   - Reusability
   - Testing strategy

4. **Monitoring**
   - Dashboard setup
   - Alert correlation
   - Historical analysis
   - Trend monitoring