# Make Your Terminal DevOps and Kubernetes Friendly

If you work with DevOps and Kubernetes, you know how important the command line interface (CLI) is for managing tasks. Fortunately, there are tools available that make the terminal easier to use in these environments. In this article, we’ll explore some top tools that simplify your workflow and help you navigate the terminal with confidence in DevOps and Kubernetes.

## ZSH <a href="#d188" id="d188"></a>

[Zsh (Z Shell)](https://www.zsh.org/) is a powerful and highly customizable command-line shell and terminal emulator that offers enhanced features and productivity improvements over traditional shells like Bash. Providing the following options makes it a popular choice among developers and DevOps engineers.

## ohmyzsh <a href="#a719" id="a719"></a>

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) is an open-source, community-driven framework for managing your Zsh configuration. You can install it with curl as below:

```bash
sh -c "$(curl -fsSL <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"
```plaintext

## zsh-syntax-highlighting <a href="#5597" id="5597"></a>

[zsh-syntx-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) is a plugin for the Zsh shell that provides real-time syntax highlighting for commands and their arguments as you type. It helps visually distinguish between different types of commands, options, paths, and variables, making it easier to spot errors and understand the structure of your commands in the terminal.

Follow the installation guide [HERE](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md).

This is what my terminal looks like before and after installing the tool:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*88WeD6CLCmXJYQT_DywlYw.png" alt="" height="314" width="700"><figcaption><p><strong>Before installation</strong></p></figcaption></figure>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*GbvokD69KHHDTHHFoMsMlQ.png" alt="" height="315" width="700"><figcaption><p><strong>After installation</strong></p></figcaption></figure>

## zsh-autosuggestions <a href="#06d6" id="06d6"></a>

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) is a helpful plugin for the Zsh shell that offers intelligent command suggestions as you type. It analyzes your command history and provides predictive suggestions for completing commands.

Follow the installation guide [HERE](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md).

This is what my terminal looks like before and after installing the tool:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*bV-6hwurlCMZvEi9z9RJ0w.png" alt="" height="32" width="700"><figcaption><p><strong>Before installation</strong></p></figcaption></figure>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*U0XHGbUj-UCC4TWNe8sNzg.png" alt="" height="28" width="700"><figcaption><p><strong>After installation</strong></p></figcaption></figure>

## Terraform <a href="#93e0" id="93e0"></a>

If you work with Terraform and Terragrunt as Infrastructure as Code tools, then you might find the below relevant tools useful while working with Terraform and Terragrunt.

## tfswitch and tgswitch <a href="#3092" id="3092"></a>

[Tfswitch](https://github.com/warrensbox/terraform-switcher) and [tgswitch](https://github.com/warrensbox/tgswitch) are command line tools that simplify switching between different versions of the Terraform and Terragrunt infrastructure-as-code tools. They allow developers and operators to easily manage and switch between different versions of Terraform and Terragrunt for different projects or environments.

On Mac, you can install these tools as below:

```bash
brew install warrensbox/tap/tfswitch
brew install warrensbox/tap/tgswitch
```plaintext

**NOTE:** For Terraform and Terragrunt installations to work with tfswitch and tgswitch on Mac with Zsh, you might need to add the below line to your .zshrc file.

```sh
export PATH=$HOME/bin:/usr/local/bin:$PATH
```plaintext

## Infracost <a href="#ce37" id="ce37"></a>

[Infracost](https://www.infracost.io/) is a powerful tool that helps you estimate and track the cost of your infrastructure as code (IaC) in platforms like Terraform. By analyzing your infrastructure configuration files, Infracost provides real-time cost estimates, allowing you to make informed decisions and optimize your cloud spending by identifying potential cost-saving opportunities.

This tool also has a [Visual Studio Code (VSCode) extension](https://github.com/infracost/vscode-infracost/).

This is what I got running it for a project:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*-poFkzF3rjT6JL9AUhSWJA.png" alt="" height="579" width="700"><figcaption></figcaption></figure>

## TfSec <a href="#77cb" id="77cb"></a>

[TFSec](https://github.com/aquasecurity/tfsec) is a security scanning tool specifically designed for Terraform code. It helps identify potential security vulnerabilities and best practice violations in your infrastructure as code, allowing you to proactively address security concerns and ensure compliance with industry standards and organizational policies.

You can install it on Mac as below:

```shell
brew install tfsec
```plaintext

This is what I got running it for my project:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*5m9pXM_jVn3AGrV23q0pwQ.png" alt="" height="493" width="700"><figcaption></figcaption></figure>

## Git <a href="#1bca" id="1bca"></a>

There are also some tools that make your life easier if you work with Git!

## Git aliases <a href="#fbf2" id="fbf2"></a>

Using aliases for Git offers numerous benefits, including enhanced productivity and efficiency by minimizing the need to repeatedly type lengthy Git commands. If you frequently work with Git, it is recommended to define aliases for commonly used Git commands in your .zshrc file. Here’s an example section to help you get started:

```sh
# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
```plaintext

By defining these aliases in your shell configuration file (e.g., .bashrc or .zshrc), you can simply type the alias instead of the full Git command to execute common operations, saving you time and effort in your daily Git workflow.

## GitLens <a href="#a2e7" id="a2e7"></a>

[GitLens](https://gitlens.amod.io/) is a helpful extension for VSCode that provides valuable insights and additional functionality when working with Git repositories. It enables users to easily track changes, view commit details, and understand code authorship directly within the code editor, enhancing collaboration and making it easier to navigate and explore the history of a project.

Once you enable the GitLens extension in Visual Studio Code, you will see clear indications of code authorship:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*JC-afixfIQ0jZrpRLuKU2g.png" alt="" height="160" width="700"><figcaption></figcaption></figure>

## Git Graph <a href="#1dfa" id="1dfa"></a>

[Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph) is a user-friendly extension for Visual Studio Code that displays a visual representation of your Git repository’s commit history. It allows you to easily visualize branches, merges, and commits, providing a helpful overview of the project’s development timeline and making it simpler to navigate and understand the structure of your Git repository.

## Kubernetes <a href="#bf9d" id="bf9d"></a>

Due to the complexity of Kubernetes, many additional tools have been created to assist DevOps teams in effectively utilizing it. These tools are designed to simplify the process, allowing DevOps professionals to seamlessly work with Kubernetes and optimize their deployment and management tasks.

## Kubernetes aliases <a href="#e1b6" id="e1b6"></a>

Just like using aliases for Git commands, utilizing aliases for Kubernetes commands is also beneficial. Aliases can make working with Kubernetes commands easier and more efficient, saving time and effort when interacting with Kubernetes clusters and resources.

```shell
alias k='kubectl'
```plaintext

```sh
# For switching context between different clusters
alias kswitch-maryam='kubectl config use-context maryam'
alias kswitch-mary='kubectl config use-context mary'alias kpod='kubectl get pods -A'
alias knode='kubectl get nodes'
alias kdesp='kubectl describe pod'
alias kdp='kubectl delete pod'
alias kgd='kubectl get deployments'
```plaintext

These are just a few examples, and you can customize aliases based on your frequently used Kubernetes commands. By adding these aliases to your shell configuration file (e.g., .bashrc or .zshrc), you can use these shortcuts to execute Kubernetes commands quickly and easily.

## kube-ps1 <a href="#19de" id="19de"></a>

[Kube-ps1](https://github.com/jonmosco/kube-ps1) enhances your command prompt with relevant information about your current Kubernetes context. It has been incredibly helpful for me while working with multiple Kubernetes clusters and managing different cluster contexts. Visually highlighting the details of the active cluster context, it has saved me from potential mistakes and provided clarity in navigating and interacting with Kubernetes environments.

You can install it on Mac as follow:

```sh
brew install kube-ps1
```plaintext

If you work with Zsh, make sure to add the below to your .zshrc file:

```sh
plugins=(
  kube-ps1
)
```plaintext

```sh
PROMPT='$(kube_ps1)'$PROMPT # or RPROMPT='$(kube_ps1)'
```plaintext

This is how this tool visualizes your current active context and namespace:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*FzuTCCP_yAyv_PHe30U3kg.png" alt="" height="107" width="700"><figcaption></figcaption></figure>

## kubecolor <a href="#ffe0" id="ffe0"></a>

[Kubecolor](https://github.com/hidetatz/kubecolor) is a handy tool that enhances the output of Kubernetes commands with color and formatting, making it easier to read and understand. Kubecolor improves visibility and helps quickly identify important information when working with Kubernetes. (Its again one lifesaver tool while daily working with Kubernetes!)

Install it as below on Mac and make sure to add the second line to your .zshrc for it to work with kubectl auto-complete:

```sh
brew install hidetatz/tap/kubecolor
# get zsh complete kubectl
source <(kubectl completion zsh)
alias kubectl=kubecolor
# make completion work with kubecolor
compdef kubecolor=kubectl
```plaintext

This is an example of how this tool colorizes the output of Kubernetes commands:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*TPJOH-x436fJ3vkHp6nY3A.png" alt="" height="269" width="700"><figcaption></figcaption></figure>

## kubectx + kubens <a href="#357e" id="357e"></a>

[Kubectx and kubens](https://github.com/ahmetb/kubectx) are helpful tools for managing Kubernetes contexts and namespaces. Kubectx allows users to switch between different Kubernetes contexts, while Kubens simplifies switching between namespaces within a specific context, making it easier to work with multiple clusters and organize resources efficiently.

## K9s <a href="#64d1" id="64d1"></a>

[K9s](https://k9scli.io/) is a user-friendly command-line tool that provides a visual dashboard for managing Kubernetes clusters. It offers a simple and intuitive interface to view and interact with resources, pods, logs, and events, making it easier for DevOps professionals to monitor and troubleshoot their Kubernetes deployments.

## k8s Lens <a href="#3dc8" id="3dc8"></a>

[K8s Lens](https://k8slens.dev/) is a user-friendly desktop application that provides a graphical interface for managing and monitoring Kubernetes clusters. It offers a visual representation of resources, pods, and nodes, allowing users to easily navigate and interact with their Kubernetes environments, making it convenient for developers and administrators to work with Kubernetes.

## popeye <a href="#7384" id="7384"></a>

[Popeye](https://github.com/derailed/popeye) is a helpful command-line tool that analyzes Kubernetes clusters and provides valuable insights regarding potential issues or misconfigurations. It scans the cluster configuration, namespaces, deployments, and pods to identify best practices violations, resource inefficiencies, and security concerns, helping users ensure their Kubernetes deployments are optimized and well-maintained.

This is the example information that scanning a cluster, Popeye will give you:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*lVIK3JDjEpCuxTPaGbSScg.png" alt="" height="308" width="700"><figcaption></figcaption></figure>

Install the tool on Mac as below:

```sh
brew install derailed/popeye/popeye
```plaintext

## Kube-shell <a href="#3201" id="3201"></a>

[Kube-shell](https://github.com/cloudnativelabs/kube-shell) is an integrated shell for Kubernetes CLI. It offers a user-friendly interface with visual representations of cluster resources, allowing users to easily navigate, monitor, and manage their Kubernetes deployments without needing to rely on command-line interfaces.

## Kube-Capacity <a href="#12ea" id="12ea"></a>

[Kube-Capacity](https://github.com/robscott/kube-capacity) is a handy tool that provides insights into the resource usage and capacity of your Kubernetes cluster. It helps you understand how your cluster’s resources are allocated and utilized, allowing you to optimize resource allocation, plan for scaling, and ensure efficient resource management within your Kubernetes environment.
