# Load Testing and Monitoring Configuration

## Load Testing Setup

### K6 Load Test
```yaml
apiVersion: k6.io/v1alpha1
kind: TestRun
metadata:
  name: load-test
spec:
  script:
    configMap:
      name: k6-test-script
      file: test.js
  runner:
    image: loadimpact/k6:latest
    env:
      - name: TARGET_URL
        value: "http://app-canary"
  arguments: --vus 10 --duration 30s
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: k6-test-script
data:
  test.js: |
    import http from 'k6/http';
    import { check, sleep } from 'k6';

    export default function() {
      const res = http.get(__ENV.TARGET_URL);
      check(res, {
        'status is 200': (r) => r.status === 200,
        'response time < 500ms': (r) => r.timings.duration < 500
      });
      sleep(1);
    }
```

## Monitoring Configuration

### Grafana Dashboard
```yaml
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDashboard
metadata:
  name: progressive-delivery
spec:
  json: |
    {
      "dashboard": {
        "id": null,
        "title": "Progressive Delivery Metrics",
        "panels": [
          {
            "title": "Success Rate",
            "type": "graph",
            "datasource": "Prometheus",
            "targets": [
              {
                "expr": "sum(rate(http_requests_total{status=~\"2..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100"
              }
            ]
          },
          {
            "title": "Latency",
            "type": "graph",
            "datasource": "Prometheus",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))"
              }
            ]
          }
        ]
      }
    }
```

### Alert Rules
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: canary-alerts
spec:
  groups:
    - name: canary.rules
      rules:
        - alert: HighErrorRate
          expr: |
            sum(rate(http_requests_total{status=~"5.."}[1m])) 
            / 
            sum(rate(http_requests_total[1m])) * 100 > 1
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: High error rate detected in canary deployment

        - alert: HighLatency
          expr: |
            histogram_quantile(0.95, 
              sum(rate(http_request_duration_seconds_bucket[1m])) by (le)
            ) > 0.5
          for: 1m
          labels:
            severity: warning
          annotations:
            summary: High latency detected in canary deployment
```

## Integration Tests

### Acceptance Test
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: integration-test
spec:
  template:
    spec:
      containers:
        - name: test
          image: cypress/included:12.3.0
          env:
            - name: CYPRESS_baseUrl
              value: http://app-canary
          command:
            - cypress
            - run
            - --config-file
            - cypress.config.js
      restartPolicy: Never
```

## Best Practices

1. **Load Testing**
   - Realistic traffic patterns
   - Gradual load increase
   - Performance thresholds
   - Resource monitoring

2. **Monitoring Setup**
   - Key metrics selection
   - Dashboard organization
   - Alert thresholds
   - Historical data retention

3. **Integration Testing**
   - End-to-end coverage
   - API validation
   - Security checks
   - Performance validation

4. **Alerting Strategy**
   - Severity levels
   - Notification channels
   - Escalation paths
   - Incident response