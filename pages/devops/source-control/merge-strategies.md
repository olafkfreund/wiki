# Merge strategies

Agree if you want a linear or non-linear commit history. There are pros and cons to both approaches:

* Pro linear: [Avoid messy git history, use linear history](https://dev.to/bladesensei/avoid-messy-git-history-3g26)
* Con linear: [Why you should stop using Git rebase](https://medium.com/@fredrikmorken/why-you-should-stop-using-git-rebase-5552bee4fed1)

### Approach for non-linear commit history <a href="#approach-for-non-linear-commit-history" id="approach-for-non-linear-commit-history"></a>

Merging `topic` into `main`

```plaintext
  A---B---C topic
 /         \
D---E---F---G---H main

git fetch origin
git checkout main
git merge topic
```plaintext

### Two approaches to achieve a linear commit history <a href="#two-approaches-to-achieve-a-linear-commit-history" id="two-approaches-to-achieve-a-linear-commit-history"></a>

#### Rebase topic branch before merging into main <a href="#rebase-topic-branch-before-merging-into-main" id="rebase-topic-branch-before-merging-into-main"></a>

Before merging `topic` into `main`, we rebase `topic` with the `main` branch:

```plaintext
          A---B---C topic
         /         \
D---E---F-----------G---H main

git checkout main
git pull
git checkout topic
git rebase origin/main
```plaintext

Create a PR topic --> main in Azure DevOps and approve using the squash merge option

#### Rebase topic branch before squash merge into main <a href="#rebase-topic-branch-before-squash-merge-into-main" id="rebase-topic-branch-before-squash-merge-into-main"></a>

[Squash merging](https://learn.microsoft.com/en-us/azure/devops/repos/git/merging-with-squash?view=azure-devops) is a merge option that allows you to condense the Git history of topic branches when you complete a pull request. Instead of adding each commit on `topic` to the history of `main`, a squash merge takes all the file changes and adds them to a single new commit on `main`.

```plaintext
          A---B---C topic
         /
D---E---F-----------G---H main
```plaintext

Create a PR topic --> main in Azure DevOps and approve using the squash merge option
