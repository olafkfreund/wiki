# E2E Testing Methods for DevOps

End-to-End (E2E) testing is a crucial methodology in modern DevOps practices that validates the entire system's workflow from start to finish. This approach ensures that all integrated components work together as expected in production-like environments.

## Core E2E Testing Methodologies

### Horizontal Test <a href="#horizontal-test" id="horizontal-test"></a>

This method is used very commonly. It occurs horizontally across the context of multiple applications. Take an example of a data ingest management system.

![Horizontal Test](https://microsoft.github.io/code-with-engineering-playbook/automated-testing/e2e-testing/images/horizontal-e2e-testing.png)

The inbound data may be injected from various sources, but it then "flatten" into a horizontal processing pipeline that may include various components, such as a gateway API, data transformation, data validation, storage, etc... Throughout the entire Extract-Transform-Load (ETL) processing, the data flow can be tracked and monitored under the horizontal spectrum with little sprinkles of optional, and thus not important for the overall E2E test case, services, like logging, auditing, authentication.

#### Implementation Example: Kubernetes-based Data Pipeline

```yaml
# Example Horizontal E2E Test using kubectl and a test job
apiVersion: batch/v1
kind: Job
metadata:
  name: data-pipeline-e2e-test
spec:
  template:
    spec:
      containers:
      - name: test-runner
        image: test-framework:latest
        command: ["python", "/test/run_e2e_horizontal_test.py"]
        env:
        - name: GATEWAY_ENDPOINT
          value: "http://api-gateway:8080"
        - name: STORAGE_ENDPOINT
          value: "http://storage-service:9000"
      restartPolicy: Never
  backoffLimit: 0
```

### Vertical Test <a href="#vertical-test" id="vertical-test"></a>

In this method, all most critical transactions of any application are verified and evaluated right from the start to finish. Each individual layer of the application is tested starting from top to bottom. Take an example of a web-based application that uses middleware services for reaching back-end resources.

![Vertical Test](https://microsoft.github.io/code-with-engineering-playbook/automated-testing/e2e-testing/images/vertical-e2e-testing.png)

In such case, each layer (tier) is required to be fully tested in conjunction with the "connected" layers above and beneath, in which services "talk" to each other during the end-to-end data flow. All these complex testing scenarios will require proper validation and dedicated automated testing. Thus, this method is much more difficult.

#### Implementation Example: Terraform and GitHub Actions

```yaml
# Example GitHub Actions workflow for vertical E2E testing
name: Vertical E2E Testing

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  vertical-e2e-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Test Environment
        run: |
          terraform init
          terraform apply -auto-approve -var-file=e2e-test.tfvars
      
      - name: Run Vertical E2E Tests
        run: |
          npm install
          npm run test:e2e-vertical
      
      - name: Cleanup Resources
        if: always()
        run: terraform destroy -auto-approve -var-file=e2e-test.tfvars
```

## Additional Testing Strategies

### Cross-Browser/Cross-Platform Testing

This methodology ensures that applications function correctly across different browsers, operating systems, and devices. Essential for web applications with diverse user bases.

```bash
# Example using Playwright for cross-browser testing
npx playwright test --browser=chromium,firefox,webkit
```

### Performance-Focused E2E Testing

Combines end-to-end functional validation with performance benchmarks to ensure the system meets both functional and non-functional requirements.

```python
# Example using Locust for performance-focused E2E testing
from locust import HttpUser, task, between

class UserJourney(HttpUser):
    wait_time = between(1, 5)
    
    @task
    def complete_purchase_flow(self):
        # Login
        self.client.post("/login", json={"username": "test_user", "password": "password"})
        # Browse products
        self.client.get("/products")
        # Add to cart
        self.client.post("/cart", json={"product_id": 1, "quantity": 1})
        # Checkout
        self.client.post("/checkout")
```

## E2E Test Cases Design Guidelines <a href="#e2e-test-cases-design-guidelines" id="e2e-test-cases-design-guidelines"></a>

Below enlisted are key **guidelines** that should be kept in mind while designing the test cases for performing E2E testing:

* Test cases should be designed from the end user's perspective.
* Should focus on testing some existing features of the system.
* Multiple scenarios should be considered for creating multiple test cases.
* Different sets of test cases should be created to focus on multiple scenarios of the system.
* Tests should be independent and idempotent whenever possible.
* Implement proper test data management to ensure test reproducibility.
* Consider using service virtualization for unavailable or unstable dependencies.
* Include data validation checkpoints at critical stages of the workflow.

## DevOps Best Practices for E2E Testing

### Infrastructure as Code (IaC) for Test Environments

Use Terraform, Ansible, or other IaC tools to create reproducible test environments:

```hcl
# Example Terraform snippet for test environment
resource "aws_instance" "e2e_test_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  
  tags = {
    Name = "E2E-Test-Environment"
    Purpose = "Testing"
  }
}

resource "aws_security_group" "test_sg" {
  name = "e2e-test-security-group"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Containerization for Test Consistency

Using Docker to ensure test environment consistency:

```dockerfile
# Example Dockerfile for E2E testing environment
FROM node:16-alpine

WORKDIR /app

# Install testing tools
RUN npm install -g cypress@10.3.0
RUN apk add --no-cache chromium

# Copy test files
COPY tests/ /app/tests/
COPY cypress.json /app/

# Run tests
ENTRYPOINT ["cypress", "run"]
```

### Automated E2E Testing in CI/CD Pipelines

```yaml
# Example Azure Pipeline for E2E testing
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: E2ETest
  jobs:
  - job: RunE2ETests
    steps:
    - task: DockerCompose@0
      inputs:
        containerregistrytype: 'Container Registry'
        dockerComposeFile: 'docker-compose.test.yml'
        action: 'Run services'
        
    - script: |
        npm install
        npm run test:e2e
      displayName: 'Run E2E Tests'
      
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results.xml'
        mergeTestResults: true
        testRunTitle: 'E2E Tests'
```

### Monitoring and Observability Integration

Collect telemetry during E2E tests to identify performance bottlenecks:

```python
# Example using OpenTelemetry for test instrumentation
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

def setup_telemetry():
    trace.set_tracer_provider(TracerProvider())
    jaeger_exporter = JaegerExporter(
        agent_host_name="localhost",
        agent_port=6831,
    )
    trace.get_tracer_provider().add_span_processor(
        BatchSpanProcessor(jaeger_exporter)
    )
    
    return trace.get_tracer(__name__)

# Use in tests
tracer = setup_telemetry()
with tracer.start_as_current_span("e2e_test_execution"):
    # Your test code here
    pass
```

## Tool Selection for E2E Testing

| Testing Need | Recommended Tools | Cloud Integration |
|--------------|-------------------|-------------------|
| UI Testing | Cypress, Playwright, Selenium | AWS Device Farm, BrowserStack |
| API Testing | Postman, REST-assured, Karate | API Gateway Test Harness |
| Mobile Testing | Appium, Detox | Firebase Test Lab, AWS Device Farm |
| Performance | JMeter, k6, Locust | Azure Load Testing, AWS Load Balancer |
| Infrastructure | Terratest, Goss, InSpec | Cloud-provider specific testing frameworks |

Selecting the right tools based on your tech stack and cloud provider can significantly improve testing efficiency and coverage while reducing maintenance overhead.
