# Simplicity

> A complex system that works is invariably found to have evolved from a simple system that worked.
>
> [Gall’s Law](https://en.wikipedia.org/wiki/John\_Gall\_\(author\))

Simplicity is an important goal for SREs, as it strongly correlates with reliability: simple software breaks less often and is easier and faster to fix when it does break. Simple systems are easier to understand, easier to maintain, and easier to test.

For SREs, simplicity is an end-to-end goal: it should extend beyond the code itself to the system architecture and the tools and processes used to manage the software lifecycle. This chapter explores some examples that demonstrate how SREs can measure, think about, and encourage simplicity.

## Measuring Complexity <a href="#measuring-complexity" id="measuring-complexity"></a>

Measuring the complexity of software systems is not an absolute science. There are a number of ways to measure software code complexity, most of which are quite objective.[1](https://sre.google/workbook/simplicity/#ch07fn1) The best-known and most widely available standard is [cyclomatic code complexity](https://en.wikipedia.org/wiki/Cyclomatic\_complexity), which measures the number of distinct code paths through a specific set of statements. For example, a block of code with no loops or conditionals has a cyclomatic complexity number (CCN) of 1. The software community is quite good at measuring code complexity, and there are measurement tools for a number of integrated development environments (including Visual Studio, Eclipse, and IntelliJ). We’re less adept at understanding whether the resulting measured complexity is necessary or accidental, how the complexity of one method might influence a larger system, and which approaches are best for refactoring.

On the other hand, formal methodologies for measuring system complexity are rare.[2](https://sre.google/workbook/simplicity/#ch07fn2) You might be tempted to try a CCN-type approach of counting the number of distinct entities (e.g., microservices) and communication paths between them. However, for most sizable systems, that number can grow hopelessly large very quickly.

Some more practical proxies for systems-level complexity include:

Training time

* How long does it take a new team member to go on-call? Poor or missing documentation can be a significant source of subjective complexity.

Explanation time

* How long does it take to explain a comprehensive high-level view of the service to a new team member (e.g., diagram the system architecture on a whiteboard and explain the functionality and dependencies of each component)?

Administrative diversity

* How many ways are there to configure similar settings in different parts of the system? Is configuration stored in a centralized place, or in multiple locations?

Diversity of deployed configurations

* How many unique configurations are deployed in production (including binaries, binary versions, flags, and environments)?

Age

* How old is the system? [Hyrum’s Law](https://www.hyrumslaw.com/) states that over time, the users of an API depend on every aspect of its implementation, resulting in fragile and unpredictable behaviors.

While measuring complexity is occasionally worthwhile, it’s difficult. However, there seems to be no serious opposition to the observations that:

* In general, complexity will increase in living software systems unless there is a countervailing effort.
* Providing that effort is a worthwhile thing to do.

More here: [https://sre.google/workbook/simplicity/](https://sre.google/workbook/simplicity/)
