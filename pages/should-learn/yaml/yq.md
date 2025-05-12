# yq

a lightweight and portable command-line YAML, JSON and XML processor. `yq` uses [jq](https://github.com/stedolan/jq) like syntax but works with yaml files as well as json, xml, properties, csv and tsv. It doesn't yet support everything `jq` does - but it does support the most common operations and functions, and more is being added continuously.

yq is written in go - so you can download a dependency free binary for your platform and you are good to go! If you prefer there are a variety of package managers that can be used as well as Docker and Podman, all listed below.

### Quick Usage Guide

Read a value:

```sh
yq '.a.b[0].c' file.yaml
```plaintext

Pipe from STDIN:

```sh
yq '.a.b[0].c' < file.yaml
```plaintext

Update a yaml file, inplace

```sh
yq -i '.a.b[0].c = "cool"' file.yaml
```plaintext

Update using environment variables

```shell
NAME=mike yq -i '.a.b[0].c = strenv(NAME)' file.yaml
```plaintext

Merge multiple files

```shell
# note the use of `ea` to evaluate all the files at once
# instead of in sequence
yq ea '. as $item ireduce ({}; . * $item )' path/to/*.yml
```plaintext

Multiple updates to a yaml file

```sh
yq -i '
  .a.b[0].c = "cool" |
  .x.y.z = "foobar" |
  .person.name = strenv(NAME)
' file.yaml
```plaintext

Convert JSON to YAML

```plaintext
yq -Poy sample.json
```plaintext

See the [documentation](https://mikefarah.gitbook.io/yq/) for more examples.

Take a look at the discussions for [common questions](https://github.com/mikefarah/yq/discussions/categories/q-a), and [cool ideas](https://github.com/mikefarah/yq/discussions/categories/show-and-tell)

### Install

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
