# FAQ: Code Reviews in DevOps

This FAQ addresses common questions and real-life issues encountered during code reviews, with actionable solutions and best practices for engineers.

---

### What makes a code review different from a PR?
A pull request (PR) is a request to merge code into the main branch. A code review is the process of examining that code for quality, security, and compliance before merging. Code reviews can also occur outside PRs (e.g., pair programming, mob reviews).

| Code Review                                                                                                   | Pull Request                                                                                                   |
| ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Focused on code quality, standards, and knowledge sharing                                                     | Mechanism to propose and track changes before merging                                                          |
| Can be synchronous (pair/mob, meetings) or asynchronous (PR comments)                                         | Usually asynchronous, but can be discussed in meetings                                                         |
| Early feedback possible (draft PRs, design reviews)                                                           | Typically used when code is ready for integration                                                              |

---

### Why do we need code reviews?
- Catch bugs and security issues early
- Share knowledge and spread best practices
- Ensure code consistency and maintainability
- Reduce technical debt

**Example:**
> A missed null check in a microservice API was caught during review, preventing a production outage.

---

### PRs are too large; how can we fix this?
- Break work into small, logical commits and PRs
- Use feature flags for incomplete features
- Encourage early, incremental reviews (draft PRs)

**Best Practice:**
> Limit PRs to 200-400 lines of code for easier, faster reviews ([Microsoft guidance](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/)).

---

### How can we expedite code reviews?
- Set PR turnaround time in your team agreement
- Schedule daily review slots (e.g., after standup)
- Assign a PR review manager to monitor and assign reviews
- Use tools to highlight stale PRs ([ADO Task Boards](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/tools/#task-boards))

**Example:**
> Use GitHub Actions to auto-label and ping reviewers if a PR is idle for 24 hours.

---

### How can we enforce code review policies?
- Configure branch protection rules (GitHub, Azure Repos, GitLab)
- Require minimum reviewers and status checks before merging
- Automate checks (lint, tests, security scans) in CI/CD pipelines

**Reference:**
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)

---

### We pair or mob. How should this reflect in our code reviews?
- Pair: Have someone outside the pair review the code for fresh perspective
- Mob: A mob member with less keyboard time should review
- Document who participated in the review for traceability

---

### Best Practices
- Use checklists for consistent reviews (security, style, tests)
- Review both code and infrastructure-as-code (Terraform, Helm, etc.)
- Use LLMs (Copilot, Claude) to suggest improvements or spot issues
- Document recurring review findings in a team knowledge base

---

### Common Pitfalls
- Rushing reviews or rubber-stamping approvals
- Not reviewing IaC or pipeline changes
- Ignoring automated test failures
- Lack of feedback on rejected PRs

---

### References
- [Microsoft Code Review Playbook](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/)
- [GitHub Code Review Docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests)
- [Azure DevOps Code Review](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests)
