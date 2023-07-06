# Expose minikube to windows from wsl2

Change following in `/usr/lib/systemd/system/docker.service`

```
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --tls=false --containerd=/run/containerd/containerd.sock
```

Copy all certs from `.minkube/` root and `./minkube/profiles` to `./minkube` in Windows&#x20;

<figure><img src="../../../../../.gitbook/assets/Screenshot 2023-07-06 234724.png" alt=""><figcaption></figcaption></figure>

Copy .`kube/config and replace the paths to .crt and .key in the config.`

It will look something like this:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: C:\Users\xxxx\.minikube\ca.crt
    extensions:
    - extension:
        last-update: Thu, 06 Jul 2023 18:30:09 CEST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: cluster_info
    server: https://127.0.0.1:32769
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Thu, 06 Jul 2023 18:30:09 CEST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: C:\Users\xxxx\.minikube\profiles\minikube\client.crt
    client-key: C:\Users\xxxx\.minikube\profiles\minikube\client.key
```
