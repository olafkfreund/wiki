# Different Testing Methods

## Unit vs Integration vs System vs E2E Testing <a href="#unit-vs-integration-vs-system-vs-e2e-testing" id="unit-vs-integration-vs-system-vs-e2e-testing"></a>

The table below illustrates the most critical characteristics and differences among Unit, Integration, System, and End-to-End Testing, and when to apply each methodology in a project.

|                         | Unit Test              | Integration Test                             | System Testing                                            | E2E Test                                                      |
| ----------------------- | ---------------------- | -------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------- |
| **Scope**               | Modules, APIs          | Modules, interfaces                          | Application, system                                       | All sub-systems, network dependencies, services and databases |
| **Size**                | Tiny                   | Small to medium                              | Large                                                     | X-Large                                                       |
| **Environment**         | Development            | Integration test                             | QA test                                                   | Production like                                               |
| **Data**                | Mock data              | Test data                                    | Test data                                                 | Copy of real production data                                  |
| **System Under Test**   | Isolated unit test     | Interfaces and flow data between the modules | Particular system as a whole                              | Application flow from start to end                            |
| **Scenarios**           | Developer perspectives | Developers and IT Pro tester perspectives    | Developer and QA tester perspectives                      | End-user perspectives                                         |
| **When**                | After each build       | After Unit testing                           | Before E2E testing and after Unit and Integration testing | After System testing                                          |
| **Automated or Manual** | Automated              | Manual or automated                          | Manual or automated                                       | Manual or automated                                           |

## Detailed Testing Methodologies

### Unit Testing

Unit testing focuses on testing individual components or functions in isolation. In a DevOps context, unit tests are:

- **Fast:** Execute in milliseconds
- **Numerous:** Often thousands in a single project
- **Isolated:** No external dependencies (DB, API, filesystem)
- **Automated:** Run on every commit via CI pipeline

**Example (Python with pytest):**

```python
# Function to test
def add_numbers(a, b):
    return a + b

# Unit test
def test_add_numbers():
    assert add_numbers(1, 2) == 3
    assert add_numbers(-1, 1) == 0
    assert add_numbers(0, 0) == 0
```

### Integration Testing

Integration testing verifies that different modules or services work together correctly. In DevOps pipelines, these tests:

- **Target Interfaces:** API endpoints, message queues, data exchanges
- **Use Real Dependencies:** Often connect to actual databases or test versions
- **Run After Unit Tests:** Part of the CI/CD pipeline but less frequently than unit tests

**Example (API Integration Test with Jest):**

```javascript
describe('User API Integration', () => {
  it('should create and retrieve a user', async () => {
    // Create a user
    const createResponse = await request(app)
      .post('/api/users')
      .send({ name: 'Test User', email: 'test@example.com' });
    
    expect(createResponse.status).toBe(201);
    const userId = createResponse.body.id;
    
    // Retrieve the user
    const getResponse = await request(app).get(`/api/users/${userId}`);
    expect(getResponse.status).toBe(200);
    expect(getResponse.body.name).toBe('Test User');
  });
});
```

### System Testing

System testing evaluates the complete application to ensure it meets specified requirements. In DevOps:

- **Environment:** Performed in environments that closely mimic production
- **Scope:** Tests the entire system's functionality, not just individual components
- **Automation:** Increasingly automated in mature DevOps pipelines

**Example (System Test Scenario):**

```gherkin
Feature: Order Processing System
  
  Scenario: Complete order placement flow
    Given a customer with items in their cart
    When they proceed to checkout
    And enter valid payment information
    And confirm the order
    Then the order should be saved in the database
    And inventory should be updated
    And a confirmation email should be sent
    And the payment gateway should process the transaction
```

### End-to-End (E2E) Testing

E2E testing validates the entire application flow from start to finish. In modern DevOps:

- **User-Centered:** Tests from the user's perspective
- **Full Stack:** Includes UI, backend, databases, and external services
- **Real Environment:** Uses production-like environments with realistic data
- **Automation:** Often uses tools like Selenium, Cypress, or Playwright

**Example (E2E Test with Cypress):**

```javascript
describe('E-commerce Checkout', () => {
  it('allows a user to complete a purchase', () => {
    // Visit the store
    cy.visit('/store');
    
    // Add products to cart
    cy.get('[data-product-id="123"]').click();
    cy.get('[data-add-to-cart]').click();
    
    // Go to checkout
    cy.get('[data-cart]').click();
    cy.get('[data-checkout]').click();
    
    // Fill shipping information
    cy.get('#name').type('Test User');
    cy.get('#address').type('123 Test St');
    // ... more fields
    
    // Complete order
    cy.get('#submit-order').click();
    
    // Verify success
    cy.get('.order-confirmation').should('contain', 'Order Complete');
    cy.get('.order-number').should('exist');
  });
});
```

## Additional Testing Methods in DevOps

### Performance Testing

Performance testing evaluates system responsiveness and stability under various load conditions.

- **Types:**
  - **Load Testing:** Behavior under expected load
  - **Stress Testing:** Behavior at or beyond capacity
  - **Scalability Testing:** How system scales with increasing load
  - **Endurance Testing:** System behavior under sustained load

**Example (Load test with k6):**

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 100,  // 100 virtual users
  duration: '5m',  // 5 minutes test
};

export default function() {
  http.get('https://api.example.com/products');
  sleep(1);
  http.post('https://api.example.com/cart', JSON.stringify({
    productId: 'ABC123',
    quantity: 1
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  sleep(2);
}
```

### Security Testing

Security testing identifies vulnerabilities in the application to prevent breaches and attacks.

- **Types:**
  - **SAST:** Static Application Security Testing (code analysis)
  - **DAST:** Dynamic Application Security Testing (running app)
  - **Penetration Testing:** Simulated cyberattacks
  - **Dependency Scanning:** Checks for vulnerable dependencies

**Example (SAST Integration in CI Pipeline - GitHub Actions):**

```yaml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run SAST with SonarQube
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    
    - name: Dependency vulnerability scan
      run: |
        npm audit --audit-level=high
        # or for Python
        # pip install safety
        # safety check
```

### Chaos Testing

Chaos testing deliberately introduces failures to ensure system resilience.

- **Purpose:** Verify recovery mechanisms and fault tolerance
- **Tools:** Chaos Monkey, Gremlin, Litmus
- **Implementation:** Targeted at infrastructure components, gradually moving toward application layer

**Example (Chaos Experiment with Chaos Toolkit):**

```yaml
---
version: 1.0.0
title: What happens when a Kubernetes pod is killed?
description: Verifying our service can recover from pod failures
tags:
  - kubernetes
  - pod
  - resilience

steady-state-hypothesis:
  title: Application responds
  probes:
  - name: api-responds
    type: probe
    tolerance: 200
    provider:
      type: http
      url: http://app.example.com/health
      
method:
- type: action
  name: terminate-app-pod
  provider:
    type: python
    module: chaosk8s.pod.actions
    func: terminate_pods
    arguments:
      label_selector: app=my-service
      ns: default
      
- type: probe
  name: wait-for-recovery
  provider:
    type: process
    path: sleep
    arguments: "30"
    
rollbacks:
- type: action
  name: deploy-app
  provider:
    type: process
    path: kubectl
    arguments: "apply -f k8s/app-deployment.yaml"
```

## Implementing Testing in CI/CD Pipelines

A typical DevOps testing flow in a CI/CD pipeline:

1. **Commit Stage:**
   - Static Code Analysis
   - Unit Tests
   - SAST (Security Scans)

2. **Build Stage:**
   - Dependency Checks
   - Build Artifacts

3. **Integration Stage:**
   - Integration Tests
   - API Tests

4. **Deployment to Test:**
   - System Tests
   - Performance Tests
   - DAST (Security Scans)

5. **Deployment to Staging:**
   - E2E Tests
   - Chaos Tests
   - User Acceptance Tests

6. **Production Deployment:**
   - Smoke Tests
   - Canary Testing
   - A/B Testing

**Example (Azure DevOps Pipeline):**

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Build
  jobs:
  - job: BuildAndTest
    steps:
    - script: npm install
    - script: npm run lint
      displayName: 'Static Analysis'
    - script: npm run test:unit
      displayName: 'Unit Tests'
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/junit.xml'

- stage: Integration
  dependsOn: Build
  jobs:
  - job: IntegrationTests
    steps:
    - script: npm run test:integration
      displayName: 'Integration Tests'

- stage: SystemTest
  dependsOn: Integration
  jobs:
  - job: DeployTest
    steps:
    - task: AzureWebApp@1
      inputs:
        azureSubscription: 'test-subscription'
        appName: 'myapp-test'
        package: '$(Build.ArtifactStagingDirectory)/*.zip'
    - script: npm run test:e2e
      displayName: 'E2E Tests'
    - script: npm run test:performance
      displayName: 'Performance Tests'

- stage: Production
  dependsOn: SystemTest
  jobs:
  - deployment: Production
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'prod-subscription'
              appName: 'myapp-prod'
              package: '$(Build.ArtifactStagingDirectory)/*.zip'
          - script: npm run test:smoke
            displayName: 'Smoke Tests'
```

## Best Practices for Testing in DevOps

1. **Shift Left:** Move testing earlier in the development lifecycle
2. **Test Automation:** Automate as many tests as possible, especially repeatable ones
3. **Test Data Management:** Maintain quality test data that represents production scenarios
4. **Parallel Testing:** Run tests concurrently to save time
5. **Test Environment Parity:** Keep test environments as close to production as possible
6. **Continuous Testing:** Make testing a continuous part of the pipeline, not just at specific gates
7. **Test Observability:** Monitor and analyze test results for trends and patterns
8. **Security Testing Integration:** Make security testing a fundamental part of the testing strategy
