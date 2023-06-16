---
description: >-
  Terrascan is a portable executable that does not strictly require
  installation, and is also available as a container image in Docker Hub.
---

# Terrascan

Install Linux:

{% code overflow="wrap" lineNumbers="true" %}
```bash
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Darwin_x86_64.tar.gz")" > terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
install terrascan /usr/local/bin && rm terrascan
$ alias terrascan="`pwd`/terrascan
terrascan
```
{% endcode %}

Windows Install:

```
tar -zxf terrascan_<version number>_Windows_x86_64.tar.gz
```

Docker use:

```bash
$ docker run --rm tenable/terrascan version
```

Use terrascan with docker from command line:

{% code overflow="wrap" lineNumbers="true" %}
```bash
alias terrascan="docker run --rm -it -v "$(pwd):/iac" -w /iac tenable/terrascan"
```
{% endcode %}
