# Logging

### Overview <a href="#overview" id="overview"></a>

Logs are discrete events with the goal of helping engineers identify problem area(s) during failures.

### Collection Methods <a href="#collection-methods" id="collection-methods"></a>

When it comes to log collection methods, two of the standard techniques are a direct-write, or an agent-based approach.

Directly written log events are handled in-process of the particular component, usually utilizing a provided library. [Azure Monitor](https://azure.microsoft.com/en-us/services/monitor) has direct send capabilities, but it's not recommended for serious/production use. This approach has some advantages:

* There is no external process to configure or monitor
* No log file management (rolling, expiring) to prevent out of disk space issues.

The potential trade-offs of this approach:

* Potentially higher memory usage if the library is using a memory backed buffer.
* In the event of an extended service outage, log data may get dropped or truncated due to buffer constraints.
* Multiple component process logging will manage & emit logs individually, which can be more complex to manage for the outbound load.

Agent-based log collection relies on an external process running on the host machine, with the component emitting log data stdout or file. Writing log data to stdout is the preferred practice when running applications within a container environment like Kubernetes. The container runtime redirects the output to files, which can then be processed by an agent. [Azure Monitor](https://azure.microsoft.com/en-us/services/monitor), [Grafana Loki](https://github.com/grafana/loki) [Elastic's Logstash](https://www.elastic.co/logstash) and [Fluent Bit](https://fluentbit.io/) are examples of log shipping agents.

There are several advantages when using an agent to collect & ship log files:

* Centralized configuration.
* Collecting multiple sources of data with a single process.
* Local pre-processing & filtering of log data before sending it to a central service.
* Utilizing disk space as a data buffer during a service disruption.

This approach isn't without trade-offs:

* Required exclusive CPU & memory resources for the processing of log data.
* Persistent disk space for buffering.

### Best Practices <a href="#best-practices" id="best-practices"></a>

#### 2025 Logging Best Practices

* **Zero-Trust Logging**: Implement cryptographic signatures for logs to ensure integrity and non-repudiation in zero-trust environments.
* **AI-Assisted Log Analysis**: Leverage LLM-powered log analysis tools to automatically identify patterns and anomalies without manual query writing.
* **eBPF-Based Logging**: Use extended Berkeley Packet Filter (eBPF) technology for kernel-level logging with minimal performance impact.
* **Vector-Based Storage**: Store logs in vector databases to enable semantic search capabilities across massive log datasets.
* **Real-Time Compliance Validation**: Implement automated compliance scanning on log streams to flag PII or regulatory violations before they reach storage.

#### Established Best Practices

* Pay attention to logging levels. Logging too much will increase costs and decrease application throughput.
* Ensure logging configuration can be modified without code changes. Ideally, make it changeable without application restarts.
* If available, take advantage of logging levels per category allowing granular logging configuration.
* Check for log levels before logging, thus avoiding allocations and string manipulation costs.
* Ensure service versions are included in logs to be able to identify problematic releases.
* Log a raised exception only once. In your handlers, only catch expected exceptions that you can handle gracefully (even with a specific return code). If you want to log and rethrow, leave it to the top level exception handler. Do the minimal amount of cleanup work needed then throw to maintain the original stack trace. Don't log a warning or stack trace for expected exceptions (eg: properly expected 404, 403 HTTP statuses).
* Fine tune logging levels in production (>= warning for instance). During a new release the verbosity can be increased to facilitate bug identification.
* If using sampling, implement this at the service level rather than defining it in the logging system. This way we have control over what gets logged. An additional benefit is reduced number of roundtrips.
* Only include failures from health checks and non-business driven requests.
* Ensure a downstream system malfunction won't cause repetitive logs being stored.
* Don't reinvent the wheel, use existing tools to collect and analyze the data.
* Ensure personal identifiable information policies and restrictions are followed.
* Ensure errors and exceptions in dependent services are captured and logged. For example, if an application uses Redis cache, Service Bus or any other service, any errors/exceptions raised while accessing these services should be captured and logged.

#### Log Retention and Cost Management (2025)

* **Tiered Log Storage**: Implement multi-tiered log storage with hot, warm, and cold tiers based on access patterns and compliance requirements.
* **Dynamic Retention Policies**: Use machine learning to automatically adjust retention periods based on the criticality and usage patterns of different log types.
* **Compute-Adjacent Storage**: Position log storage infrastructure in the same availability zones as compute to minimize cross-zone data transfer costs.
* **Federated Query Engines**: Deploy federated query systems to analyze logs across multiple storage backends without data duplication.

#### If there's sufficient log data, is there a need for instrumenting metrics? <a href="#if-theres-sufficient-log-data-is-there-a-need-for-instrumenting-metrics" id="if-theres-sufficient-log-data-is-there-a-need-for-instrumenting-metrics"></a>

[Logs vs Metrics vs Traces](https://microsoft.github.io/code-with-engineering-playbook/observability/log-vs-metric-vs-trace/) covers some high level guidance on when to utilize metric data and when to use log data. Both have a valuable part to play in creating observable systems.

In 2025, the distinction has evolved with the rise of unified observability platforms that automatically derive metrics from logs and correlate them with traces. However, direct instrumentation of critical metrics remains beneficial for performance and cost reasons, particularly for high-cardinality data points.

### Real-Life Examples and Scenarios (2025)

#### Case Study 1: Financial Services API Platform

A major financial services company implemented a new logging strategy for their API platform serving 50+ million daily transactions:

```json
{
  "timestamp": "2025-03-15T14:23:45.232Z",
  "service": "payment-gateway",
  "version": "3.4.2",
  "instance": "pod-23a7f",
  "trace_id": "abc123def456ghi789",
  "span_id": "span456def",
  "level": "ERROR",
  "message": "Payment processing timeout",
  "context": {
    "merchant_id": "m-28937423", 
    "transaction_type": "debit",
    "amount": 432.19,
    "currency": "USD",
    "processing_time_ms": 30214,
    "timeout_threshold_ms": 3000
  },
  "resource": {
    "payment_processor": "external-gateway-2",
    "region": "us-east-1",
    "endpoint": "/api/v2/process"
  },
  "signature": "ed25519:a97b5e8d23f0cac9..."
}
```

**Key Implementation Details:**
* Log events are cryptographically signed to maintain chain of custody for compliance
* Context contains business-relevant information without PII
* Standardized schema enables automated triage and routing
* Integration with their vector database allows semantic querying like "find all payment timeout errors affecting high-value transactions"

#### Case Study 2: Kubernetes Cluster Autoscaling Events

A global SaaS provider implemented eBPF-based logging to capture autoscaling decisions in their Kubernetes environment:

```yaml
timestamp: 2025-04-22T09:12:34Z
event_type: cluster_autoscaling_decision
cluster_id: prod-east-12
scaling_action: node_addition
details:
  node_pool: compute-optimized-4
  previous_count: 17
  new_count: 22
  trigger:
    type: resource_pressure
    resource: memory
    current_utilization: 87%
    threshold: 80%
  workloads_impacted:
    - namespace: customer-facing
      deployment: recommendation-engine
      replicas_pending: 7
  estimated_cost_impact:
    daily_increase_usd: 42.85
    monthly_forecast_usd: 1285.50
```

This logging approach allowed them to correlate infrastructure scaling events with business impact and costs, leading to a 23% reduction in cloud spending by optimizing autoscaling parameters based on historical patterns.

#### Having problems identifying what to log? <a href="#having-problems-identifying-what-to-log" id="having-problems-identifying-what-to-log"></a>

**At application startup**:

* Unrecoverable errors from startup.
* Warnings if application still runnable, but not as expected (i.e. not providing blob connection string, thus resorting to local files. Another example is if there's a need to fail back to a secondary service or a known good state, because it didn't get an answer from a primary dependency.)
* Information about the service's state at startup (build #, configs loaded, etc.)
* Runtime environment details such as container orchestration metadata, cloud provider region, and infrastructure generation.
* Service mesh configuration and connectivity status.

**Per incoming request**:

* Basic information for each incoming request: the url (scrubbed of any personally identifying data, a.k.a. PII), any user/tenant/request dimensions, response code returned, request-to-response latency, payload size, record counts, etc. (whatever you need to learn something from the aggregate data)
* Warning for any unexpected exceptions, caught only at the top controller/interceptor and logged with or alongside the request info, with stack trace. Return a 500. This code doesn't know what happened.
* Feature flag evaluations that affected request processing.
* AI/ML model versions used for request processing, including confidence scores.

**Per outgoing request**:

* Basic information for each outgoing request: the url (scrubbed of any personally identifying data, a.k.a. PII), any user/tenant/request dimensions, response code returned, request-to-response latency, payload sizes, record counts returned, etc. Report perceived availability and latency of dependencies and including slicing/clustering data that could help with later analysis.
* Circuit breaker status and fallback strategy activations.
* API version and deprecation warnings from dependencies.

### Recommended Tools <a href="#recommended-tools" id="recommended-tools"></a>

* [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) - Umbrella of services including system metrics, log analytics and more. Now featuring AI-powered insights with Azure Monitor Copilot.
* [Grafana Loki](https://grafana.com/oss/loki/) - An open source log aggregation platform, built on the learnings from the Prometheus Community for highly efficient collection & storage of log data at scale. Now with vector search capabilities.
* [The Elastic Stack](https://www.elastic.co/elastic-stack/) - An open source log analytics tech stack utilizing Logstash, Beats, Elastic search and Kibana with advanced ML capabilities.
* [Grafana](https://grafana.com/) - Open source dashboard & visualization tool. Supports Log, Metrics and Distributed tracing data sources with 2025's addition of natural language querying.
* [OpenTelemetry Logging](https://opentelemetry.io/docs/specs/otel/logs/) - The CNCF standard for logs collection that integrates seamlessly with distributed traces and metrics.
* [Vector](https://vector.dev/) - High-performance observability pipeline for collecting, transforming, and routing logs with eBPF capabilities.
* [Wazuh](https://wazuh.com/) - Open source security monitoring with advanced log analysis for threat detection and compliance monitoring.

### 2025 Logging Architecture Patterns

#### Hybrid Edge-Cloud Processing

Modern logging architectures now commonly implement a tiered approach:

1. **Edge Processing**: Initial log aggregation and filtering at the edge
2. **Regional Consolidation**: Normalized logs routed to regional processing centers
3. **Central Analysis**: Long-term storage and cross-regional analysis in core infrastructure

This pattern has become standard for global applications needing to balance performance, sovereignty requirements, and global visibility.

#### Example Architecture Diagram

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  Application  │     │  Application  │     │  Application  │
│  Containers   │     │  Containers   │     │  Containers   │
└───────┬───────┘     └───────┬───────┘     └───────┬───────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  Vector Agent │     │  Vector Agent │     │  Vector Agent │
│  (eBPF mode)  │     │  (eBPF mode)  │     │  (eBPF mode)  │
└───────┬───────┘     └───────┬───────┘     └───────┬───────┘
        │                     │                     │
        └─────────┬───────────┴─────────┬───────────┘
                  │                     │
                  ▼                     ▼
        ┌───────────────┐     ┌───────────────┐
        │ Regional Log  │     │ Regional Log  │
        │ Aggregator    │     │ Aggregator    │
        └───────┬───────┘     └───────┬───────┘
                │                     │
                └─────────┬───────────┘
                          │
                          ▼
                ┌───────────────────┐
                │  Central Log      │
                │  Storage & ML     │
                └─────────┬─────────┘
                          │
            ┌─────────────┴─────────────┐
            │                           │
            ▼                           ▼
┌───────────────────┐       ┌───────────────────┐
│  Compliance &     │       │   Visualization   │
│  Audit Storage    │       │   & Analysis      │
└───────────────────┘       └───────────────────┘
```

This architecture enables real-time log analysis while maintaining compliance with data sovereignty and retention requirements.
