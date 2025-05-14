---
description: >-
  A utility to generate documentation from Terraform modules in various output
  formats.
---

# Terraform-docs

### Installation:

Linux:

```bash
brew install terraform-docs/tap/terraform-docs
```plaintext

Windows:

```powershell
scoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket
scoop install terraform-docs
```plaintext

```powershell
choco install terraform-docs
```plaintext

Docker/Podman

{% code overflow="wrap" lineNumbers="true" %}
```bash
/docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs
```plaintext
{% endcode %}

GitHub Actions:

{% code overflow="wrap" lineNumbers="true" %}
```yaml
/name: Generate terraform docs
on:
  - pull_request

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.ref }}

    - name: Render terraform docs and push changes back to PR
      uses: terraform-docs/gh-actions@main
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```plaintext
{% endcode %}

#### pre-commit hook

With pre-commit, you can ensure your Terraform module documentation is kept up-to-date each time you make a commit.

{% code overflow="wrap" lineNumbers="true" %}
```yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.16.0"
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md", "./mymodule/path"]
```plaintext
{% endcode %}

### Configuration

terraform-docs can be configured with a yaml file. The default name of this file is `.terraform-docs.yml` and the path order for locating it is:

1. root of module directory
2. `.config/` folder at root of module directory
3. current directory
4. `.config/` folder at current directory
5. `$HOME/.tfdocs.d/`

{% code overflow="wrap" lineNumbers="true" %}
```yaml
formatter: "" # this is required

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules

sections:
  hide: []
  show: []

content: ""

output:
  file: ""
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: trueaml
```plaintext
{% endcode %}
