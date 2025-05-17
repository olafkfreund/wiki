# Team Manifesto

### Introduction <a href="#introduction" id="introduction"></a>

ISE teams work with a new development team in each customer engagement which requires a phase of introduction & knowledge transfer before starting an engagement.

Completion of this phase of icebreakers and discussions about the standards takes time but is required to start increasing the learning curve of the new team.

A team manifesto is a lightweight one page agile document among team members which summarizes the basic principles and values of the team and aiming to provide a consensus about technical expectations from each team member in order to deliver high quality output at the end of each engagement.

It aims to reduce the time on setting the right expectations without arranging longer "team document reading" meetings and provide a consensus among team members to answer the question - "How does the new team develop the software?" - by covering all engineering fundamentals and excellence topics such as release process, clean coding, testing.

Another main goal of writing the manifesto is to start a conversation during the "manifesto building session" to detect any differences of opinion around how the team should work.

It also serves in the same way when a new team member joins to the team. New joiners can quickly get up to speed on the agreed standards.

### How to Build a Team Manifesto <a href="#how-to-build-a-team-manifesto" id="how-to-build-a-team-manifesto"></a>

It can be said that the best time to start building it is at the very early phase of the engagement when teams meet with each other for swarming or during the preparation phase.

It is recommended to keep team manifesto as simple as possible, so preferably, one-page simple document which **doesn't include any references or links** is a nice format for it. If there is a need for providing knowledge on certain topics, the way to do is delivering brown-bag sessions, technical katas, team practices, documentations and others later on.

A few important points about the team manifesto

* The development team builds the team manifesto itself
* It should cover all required technical engineering points for the excellence as well as behavioral agility mindset items that the team finds relevant
* It aims to give a mutual understanding about the desired expertise, practices and/or mindset within the team
* Based on the needs of the team and retrospective results, it can be modified during the engagement.

In ISE, we aim for quality over quantity, and well-crafted software as well as to a comfortable/transparent environment where each team member can reach their highest potential.

The difference between the team manifesto and other team documents is that it is used to give a short summary of expectations around the technical way of working and supported mindset in the team, before code-with sprints starts.

Below, you can find some including, but not limited, topics many teams touch during engagements,

| Topic                   | What is it about ?                                                                                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Collective Ownership    | Does team own the code rather than individuals? What is the expectation?                                                                                              |
| Respect                 | Any preferred statement about it's a "must-have" team value                                                                                                           |
| Collaboration           | Any preferred statement about how does team want to collaborate ?                                                                                                     |
| Transparency            | A simple statement about it's a "must-have" team value and if preferred, how does this being provided by the team ? meetings, retrospective, feedback mechanisms etc. |
| Craftspersonship        | Which tools such as Git, VS Code LiveShare, etc. are being used ? What is the definition of expected best usage of them?                                              |
| PR sizing               | What does team prefer in PRs ?                                                                                                                                        |
| Branching               | Team's branching strategy and standards                                                                                                                               |
| Commit standards        | Preferred format in commit messages, rules and more                                                                                                                   |
| Clean Code              | Does team follow clean code principles ?                                                                                                                              |
| Pair/Mob Programming    | Will team apply pair/mob programming ? If yes, what programming styles are suitable for the team ?                                                                    |
| Release Process         | Principles around release process such as quality gates, reviewing process ...etc.                                                                                    |
| Code Review             | Any rule for code reviewing such as min number of reviewers, team rules ...etc.                                                                                       |
| Action Readiness        | How the backlog will be refined? How do we ensure clear Definition of Done and Acceptance Criteria ?                                                                  |
| TDD                     | Will the team follow TDD ?                                                                                                                                            |
| Test Coverage           | Is there any expected number, percentage, or measurement ?                                                                                                            |
| Dimensions in Testing   | Required tests for high quality software, eg : unit, integration, functional, performance, regression, acceptance                                                     |
| Build process           | build for all? or not; The clear statement of where code and under what conditions code should work ? eg : OS, DevOps, tool dependency                                |
| Bug fix                 | The rules of bug fixing in the team ? eg: contact people, attaching PR to the issue etc.                                                                              |
| Technical debt          | How does team manage/follow it?                                                                                                                                       |
| Refactoring             | How does team manage/follow it?                                                                                                                                       |
| Agile Documentation     | Does team want to use diagrams and tables more rather than detailed KB articles ?                                                                                     |
| Efficient Documentation | When is it necessary? Is it a prerequisite to complete tasks/PRs etc.?                                                                                                |
| Definition of Fun       | How will we have fun for relaxing/enjoying the team spirit during the engagement?                                                                                     |

### Team Manifesto for DevOps and SRE Engineers (2025 Standards) <a href="#manifesto-2025" id="manifesto-2025"></a>

As DevOps and SRE practices continue to evolve, the team manifesto for 2025 should incorporate modern principles that address platform engineering, observability, security automation, and AI integration. Below are additional topics specifically tailored for DevOps/SRE teams:

| Topic                      | What is it about?                                                                                                          |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------|
| Platform Engineering       | How does the team approach internal developer platforms? Which self-service capabilities are prioritized?                   |
| Infrastructure as Code     | Which IaC tools are used (Terraform, Pulumi, CDK)? What are the standards for modules, testing, and documentation?          |
| Observability Standards    | What constitutes proper instrumentation? SLO/SLI definitions, telemetry requirements, and alerting philosophy               |
| Incident Response          | On-call expectations, incident classification, communication channels, and post-mortem requirements                         |
| Security Automation        | How is security incorporated into pipelines? What scanning tools are mandatory? Remediation SLAs for vulnerabilities        |
| Toil Reduction             | How to identify and prioritize automation opportunities, acceptable thresholds for manual work                              |
| GitOps Practices           | Expectations around declarative configurations, drift detection, and reconciliation approaches                              |
| AI/ML Integration          | How are AI tools (Copilot, LLM assistants) used in workflows? Boundaries for AI-generated code review and documentation     |
| Cost Optimization          | FinOps practices, resource tagging standards, cost monitoring responsibilities, and optimization targets                    |
| Release Cadence            | Deployment frequency expectations, progressive delivery approaches, feature flag usage                                      |
| Collaboration with Product | Engagement model with product teams, how technical constraints are communicated, SRE engagement in product planning         |
| Knowledge Sharing          | Internal documentation standards, runbook expectations, learning programs, and mentorship responsibilities                  |
| Chaos Engineering          | Approach to resilience testing, failure injection practices, and learning from controlled experiments                       |

### Team Manifesto Template for DevOps/SRE Teams (2025)

Below is a sample template that DevOps and SRE teams can use as a starting point:

```
# OUR TEAM MANIFESTO

## Our Values
- We prioritize system reliability and user experience over new features
- We automate repetitive work to focus on high-value engineering
- We share ownership of production systems and on-call responsibilities
- We learn from incidents without blame and continuously improve
- We treat configuration as code and apply software engineering practices to infrastructure

## Our Standards
- All infrastructure changes go through code review and CI/CD pipelines
- Observability is built-in from the start with logs, metrics, and traces
- Security is everyone's responsibility and integrated into our workflows
- We maintain SLOs for critical services and alert on burn rates
- Documentation is kept updated as a primary artifact

## Our Practices
- Infrastructure changes are made through pull requests, never manually
- We practice blameless postmortems after incidents
- We run game days to test our resilience regularly
- We rotate knowledge through pairing and documentation
- We measure and reduce toil systematically

## Our Tools
[List team-approved tools for each category]
```

The modern DevOps/SRE team manifesto reflects the convergence of software engineering, operations, and product development while emphasizing automation, observability, and reliability as first-class concerns.

### DevOps/SRE Facilitation Guide for Team Manifesto Sessions

When facilitating a team manifesto session for DevOps/SRE teams, consider the following approach:

1. **Pre-meeting preparation**: Send a survey to collect initial thoughts on key practices and values
2. **Opening exercise**: Start with "What does reliability mean to us?" to center the conversation
3. **Value mapping**: Identify the top 3-5 values that will drive technical decisions
4. **Practice definition**: For each key practice area (IaC, Observability, etc.), define concrete standards
5. **Tool consensus**: Agree on the toolchain that supports your practices, including version control, CI/CD, monitoring
6. **Decision-making framework**: Define how technical decisions are made, particularly for architecture changes
7. **Review and refine**: Consolidate the document to a single page and review as a team

The resulting manifesto should be concise enough to reference daily while containing enough detail to guide technical decisions.

