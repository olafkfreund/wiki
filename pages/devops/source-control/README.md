# Source Control

There are many options when working with Source Control. In [ISE](https://microsoft.github.io/code-with-engineering-playbook/ISE/) we use [AzureDevOps](https://azure.microsoft.com/en-us/services/devops/) for private repositories and [GitHub](https://github.com/) for public repositories.

### Sections within Source Control <a href="#sections-within-source-control" id="sections-within-source-control"></a>

* [Merge Strategies](https://microsoft.github.io/code-with-engineering-playbook/source-control/merge-strategies/)
* [Branch Naming](https://microsoft.github.io/code-with-engineering-playbook/source-control/naming-branches/)
* [Versioning](https://microsoft.github.io/code-with-engineering-playbook/source-control/component-versioning/)
* [Working with Secrets](https://microsoft.github.io/code-with-engineering-playbook/source-control/secrets-management/)
* [Git Guidance](https://microsoft.github.io/code-with-engineering-playbook/source-control/git-guidance/)

### Goal <a href="#goal" id="goal"></a>

* Following industry best practice to work in geo-distributed teams which encourage contributions from across [ISE](https://microsoft.github.io/code-with-engineering-playbook/ISE/) as well as the broader OSS community
* Improve code quality by enforcing reviews before merging into main branches
* Improve traceability of features and fixes through a clean commit history

### General Guidance <a href="#general-guidance" id="general-guidance"></a>

Consistency is important, so agree to the approach as a team before starting to code. Treat this as a design decision, so include a design proposal and review, in the same way as you would document all design decisions (see [Working Agreements](https://microsoft.github.io/code-with-engineering-playbook/agile-development/advanced-topics/team-agreements/working-agreements/) and [Design Reviews](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/)).

### Creating a new repository <a href="#creating-a-new-repository" id="creating-a-new-repository"></a>

When creating a new repository, the team should at least do the following

* Agree on the **branch**, **release,** and **merge strategy**
* Define the merge strategy ([linear or non-linear](https://microsoft.github.io/code-with-engineering-playbook/source-control/merge-strategies/))
* Lock the default branch and merge using [pull requests (PRs)](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-requests/)
* Agree on [branch naming](https://microsoft.github.io/code-with-engineering-playbook/source-control/naming-branches/) (e.g. `user/your_alias/feature_name`)
* Establish [branch/PR policies](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-requests/)
* For public repositories the default branch should contain the following files:
  * [LICENSE](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/LICENSE)
  * [README.md](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/)
  * [CONTRIBUTING.md](https://microsoft.github.io/code-with-engineering-playbook/resources/templates/CONTRIBUTING/)

### Contributing to an existing repository <a href="#contributing-to-an-existing-repository" id="contributing-to-an-existing-repository"></a>

When working on an existing project, `git clone` the repository and ensure you understand the team's branch, merge and release strategy (e.g. through the projects [CONTRIBUTING.md file](https://blog.github.com/2012-09-17-contributing-guidelines/)).

### Mixed DevOps Environments <a href="#mixed-devops-environments" id="mixed-devops-environments"></a>

For most engagements having a single hosted DevOps environment (i.e. Azure DevOps) is the preferred path but there are times when a mixed DevOps environment (i.e. Azure DevOps for Agile/Work item tracking & GitHub for Source Control) is needed due to customer requirements. When working in a mixed environment:

* Manually tag PR's in work items
* Ensure that the scope of work items / tasks align with PR's

### Resources <a href="#resources" id="resources"></a>

* [Git](https://git-scm.com/) `--local-branching-on-the-cheap`
* [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/)
* [ISE Git details](https://microsoft.github.io/code-with-engineering-playbook/source-control/git-guidance/)details on how to use Git as part of a [ISE](https://microsoft.github.io/code-with-engineering-playbook/ISE/) project.
* [GitHub - Removing sensitive data from a repository](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)
