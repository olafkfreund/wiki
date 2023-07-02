# Minikube

### Enable systemd in WSL2. <a href="#e0dc" id="e0dc"></a>

```
$ sudo nano /etc/wsl.conf
```

Add following lines in it and save.

```yaml
[boot]
systemd=true
```

Shutdown wsl2 and start it again.

```bash
$ wsl --shutdown
$ wsl
```

### Installing Docker <a href="#9eaa" id="9eaa"></a>

```bash
$ sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

```bash
sudo apt-get update -y
```

```bash
sudo apt-get install -y docker-ce
```

```bash
sudo usermod -aG docker $USER && newgrp docker
```

### Install Minikube <a href="#1701" id="1701"></a>

```bash
# Download the latest Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Make it executable
chmod +x ./minikube

# Move it to your user's executable PATH
sudo mv ./minikube /usr/local/bin/

#Set the driver version to Docker
minikube config set driver docker
```

### Install Kubectl <a href="#cd72" id="cd72"></a>

```bash
# Download the latest Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x ./kubectl

# Move it to your user's executable PATH
sudo mv ./kubectl /usr/local/bin/
```

### Running Minikube <a href="#b78e" id="b78e"></a>

```bash
$ minikube start
```

It will take couple of minutes depending upon your internet connection.

> If it shows you an error, it could be possible to your WSL2 is out of date as systemd was introduced in Sept-2022.
>
> To fix that
>
> \# In powershell type wsl.exe — update and try running minikube start after restarting wsl

Once your minikube starts working, type:

```bash
$ kubectl config use-context minikube
```

```bash
# Start minikube again to enable kubectl in it
$ minikube start
```

```bash
$ kubectl get pods -A
```

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*4On7Lk4zpEXcZ7OxV0YG_w.png" alt="" height="182" width="700"><figcaption></figcaption></figure>

You’ll see something.
