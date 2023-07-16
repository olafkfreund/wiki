# Understanding SLI,SLO and SLA

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
