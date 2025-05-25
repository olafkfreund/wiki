# Understanding SLI, SLO, and SLA

### Service Level Indicator (**SLI)**: <a href="#c0e1" id="c0e1"></a>

Imagine that SLI means how well something is doing what it's supposed to do. In a technical overview, this is something you can "feel" when using products that use this approach. For instance, from a user's perspective, **response time**, **error rate**, and **availability** are **Indicators**.

As mentioned above, we can get deeper and see a classic example of **SLI**:

* **Request Latency** for requests should be under 330 milliseconds
* The **availability** of the server should be 99.9% for a given period.
* **Throughput** for an e-Commerce endpoint, for instance, using the number of successful purchases per minute
* The **error rate** for the service should be below 1%

All the points above help us **measure the service level** delivered by a system. When thinking about **SLI**, remember the association with Product Managers, Product Owners, and SREs, where technical and clean objectives are designed.

### Service Level Objectives (**SLO)**: <a href="#b20a" id="b20a"></a>

On the other side, **SLO** works with the word **"promise."** This happens because you must perform a certain way most of the time and quantify the reliability of a product. After all, it is **directly** **related** to the **customer** **experience**.

Can some cases be associated with **SLO**:

* Response time of 100 milliseconds for **all** requests
* System uptime of 99.99%
* An error rate of less than 0.8%
* Error budget

Generally, SLO attempts tend to be aggressive. However, the goal of perfection could not be worth it. In the end, the customers need to be happy. If 99.99% causes customers happiness and mindfulness, it is unnecessary to change for a higher value.

In the **Preface** of the book **Implementing Service Level Objectives: A Practical Guide to Slis, Slos, and Error Budgets**[**\[7\]**](https://www.amazon.com.br/Implementing-Service-Level-Objectives-Practical/dp/1492076813/ref=sr\_1\_12?\_\_mk\_pt\_BR=%C3%85M%C3%85%C5%BD%C3%95%C3%91\&crid=180ATAPBHQHCB\&keywords=service+level+indicator\&qid=1681934586\&sprefix=service+level+indicato%2Caps%2C222\&sr=8-12\&ufe=app\_do%3Aamzn1.fos.db68964d-7c0e-4bb2-a95c-e5cb9e32eb12), the author gives a great example about **You Don't Have to Be Perfect** that could help you on your journey with **SLO**.

### Service Level Agreement (SLA): <a href="#e122" id="e122"></a>

If some "agreement" mentioned above is broken, a value, price, or touchable must be on the table. In other words, a contract. Almost all of the consequences are **financial**, but can vary as said before, for instance:

* Uptime falls below 99.9% in a Black Friday week. As a result, the provider will issue a discount of 40% to the customer.
* Support requests will be responded to within 1 hour.
* Maintenance will be scheduled outside of business hours.

---

## Real-World SLI, SLO, and SLA Examples in Public Clouds

### AWS Example

* **SLI:** API Gateway average latency (measured via CloudWatch):

  * `SLI = Percentage of requests with latency < 200ms`

* **SLO:** 99.5% of API requests must have latency < 200ms over a rolling 30-day window.
* **SLA:** If monthly API uptime drops below 99.9%, the customer receives a 10% service credit.

**Implementation:**

* Use CloudWatch metrics and alarms to monitor latency and availability.
* Define SLOs in documentation and dashboards.
* Reference: [AWS Service Level Agreements](https://aws.amazon.com/legal/service-level-agreements/)

### Azure Example

* **SLI:** Azure App Service HTTP 5xx error rate (measured via Azure Monitor):

  * `SLI = Percentage of successful HTTP requests`

* **SLO:** 99.95% of requests must succeed each month.
* **SLA:** If uptime falls below 99.95%, a service credit is issued per [Azure SLA](https://azure.microsoft.com/en-us/support/legal/sla/).

**Implementation:**

* Use Azure Monitor and Application Insights for real-time tracking.
* Set up alerts and dashboards for SLO compliance.

### GCP Example

* **SLI:** Google Cloud Storage availability (measured via Stackdriver Monitoring):

  * `SLI = Percentage of successful object retrievals`

* **SLO:** 99.99% monthly availability for object retrievals.
* **SLA:** If availability drops below 99.99%, customers receive credits as per [GCP SLA](https://cloud.google.com/storage/sla).

**Implementation:**

* Use Cloud Monitoring to track and alert on SLI breaches.
* Document SLOs and SLAs in internal and customer-facing docs.

---

## How a Private Company Defines and Follows SLI, SLO, and SLA

### 1. Define SLIs (What to Measure)

* Identify key user journeys (e.g., login, checkout, API call).
* Choose measurable indicators (latency, error rate, availability, throughput).
* Example: `SLI = Percentage of checkout requests completed in < 1s`.

### 2. Set SLOs (Targets for SLIs)

* Set realistic, customer-focused targets (e.g., 99.9% of checkouts < 1s).
* Involve product, engineering, and business teams.
* Document SLOs in runbooks and dashboards.

### 3. Establish SLAs (External Commitments)

* Define contractual obligations (e.g., 99.9% uptime per month, 1-hour support response).
* Specify remedies for breaches (service credits, penalties).
* Communicate SLAs to customers and stakeholders.

### 4. Monitor and Enforce

* Use cloud-native tools (CloudWatch, Azure Monitor, GCP Monitoring) to track SLIs.
* Automate alerting for SLO breaches.
* Review SLO/SLA performance in regular ops meetings.

### 5. Iterate and Improve

* Analyze incidents and error budgets.
* Adjust SLOs as business needs evolve.
* Share learnings with engineering and product teams.

---

## Example: SLI/SLO/SLA Table for a SaaS API

| Metric         | SLI Definition                        | SLO Target         | SLA Commitment         |
|---------------|---------------------------------------|--------------------|-----------------------|
| Latency       | % requests < 300ms (API Gateway)      | 99.5% per month    | 99.0% per month, 10% credit if breached |
| Error Rate    | % HTTP 5xx errors (App Service)       | <0.5% per month    | <1% per month, 5% credit if breached   |
| Availability  | % successful requests (Cloud Storage) | 99.99% per month   | 99.9% per month, 10% credit if breached|

---

**Best Practices:**

* Use Infrastructure as Code (Terraform, ARM, Deployment Manager) to automate monitoring setup.
* Store SLO definitions in version control and keep them visible to all teams.
* Regularly review and update SLOs/SLA as your product and customer needs change.

---

For more, see:

* [Google SRE Workbook: SLOs](https://sre.google/workbook/slo/)
* [AWS Well-Architected Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html)
* [Azure Monitor Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)
