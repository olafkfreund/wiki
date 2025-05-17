# Sections of a Working Agreement

A working agreement is a document, or a set of documents that describe how we work together as a team and what our expectations and principles are.

The working agreement created by the team at the beginning of the project and is stored in the repository so that it is readily available for everyone working on the project.

The following are examples of sections and points that can be part of a working agreement, but each team should compose their own, and adjust times, communication channels, branch naming policies etc. to fit their team needs.

### General <a href="#general" id="general"></a>

* We work as one team towards a common goal and clear scope
* We make sure everyone's voice is heard, listened to
* We show all team member's equal respect
* We work as a team to have common expectations for technical delivery that are documented in a [Team Manifesto](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/team-manifesto/).
* We make sure to spread our expertise and skills in the team, so no single person is relied on for one skill
* All times below are listed in CET

### Communication <a href="#communication" id="communication"></a>

* We communicate all information relevant to the team through the Project Teams channel
* We add all [technical spikes](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/recipes/technical-spike/), [trade studies](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/trade-studies/), and other technical documentation to the project repository through [async design reviews in PRs](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/recipes/async-design-reviews/)

### Work-life Balance <a href="#work-life-balance" id="work-life-balance"></a>

* Our office hours, when we can expect to collaborate via Microsoft Teams, phone or face-to-face are Monday to Friday 10AM - 5PM
* We are not expected to answer emails past 6PM, on weekends or when we are on holidays or vacation.
* We work in different time zones and respect this, especially when setting up recurring meetings.
* We record meetings when possible, so that team members who could not attend live can listen later.

### Quality and not Quantity <a href="#quality-and-not-quantity" id="quality-and-not-quantity"></a>

* We agree on a [Definition of Done](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/definition-of-done/) for our user stories and sprints and live by it.
* We follow engineering best practices like the [Code With Engineering Playbook](https://github.com/microsoft/code-with-engineering-playbook)

### Scrum Rhythm <a href="#scrum-rhythm" id="scrum-rhythm"></a>

| Activity                                                                                                                               | When                  | Duration | Who          | Accountable  | Goal                                                                       |
| -------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | -------- | ------------ | ------------ | -------------------------------------------------------------------------- |
| [Project Standup](https://microsoft.github.io/code-with-engineering-playbook/agile-development/core-expectations/)                     | Tue-Fri 9AM           | 15 min   | Everyone     | Process Lead | What has been accomplished, next steps, blockers                           |
| Sprint Demo                                                                                                                            | Monday 9AM            | 1 hour   | Everyone     | Dev Lead     | Present work done and sign off on user story completion                    |
| [Sprint Retro](https://microsoft.github.io/code-with-engineering-playbook/agile-development/core-expectations/)                        | Monday 10AM           | 1 hour   | Everyone     | Process Lead | Dev Teams shares learnings and what can be improved                        |
| [Sprint Planning](https://microsoft.github.io/code-with-engineering-playbook/agile-development/core-expectations/)                     | Monday 11AM           | 1 hour   | Everyone     | PO           | Size and plan user stories for the sprint                                  |
| Task Creation                                                                                                                          | After Sprint Planning | -        | Dev Team     | Dev Lead     | Create tasks to clarify and determine velocity                             |
| [Backlog refinement](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/backlog-management/) | Wednesday 2PM         | 1 hour   | Dev Lead, PO | PO           | Prepare for next sprint and ensure that stories are ready for next sprint. |

### Process Lead <a href="#process-lead" id="process-lead"></a>

The Process Lead is responsible for leading any scrum or agile practices to enable the project to move forward.

* Facilitate standup meetings and hold team accountable for attendance and participation.
* Keep the meeting moving as described in the [Project Standup](https://microsoft.github.io/code-with-engineering-playbook/agile-development/core-expectations/) page.
* Make sure all action items are documented and ensure each has an owner and a due date and tracks the open issues.
* Notes as needed after planning / stand-ups.
* Make sure that items are moved to the parking lot and ensure follow-up afterwards.
* Maintain a location showing team’s work and status and removing impediments that are blocking the team.
* Hold the team accountable for results in a supportive fashion.
* Make sure that project and program documentation are up-to-date.
* Guarantee the tracking/following up on action items from retrospectives (iteration and release planning) and from daily standup meetings.
* Facilitate the sprint retrospective.
* Coach Product Owner and the team in the process, as needed.

### Backlog Management <a href="#backlog-management" id="backlog-management"></a>

* We work together on a [Definition of Ready](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/definition-of-ready/) and all user stories assigned to a sprint need to follow this
* We communicate what we are working on through the board
* We assign ourselves a task when we are ready to work on it (not before) and move it to active
* We capture any work we do related to the project in a user story/task
* We close our tasks/user stories only when they are done (as described in the [Definition of Done](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/definition-of-done/))
* We work with the PM if we want to add a new user story to the sprint
* If we add new tasks to the board, we make sure it matches the acceptance criteria of the user story (to avoid scope creep). If it doesn't match the acceptance criteria we should discuss with the PM to see if we need a new user story for the task or if we should adjust the acceptance criteria.

### Code Management <a href="#code-management" id="code-management"></a>

* We follow the git flow branch naming convention for branches and identify the task number e.g. `feature/123-add-working-agreement`
* We merge all code into main branches through PRs
* All PRs are reviewed by one person from \[Customer/Partner Name] and one from Microsoft (for knowledge transfer and to ensure code and security standards are met)
* We always review existing PRs before starting work on a new task
* We look through open PRs at the end of stand-up to make sure all PRs have reviewers.
* We treat documentation as code and apply the same [standards to Markdown](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/markdown/) as code

### Infrastructure as Code <a href="#infrastructure-as-code" id="infrastructure-as-code"></a>

* We treat infrastructure code with the same quality standards as application code
* All infrastructure changes must be made through IaC (Terraform, Bicep, etc.) and never manually in cloud portals
* Infrastructure code requires the same PR review process as application code
* We maintain test environments that mirror production configurations as closely as possible
* We document infrastructure architecture decisions through ADRs (Architecture Decision Records)
* We follow the principle of immutable infrastructure: modify by replacing, not updating

### Observability and Monitoring <a href="#observability-and-monitoring" id="observability-and-monitoring"></a>

* We define and track Service Level Objectives (SLOs) for all critical services
* All services must emit logs, metrics, and traces in standardized formats
* We maintain dashboards for key services that visualize the four golden signals (latency, traffic, errors, and saturation)
* We implement structured logging with consistent correlation IDs across service boundaries
* Alert configurations are stored as code and version-controlled
* We practice "monitor-driven development" - defining monitoring requirements during design phase

### On-Call and Incident Response <a href="#on-call-and-incident-response" id="on-call-and-incident-response"></a>

* Primary on-call rotation is weekly, from Monday 9AM to the following Monday 9AM
* Secondary on-call provides backup when primary cannot be reached within 15 minutes
* We use a severity classification system (SEV1-SEV4) to prioritize incidents
* We conduct blameless postmortems for all SEV1/SEV2 incidents within 48 hours
* All production incidents are documented with timeline, impact, root cause, and action items
* We maintain an up-to-date runbook for common operational tasks and troubleshooting
* Game Days are scheduled quarterly to test our incident response procedures

### Security Practices <a href="#security-practices" id="security-practices"></a>

* We implement security scanning in all CI/CD pipelines (SAST, DAST, SCA, secrets scanning)
* We follow the principle of least privilege for all service accounts and IAM roles
* Credentials are never stored in code repositories and are rotated regularly
* We perform regular threat modeling as part of our design process
* All data at rest and in transit is encrypted using industry-standard encryption
* We conduct security reviews before deploying major changes to production
* We maintain a vulnerability management process with defined SLAs for remediation

### GitOps and Continuous Delivery <a href="#gitops-and-continuous-delivery" id="gitops-and-continuous-delivery"></a>

* We follow GitOps principles - the Git repository is the source of truth for system configuration
* We practice trunk-based development with short-lived feature branches
* Our CI/CD pipelines include automated tests, security scans, and compliance checks
* We implement progressive delivery using feature flags and canary deployments
* Production deployments require automated smoke tests and validation
* We maintain a deployment schedule and avoid high-risk changes during peak business hours
* Deployment metrics (frequency, lead time, failure rate, MTTR) are tracked and reviewed monthly

### AI and Automation Integration <a href="#ai-and-automation-integration" id="ai-and-automation-integration"></a>

* We use LLM tools (GitHub Copilot, Claude, etc.) to assist with code and documentation generation
* AI-generated code requires the same review process as human-written code
* We prioritize automation of repetitive operational tasks and measure toil reduction
* We implement AI-assisted anomaly detection in our monitoring systems
* Automation scripts are treated as production code and follow the same quality standards
* We maintain a backlog of automation opportunities prioritized by toil reduction potential
* We use AI coding assistants responsibly and review all generated content for security and correctness
