# yq for DevOps & SRE (2025)

yq is a lightweight, portable command-line YAML, JSON, and XML processor. It is essential for DevOps and SRE engineers working with Kubernetes, Terraform, Ansible, and CI/CD pipelines across AWS, Azure, GCP, Linux, NixOS, and WSL environments.

## Why Use yq in DevOps & SRE?
- **Automate YAML/JSON edits**: Update Kubernetes manifests, Terraform variables, and CI/CD configs programmatically.
- **Bulk Operations**: Apply changes across multiple files for GitOps, policy enforcement, or compliance.
- **CI/CD Integration**: Use yq in GitHub Actions, Azure Pipelines, or GitLab CI/CD for validation, patching, and templating.
- **Cloud-Native**: Works seamlessly with cloud IaC and configuration workflows.

## Real-Life Examples

### 1. Update Image Tag in All Kubernetes Deployments
```sh
grep -rl 'image:' ./k8s | xargs -I{} yq -i '.spec.template.spec.containers[0].image = "nginx:1.25.0"' {}
```

### 2. Extract All Resource Limits for Audit
```sh
find ./manifests -name '*.yaml' | xargs -I{} yq '.spec.template.spec.containers[].resources.limits' {}
```

### 3. Patch a Value in a CI/CD Pipeline (GitHub Actions)
```yaml
- name: Patch image tag in deployment
  run: yq -i '.spec.template.spec.containers[0].image = "myrepo/app:${{ github.sha }}"' k8s/deployment.yaml
```

### 4. Merge Multiple YAML Files for GitOps
```sh
yq ea '. as $item ireduce ({}; . * $item )' overlays/*.yml > merged.yaml
```

### 5. Use Environment Variables for Dynamic Values
```sh
export VERSION=1.2.3
yq -i '.app.version = strenv(VERSION)' values.yaml
```

## Best Practices (2025)
- Always validate YAML after edits: `kubectl apply --dry-run=client -f file.yaml`
- Use yq in CI/CD for repeatable, automated changes
- Document yq commands in README or pipeline logs
- Prefer explicit paths to avoid accidental overwrites
- Use yq with version control for traceability

## Common Pitfalls
- Overwriting files without backup (`-i` is destructive)
- Not validating YAML after bulk edits
- Using ambiguous paths (be specific to avoid wrong fields)
- Forgetting to quote strings with special characters

## Install

#### [Download the latest binary](https://github.com/mikefarah/yq/releases/latest)

#### wget

Use wget to download, gzipped pre-compiled binaries:

For instance, VERSION=v4.2.0 and BINARY=yq\_linux\_amd64

**Compressed via tar.gz**

```sh
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/yq
```plaintext

**Plain binary**

```sh
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
```plaintext

**Latest version**

```sh
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
```plaintext

#### MacOS / Linux via Homebrew:

Using [Homebrew](https://brew.sh/)

```shell
brew install yq
```plaintext

#### Linux via snap:

```shell
snap install yq
```plaintext

**Snap notes**

`yq` installs with [_strict confinement_](https://docs.snapcraft.io/snap-confinement/6233) in snap, this means it doesn't have direct access to root files. To read root files you can:

```sh
sudo cat /etc/myfile | yq '.a.path'
```plaintext

And to write to a root file you can either use [sponge](https://linux.die.net/man/1/sponge):

```shell
sudo cat /etc/myfile | yq '.a.path = "value"' | sudo sponge /etc/myfile
```plaintext

or write to a temporary file:

```sh
sudo cat /etc/myfile | yq '.a.path = "value"' | sudo tee /etc/myfile.tmp
sudo mv /etc/myfile.tmp /etc/myfile
rm /etc/myfile.tmp
```plaintext

#### Run with Docker or Podman

**Oneshot use:**

```sh
docker run --rm -v "${PWD}":/workdir mikefarah/yq [command] [flags] [expression ]FILE...
```plaintext

Note that you can run `yq` in docker without network access and other privileges if you desire, namely `--security-opt=no-new-privileges --cap-drop all --network none`.

```shell
podman run --rm -v "${PWD}":/workdir mikefarah/yq [command] [flags] [expression ]FILE...
```plaintext

**Pipe in via STDIN:**

You'll need to pass the `-i\--interactive` flag to docker:

```sh
docker run -i --rm mikefarah/yq '.this.thing' < myfile.yml
```plaintext

```sh
podman run -i --rm mikefarah/yq '.this.thing' < myfile.yml
```plaintext

**Run commands interactively:**

```sh
docker run --rm -it -v "${PWD}":/workdir --entrypoint sh mikefarah/yq
```plaintext

```sh
podman run --rm -it -v "${PWD}":/workdir --entrypoint sh mikefarah/yq
```plaintext

It can be useful to have a bash function to avoid typing the whole docker command:

```shell
yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}
```plaintext

```shell
yq() {
  podman run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}
```plaintext

**Running as root:**

`yq`'s container image no longer runs under root ([#860](https://github.com/mikefarah/yq/pull/860)). If you'd like to install more things in the container image, or you're having permissions issues when attempting to read/write files you'll need to either:

```sh
docker run --user="root" -it --entrypoint sh mikefarah/yq
```plaintext

```sh
podman run --user="root" -it --entrypoint sh mikefarah/yq
```plaintext

Or, in your Dockerfile:

```shell
FROM mikefarah/yq

USER root
RUN apk add --no-cache bash
USER yq
```plaintext

**Missing timezone data**

By default, the alpine image yq uses does not include timezone data. If you'd like to use the `tz` operator, you'll need to include this data:

```shell
FROM mikefarah/yq

USER root
RUN apk add --no-cache tzdata
USER yq
```plaintext

**Podman with SELinux**

If you are using podman with SELinux, you will need to set the shared volume flag `:z` on the volume mount:

```sh
-v "${PWD}":/workdir:z
```plaintext

#### GitHub Action

```shell
  - name: Set foobar to cool
    uses: mikefarah/yq@master
    with:
      cmd: yq -i '.foo.bar = "cool"' 'config.yml'
  - name: Get an entry with a variable that might contain dots or spaces
    id: get_username
    uses: mikefarah/yq@master
    with:
      cmd: yq '.all.children.["${{ matrix.ip_address }}"].username' ops/inventories/production.yml
  - name: Reuse a variable obtained in another step
    run: echo ${{ steps.get_username.outputs.result }}
```plaintext

See [https://mikefarah.gitbook.io/yq/usage/github-action](https://mikefarah.gitbook.io/yq/usage/github-action) for more.

#### Go Install:

```sh
go install github.com/mikefarah/yq/v4@latest
```plaintext

---

> **yq Joke:**
> Why did the SRE love yq? Because it could fix YAML faster than they could break it!
