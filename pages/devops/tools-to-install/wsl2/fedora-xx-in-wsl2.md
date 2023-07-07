# Fedora XX in WSL2

### Third party repositories <a href="#third-party-repositories" id="third-party-repositories"></a>

There are several third-party software repositories for Fedora. They have more liberal licensing policies and provide software packages that Fedora excludes for several reasons. These software repositories are not officially affiliated or endorsed by the Fedora Project. Use them at your own discretion. For complete list, see [FedoraThirdPartyRepos](https://rpmfusion.org/FedoraThirdPartyRepos) The following repositories are commonly used by end users and do not conflict with each other:

* [https://rpmfusion.org](https://rpmfusion.org/)

#### Mixing third party software repositories

Mixing a lot of third-party repositories is not recommended since they might conflict with each other causing instability and hard to debug issues. If you are not a technical user, one way is to not enable the third-party repo by default and instead use the **`--enablerepo`** switch for dnf, or a similar method configurable in the graphical package manager.

### Enabling the RPM Fusion repositories using command-line utilities <a href="#proc_enabling-the-rpmfusion-repositories-using-command-line-utilities_enabling-the-rpmfusion-reposit" id="proc_enabling-the-rpmfusion-repositories-using-command-line-utilities_enabling-the-rpmfusion-reposit"></a>

This procedure describes how to enable the RPM Fusion software repositories without using any graphical applications.

#### Prerequisites <a href="#_prerequisites" id="_prerequisites"></a>

* You have internet access.

#### Procedure <a href="#_procedure" id="_procedure"></a>

1.  To enable the _Free_ repository, use:

    ```bash
    $ sudo dnf install \
      https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    ```
2.  Optionally, enable the _Nonfree_ repository:

    ```bash
    $ sudo dnf install \
      https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    ```
3. The first time you attempt to install packages from these repositories, the `dnf` utility prompts you to confirm the signature of the repositories. Confirm it.

If you want to use Fedora as your main workstation please consider installing:

```bash
sudo dnf install fedora-workstation-repositories
```
