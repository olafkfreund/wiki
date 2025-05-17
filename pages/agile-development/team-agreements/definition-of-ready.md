# Definition of Ready

When the development team picks a user story from the top of the backlog, the user story needs to have enough detail to estimate the work needed to complete the story within the sprint. If it has enough detail to estimate, it is Ready to be developed.

> If a user story is not Ready in the beginning of the Sprint it increases the chance that the story will not be done at the end of this sprint.

### What it is <a href="#what-it-is" id="what-it-is"></a>

_Definition of Ready_ is the agreement made by the scrum team around how complete a user story should be in order to be selected as candidate for estimation in the sprint planning. These can be codified as a checklist in user stories using [GitHub Issue Templates](https://help.github.com/en/github/building-a-strong-community/configuring-issue-templates-for-your-repository) or [Azure DevOps Work Item Templates](https://learn.microsoft.com/en-us/azure/devops/boards/backlogs/work-item-template?view=azure-devops\&tabs=browser).

It can be understood as a checklist that helps the Product Owner to ensure that the user story they wrote contains all the necessary details for the scrum team to understand the work to be done.

#### Examples of ready checklist items <a href="#examples-of-ready-checklist-items" id="examples-of-ready-checklist-items"></a>

* [ ] Does the description have the details including any input values required to implement the user story?
* [ ] Does the user story have clear and complete acceptance criteria?
* [ ] Does the user story address the business need?
* [ ] Can we measure the acceptance criteria?
* [ ] Is the user story small enough to be implemented in a short amount of time, but large enough to provide value to the customer?
* [ ] Is the user story blocked? For example, does it depend on any of the following:
  * The completion of unfinished work
  * A deliverable provided by another team (code artifact, data, etc...)

#### DevOps and Cloud Infrastructure Ready Checklist (2025) <a href="#devops-ready-checklist" id="devops-ready-checklist"></a>

For stories involving infrastructure changes, cloud deployments, or automation, consider these additional ready criteria:

* [ ] Are cloud resource requirements clearly defined (instance types, storage needs, networking configurations)?
* [ ] Have cost implications been calculated and approved?
* [ ] Are there existing infrastructure components that will be impacted by this change?
* [ ] Have security requirements been defined and reviewed?
* [ ] Is there clarity on which environments (dev/test/staging/prod) will be affected?
* [ ] Are all required service principals, permissions, and access credentials documented and available?
* [ ] Are integration points with other services or systems documented?
* [ ] Have compliance requirements been identified and documented?
* [ ] Are monitoring and observability requirements defined?
* [ ] Have roll-back procedures been considered?
* [ ] Is there a testing strategy for the infrastructure changes?
* [ ] For multi-cloud stories: are the cloud-specific implementation details documented?

#### IaC and Automation Ready Checklist <a href="#iac-ready-checklist" id="iac-ready-checklist"></a>

For stories involving Infrastructure as Code or automation:

* [ ] Is the IaC tool specified (Terraform, Bicep, CloudFormation, Pulumi, etc.)?
* [ ] Are state management requirements documented (remote state, locking mechanisms)?
* [ ] Are module/component boundaries clearly defined?
* [ ] Are there existing modules or components that can be reused?
* [ ] Have CI/CD pipeline requirements been defined?
* [ ] Are there automated testing requirements for the infrastructure code?
* [ ] Have drift detection and remediation strategies been considered?
* [ ] Are secrets management requirements defined?

### Who writes it <a href="#who-writes-it" id="who-writes-it"></a>

The ready checklist can be written by a Product Owner in agreement with the development team and the Process Lead. For DevOps and infrastructure-related stories, input from cloud architects, security specialists, and SREs is highly valuable.

### When should a Definition of Ready be updated <a href="#when-should-a-definition-of-ready-be-updated" id="when-should-a-definition-of-ready-be-updated"></a>

Update or change the definition of ready anytime the scrum team observes that there are missing information in the user stories that recurrently impacts the planning. For DevOps teams, also consider updating when:

- Adopting new cloud services or platforms
- Implementing new security or compliance requirements
- Changing infrastructure management tools
- Adopting new observability or monitoring practices
- Introducing new automation capabilities

### What should be avoided <a href="#what-should-be-avoided" id="what-should-be-avoided"></a>

The ready checklist should contain items that apply broadly. Don't include items or details that only apply to one or two user stories. This may become an overhead when writing the user stories.

For DevOps stories specifically:
- Avoid overly prescriptive implementation details that limit engineering creativity and problem-solving
- Don't require extensive documentation of technical minutiae that could be better captured in code
- Avoid requiring approvals that could be automated through policy-as-code
- Don't include detailed configurations that are environment-specific and should be parameterized

### How to get stories ready <a href="#how-to-get-stories-ready" id="how-to-get-stories-ready"></a>

In the case that the highest priority work is not yet ready, it still may be possible to make forward progress. Here are some strategies that may help:

* [Backlog Refinement](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/backlog-management/) sessions are a good time to validate that high priority user stories are verified to have a clear description, acceptance criteria and demonstrable business value. It is also a good time to breakdown large stories will likely not be completable in a single sprint.
* Prioritization sessions are a good time to prioritize user stories that unblock other blocked high priority work.
* Blocked user stories can often be broken down in a way that unblocks a portion of the original stories scope. This is a good way to make forward progress even when some work is blocked.

#### DevOps-specific Readiness Strategies <a href="#devops-readiness-strategies" id="devops-readiness-strategies"></a>

For infrastructure and cloud automation stories:

* **Infrastructure as Diagrams**: Use architecture diagrams (as code with tools like Diagrams.net, Mermaid, or Structurizr) to visualize the target state, which helps clarify requirements before implementation.

* **Spike Solutions**: For complex infrastructure changes, create time-boxed spike user stories to explore technical feasibility or proof-of-concept implementations before committing to the full implementation.

* **Progressive Enhancement**: Break down large infrastructure changes into smaller, independently valuable enhancements that can be delivered incrementally.

* **Resource Templates**: Maintain a library of standard resource definitions (Terraform modules, Helm charts, etc.) that can be quickly composed to implement new infrastructure requirements.

* **Pre-implementation Scanning**: Run automated policy, security, and cost estimation tools against infrastructure-as-code files before implementation to identify potential issues early.

* **Shadow Environment Testing**: Test changes in parallel environments that mirror production but don't affect real users, to validate changes before formal implementation stories are undertaken.
