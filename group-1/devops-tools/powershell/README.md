---
description: PowerShell on Fedora Linux
---

# PowerShell

{% code overflow="wrap" lineNumbers="true" %}
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf makecache
sudo dnf install powershell
pwsh
```plaintext
{% endcode %}

Running PowerShell from a container:

{% code overflow="wrap" lineNumbers="true" %}
```bash
podman run \
 -it \
 --privileged \
 --rm \
 --name powershell \
 --env-host \
 --net=host --pid=host --ipc=host \
 --volume $HOME:$HOME \
 --volume /:/var/host \
 mcr.microsoft.com/powershell \
 /usr/bin/pwsh -WorkingDirectory $(pwd)as
```plaintext
{% endcode %}
