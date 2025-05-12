# How to Use SSH Config

## Connecting via SSH Config file <a href="#cf41" id="cf41"></a>

By default, the ssh config file is located inside `~/.ssh` directory.

If the file is not present, you can create one using:

```bash
touch ~/.ssh/config
```plaintext

Now the format for writing a remote host configuration inside a config file is as follows:

```bash
Host <server-alias>
  HostName <server IP or url>
  User <username>
  IdentityFile <location of private key>
```plaintext

The space provided from the second line is not compulsory but helps in making the file more readable.

For our use case the configuration to connect to our AWS EC2 instance would be as follows:

```bash
Host nano-server
  HostName 174.129.141.81
  User ubuntu
  IdentityFile ~/t3_nano_ssh_aws_keys.pem
```plaintext

After saving the following configuration we can now ssh directly with the host name provided above.

```bash
ssh nano-server
```plaintext

Running the above command lets us connect to the EC2 instance directly.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*8MznGgnS9Jl6EvXVWtaqPQ.png" alt="" height="389" width="700"><figcaption></figcaption></figure>

## SSH config file syntax <a href="#2461" id="2461"></a>

A single ssh config file can have multiple ssh configurations. For example:

```bash
Host HOST_NAME_1
  HostName IP_1
  User USER_1
  IdentityFile LOCATION_1Host HOST_NAME_2
  HostName IP_1Host HOST_NAME_3
  HostName Ifull list above the parameters like User IdentityFile are not mandatory and their presence can vary from one configuration to another.
```plaintext

The entire list of parameters can be found [here](https://www.ssh.com/academy/ssh/config)

Along with having multiple configurations we can also use a lot of wildcards while creating out configuration files

* ( \* ) Can be used as a substitute for one or more characters. For example, in case there is a common `IdentityFile` for all dev servers, we can add the following line in config file:

```bash
Host dev-*
  IdentityFile <location to identity file>
```plaintext

* ( ? ) Can be used as a substitute for a single character. For example, in case we want to write configuration for all servers, with same prefix we can write:

```bash
Host ????-server
  HostName 174.129.141.81
  User ubuntu
```plaintext

We can connect to this server via command like `ssh nano-server` `tall-server` `omni-server` but not via `dev-server` as `dev` only contains 3 characters.

* ( ! ) Can be used to negate the matches to the expression that is written after it

```bash
Host !prod-server
  User low-priority-user
```plaintext

The above configuration file would mean that until the host is `prod-server` set value of user field to `low-priority-user`

Based on these wildcards, we can write a sample configuration file as follows:

```bash
Host prod-server
  HostName xxx.xxx.xxx.xx
  User ubuntu
  IdentityFile ~/prod.pemHost stag-server
  HostName xxx.xxx.xxx.xx
  User ubuntu
  IdentityFile ~/stag.pemHost dev-server
  HostName xxx.xxx.xxx.xxHost !prod-server
  LogLevel DEBUGHost *-server
  IdentityFile ~/low-security.pem
```plaintext

In the above file we have defined separate configurations for `prod-server` and `stag-server` with their separate IdentityFile. While for `dev-server` and any other possible server, there is a default `pem`file.

Also for all servers except `prod-server` the LogLevel is set to `DEBUG`:
