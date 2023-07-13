# yq

a lightweight and portable command-line YAML, JSON and XML processor. `yq` uses [jq](https://github.com/stedolan/jq) like syntax but works with yaml files as well as json, xml, properties, csv and tsv. It doesn't yet support everything `jq` does - but it does support the most common operations and functions, and more is being added continuously.

yq is written in go - so you can download a dependency free binary for your platform and you are good to go! If you prefer there are a variety of package managers that can be used as well as Docker and Podman, all listed below.

### Quick Usage Guide

Read a value:

```sh
yq '.a.b[0].c' file.yaml
```

Pipe from STDIN:

```sh
yq '.a.b[0].c' < file.yaml
```

Update a yaml file, inplace

```sh
yq -i '.a.b[0].c = "cool"' file.yaml
```

Update using environment variables

```shell
NAME=mike yq -i '.a.b[0].c = strenv(NAME)' file.yaml
```

Merge multiple files

```shell
# note the use of `ea` to evaluate all the files at once
# instead of in sequence
yq ea '. as $item ireduce ({}; . * $item )' path/to/*.yml
```

Multiple updates to a yaml file

```sh
yq -i '
  .a.b[0].c = "cool" |
  .x.y.z = "foobar" |
  .person.name = strenv(NAME)
' file.yaml
```

Convert JSON to YAML

```
yq -Poy sample.json
```

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
```

**Plain binary**

```sh
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
```

**Latest version**

```sh
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
```

#### MacOS / Linux via Homebrew:

Using [Homebrew](https://brew.sh/)

```shell
brew install yq
```

#### Linux via snap:

```shell
snap install yq
```

**Snap notes**

`yq` installs with [_strict confinement_](https://docs.snapcraft.io/snap-confinement/6233) in snap, this means it doesn't have direct access to root files. To read root files you can:

```sh
sudo cat /etc/myfile | yq '.a.path'
```

And to write to a root file you can either use [sponge](https://linux.die.net/man/1/sponge):

```shell
sudo cat /etc/myfile | yq '.a.path = "value"' | sudo sponge /etc/myfile
```

or write to a temporary file:

```sh
sudo cat /etc/myfile | yq '.a.path = "value"' | sudo tee /etc/myfile.tmp
sudo mv /etc/myfile.tmp /etc/myfile
rm /etc/myfile.tmp
```

#### Run with Docker or Podman

**Oneshot use:**

```sh
docker run --rm -v "${PWD}":/workdir mikefarah/yq [command] [flags] [expression ]FILE...
```

Note that you can run `yq` in docker without network access and other privileges if you desire, namely `--security-opt=no-new-privileges --cap-drop all --network none`.

```shell
podman run --rm -v "${PWD}":/workdir mikefarah/yq [command] [flags] [expression ]FILE...
```

**Pipe in via STDIN:**

You'll need to pass the `-i\--interactive` flag to docker:

```sh
docker run -i --rm mikefarah/yq '.this.thing' < myfile.yml
```

```sh
podman run -i --rm mikefarah/yq '.this.thing' < myfile.yml
```

**Run commands interactively:**

```sh
docker run --rm -it -v "${PWD}":/workdir --entrypoint sh mikefarah/yq
```

```sh
podman run --rm -it -v "${PWD}":/workdir --entrypoint sh mikefarah/yq
```

It can be useful to have a bash function to avoid typing the whole docker command:

```shell
yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}
```

```shell
yq() {
  podman run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}
```

**Running as root:**

`yq`'s container image no longer runs under root ([#860](https://github.com/mikefarah/yq/pull/860)). If you'd like to install more things in the container image, or you're having permissions issues when attempting to read/write files you'll need to either:

```sh
docker run --user="root" -it --entrypoint sh mikefarah/yq
```

```sh
podman run --user="root" -it --entrypoint sh mikefarah/yq
```

Or, in your Dockerfile:

```shell
FROM mikefarah/yq

USER root
RUN apk add --no-cache bash
USER yq
```

**Missing timezone data**

By default, the alpine image yq uses does not include timezone data. If you'd like to use the `tz` operator, you'll need to include this data:

```shell
FROM mikefarah/yq

USER root
RUN apk add --no-cache tzdata
USER yq
```

**Podman with SELinux**

If you are using podman with SELinux, you will need to set the shared volume flag `:z` on the volume mount:

```sh
-v "${PWD}":/workdir:z
```

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
```

See [https://mikefarah.gitbook.io/yq/usage/github-action](https://mikefarah.gitbook.io/yq/usage/github-action) for more.

#### Go Install:

```sh
go install github.com/mikefarah/yq/v4@latest
```
