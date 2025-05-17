# Source Control

Source control (or version control) is fundamental to modern DevOps practices. It provides a single source of truth for both application code and infrastructure definitions. This guide covers best practices for implementing effective source control strategies across cloud providers.

## Popular Source Control Systems

* **GitHub** - Widely used for public and private repositories with excellent CI/CD integration
* **GitLab** - Self-hosted or SaaS platform with built-in CI/CD capabilities
* **Azure DevOps** - Microsoft's comprehensive DevOps platform with integrated work tracking
* **Bitbucket** - Atlassian's Git solution that integrates with their suite of products

## Sections within Source Control <a href="#sections-within-source-control" id="sections-within-source-control"></a>

* [Merge Strategies](https://microsoft.github.io/code-with-engineering-playbook/source-control/merge-strategies/)
* [Branch Naming](https://microsoft.github.io/code-with-engineering-playbook/source-control/naming-branches/)
* [Versioning](https://microsoft.github.io/code-with-engineering-playbook/source-control/component-versioning/)
* [Working with Secrets](https://microsoft.github.io/code-with-engineering-playbook/source-control/secrets-management/)
* [Git Guidance](https://microsoft.github.io/code-with-engineering-playbook/source-control/git-guidance/)
* [Monorepo vs. Multirepo](#monorepo-vs-multirepo)
* [GitOps Workflow](#gitops-workflow)
* [Infrastructure as Code Management](#infrastructure-as-code-management)

## Goal <a href="#goal" id="goal"></a>

* Following industry best practice to work in geo-distributed teams which encourage contributions across organizations
* Improve code quality by enforcing reviews before merging into main branches
* Improve traceability of features and fixes through a clean commit history
* Enable GitOps workflows for infrastructure and application deployments
* Support multi-cloud environments with consistent practices

## Modern Source Control Patterns

### Trunk-Based Development <a href="#trunk-based-development" id="trunk-based-development"></a>

Trunk-based development is a source control pattern where developers collaborate on code in a single branch (trunk/main), using feature flags and other techniques to disable incomplete code in production.

**Key characteristics:**

* Short-lived feature branches (typically less than 2 days)
* Frequent merges to the main branch (at least daily)
* Comprehensive automated testing
* Feature toggles to manage incomplete features

```bash
# Example workflow
git checkout -b feature/add-monitoring
# Make changes
git commit -am "Add Prometheus metrics endpoint"
# Pull latest changes from main
git pull origin main --rebase
# Run tests
npm test
# Push and create PR
git push -u origin feature/add-monitoring
# PR is reviewed and merged quickly (same day if possible)
```

### Monorepo vs. Multirepo <a href="#monorepo-vs-multirepo" id="monorepo-vs-multirepo"></a>

#### Monorepo

A monorepo stores multiple projects in a single repository.

**Advantages:**
* Simplified dependency management
* Atomic changes across projects
* Unified versioning
* Easier code sharing and refactoring

**Disadvantages:**
* Can become unwieldy for very large projects
* Requires more sophisticated build tooling
* Access control is less granular

#### Multirepo

A multirepo uses separate repositories for different projects or services.

**Advantages:**
* Clear ownership boundaries
* Fine-grained access control
* Focused scope per repository
* Independent release cycles

**Disadvantages:**
* Challenging cross-project changes
* Dependency management complexity
* Version compatibility issues

**Decision criteria:**
* Team size and structure
* Project architecture (monolith vs microservices)
* Deployment frequency requirements
* Security and access control needs

### GitOps Workflow <a href="#gitops-workflow" id="gitops-workflow"></a>

GitOps uses Git repositories as the source of truth for declarative infrastructure and applications.

**Core principles:**
1. The entire system is described declaratively
2. The canonical desired system state is versioned in Git
3. Approved changes can be automatically applied to the system
4. Software agents ensure correctness and alert on drift

**Example GitOps workflow with Flux:**

```yaml
# Example Flux GitRepository resource
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/organization/infrastructure
  ref:
    branch: main
```

### Infrastructure as Code Management <a href="#infrastructure-as-code-management" id="infrastructure-as-code-management"></a>

Best practices for managing Infrastructure as Code in source control:

1. **Structure repositories effectively**
   * Separate application code from infrastructure code
   * Organize by environment, region, or component

   ```
   infrastructure/
   ├── modules/           # Reusable infrastructure components
   ├── environments/      # Environment-specific configurations
   │   ├── dev/
   │   ├── staging/ 
   │   └── production/
   └── platform/          # Shared platform resources
   ```

2. **Version infrastructure resources**
   * Use semantic versioning for infrastructure modules
   * Tag stable infrastructure releases

   ```bash
   # Tag infrastructure releases
   git tag -a "infra/v1.2.0" -m "Added VPC peering and updated security groups"
   ```

3. **Handle state files securely**
   * Never store state files with secrets in source control
   * Use remote state with appropriate access controls
   
   ```hcl
   # Terraform remote state example
   terraform {
     backend "s3" {
       bucket         = "terraform-state"
       key            = "prod/network/terraform.tfstate"
       region         = "us-west-2"
       encrypt        = true
       dynamodb_table = "terraform-locks"
     }
   }
   ```

4. **Manage secrets properly**
   * Use secret management services (AWS Secrets Manager, Azure Key Vault)
   * Consider solutions like SOPS or Vault for encrypted secrets in Git

## General Guidance <a href="#general-guidance" id="general-guidance"></a>

Consistency is important, so agree to the approach as a team before starting to code. Treat this as a design decision, so include a design proposal and review, in the same way as you would document all design decisions (see [Working Agreements](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/working-agreements/) and [Design Reviews](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/)).

## Creating a new repository <a href="#creating-a-new-repository" id="creating-a-new-repository"></a>

When creating a new repository, the team should at least do the following:

* Agree on the **branch**, **release,** and **merge strategy**
* Define the merge strategy ([linear or non-linear](https://microsoft.github.io/code-with-engineering-playbook/source-control/merge-strategies/))
* Lock the default branch and merge using [pull requests (PRs)](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-requests/)
* Agree on [branch naming](https://microsoft.github.io/code-with-engineering-playbook/source-control/naming-branches/) (e.g. `feature/add-monitoring` or `user/your_alias/feature_name`)
* Establish [branch/PR policies](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-requests/)
* Configure CI/CD pipelines to run on PR creation
* Set up automated linting and security scanning
* For public repositories the default branch should contain the following files:
  * [LICENSE](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/LICENSE)
  * [README.md](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/)
  * [CONTRIBUTING.md](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/CONTRIBUTING/)

## Conventional Commits <a href="#conventional-commits" id="conventional-commits"></a>

Using conventional commits improves repository readability and enables automated versioning:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Common types include:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `chore`: Routine tasks, maintenance
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or correcting tests
- `ci`: Changes to CI configuration

Example:
```
feat(api): add endpoint for user authentication

Implement JWT-based authentication for the API service.

BREAKING CHANGE: `Authorization` header now required for protected routes
```

## Contributing to an existing repository <a href="#contributing-to-an-existing-repository" id="contributing-to-an-existing-repository"></a>

When working on an existing project:

1. `git clone` the repository
2. Review the project's README.md and CONTRIBUTING.md files
3. Understand the team's branch, merge and release strategy
4. Follow the established workflow and coding standards

```bash
# Clone the repository
git clone https://github.com/organization/project.git

# Create a feature branch
git checkout -b feature/implement-monitoring

# Make changes, commit using conventional commits
git commit -m "feat(monitoring): add Prometheus metrics endpoint"

# Push changes and create a pull request
git push -u origin feature/implement-monitoring
```

## Multi-Cloud Source Control Practices <a href="#multi-cloud" id="multi-cloud"></a>

When managing infrastructure for multiple cloud providers:

1. **Unified Repository Structure**
   * Use consistent naming conventions across providers
   * Organize by capability rather than by provider when possible

2. **Provider Abstractions**
   * Consider using abstraction layers in IaC
   * Implement consistent tagging across cloud providers

3. **Cross-Provider Testing**
   * Test infrastructure changes across all targeted cloud environments
   * Use matrix CI/CD jobs to validate across providers

## Mixed DevOps Environments <a href="#mixed-devops-environments" id="mixed-devops-environments"></a>

For most engagements, having a single hosted DevOps environment (i.e., Azure DevOps) is the preferred path, but there are times when a mixed DevOps environment (e.g., Azure DevOps for Agile/Work item tracking & GitHub for Source Control) is needed due to customer requirements. When working in a mixed environment:

* Use integrations between systems where available (Azure Boards GitHub App)
* Manually reference work items in commits with standard formats (e.g., AB#123)
* Ensure that the scope of work items / tasks align with PR's
* Consider automation tools like GitHub Actions to sync state between systems
* Document the workflow clearly to avoid confusion

## Resources <a href="#resources" id="resources"></a>

* [Git](https://git-scm.com/) - Official Git documentation
* [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/) - Microsoft's DevOps platform
* [GitHub](https://github.com/) - GitHub documentation and guides
* [GitLab](https://about.gitlab.com/) - GitLab documentation
* [Learn Git Branching](https://learngitbranching.js.org/) - Interactive Git tutorial
* [Conventional Commits](https://www.conventionalcommits.org/) - Commit message convention
* [GitHub - Removing sensitive data from a repository](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)
* [GitHub Flow](https://githubflow.github.io/) - A lightweight branch-based workflow
* [GitOps Principles](https://opengitops.dev/) - Core GitOps concepts and practices
