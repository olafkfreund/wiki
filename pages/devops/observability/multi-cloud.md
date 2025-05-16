# Multi-Cloud Observability (2024+)

## OpenTelemetry Setup

### Collector Configuration
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
  attributes:
    actions:
      - key: cloud.provider
        value: ${CLOUD_PROVIDER}
        action: upsert

exporters:
  awsxray:
    region: us-west-2
  azuremonitor:
    instrumentation_key: ${AZURE_INSTRUMENTATION_KEY}
  googlecloud:
    project: my-project
    metric_prefix: custom.opentelemetry

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, attributes]
      exporters: [awsxray, azuremonitor, googlecloud]
```

## Cross-Cloud Correlation

### Distributed Tracing
```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: cross-cloud-demo
spec:
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: "1.0"
  env:
    - name: OTEL_RESOURCE_ATTRIBUTES
      value: service.namespace=production,service.name=cross-cloud-app
```

## Unified Dashboarding

### Grafana Integration
```yaml
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDataSource
metadata:
  name: multi-cloud-metrics
spec:
  name: MultiCloudMetrics
  datasources:
    - name: AWS CloudWatch
      type: cloudwatch
      jsonData:
        authType: default
        defaultRegion: us-west-2
    - name: Azure Monitor
      type: grafana-azure-monitor-datasource
      jsonData:
        cloudName: azuremonitor
        subscriptionId: ${AZURE_SUBSCRIPTION_ID}
    - name: Google Cloud
      type: stackdriver
      jsonData:
        tokenUri: https://oauth2.googleapis.com/token
        projectName: ${GCP_PROJECT_ID}
```

## Best Practices

1. **Data Collection**
   - Unified instrumentation
   - Consistent labeling
   - Cross-cloud correlation
   - Custom attributes

2. **Storage Strategy**
   - Data retention policies
   - Cost optimization
   - Query performance
   - Data federation

3. **Visualization**
   - Cross-cloud dashboards
   - Service maps
   - Alert correlation
   - Custom widgets