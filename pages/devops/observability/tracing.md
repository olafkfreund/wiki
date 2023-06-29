# Tracing

### Overview <a href="#overview" id="overview"></a>

Produces the information required to observe series of correlated operations in a distributed system. Once collected they show the path, measurements, and faults in an end-to-end transaction.

### Best Practices <a href="#best-practices" id="best-practices"></a>

* Ensure that at least key business transactions are traced.
* Include in each trace necessary information to identify software releases (i.e. service name, version). This is important to correlate deployments and system degradation.
* Ensure dependencies are included in trace (databases, I/O).
* If costs are a concern use sampling, avoiding throwing away errors, unexpected behavior and critical information.
* Don't waste a lot of time for no reason, use existing tools to collect and analyze the data.
* Ensure personal identifiable information policies and restrictions are followed.

### Recommended Tools <a href="#recommended-tools" id="recommended-tools"></a>

* [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) - Umbrella of services including system metrics, log analytics and more.
* [Jaeger Tracing](https://www.jaegertracing.io/) - Open source, end-to-end distributed tracing.
* [Grafana](https://grafana.com/) - Open source dashboard & visualization tool. Supports Log, Metrics and Distributed tracing data sources.

> Consider using [OpenTelemetry](https://microsoft.github.io/code-with-engineering-playbook/observability/tools/OpenTelemetry/) as it implements open-source cross-platform context propagation for end-to-end distributed transactions over heterogeneous components out-of-the-box. It takes care of automatically creating and managing the Trace Context object among a full stack of microservices implemented across different technical stacks.
