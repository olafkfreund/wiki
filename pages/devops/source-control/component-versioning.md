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

### Resources <a href="#resources" id="resources"></a>

* [GitVersion](https://gitversion.net/)
* [Semantic Versioning](https://semver.org/)

