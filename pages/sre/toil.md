# Toil

## What Is Toil? <a href="#what-is-toil" id="what-is-toil"></a>

Toil tends to fall on a spectrum measured by the following characteristics, which are described in our first book. Here, we provide a concrete example for each toil characteristic:

Manual

* When the tmp directory on a web server reaches 95% utilization, engineer Anne logs in to the server and scours the filesystem for extraneous log files to delete.

Repetitive

* A full tmp directory is unlikely to be a one-time event, so the task of fixing it is repetitive.

Automatable[1](https://sre.google/workbook/eliminating-toil/#ch06fn1)

* If your team has remediation documents with content like “log in to X, execute this command, check the output, restart Y if you see…,” these instructions are essentially pseudocode to someone with software development skills! In the tmp directory example, the solution has been partially automated. It would be even better to fully automate the problem detection and remediation by not requiring a human to run the script. Better still, submit a patch so that the software no longer breaks in this way.

Nontactical/reactive

* When you receive too many alerts along the lines of “disk full” and “server down,” they distract engineers from higher-value engineering and potentially mask other, higher-severity alerts. As a result, the health of the service suffers.

Lacks enduring value

* Completing a task often brings a satisfying sense of accomplishment, but this repetitive satisfaction isn’t a positive in the long run. For example, closing that alert-generated ticket ensured that the user queries continued to flow and HTTP requests continued to serve with status codes < 400, which is good. However, resolving the ticket today won’t prevent the issue in the future, so the payback has a short duration.

Grows at least as fast as its source

* Many classes of operational work grow as fast as (or faster than) the size of the underlying infrastructure. For example, you can expect time spent performing hardware repairs to increase in lock-step fashion with the size of a server fleet. Physical repair work may unavoidably scale with the number of machines, but ancillary tasks (for example, making software/configuration changes) doesn’t necessarily have to.

Sources of toil may not always meet all of these criteria, but remember that toil comes in many forms. In addition to the preceding traits, consider the effect a particular piece of work has on team morale. Do people enjoy doing a task and find it rewarding, or is it the type of work that’s often neglected because it’s viewed as boring or unrewarding?[2](https://sre.google/workbook/eliminating-toil/#ch06fn2) Toil can slowly deflate team morale. Time spent working on toil is generally time not spent thinking critically or expressing creativity; reducing toil is an acknowledgment that an engineer’s effort is better utilized in areas where human judgment and expression are possible.

## Toil Taxonomy <a href="#toil-taxonomy" id="toil-taxonomy"></a>

Toil, like a crumbling bridge or a leaky dam, hides in the banal day to day. The categories in this section aren’t exhaustive, but represent some common categories of toil. Many of these categories seem like “normal” engineering work, and they are. It’s helpful to think of toil as a spectrum rather than a binary classification.



More here: [https://sre.google/workbook/eliminating-toil/](https://sre.google/workbook/eliminating-toil/)
