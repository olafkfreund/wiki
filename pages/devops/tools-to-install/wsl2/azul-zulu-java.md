# Azul Zulu Java

### nstall from Azul RPM repository

This section shows how to set up Azul’s RPM repository and install Azul Zulu using your package manager.

The Azul RPM repository provides packages for the following architectures:

| CPU architecture | Azul Zulu versions       |
| ---------------- | ------------------------ |
| x86              | 7, 8, 11, 13, 15, 17, 18 |
| arm64            | 8, 11, 15, 17, 18        |

| Note | The Azul repository contains RPM packages for the x86 and arm64 architectures. If your machine has a different CPU architecture (for example, arm32), consider installing the appropriate TAR.GZ package. You can find TAR.GZ packages for all supported platforms on the [Downloads](https://www.azul.com/downloads) page. |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

Installing with a package manager requires `root` privileges. Log in as `root` or use `sudo` to execute the commands listed below.

1.  Set up the Azul RPM repository.

    For RHEL or Fedora Linux:

    ```bash
     # add the Azul RPM repository 
    sudo yum install -y https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm
    ```
2.  Install the required Azul Zulu package.

    For RHEL or Fedora

    ```bash
     # install Azul Zulu 11 JDK 
    sudo yum install zulu11-jdk
    ```

    The default installation folder is:

    ```bash
     /usr/lib/jvm/java-<major_version>-zulu-openjdk-ca
    ```

    For example, the default installation folder for Azul Zulu JDK 11 is:

    ```bash
     /usr/lib/jvm/java-11-zulu-openjdk-ca
    ```
3.  (Optional) You may want to add the `<installation_folder>/bin` to your `PATH` environment variable so you can run `java` without typing the full path.

    ```bash
     export PATH=<installation_folder>/bin:$PATH
    ```
4.  Your Java version in use remains the same unless you explicitly change it. Use this command to list the installed Java versions on your system:

    ```bash
    sudo alternatives --config java
    ```

\
