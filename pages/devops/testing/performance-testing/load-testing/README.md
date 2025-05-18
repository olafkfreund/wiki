# Load Testing

_Load testing is performed to determine a system's behavior under both normal and anticipated peak load conditions._ — [Load testing - Wikipedia](https://en.wikipedia.org/wiki/Load_testing)

Load testing evaluates how a system performs under expected and peak workloads. Its main goal is to confirm the system can handle real-world traffic, such as concurrent users, requests per second, or data volume, without performance degradation.

---

> **Nerdy Joke:**
> Why did the server go to therapy after load testing?
> Because it couldn't handle the pressure and needed to process its requests!

---

## Why Load Testing

- **Validate reliability:** Ensure the system remains available and responsive under normal and peak loads.
- **Meet SLAs:** Confirm response times, error rates, and throughput meet business requirements.
- **Capacity planning:** Use results to inform scaling decisions and infrastructure investments.
- **Identify bottlenecks:** Detect performance issues before production.

## Key Components of Load Testing

1. **Production-like environment:** Test in an environment that closely matches production (network, hardware, cloud region, etc.).
2. **Realistic user simulation:** Simulate user activity that mirrors real-world usage patterns (e.g., browsing, purchasing, API calls, IoT data ingestion). Avoid overly uniform or predictable data to ensure accurate cache and hit ratio results.
3. **Scalable load generation:** Use one or more agents to generate the required load. For large-scale tests, distribute agents across regions or cloud providers.
4. **Comprehensive monitoring:** Integrate monitoring and logging to capture system metrics (CPU, memory, network, latency, error rates) and identify bottlenecks.

## Load Testing Workflow

### 1. Planning

- **Identify critical scenarios:** Work with stakeholders to select representative user journeys and API calls.
- **Define load profiles:** Determine normal and peak loads (e.g., 500 concurrent users, 1000 RPS).
- **Set success criteria:** Establish thresholds for response time, error rate, resource utilization, and throughput.
- **Select tools:** Choose a load testing tool that fits your stack and requirements (see below).

### 2. Test Design & Execution

- **Script user scenarios:** Use your chosen tool to define realistic workflows.
- **Ramp up gradually:** Start with low load, increase to target, and hold steady to observe system behavior. Optionally, ramp down to observe recovery.
- **Distribute load:** For global systems, generate load from multiple regions to simulate real user traffic.
- **Monitor in real time:** Track system and application metrics during the test.

### 3. Analysis & Reporting

- **Analyze results:** Compare metrics against success criteria. Look for slow responses, errors, resource saturation, and scaling issues.
- **Identify root causes:** Use logs, traces, and monitoring dashboards to pinpoint bottlenecks.
- **Document findings:** Summarize results, highlight issues, and recommend improvements.

### 4. Follow-up Testing

- **Soak (Endurance) Testing:** Run load tests over extended periods to detect memory leaks and stability issues.
- **Stress Testing:** Increase load beyond peak to find system limits and failure points.
- **Spike Testing:** Introduce sudden load surges to test resilience.
- **Scalability Testing:** Re-test after scaling infrastructure to validate improvements.

## Modern Load Testing Tools (2025)

| Tool                | Language      | Cloud/CI Integration         | Notes                                  |
|---------------------|--------------|------------------------------|----------------------------------------|
| Azure Load Testing  | JMeter/YAML  | Azure DevOps, GitHub Actions | Managed, supports private endpoints    |
| AWS Distributed Load Testing | JMeter | AWS CodePipeline, CLI        | Scalable, integrates with CloudWatch   |
| Google Cloud DLT    | JMeter       | Cloud Build, CLI             | Managed, integrates with GCP metrics   |
| k6                  | JavaScript   | All major CI/CD, Kubernetes  | Modern, cloud-native, Grafana Cloud    |
| Locust              | Python       | All major CI/CD, Docker      | Flexible, distributed, Pythonic        |
| Artillery           | JavaScript   | Node.js, CI/CD, AWS Lambda   | Lightweight, serverless support        |
| Gatling             | Scala/Java   | Jenkins, GitHub Actions      | High performance, detailed reports     |
| JMeter              | Java         | All major CI/CD, CLI         | Mature, extensible, large ecosystem    |
| NBomber             | C#/F#        | .NET, CI/CD                  | .NET-native, integrates with test runners |

**Tip:** For cloud-native systems, prefer tools that support distributed execution, containerization, and integration with cloud monitoring (e.g., Prometheus, Grafana, CloudWatch).

## Example: k6 Load Test Script

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp-up
    { duration: '5m', target: 200 },  // Peak load
    { duration: '2m', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests < 500ms
    http_req_failed: ['rate<0.01'],   // <1% errors
  },
};

export default function () {
  const res = http.get('https://api.example.com/health');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}
```

## Example: Azure Load Testing YAML

```yaml
# azure-load-test.yaml
resources:
  - name: load-test
    type: Microsoft.LoadTestService/loadTests
    properties:
      description: "API Load Test"
      loadTestConfig:
        engineInstances: 2
        testPlan: "loadtest.jmx"
      secrets:
        - name: "endpoint"
          value: "https://api.example.com"
```

## Best Practices (2025)

- **Automate load tests in CI/CD:** Run load tests on every major release using GitHub Actions, Azure Pipelines, or your preferred CI/CD tool.
- **Use Infrastructure as Code:** Provision test environments with Terraform or ARM/Bicep templates for consistency.
- **Monitor everything:** Integrate with Prometheus, Grafana, CloudWatch, or Azure Monitor for real-time insights.
- **Test from multiple regions:** Use cloud-based agents to simulate global traffic patterns.
- **Leverage LLMs:** Use LLMs to generate test scenarios, analyze logs, and suggest optimizations.
- **Document and iterate:** Keep detailed records of test results and continuously refine your scenarios.

## References
- [Azure Load Testing Documentation](https://learn.microsoft.com/en-us/azure/load-testing/)
- [k6 Documentation](https://k6.io/docs/)
- [AWS Distributed Load Testing](https://aws.amazon.com/solutions/implementations/distributed-load-testing-on-aws/)
- [Google Cloud DLT](https://cloud.google.com/solutions/distributed-load-testing-using-kubernetes)

---

Load testing is essential for ensuring your system can handle real-world traffic and scale reliably. By following modern best practices and leveraging cloud-native tools, you can confidently deliver performant, resilient applications.
