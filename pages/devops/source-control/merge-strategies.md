# Merge Strategies

The merge strategy you choose impacts your team's development workflow, code review practices, and deployment processes. This guide covers common merge strategies and their implementation across different CI/CD platforms.

## Linear vs Non-Linear History

When establishing a team's git workflow, agree on whether you want a linear or non-linear commit history:

* **Pro linear**: [Avoid messy git history, use linear history](https://dev.to/bladesensei/avoid-messy-git-history-3g26)
* **Con linear**: [Why you should stop using Git rebase](https://medium.com/@fredrikmorken/why-you-should-stop-using-git-rebase-5552bee4fed1)

### Approach for Non-Linear Commit History <a href="#approach-for-non-linear-commit-history" id="approach-for-non-linear-commit-history"></a>

Merging `topic` into `main` creates a merge commit:

```plaintext
  A---B---C topic
 /         \
D---E---F---G---H main
```

Implementation:

```bash
git fetch origin
git checkout main
git merge topic
```

### Two Approaches to Achieve a Linear Commit History <a href="#two-approaches-to-achieve-a-linear-commit-history" id="two-approaches-to-achieve-a-linear-commit-history"></a>

#### Rebase Topic Branch Before Merging into Main <a href="#rebase-topic-branch-before-merging-into-main" id="rebase-topic-branch-before-merging-into-main"></a>

Before merging `topic` into `main`, rebase `topic` with the `main` branch:

```plaintext
          A---B---C topic
         /         \
D---E---F-----------G---H main
```

Implementation:

```bash
git checkout main
git pull
git checkout topic
git rebase origin/main
```

#### Rebase Topic Branch Before Squash Merge into Main <a href="#rebase-topic-branch-before-squash-merge-into-main" id="rebase-topic-branch-before-squash-merge-into-main"></a>

[Squash merging](https://learn.microsoft.com/en-us/azure/devops/repos/git/merging-with-squash?view=azure-devops) condenses all commit history from a feature branch into a single commit on the target branch:

```plaintext
          A---B---C topic
         /
D---E---F-----------G main
```

## Platform-Specific Implementations

### Azure DevOps

Configure branch policies in Azure DevOps to enforce your selected merge strategy:

1. Navigate to **Repos** > **Branches**
2. Select the branch to configure (e.g., `main`)
3. Click **Branch policies**
4. Under **Merge strategies**, select your preferred option:
   - **Basic merge (no fast-forward)** - Creates a non-linear history with merge commits
   - **Squash merge** - Creates a linear history, combining all commits
   - **Rebase and fast-forward** - Creates a linear history, preserving individual commits

Example Azure DevOps Pipeline YAML policy enforcement:

```yaml
trigger:
  branches:
    include:
    - main
    - feature/*

pool:
  vmImage: 'ubuntu-latest'

steps:
- checkout: self
  persistCredentials: true
  
- script: |
    # Ensure feature branches are rebased on main before PR
    if [[ $(Build.SourceBranch) == refs/heads/feature/* ]]; then
      git checkout main
      git pull
      git checkout $(Build.SourceBranch)
      git rebase main
      git push --force-with-lease origin $(Build.SourceBranch)
    fi
  displayName: 'Enforce Linear History'
```

### GitHub

Configure repository settings in GitHub:

1. Go to your repository 
2. Navigate to **Settings** > **General**
3. Under **Pull Requests**, select your preferred merge strategy:
   - **Allow merge commits** - Non-linear history
   - **Allow squash merging** - Linear history with combined commits
   - **Allow rebase merging** - Linear history preserving individual commits

Example GitHub Actions workflow to enforce branch policies:

```yaml
name: Branch Policy

on:
  pull_request:
    branches: [ main ]

jobs:
  linear-history-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Check if branch is rebased on main
        run: |
          git fetch origin main
          MERGE_BASE=$(git merge-base HEAD origin/main)
          MAIN_HEAD=$(git rev-parse origin/main)
          
          if [ "$MERGE_BASE" != "$MAIN_HEAD" ]; then
            echo "ERROR: Branch is not rebased on latest main"
            echo "Please run: git checkout your-branch && git rebase origin/main"
            exit 1
          fi
```

### GitLab

Configure merge request settings in GitLab:

1. Go to **Settings** > **Merge requests**
2. Under **Merge method**, select your preferred option:
   - **Merge commit** - Non-linear history
   - **Merge commit with semi-linear history** - Requires rebase before merge
   - **Fast-forward merge** - Linear history

Example GitLab CI configuration:

```yaml
stages:
  - validate
  - build

validate_branch:
  stage: validate
  script:
    - |
      if [ "$CI_MERGE_REQUEST_TARGET_BRANCH_NAME" == "main" ]; then
        git fetch origin main
        MERGE_BASE=$(git merge-base HEAD origin/main)
        MAIN_HEAD=$(git rev-parse origin/main)
        
        if [ "$MERGE_BASE" != "$MAIN_HEAD" ]; then
          echo "Branch needs to be rebased on main"
          exit 1
        fi
      fi
  only:
    - merge_requests
```

## Multi-Cloud Infrastructure Development Considerations

When working with infrastructure as code across multiple cloud providers, consider these merge strategy recommendations:

### Pull Request Validation by Cloud Provider

For multi-cloud repositories, structure your CI validation to test changes against each cloud:

```yaml
# GitHub Actions example
name: Validate IaC Changes

on:
  pull_request:
    branches: [ main ]
    paths:
      - 'terraform/**'

jobs:
  validate:
    strategy:
      matrix:
        cloud: [aws, azure, gcp]
        include:
          - cloud: aws
            directory: terraform/aws
          - cloud: azure
            directory: terraform/azure
          - cloud: gcp
            directory: terraform/gcp
    
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Init
        run: terraform -chdir=${{ matrix.directory }} init -backend=false
        
      - name: Terraform Validate
        run: terraform -chdir=${{ matrix.directory }} validate
```

### Merge Strategy for IaC Repositories

For infrastructure as code repositories managing multiple cloud environments:

1. **Non-linear history (merge commits)** - Preferred when:
   - Changes need to be clearly grouped by provider or feature
   - Working with multiple cloud provider teams
   - Rollbacks need to target specific environments

2. **Linear history (rebase/squash)** - Preferred when:
   - Implementing cross-cloud standards
   - Creating consistent patterns across providers
   - Maintaining a clean deployment history

## Best Practices for Modern DevOps Teams

Regardless of your chosen strategy, follow these best practices:

1. **Document your strategy** - Include merge strategy guidelines in CONTRIBUTING.md

2. **Automate enforcement** - Use branch protection rules and CI/CD checks

3. **Use conventional commits** - Adopt [Conventional Commits](https://www.conventionalcommits.org/) syntax for clear history:
   ```bash
   feat(aws): add support for EKS Fargate profiles
   fix(azure): resolve AKS RBAC configuration issue
   docs(gcp): update GKE cluster setup instructions
   ```

4. **Consider GitOps workflows** - For environments managed through GitOps:
   ```bash
   # Create an environment-specific branch for GitOps controllers
   git checkout -b env/production
   # Merge changes from main with commit history preserved
   git merge --no-ff main
   ```

5. **Implement PR templates** - Create templates that enforce proper change documentation:
   ```markdown
   ## Description
   [Description of changes]
   
   ## Cloud Providers Affected
   - [ ] AWS
   - [ ] Azure
   - [ ] GCP
   
   ## Testing Performed
   [Description of testing]
   
   ## Merge Strategy
   - [ ] Standard merge (non-linear)
   - [ ] Squash commit
   - [ ] Rebase and merge
   ```

## Handling Hotfixes and Emergency Changes

For critical fixes that need to be applied quickly:

```bash
# Create hotfix branch from main
git checkout -b hotfix/critical-security-fix main

# Make changes and commit
git add .
git commit -m "fix: resolve critical security vulnerability in IAM policy"

# Create PR for review and merge directly to main
# After merging to main, cherry-pick to other environment branches if needed
git checkout env/production
git cherry-pick [commit-hash]
```

## Conclusion

Choose the merge strategy that best aligns with your team's workflow, project requirements, and organizational policies. Document your chosen approach and enforce it through automation to ensure consistency across your codebase.
