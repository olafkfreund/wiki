# Install

Fedora

Install `dnf config-manager` to manage your repositories.

```shell-session
$ sudo dnf install -y dnf-plugins-core
```plaintext

Use `dnf config-manager` to add the official HashiCorp Linux repository.

```shell-session
$ sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```plaintext

Install Terraform from the new repository.

```shell-session
$ sudo dnf -y install terraform
```plaintext

Ubuntu/Debian

nsure that your system is up to date and you have installed the `gnupg`, `software-properties-common`, and `curl` packages installed. You will use these packages to verify HashiCorp's GPG signature and install HashiCorp's Debian package repository.

```shell-session
$ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```plaintext

Install the HashiCorp [GPG key](https://apt.releases.hashicorp.com/gpg).

```shell-session
$ wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```plaintext

Verify the key's fingerprint.

```shell-session
$ gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```plaintext

The `gpg` command will report the key fingerprint:

```plaintext
/usr/share/keyrings/hashicorp-archive-keyring.gpg
-------------------------------------------------
pub   rsa4096 XXXX-XX-XX [SC]
AAAA AAAA AAAA AAAA
uid           [ unknown] HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
sub   rsa4096 XXXX-XX-XX [E]
```plaintext

Add the official HashiCorp repository to your system. The `lsb_release -cs` command finds the distribution release codename for your current system, such as `buster`, `groovy`, or `sid`.

```shell-session
$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```plaintext

Download the package information from HashiCorp.

```shell-session
$ sudo apt update
```plaintext

Install Terraform from the new repository.

```shell-session
$ sudo apt-get install terraform
```plaintext

### Verify the installation <a href="#verify-the-installation" id="verify-the-installation"></a>

Verify that the installation worked by opening a new terminal session and listing Terraform's available subcommands.

```shell-session
$ terraform -help
Usage: terraform [-version] [-help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.
##...
```plaintext

Add any subcommand to `terraform -help` to learn more about what it does and available options.

```shell-session
$ terraform -help plan
```plaintext
