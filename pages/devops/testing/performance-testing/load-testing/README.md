# Load Testing

"_Load testing is performed to determine a system's behavior under both normal and anticipated peak load conditions._" - [Load testing - Wikipedia](https://en.wikipedia.org/wiki/Load\_testing)

A load test is designed to determine how a system behaves under expected normal and peak workloads. Specifically its main purpose is to confirm if a system can handle the expected load level. Depending on the target system this could be concurrent users, requests per second or data size.

### Why Load Testing <a href="#why-load-testing" id="why-load-testing"></a>

The main objective is to prove the system can behave normally under the expected normal load before releasing it to production. The criteria which defines "behave normally" will depend on your target, this may be as simple as "the system remains available", but it could also include meeting a response time SLA or error rate.

Additionally, the results of a load test can also be used as data to help with capacity planning and calculating scalability.

### Load Testing Design Blocks <a href="#load-testing-design-blocks" id="load-testing-design-blocks"></a>

There are a number of basic component which are required to carry out a load test.

1. In order to have meaningful results the system needs to be tested in a production-like environment with a network and hardware which closely resembles the expected deployment environment.
2. The load test will consist of a module which simulates user activity. Of course the composition of this "user activity" will vary based on the type of application being tested. For example, an e-commerce website might simulate user browsing and purchasing items, but an IoT data ingestion pipeline would simulate a stream of device readings. Please ensure the simulation is as close to real activity as possible, and consider not just volume but also patterns and variability. For example, if the simulator data is too uniform or predictable, then cache/hit ratios may impact your results.
3. The load test will be initiated from a component external to the target system which can control the amount of load applied. This can be a single agent, but may need to scaled to multiple agents in order to achieve higher levels of activity.
4. Although not required to run a load test, it is advisable to have monitoring and/or logging in place to be able to measure the impact of the test and discover potential bottlenecks.

### Applying the Load Testing <a href="#applying-the-load-testing" id="applying-the-load-testing"></a>

#### Planning <a href="#planning" id="planning"></a>

1. **Identify key scenarios to measure** - Gather these scenarios from Product Owner, they should provide a representative sample of real world traffic.
2. **Determine expected normal and peak load for the scenarios** - Determine a load level such as concurrent users or requests per second to find the size of the load test you will run.
3. **Identify success criteria metrics** - These may be on testing side such as response time and error rate, or they may be on the system side such as CPU and memory usage.
4. **Select the right tool** - Many frameworks exist for load testing so consider if features and limitations are suitable for your needs. (Some popular tools are listed below).

#### Execution <a href="#execution" id="execution"></a>

It is recommended to use an existing testing framework (see below). These tools will provide a method of both specifying the user activity scenarios and how to execute those at load. It is common to slowly ramp up to your desired load to better replicate real world behavior. Once you have reached your defined workload, maintain this level long enough to see if your system stabilizes. To finish up the test you should also ramp to see record how the system slows down as well.

You should also consider the origin of your load test traffic. Depending on the scope of the target system you may want to initiate from a different location to better replicate real world traffic such as from a different region.

**Note:** Before starting please be aware of any restrictions on your network such as DDOS protection where you may need to notify a network administrator or apply for an exemption.

#### Further Testing <a href="#further-testing" id="further-testing"></a>

After completing your load test you should be set up to continue on to additional related testing such as;

* **Soak Testing** - Also known as **Endurance Testing**. Performing a load test over an extended period of time to ensure long term stability.
* **Stress Testing** - Gradually increasing the load to find the limits of the system and identify the maximum capacity.
* **Spike Testing** - Introduce a sharp short-term increase into the load scenarios.
* **Scalability Testing** - Re-testing of a system as your expand horizontally or vertically to measure how it scales.

### Load Testing Frameworks and Tools <a href="#load-testing-frameworks-and-tools" id="load-testing-frameworks-and-tools"></a>

Here are a few popular load testing frameworks you may consider, and the languages used to define your scenarios.

* **Azure Load Testing** ([https://learn.microsoft.com/en-us/azure/load-testing/](https://learn.microsoft.com/en-us/azure/load-testing/)) - Managed platform for running load tests on Azure. It allows to run and monitor tests automatically, source secrets from the KeyVault, generate traffic at scale, and load test Azure private endpoints. In the simple case, it executes load tests with HTTP GET traffic to a given endpoint. For the more complex cases, you can upload your own **JMeter scenarios**.
* **JMeter** ([https://github.com/apache/jmeter](https://github.com/apache/jmeter)) - Has built in patterns to test without coding, but can be extended with Java.
* **Artillery** ([https://artillery.io/](https://artillery.io/)) - Write your scenarios in Javascript, executes a node application.
* **Gatling** ([https://gatling.io/](https://gatling.io/)) - Write your scenarios in Scala with their DSL.
* **Locust** ([https://locust.io/](https://locust.io/)) - Write your scenarios in Python using the concept of concurrent user activity.
* **K6** ([https://k6.io/](https://k6.io/)) - Write your test scenarios in Javascript, available as open source or as SaaS.
* **NBomber** ([https://nbomber.com/](https://nbomber.com/)) - Write your test scenarios in C# or F#, available integration with test runners (NUnit/xUnit).

### Conclusion <a href="#conclusion" id="conclusion"></a>

A load test is critical step to understand if a target system will be reliable under the expected real world traffic.

Of course, it's only as good as your ability to predict the expected load, so it's important to follow up with other further testing to truly understand how your system behaves in different situations.
