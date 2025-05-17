# Definition of Done

When a team starts a new project, one of the first activities is to align on a Definition of Done.

Definition of Done (DoD) is a collection of deliverables that must be completed for every User Story to be considered ready to be released.

> ⚠ Remember
> Definition of Done is informed by the reality of the current situation. It will be different depending on the application/service you are building and the stage of the project.

> 📓 Note
> Imagine going into a restaurant and ordering a steak. When is that steak done? If the steak is raw, it's not done. If the steak is charred to a crisp, it's overdone. When is it just right? It depends.
> It's the same with software. Being "done" with a user story includes everything involved in producing and ensuring quality of the code. It's not just about implementing the functionality.

### What it is <a href="#what-it-is" id="what-it-is"></a>

_Definition of Done_ is a list of requirements that a user story must adhere to for the team to call it complete. Until all the items on this checklist are done, a user story cannot be considered complete. Having a clear definition of done (DoD) is critical for the team to have a common understanding of what it means to complete a user story.

It is effectively a checklist that is used to know when a user story is complete. It can also be used as a checklist during implementation to know what activities should be done for each user story.

#### Examples of DoD checklist items <a href="#examples-of-dod-checklist-items" id="examples-of-dod-checklist-items"></a>

A definition of done may include:

* The product builds with no warnings or errors.
* Unit tests are written and passing
* Existing automated tests pass
* Code has been peer-reviewed
* Code is checked in to the correct branch in source control
* Code is deployed to the dev environment and tested.
* All acceptance criteria have been verified by the Product Owner
* Non-functional requirements are met
* Documentation on how the feature works has been added to user documentation

#### DevOps and Infrastructure Definition of Done (2025) <a href="#devops-dod" id="devops-dod"></a>

For modern DevOps teams working with cloud infrastructure, the Definition of Done should include these additional criteria:

* [ ] Infrastructure as Code (IaC) changes have been peer-reviewed
* [ ] All IaC changes pass automated validation (terraform validate, ARM TTK, etc.)
* [ ] Security scanning of IaC has passed (Checkov, tfsec, etc.)
* [ ] Cost impact analysis has been performed and documented
* [ ] Resources have proper tagging for billing and ownership
* [ ] Configuration changes are documented in version control
* [ ] Service Level Indicators (SLIs) are implemented for new services
* [ ] Alert thresholds and dashboards are updated for new components
* [ ] Changes are tested in a pre-production environment
* [ ] Runbooks are updated for any new operational procedures
* [ ] Policy compliance is validated for all new infrastructure
* [ ] Roll-back plan has been documented and tested
* [ ] Secrets are properly stored in a secure vault, not in code
* [ ] Resource naming follows established conventions
* [ ] Network security controls (NSGs, Security Groups) are properly configured
* [ ] Logging and monitoring are properly configured and verified

#### Automation and CI/CD Definition of Done <a href="#cicd-dod" id="cicd-dod"></a>

For automation and CI/CD pipeline changes:

* [ ] Pipeline changes are peer-reviewed
* [ ] Pipeline code has automated testing
* [ ] Pipeline successfully builds and deploys to test environment
* [ ] Pipeline execution time is within acceptable limits
* [ ] Failed pipeline runs include clear error messages
* [ ] Pipeline logs are properly configured and accessible
* [ ] Pipeline credentials use least-privilege access
* [ ] Pipeline includes appropriate security scanning stages
* [ ] Pipeline metrics are captured (success rate, duration, etc.)
* [ ] Pipeline has appropriate approvals for production deployments
* [ ] Documentation is updated to reflect pipeline changes

#### Multi-Cloud and Hybrid Definition of Done <a href="#multi-cloud-dod" id="multi-cloud-dod"></a>

For multi-cloud or hybrid cloud implementations:

* [ ] Implementation works consistently across targeted cloud providers
* [ ] Cloud provider abstraction layers are properly tested
* [ ] Cloud-specific features are appropriately documented
* [ ] Identity and access management is properly configured across clouds
* [ ] Network connectivity between clouds is properly established and tested
* [ ] Monitoring spans all environments with consolidated views
* [ ] Cost attribution is properly configured across all environments
* [ ] Disaster recovery procedures are tested across environments
* [ ] Provider-specific compliance requirements are addressed

### Who writes it <a href="#who-writes-it" id="who-writes-it"></a>

The Definition of Done checklist can be written by the team lead in agreement with the team and the Product Owner. For DevOps teams, input from security specialists, cloud architects, and SRE team members is critical.

### When should a Definition of Done be updated <a href="#when-should-a-definition-of-done-be-updated" id="when-should-a-definition-of-done-be-updated"></a>

Update or change the definition of done anytime the team decides they need to change how they build their product. 

Examples of when to update the DoD:
* When the team identifies a recurring issue in production that could be prevented by adding an item to the DoD
* When new security requirements must be implemented
* When compliance standards change
* When adopting new cloud services or platforms
* When introducing new observability tools or practices
* When changing deployment strategies (e.g., moving to GitOps or progressive delivery)

### What should be avoided <a href="#what-should-be-avoided" id="what-should-be-avoided"></a>

Try to avoid a definition of done that:
* Is too long and unwieldy
* Includes items that are not applicable to all stories
* Is ignored by the team
* Is not updated when processes change
* Doesn't account for technical debt that may be created

For DevOps and infrastructure work specifically:
* Avoid manual verification steps that could be automated
* Don't include overly rigid requirements that don't accommodate legitimate exceptions
* Avoid platform-specific criteria that don't apply to all your environments
* Don't include requirements without clear verification methods

### DoD Verification Methods <a href="#dod-verification" id="dod-verification"></a>

For DevOps teams, it's important to automate verification of the Definition of Done criteria wherever possible. Consider implementing:

* **Policy as Code**: Use tools like OPA (Open Policy Agent), Sentinel, or Azure Policy to automatically verify compliance with infrastructure standards
* **Quality Gates**: Implement quality gates in your CI/CD pipelines that validate security, cost, and compliance requirements
* **Automated Reporting**: Generate compliance and validation reports automatically as part of your pipeline
* **Pre-commit Hooks**: Run validation checks locally before code is committed
* **Post-deployment Validation**: Automatically verify deployed resources match expected configurations
* **Continuous Compliance**: Implement continuous scanning to detect drift from compliance standards
* **Immutability Validation**: Verify that resources are created and destroyed rather than modified in place
