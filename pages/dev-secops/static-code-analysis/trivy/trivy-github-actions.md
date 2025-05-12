# Trivy GitHub Actions

### Usage

#### Scan CI Pipeline

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build an image from Dockerfile
        run: |
          docker build -t docker.io/my-organization/my-app:${{ github.sha }} .
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'
```plaintext

#### Scan CI Pipeline (w/ Trivy Config)

```yaml
name: build
on:
  push:
    branches:
    - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Run Trivy vulnerability scanner in fs mode
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        trivy-config: trivy.yaml
```plaintext

In this case `trivy.yaml` is a YAML configuration that is checked in as part of the repo. Detailed information is available on the Trivy website but an example is as follows:

```yaml
format: json
exit-code: 1
severity: CRITICAL
```plaintext

It is possible to define all options in the `trivy.yaml` file. Specifying individual options via the action are left for backward compatibility purposes. Defining the following is required as they cannot be defined with the config file:

* `scan-ref`: If using `fs, repo` scans.
* `image-ref`: If using `image` scan.
* `scan-type`: To define the scan type, e.g. `image`, `fs`, `repo`, etc.

**Order of prerference for options**

Trivy uses [Viper](https://github.com/spf13/viper) which has a defined precedence order for options. The order is as follows:

* GitHub Action flag
* Environment variable
* Config file
* Default

#### Scanning a Tarball

```yaml
name: build
on:
  push:
    branches:
    - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Generate tarball from image
      run: |
        docker pull <your-docker-image>
        docker save -o vuln-image.tar <your-docker-image>
        
    - name: Run Trivy vulnerability scanner in tarball mode
      uses: aquasecurity/trivy-action@master
      with:
        input: /github/workspace/vuln-image.tar
        severity: 'CRITICAL,HIGH'
```plaintext

#### Using Trivy with GitHub Code Scanning

If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Trivy as a scanning tool as follows:

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build an image from Dockerfile
        run: |
          docker build -t docker.io/my-organization/my-app:${{ github.sha }} .

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

You can find a more in-depth example here: [https://github.com/aquasecurity/trivy-sarif-demo/blob/master/.github/workflows/scan.yml](https://github.com/aquasecurity/trivy-sarif-demo/blob/master/.github/workflows/scan.yml)

If you would like to upload SARIF results to GitHub Code scanning even upon a non zero exit code from Trivy Scan, you can add the following to your upload step:

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build an image from Dockerfile
        run: |
          docker build -t docker.io/my-organization/my-app:${{ github.sha }} .

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

See this for more details: [https://docs.github.com/en/actions/learn-github-actions/expressions#always](https://docs.github.com/en/actions/learn-github-actions/expressions#always)

#### Using Trivy to scan your Git repo

It's also possible to scan your git repos with Trivy's built-in repo scan. This can be handy if you want to run Trivy as a build time check on each PR that gets opened in your repo. This helps you identify potential vulnerablites that might get introduced with each PR.

If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Trivy as a scanning tool as follows:

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner in repo mode
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

#### Using Trivy to scan your rootfs directories

It's also possible to scan your rootfs directories with Trivy's built-in rootfs scan. This can be handy if you want to run Trivy as a build time check on each PR that gets opened in your repo. This helps you identify potential vulnerablites that might get introduced with each PR.

If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Trivy as a scanning tool as follows:

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner with rootfs command
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'rootfs'
          scan-ref: 'rootfs-example-binary'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

#### Using Trivy to scan Infrastructure as Code

It's also possible to scan your IaC repos with Trivy's built-in repo scan. This can be handy if you want to run Trivy as a build time check on each PR that gets opened in your repo. This helps you identify potential vulnerablites that might get introduced with each PR.

If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Trivy as a scanning tool as follows:

```plaintext
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner in IaC mode
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          hide-progress: false
          format: 'sarif'
          output: 'trivy-results.sarif'
          exit-code: '1'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

#### Using Trivy to generate SBOM

It's possible for Trivy to generate an [SBOM](https://www.aquasec.com/cloud-native-academy/supply-chain-security/sbom/) of your dependencies and submit them to a consumer like [GitHub Dependency Graph](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-the-dependency-graph).

The [sending of an SBOM to GitHub](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/using-the-dependency-submission-api) feature is only available if you currently have GitHub Dependency Graph [enabled in your repo](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/configuring-the-dependency-graph#enabling-and-disabling-the-dependency-graph-for-a-private-repository).

In order to send results to GitHub Dependency Graph, you will need to create a [GitHub PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) or use the [GitHub installation access token](https://docs.github.com/en/actions/security-guides/automatic-token-authentication) (also known as `GITHUB_TOKEN`):

```yaml
---
name: Pull Request
on:
  push:
    branches:
    - master

## GITHUB_TOKEN authentication, add only if you're not going to use a PAT
permissions:
  contents: write

jobs:
  build:
    name: Checks
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy in GitHub SBOM mode and submit results to Dependency Graph
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          format: 'github'
          output: 'dependency-results.sbom.json'
          image-ref: '.'
          github-pat: ${{ secrets.GITHUB_TOKEN }} # or ${{ secrets.github_pat_name }} if you're using a PAT
```plaintext

#### Using Trivy to scan your private registry

It's also possible to scan your private registry with Trivy's built-in image scan. All you have to do is set ENV vars.

**Docker Hub registry**

Docker Hub needs `TRIVY_USERNAME` and `TRIVY_PASSWORD`. You don't need to set ENV vars when downloading from a public repository.

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
        env:
          TRIVY_USERNAME: Username
          TRIVY_PASSWORD: Password

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

**AWS ECR (Elastic Container Registry)**

Trivy uses AWS SDK. You don't need to install `aws` CLI tool. You can use [AWS CLI's ENV Vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'aws_account_id.dkr.ecr.region.amazonaws.com/imageName:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
        env:
          AWS_ACCESS_KEY_ID: key_id
          AWS_SECRET_ACCESS_KEY: access_key
          AWS_DEFAULT_REGION: us-west-2

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

**GCR (Google Container Registry)**

Trivy uses Google Cloud SDK. You don't need to install `gcloud` command.

If you want to use target project's repository, you can set it via `GOOGLE_APPLICATION_CREDENTIAL`.

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
        env:
          GOOGLE_APPLICATION_CREDENTIAL: /path/to/credential.json

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

**Self-Hosted**

BasicAuth server needs `TRIVY_USERNAME` and `TRIVY_PASSWORD`. if you want to use 80 port, use NonSSL `TRIVY_NON_SSL=true`

```yaml
name: build
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
        env:
          TRIVY_USERNAME: Username
          TRIVY_PASSWORD: Password

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```plaintext

### Customizing

#### inputs

Following inputs can be used as `step.with` keys:

<table data-full-width="true"><thead><tr><th>Name</th><th>Type</th><th>Default</th><th>Description</th></tr></thead><tbody><tr><td><code>scan-type</code></td><td>String</td><td><code>image</code></td><td>Scan type, e.g. <code>image</code> or <code>fs</code></td></tr><tr><td><code>input</code></td><td>String</td><td></td><td>Tar reference, e.g. <code>alpine-latest.tar</code></td></tr><tr><td><code>image-ref</code></td><td>String</td><td></td><td>Image reference, e.g. <code>alpine:3.10.2</code></td></tr><tr><td><code>scan-ref</code></td><td>String</td><td><code>/github/workspace/</code></td><td>Scan reference, e.g. <code>/github/workspace/</code> or <code>.</code></td></tr><tr><td><code>format</code></td><td>String</td><td><code>table</code></td><td>Output format (<code>table</code>, <code>json</code>, <code>sarif</code>, <code>github</code>)</td></tr><tr><td><code>template</code></td><td>String</td><td></td><td>Output template (<code>@/contrib/gitlab.tpl</code>, <code>@/contrib/junit.tpl</code>)</td></tr><tr><td><code>output</code></td><td>String</td><td></td><td>Save results to a file</td></tr><tr><td><code>exit-code</code></td><td>String</td><td><code>0</code></td><td>Exit code when specified vulnerabilities are found</td></tr><tr><td><code>ignore-unfixed</code></td><td>Boolean</td><td>false</td><td>Ignore unpatched/unfixed vulnerabilities</td></tr><tr><td><code>vuln-type</code></td><td>String</td><td><code>os,library</code></td><td>Vulnerability types (os,library)</td></tr><tr><td><code>severity</code></td><td>String</td><td><code>UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL</code></td><td>Severities of vulnerabilities to scanned for and displayed</td></tr><tr><td><code>skip-dirs</code></td><td>String</td><td></td><td>Comma separated list of directories where traversal is skipped</td></tr><tr><td><code>skip-files</code></td><td>String</td><td></td><td>Comma separated list of files where traversal is skipped</td></tr><tr><td><code>cache-dir</code></td><td>String</td><td></td><td>Cache directory</td></tr><tr><td><code>timeout</code></td><td>String</td><td><code>5m0s</code></td><td>Scan timeout duration</td></tr><tr><td><code>ignore-policy</code></td><td>String</td><td></td><td>Filter vulnerabilities with OPA rego language</td></tr><tr><td><code>hide-progress</code></td><td>String</td><td><code>true</code></td><td>Suppress progress bar</td></tr><tr><td><code>list-all-pkgs</code></td><td>String</td><td></td><td>Output all packages regardless of vulnerability</td></tr><tr><td><code>scanners</code></td><td>String</td><td><code>vuln,secret</code></td><td>comma-separated list of what security issues to detect (<code>vuln</code>,<code>secret</code>,<code>config</code>)</td></tr><tr><td><code>trivyignores</code></td><td>String</td><td></td><td>comma-separated list of relative paths in repository to one or more <code>.trivyignore</code> files</td></tr><tr><td><code>trivy-config</code></td><td>String</td><td></td><td>Path to trivy.yaml config</td></tr><tr><td><code>github-pat</code></td><td>String</td><td></td><td>Authentication token to enable sending SBOM scan results to GitHub Dependency Graph. Can be either a GitHub Personal Access Token (PAT) or GITHUB_TOKEN</td></tr><tr><td><code>limit-severities-for-sarif</code></td><td>Boolean</td><td>false</td><td>By default <em>SARIF</em> format enforces output of all vulnerabilities regardless of configured severities. To override this behavior set this parameter to <strong>true</strong></td></tr></tbody></table>
