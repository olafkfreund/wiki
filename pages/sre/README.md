# SRE

Site reliability engineering (SRE) is a software engineering approach to IT operations. SRE teams use software as a tool to manage systems, solve problems, and automate operations tasks.

SRE takes the tasks that have historically been done by operations teams, often manually, and instead gives them to engineers or operations teams who use software and automation to solve problems and manage production systems.&#x20;

SRE is a valuable practice when creating scalable and highly reliable software systems. It helps manage large systems through code, which is more scalable and sustainable for system administrators (sysadmins) managing thousands or hundreds of thousands of machines.&#x20;

The concept of site reliability engineering comes from the Google engineering team and is credited to Ben Treynor Sloss.&#x20;

SRE helps teams find a balance between releasing new features and ensuring reliabilty for users.

In this context, standardization and automation are 2 important components of the SRE model. Here, site reliability engineers seek to enhance and automate operations tasks.

In these ways, SRE helps improve system reliability today—and as it grows over time.&#x20;

SRE supports teams that are moving their IT operations from a traditional approach to a cloud-native approach.

### What does a site reliability engineer do? <a href="#what-does-a-sre-do" id="what-does-a-sre-do"></a>

A site reliability engineer is a unique role that requires either a background as a sysadmin, a software developer with additional operations experience, or someone in an IT operations role that also has software development skills.&#x20;

SRE teams are responsible for how code is deployed, configured, and monitored, as well as the availability, latency, change management, emergency response, and capacity management of services in production.

SRE teams determine the launch of new features by using service-level agreements (SLAs) to define the required reliability of the system through service-level indicators (SLI) and service-level objectives (SLO).&#x20;

An SLI measures specific aspects of provided service levels. Key SLIs include request latency, availability, error rate, and system throughput. An SLO is based on the target value or range for a specified service level based on the SLI.

An SLO for the required system reliability is then based on the downtime determined to be acceptable. This downtime level is referred to as an error budget—the maximum allowable threshold for errors and outages.&#x20;

With SRE, 100% reliability is not expected—failure is planned for and expected.

Once established, the development team can "spend" the error budget when releasing a new feature. Using the SLO and error budget, the team then determines whether a product or service can launch based on the available error budget.

If a service is running within the error budget, then the development team can launch whenever it wants, but if the system currently has too many errors or goes down for longer than the error budget allows then no new launches can take place until the errors are within budget.  &#x20;

The development team conducts automated operations tests to demonstrate reliability.&#x20;

Site reliability engineers split their time between operations tasks and project work. According to SRE best practices from Google, site reliability engineers can only spend a maximum of 50% of their time on operations—and they should be monitored to ensure they don’t go over. &#x20;

The rest of their time should be spent on development tasks like creating new features, scaling the system, and implementing automation.

Excess operational work and poorly performing services can be redirected back to the development team so that the site reliability engineer doesn't spend too much time on the operations of an application or service.&#x20;

Automation is an important part of the site reliability engineer’s role. If they are repeatedly dealing with a problem, then they will automate a solution.&#x20;

Maintaining the balance between operations and development work is a key component of SRE.&#x20;

### DevOps vs. SRE <a href="#devops-vs-sre" id="devops-vs-sre"></a>

DevOps is an approach to culture, automation, and platform design intended to deliver increased business value and responsiveness through rapid, high-quality service delivery. SRE can be considered an implementation of DevOps.

Like DevOps, SRE is about team culture and relationships. Both SRE and DevOps work to bridge the gap between development and operations teams to deliver services faster.&#x20;

Faster application development life cycles, improved service quality and reliability, and reduced IT time per application developed are benefits that can be achieved by both DevOps and SRE practices.

However, SRE differs from DevOps because it relies on site reliability engineers within the development team who also have an operations background to remove communication and workflow problems.

The site reliability engineer role itself combines the skills of development teams and operations teams by requiring an overlap in responsibilities.&#x20;

SRE can help DevOps teams whose developers are overwhelmed by operations tasks and need someone with more specialized operations skills.&#x20;

When coding and building new features, DevOps focuses on moving through the development pipeline efficiently, while SRE focuses on balancing site reliability with creating new features.&#x20;

Here, modern application platforms based on container technology, Kubernetes and microservices are critical to DevOps practices, helping deliver security and innovative software services.
