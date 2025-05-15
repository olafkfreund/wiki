# Metrics (2025)

## Overview

Metrics are numerical measurements collected at regular intervals that represent the state and performance of systems, applications, and business processes. In 2025, metrics have evolved from simple system-level indicators to sophisticated, high-cardinality data points that span entire service ecosystems and directly correlate with business outcomes.

## Types of Metrics in Modern Observability

### Technical Metrics

* **System Metrics**: CPU, memory, disk, network (expanded with hardware-level telemetry)
* **Application Metrics**: Request rates, error rates, duration, saturation, throughput
* **Infrastructure Metrics**: Cloud resource utilization, capacity, cost, provisioning/scaling times
* **Network Metrics**: Latency, packet loss, bandwidth utilization, connection states
* **Container/Orchestration Metrics**: Pod health, autoscaling events, resource requests vs. limits
* **Service Mesh Metrics**: Request volumes, circuit breaker status, retry rates, traffic splitting

### Business Metrics

* **User Experience**: Page load times, time to interactive, frustration events
* **Transaction Metrics**: Checkout times, payment processing success rates, API utilization
* **Conversion Metrics**: Funnel progression, abandonment rates, session quality
* **Revenue Impact**: Real-time revenue tracking correlated with system performance
* **User Satisfaction**: Apdex scores, user ratings, sentiment analysis from support channels

### Operational Metrics

* **SLI/SLO Metrics**: Service level indicators used for reliability tracking
* **DORA Metrics**: Change lead time, deployment frequency, MTTR, failure rates
* **Cost Metrics**: Per-service expenditure, resource efficiency, scaling economics
* **Security Metrics**: Vulnerability counts, patch status, authentication patterns, threat indicators
* **Platform Metrics**: CI/CD pipeline performance, environment health, infrastructure drift

## Modern Metric Collection Approaches (2025)

### OpenTelemetry Standards

OpenTelemetry has become the industry standard for metric collection, offering:

* **Unified Instrumentation**: Single API for metrics, traces, and logs
* **Transport Protocol**: OTLP (OpenTelemetry Protocol) for efficient data transmission
* **Semantic Conventions**: Standardized naming and attribute schema
* **Collector Pipeline**: Configurable processing, filtering, and routing
* **Automatic Instrumentation**: Zero-code integration with popular frameworks

### Implementation:

```yaml
# OpenTelemetry Collector Configuration (2025)
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
  
  resource:
    attributes:
      - key: environment
        value: production
        action: upsert
      
  metricstransform:
    transforms:
      - include: http.server.duration
        action: update
        new_name: http_server_request_duration_seconds
        operations:
          - action: add_label
            new_label: slo_relevant
            new_value: "true"

exporters:
  prometheus:
    endpoint: 0.0.0.0:8889
    
  otlphttp:
    endpoint: https://monitoring.example.com/v1/metrics
    headers:
      Authorization: "Bearer ${env:API_TOKEN}"

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch, resource, metricstransform]
      exporters: [prometheus, otlphttp]
```

### Cloud-Native Collection

Modern cloud environments offer rich metric collection capabilities:

* **eBPF-Based Telemetry**: Kernel-level instrumentation with minimal overhead
* **Service Mesh Metrics**: Istio, Linkerd, and other meshes providing automated collection
* **Sidecar Approach**: Co-deployed metric collection agents
* **Managed Services**: Cloud provider observability platforms with automatic integration

### High-Cardinality Metrics

2025 observability systems can efficiently handle high-cardinality metrics:

* **Dimensional Metrics**: Multiple labels/dimensions per metric
* **Exemplars**: Statistical samples linked to traces for debugging
* **Real-Time Aggregation**: On-demand computation of aggregates from raw data
* **Time-Series Optimization**: Efficient storage and indexing models
* **Incremental Computation**: Progressive calculation of complex statistics

## Real-Life Implementation Examples

### Global Retail Platform

**Challenge**: A multinational retailer needed end-to-end visibility across 2,500 stores, e-commerce platforms, and supply chain systems.

**Solution**:
1. Implemented OpenTelemetry across all microservices
2. Deployed store-level edge collectors with local buffering
3. Created hierarchical aggregation for regional and global views
4. Built business dashboards correlating technical performance with sales data

**Technical Implementation**:
```python
# Python service instrumentation example with OpenTelemetry (2025)
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.metrics import CallbackOptions, Observation
import time

# Initialize the meter provider with OTLP exporter
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint="otel-collector:4317", insecure=True)
)
provider = MeterProvider(metric_readers=[metric_reader])
metrics.set_meter_provider(provider)

# Create a meter
meter = metrics.get_meter("retail.checkout", "1.0.0")

# Create instruments
checkout_duration = meter.create_histogram(
    name="checkout.duration",
    description="Time taken to process a checkout",
    unit="s",
)

checkout_counter = meter.create_counter(
    name="checkout.total",
    description="Number of checkouts processed",
)

cart_value_gauge = meter.create_observable_gauge(
    name="checkout.cart.value",
    description="Value of items in cart",
    unit="usd",
    callbacks=[lambda options: [Observation(get_average_cart_value(), {"region": "north_america"})]],
)

# Create dimensional metrics with rich context
def process_checkout(cart_items, payment_method, store_id, customer_segment):
    start = time.time()
    # Process checkout logic here
    duration = time.time() - start
    
    # Record with multiple dimensions
    checkout_duration.record(
        duration,
        {
            "store_id": store_id,
            "payment_method": payment_method,
            "customer_segment": customer_segment,
            "item_count": len(cart_items),
            "has_membership": customer_has_membership()
        }
    )
    
    # Count successful checkouts
    checkout_counter.add(
        1,
        {
            "store_id": store_id,
            "payment_method": payment_method,
            "result": "success"
        }
    )
```

**Results**:
- Identified performance bottlenecks during peak shopping periods
- Decreased cart abandonment by 18% through targeted optimizations
- Optimized inventory allocation based on real-time shopping patterns
- Saved $4.7M annually through better scaling of cloud resources

### Financial Trading Platform

**Challenge**: A trading platform needed microsecond-level visibility into order processing while maintaining compliance with regulatory requirements.

**Solution**:
1. Custom metrics collection with nanosecond precision
2. Real-time anomaly detection for fraud prevention
3. Regulatory compliance dashboards with audit trails
4. ML-based predictive scaling to handle market volatility

**Technical Implementation**:
- Specialized eBPF probes for ultra-low-latency measurement
- Hardware-assisted telemetry collection
- In-memory processing for real-time analytics
- Timed archival for compliance and historical analysis

**Results**:
- 99.9999% order processing reliability
- Detected trading anomalies 200ms faster than previous system
- Automated evidence generation for regulatory compliance
- Enhanced algorithm performance through granular latency insights

### Healthcare Provider Network

**Challenge**: A healthcare organization needed to monitor patient experience across digital and physical touchpoints while ensuring data privacy.

**Solution**:
1. Privacy-preserving instrumentation of patient-facing applications
2. HIPAA-compliant metric collection and storage
3. Correlation between system performance and patient care quality
4. Real-time capacity monitoring for critical care resources

**Technical Implementation**:
```terraform
# Terraform example for setting up metrics infrastructure
resource "aws_prometheus_workspace" "healthcare_metrics" {
  alias = "healthcare-metrics"
  
  tags = {
    Environment = "production"
    Compliance  = "hipaa"
  }
}

resource "aws_prometheus_rule_group_namespace" "alerts" {
  name         = "critical-service-alerts"
  workspace_id = aws_prometheus_workspace.healthcare_metrics.id
  data         = <<EOF
groups:
- name: PatientPortalAlerts
  rules:
  - alert: HighLatencyPatientRecords
    expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service="patient-records"}[5m])) by (le)) > 2
    for: 2m
    labels:
      severity: critical
      domain: patient-care
    annotations:
      summary: "Patient records access experiencing high latency"
      impact: "Patient care may be impacted"
      runbook_url: "https://wiki.example.com/alerts/patient-records-latency"
      dashboard: "https://grafana.example.com/d/patient-systems"
EOF
}

resource "aws_iam_role_policy_attachment" "prometheus_data_access" {
  role       = aws_iam_role.metrics_collection.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}

# Secure VPC endpoint for metrics collection
resource "aws_vpc_endpoint" "prometheus" {
  vpc_id            = aws_vpc.healthcare_network.id
  service_name      = "com.amazonaws.${var.region}.aps"
  vpc_endpoint_type = "Interface"
  
  security_group_ids = [
    aws_security_group.metrics_endpoint.id,
  ]
  
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets.*.id
}
```

**Results**:
- Improved patient portal responsiveness by 42%
- Enhanced resource allocation based on patient volume predictions
- Maintained 100% HIPAA compliance while improving observability
- Reduced emergency room wait times through predictive staffing

## Metric Storage and Retention Strategies (2025)

### Multi-Tier Storage

Modern metric systems use tiered storage approaches:
1. **Real-Time Tier**: In-memory or high-performance storage for recent, high-resolution metrics
2. **Warm Tier**: Compressed, optimized storage for weeks/months of data
3. **Cold Tier**: Highly compressed long-term storage for years of historical data
4. **Archival Tier**: Immutable compliance storage for auditing and regulatory requirements

### Resolution Management

- **Adaptive Resolution**: Automatic adjustment of resolution based on age
- **Statistical Downsampling**: Intelligent aggregation preserving anomalies
- **Context-Aware Retention**: Keeping detailed data for critical periods
- **Exemplar Storage**: Maintaining statistical samples of raw data points

## Metric Correlation and Analysis

### AIOps Integration

- **Automated Root Cause Analysis**: ML-driven identification of incident sources
- **Anomaly Detection**: Adaptive baseline modeling with contextual awareness
- **Predictive Alerting**: Early warning system based on trend analysis
- **Correlation Mapping**: Automatic discovery of related metrics

### Business Intelligence Integration

- **Business Metric Derivation**: Automatically generating business KPIs from technical metrics
- **Cost Attribution**: Mapping system metrics to financial impact
- **Experience Scoring**: Converting technical metrics to user experience scores
- **Capacity Forecasting**: Predictive modeling for resource planning

## Summary

In 2025, effective metric collection systems combine standardized instrumentation, sophisticated storage, and intelligent analysis to provide actionable insights. The most successful implementations blend technical performance data with business outcomes to create a holistic view of system health and service quality.

## Related Topics

- [Observability Fundamentals](README.md) - Core observability concepts and principles
- [Logging](logging/README.md) - Complementary textual record collection
- [Tracing](tracing.md) - Request flow monitoring across distributed systems
- [Dashboards](dashboard.md) - Visualizing metrics effectively
- [SLOs and SLAs](../../need-to-know/understanding-sli-slo-and-sla.md) - Using metrics for reliability targets
- [OpenTelemetry](../../should-learn/open-telemetry.md) - Standard for metrics collection
- [Kubernetes Monitoring](../../should-learn/kubernetes/monitoring.md) - Container platform metrics
