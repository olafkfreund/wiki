# E2E Testing Methods

End-to-end (E2E) testing validates the complete workflow of an application, ensuring all integrated components work together as expected. In modern DevOps, E2E tests are critical for cloud-native, microservices, and distributed systems across AWS, Azure, GCP, and on-prem environments.

---

## Horizontal Test <a href="#horizontal-test" id="horizontal-test"></a>

A horizontal E2E test covers a business process or data flow that spans multiple applications or services. This is common in data pipelines, ETL workflows, or event-driven architectures.

**Example:**

- Data is ingested from multiple sources (e.g., AWS S3, Azure Event Hub, GCP Pub/Sub)
- Flows through a gateway API, transformation service, validation, and storage (e.g., data lake)
- E2E test verifies the data is correctly processed and stored, regardless of the source

![Horizontal Test](https://microsoft.github.io/code-with-engineering-playbook/automated-testing/e2e-testing/images/horizontal-e2e-testing.png)

**Best Practice:** Use synthetic data and automate validation at each stage. Integrate E2E tests into your CI/CD pipeline (e.g., GitHub Actions, Azure Pipelines, GitLab CI).

---

## Vertical Test <a href="#vertical-test" id="vertical-test"></a>

A vertical E2E test validates a critical transaction or workflow through all layers of a single application—from frontend to backend and database.

**Example:**

- User submits a form in a web app (frontend)
- Request passes through API gateway, middleware, and backend services
- Data is persisted in a database (e.g., PostgreSQL, DynamoDB, Cosmos DB)
- E2E test checks the end-to-end flow, including error handling and data integrity

![Vertical Test](https://microsoft.github.io/code-with-engineering-playbook/automated-testing/e2e-testing/images/vertical-e2e-testing.png)

**Best Practice:** Automate vertical E2E tests for critical user journeys. Use tools like Selenium, Playwright, or Cypress for UI, and Postman or REST-assured for APIs.

---

## E2E Test Case Design Guidelines <a href="#e2e-test-cases-design-guidelines" id="e2e-test-cases-design-guidelines"></a>

When designing E2E test cases:

- Design from the end user’s perspective (user stories, business flows)
- Focus on core features and critical paths
- Cover both positive and negative scenarios
- Use data-driven tests for multiple input variations
- Automate E2E tests in your CI/CD pipeline for every deployment
- Monitor and report E2E test results for fast feedback

---

## Real-Life DevOps Example: E2E Test in a CI/CD Pipeline

**Scenario:**

- Microservices deployed on Kubernetes (AWS EKS, Azure AKS, GCP GKE)
- E2E test runs after deployment to validate the full user workflow

**GitHub Actions Example:**

```yaml
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Kubernetes
        run: ./deploy.sh
      - name: Run E2E Tests
        run: npm run test:e2e
```

**Best Practice:**

- Run E2E tests on every pull request and before production releases
- Use cloud-native test environments (ephemeral environments, preview deployments)
- Integrate with monitoring and alerting for failed E2E tests

---

## References

- [Microsoft Engineering Playbook: E2E Testing](https://microsoft.github.io/code-with-engineering-playbook/automated-testing/e2e-testing/)
- [Cypress E2E Testing](https://docs.cypress.io/guides/overview/why-cypress)
- [Playwright E2E Testing](https://playwright.dev/docs/intro)
- [Selenium E2E Testing](https://www.selenium.dev/documentation/)

> **Tip:** For cloud-native and microservices architectures, combine horizontal and vertical E2E tests for comprehensive coverage.

---

```markdown
- [E2E Testing Methods](pages/testing/e2e-testing/e2e-testing-methods.md)
