# RHEL in WSL2

```plaintext
On a podman/docker capable host:
     1. podman pull registry.access.redhat.com/ubi9
     2. podman run --name ubi9 ubi9
     3. podman export -o c:\wsl\ubi9.tar ubi9
Copy ubi8.tar to Windows
     1. wsl import c:\wsl\rhel9 $HOME/wsl/rhel9 ubi9.tar
     2. wsl -d rhel9
```plaintext

### A registration to awesomeness <a href="#a-registration-to-awesomeness" id="a-registration-to-awesomeness"></a>

In order to help us with the registration, Red Hat has the [Registration Assistant](https://access.redhat.com/labs/registrationassistant/). We will need to answer few questions and based on the answers, it will provide with the commands below:

```bash
# Register the system with our Red Hat username and password
subscription-manager register --username <username> --password <password>

# Set a role to the System
# It can be one suggested by Red Hat, or in our case, let's have "some fun", and set it to WSL
subscription-manager role --set="Red Hat Enterprise Linux WSL"

# Set a support level
# In our case, remember we have a free Developer license and the only valid support is "Self-Support"
subscription-manager service-level --set="Self-Support"

# Set a usage (read: purpose) to the System
# We will pick "Development/Test" for this first try
subscription-manager usage --set="Development/Test"

# Once everything is set, we can attach the system to our Red Hat subscription
subscription-manager attach
```plaintext
