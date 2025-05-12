# Minikube

### Enable systemd in WSL2. <a href="#e0dc" id="e0dc"></a>

```plaintext
$ sudo nano /etc/wsl.conf
```plaintext

Add following lines in it and save.

```yaml
[boot]
systemd=true
```plaintext

Shutdown wsl2 and start it again.

```bash
$ wsl --shutdown
$ wsl
```plaintext

### Installing Docker <a href="#9eaa" id="9eaa"></a>

```bash
$ sudo apt update && sudo apt upgrade -y
```plaintext

```bash
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```plaintext

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```plaintext

```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```plaintext

```bash
sudo apt-get update -y
```plaintext

```bash
sudo apt-get install -y docker-ce
```plaintext

```bash
sudo usermod -aG docker $USER && newgrp docker
```plaintext

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
```plaintext

### Install Kubectl <a href="#cd72" id="cd72"></a>

```bash
# Download the latest Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x ./kubectl

# Move it to your user's executable PATH
sudo mv ./kubectl /usr/local/bin/
```plaintext

### Running Minikube <a href="#b78e" id="b78e"></a>

```bash
$ minikube start
```plaintext

It will take couple of minutes depending upon your internet connection.

> If it shows you an error, it could be possible to your WSL2 is out of date as systemd was introduced in Sept-2022.
>
> To fix that
>
> \# In powershell type wsl.exe — update and try running minikube start after restarting wsl

Once your minikube starts working, type:

```bash
$ kubectl config use-context minikube
```plaintext

```bash
# Start minikube again to enable kubectl in it
$ minikube start
```plaintext

```bash
$ kubectl get pods -A
```plaintext

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*4On7Lk4zpEXcZ7OxV0YG_w.png" alt="" height="182" width="700"><figcaption></figcaption></figure>

You’ll see something.
