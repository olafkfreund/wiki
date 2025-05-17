# Component Versioning

### Goal <a href="#goal" id="goal"></a>

Larger applications consist of multiple components that reference each other and rely on compatibility of the interfaces/contracts of the components.

To achieve the goal of loosely coupled applications, each component should be versioned independently hence allowing developers to detect breaking changes or seamless updates just by looking at the version number.

### Version Numbers and Versioning schemes <a href="#version-numbers-and-versioning-schemes" id="version-numbers-and-versioning-schemes"></a>

For developers or other components to detect breaking changes the version number of a component is important.

There is different versioning number schemes, e.g.

`major.minor[.build[.revision]]`

or

`major.minor[.maintenance[.build]]`.

Upon build / CI these version numbers are being generated. During CD / release components are pushed to a _component repository_ such as Nuget, NPM, Docker Hub where a history of different versions is being kept.

Each build the version number is incremented at the last digit.

Updating the major / minor version indicates changes of the API / interfaces / contracts:

* Major Version: A breaking change
* Minor Version: A backwards-compatible minor change
* Build / Revision: No API change, just a different build.

### Semantic Versioning <a href="#semantic-versioning" id="semantic-versioning"></a>

Semantic Versioning is a versioning scheme specifying how to interpret the different version numbers. The most usual format is `major.minor.patch`. The version number is incremented based on the following rules:

* Major version when you make incompatible API changes,
* Minor version when you add functionality in a backwards-compatible manner, and
* Patch version when you make backwards-compatible bug fixes.

Examples of semver version numbers:

* **1.0.0-alpha.1**: +1 commit _after_ the alpha release of 1.0.0
* **2.1.0-beta**: 2.1.0 in beta branch
* **2.4.2**: 2.4.2 release

A common practice is to determine the version number during the build process. For this the source control repository is utilized to determine the version number automatically based the source code repository.

The `GitVersion` tool uses the git history to generate _repeatable_ and _unique_ version number based on

* number of commits since last major or minor release
* commit messages
* tags
* branch names

Version updates happen through:

*   Commit messages or tags for Major / Minor / Revision updates.

    > When using commit messages, a convention such as Conventional Commits is recommended (see [Git Guidance - Commit Message Structure](https://microsoft.github.io/code-with-engineering-playbook/source-control/git-guidance/#commit-message-structure))
* Branch names (e.g. develop, release/..) for Alpha / Beta / RC
* Otherwise: Number of commits (+12, ...)

### Infrastructure Component Versioning <a href="#infrastructure-component-versioning" id="infrastructure-component-versioning"></a>

Modern cloud-native applications include infrastructure components that also need versioning. This includes:

* Terraform modules
* Kubernetes Helm charts
* Azure Bicep modules
* Container images
* CloudFormation templates

When versioning infrastructure components, consider these best practices:

1. **Immutable versioning**: Once published, a specific version should never change
2. **Version pinning**: Always pin dependencies to specific versions to ensure reproducibility
3. **Version compatibility matrix**: Maintain documentation on compatible versions between components
4. **Impact labeling**: Tag versions with their potential impact (e.g., `high-risk`, `db-migration`)

Example Terraform module versioning:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"  # Pinned to exact version for reproducibility
  
  // configuration...
}
```

### Versioning in Multi-Cloud Environments <a href="#multi-cloud-versioning" id="multi-cloud-versioning"></a>

When working across multiple cloud providers, component versioning becomes even more critical. Consider these practices:

1. **Cross-provider abstraction layers**: Version your abstraction libraries independently from specific provider implementations
2. **Provider-specific version tags**: Use tags like `aws/v1.2.3` or `azure/v1.2.3` for provider-specific releases
3. **Compatibility matrices**: Document which versions work with specific provider versions
4. **Versioned provider configurations**: Pin cloud provider versions in your IaC code

Example of version pinning in Terraform across providers:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.12.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.27.0"
    }
  }
}
```

### Automated Versioning in CI/CD <a href="#automated-versioning-in-cicd" id="automated-versioning-in-cicd"></a>

Modern DevOps practices use automated versioning in CI/CD pipelines. Here are some implementation patterns:

#### GitHub Actions Example

```yaml
name: Release Version

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Important for GitVersion to work correctly
          
      - name: Install GitVersion
        uses: gittools/actions/gitversion/setup@v0.9.15
        with:
          versionSpec: '5.x'
          
      - name: Determine Version
        id: gitversion
        uses: gittools/actions/gitversion/execute@v0.9.15
        
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: v${{ steps.gitversion.outputs.semVer }}
          release_name: Release ${{ steps.gitversion.outputs.semVer }}
          draft: false
          prerelease: false
```

#### Azure DevOps Pipeline Example

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: gitversion/setup@0
  inputs:
    versionSpec: '5.x'
  displayName: 'Install GitVersion'

- task: gitversion/execute@0
  displayName: 'Determine Version'

- script: |
    echo "Building version $(GitVersion.SemVer)"
    # Build commands go here
  displayName: 'Build'

- task: PublishBuildArtifacts@1
  inputs:
    pathtoPublish: '$(Build.ArtifactStagingDirectory)'
    artifactName: 'drop'
    publishLocation: 'Container'
  displayName: 'Publish Artifacts'
```

### Calendar Versioning <a href="#calendar-versioning" id="calendar-versioning"></a>

Some projects use Calendar Versioning (CalVer) instead of Semantic Versioning. This approach uses dates in version numbers.

Common formats include:
- `YYYY.MM.DD` (e.g., 2025.06.01)
- `YY.MM.MICRO` (e.g., 25.06.1)
- `YYYY.MM` (e.g., 2025.06)

CalVer is particularly useful for:
- Regular release cycles (monthly/quarterly)
- Applications where "compatibility" isn't easily determined
- Projects that follow time-based releases rather than feature-based releases

Example: Ubuntu's version numbers like `22.04` (Year 2022, April)

### Version Constraint Operators <a href="#version-constraint-operators" id="version-constraint-operators"></a>

When declaring dependency versions, various constraint operators can be used:

| Operator | Example | Meaning |
|----------|---------|---------|
| `=` | `= 1.2.3` | Exactly version 1.2.3 |
| `!=` | `!= 1.2.3` | Any version except 1.2.3 |
| `>` | `> 1.2.3` | Any version greater than 1.2.3 |
| `>=` | `>= 1.2.3` | Version 1.2.3 or greater |
| `<` | `< 1.2.3` | Any version less than 1.2.3 |
| `<=` | `<= 1.2.3` | Version 1.2.3 or less |
| `~>` | `~> 1.2.3` | Any version between 1.2.3 and 1.3.0 (exclusive) |
| `~>` | `~> 1.2` | Any version between 1.2.0 and 2.0.0 (exclusive) |

### Tools and Automation <a href="#tools-and-automation" id="tools-and-automation"></a>

Beyond GitVersion, several other tools can help manage component versions:

1. **Conventional Changelog** - Generates changelogs based on commit messages
2. **semantic-release** - Fully automates package releases
3. **commitizen** - Interactive CLI for formatted commit messages
4. **bump2version** - Simple version bumping
5. **Release Please** - Google's release automation tool

Example semantic-release configuration (`.releaserc`):

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github",
    ["@semantic-release/exec", {
      "prepareCmd": "terraform-docs markdown . > README.md"
    }]
  ]
}
```

### Best Practices Summary <a href="#best-practices-summary" id="best-practices-summary"></a>

1. **Choose a versioning scheme** that matches your release cadence and dependency model
2. **Automate version generation** in your CI/CD pipeline 
3. **Use explicit version pinning** for all dependencies
4. **Document version compatibility** between components
5. **Use git tags** to mark releases in your repository
6. **Include version information** in build artifacts and deployments
7. **Consider deployment impact** in your versioning strategy
8. **Maintain a changelog** that maps versions to changes

### Resources <a href="#resources" id="resources"></a>

* [GitVersion](https://gitversion.net/)
* [Semantic Versioning](https://semver.org/)
* [Calendar Versioning](https://calver.org/)
* [semantic-release](https://github.com/semantic-release/semantic-release)
* [Conventional Commits](https://www.conventionalcommits.org/)
* [npm semver calculator](https://semver.npmjs.com/)
* [Terraform Version Constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)

