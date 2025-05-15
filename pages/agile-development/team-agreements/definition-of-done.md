# Definition of Done (2025)

A clear, actionable Definition of Done (DoD) ensures that user stories, sprints, and releases meet engineering, DevOps, and business standards. The DoD should be agreed upon by the whole team and documented in the project.

---

## Feature/User Story

- [ ] Acceptance criteria are met and verified by the Product Owner
- [ ] Code builds with no errors (locally and in CI)
- [ ] Unit tests are written, pass locally, and in CI
- [ ] Existing unit and integration tests pass
- [ ] Code is reviewed (peer review, optionally with LLM assistance)
- [ ] Security checks and static analysis pass (e.g., SAST, secret scanning)
- [ ] Sufficient diagnostics/telemetry are logged
- [ ] Infrastructure as Code (IaC) updated if needed (Terraform, Bicep, etc.)
- [ ] Documentation (code, runbooks, user guides) is updated
- [ ] UX review is complete (if applicable)
- [ ] Feature branch is merged into the main/develop branch via pull request
- [ ] Feature is deployed to a test/staging environment via CI/CD
- [ ] Product Owner signs off

## Sprint Goal

- [ ] DoD for all user stories in the sprint are met
- [ ] Product backlog is updated and prioritized
- [ ] Functional, integration, and performance tests pass in CI/CD
- [ ] End-to-end tests pass in staging/pre-prod
- [ ] All critical bugs are fixed or have a mitigation plan
- [ ] Security and compliance checks pass (e.g., container/image scanning)
- [ ] Sprint review and retrospective are completed
- [ ] Sprint is signed off by developers, architects, project manager, and product owner

## Release/Milestone

- [ ] All sprint goals and DoD items are met
- [ ] Release candidate is deployed to production-like environment
- [ ] Release is marked as ready for production by Product Owner
- [ ] Rollback plan and release notes are prepared
- [ ] Monitoring, alerting, and runbooks are updated
- [ ] Stakeholders are notified

---

## Real-Life Example: Cloud-Native Feature DoD

- [ ] Terraform module updated and reviewed
- [ ] Azure/AWS/GCP resources provisioned in test
- [ ] GitHub Actions pipeline passes all checks
- [ ] LLM (e.g., Copilot, Claude) used for code review suggestions
- [ ] Security scan (Trivy, Checkov) passes
- [ ] Feature demoed to stakeholders

---

## References
- [Agile Manifesto](http://agilemanifesto.org/)
- [Azure DevOps DoD Guidance](https://learn.microsoft.com/en-us/azure/devops/boards/work-items/guidance/definition-of-done)
- [Scrum.org: Definition of Done](https://www.scrum.org/resources/what-is-the-definition-of-done)
