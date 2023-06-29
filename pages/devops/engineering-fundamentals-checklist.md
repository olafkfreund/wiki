# Engineering Fundamentals Checklist

This checklist helps to ensure that our projects meet our Engineering Fundamentals.

### Source Control <a href="#source-control" id="source-control"></a>

* [ ] The default target branch is locked.
* [ ] Merges are done through PRs.
* [ ] PRs reference related work items.
* [ ] Commit history is consistent and commit messages are informative (what, why).
* [ ] Consistent branch naming conventions.
* [ ] Clear documentation of repository structure.
* [ ] Secrets are not part of the commit history or made public.&#x20;
* [ ] Public repositories follow the [OSS guidelines](https://microsoft.github.io/code-with-engineering-playbook/source-control/#creating-a-new-repository), see `Required files in default branch for public repositories`.

### Work Item Tracking <a href="#work-item-tracking" id="work-item-tracking"></a>

* [ ] All items are tracked in AzDevOps (or similar).
* [ ] The board is organized (swim lanes, feature tags, technology tags).

### Testing <a href="#testing" id="testing"></a>

* [ ] Unit tests cover the majority of all components (>90% if possible).
* [ ] Integration tests run to test the solution e2e.

### CI/CD <a href="#cicd" id="cicd"></a>

* [ ] Project runs CI with automated build and test on each PR.
* [ ] Project uses CD to manage deployments to a replica environment before PRs are merged.
* [ ] Main branch is always shippable.

### Security <a href="#security" id="security"></a>

* [ ] Access is only granted on an as-needed basis
* [ ] Secrets are stored in secured locations and not checked in to code
* [ ] Data is encrypted in transit (and if necessary at rest) and passwords are hashed
* [ ] Is the system split into logical segments with separation of concerns? This helps limiting security vulnerabilities.

### Observability <a href="#observability" id="observability"></a>

* [ ] Significant business and functional events are tracked and related metrics collected.
* [ ] Application faults and errors are logged.
* [ ] Health of the system is monitored.
* [ ] The client and server side observability data can be differentiated.
* [ ] Logging configuration can be modified without code changes (eg: verbose mode).
* [ ] [Incoming tracing context](https://microsoft.github.io/code-with-engineering-playbook/observability/correlation-id/) is propagated to allow for production issue debugging purposes.
* [ ] GDPR compliance is ensured regarding PII (Personally Identifiable Information).

### Agile/Scrum <a href="#agilescrum" id="agilescrum"></a>

* [ ] Process Lead (fixed/rotating) runs the daily standup
* [ ] The agile process is clearly defined within team.
* [ ] The Dev Lead (+ PO/Others) are responsible for backlog management and refinement.
* [ ] A working agreement is established between team members and customer.

### Design Reviews <a href="#design-reviews" id="design-reviews"></a>

* [ ] Process for conducting design reviews is included in the Working Agreement.
* [ ] Design reviews for each major component of the solution are carried out and documented, including alternatives.
* [ ] Stories and/or PRs link to the design document.
* [ ] Each user story includes a task for design review by default, which is assigned or removed during sprint planning.
* [ ] Project advisors are invited to design reviews or asked to give feedback to the design decisions captured in documentation.
* [ ] Discover all the reviews that the customer's processes require and plan for them.
* [ ] Clear non-functional requirements captured.

### Code Reviews <a href="#code-reviews" id="code-reviews"></a>

* [ ] There is a clear agreement in the team as to function of code reviews.
* [ ] The team has a code review checklist or established process.
* [ ] A minimum number of reviewers (usually 2) for a PR merge is enforced by policy.
* [ ] Linters/Code Analyzers, unit tests and successful builds for PR merges are set up.
* [ ] There is a process to enforce a quick review turnaround.

### Retrospectives <a href="#retrospectives" id="retrospectives"></a>

* [ ] Retrospectives are conducted each week/at the end of each sprint.
* [ ] The team identifies 1-3 proposed experiments to try each week/sprint to improve the process.
* [ ] Experiments have owners and are added to project backlog.
* [ ] The team conducts longer retrospective for Milestones and project completion.



### Developer Experience (DevEx) <a href="#developer-experience-devex" id="developer-experience-devex"></a>

Developers on the team can:

* [ ] Build/Compile source to verify it is free of syntax errors and compiles.
* [ ] Execute all automated tests (unit, e2e, etc).
* [ ] Start/Launch end-to-end to simulate execution in a deployed environment.
* [ ] Attach a debugger to started solution or running automated tests, set breakpoints, step through code, and inspect variables.
* [ ] Automatically install dependencies by pressing F5 (or equivalent) in their IDE.
* [ ] Use local dev configuration values (i.e. .env, appsettings.development.json).
