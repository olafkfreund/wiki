# Port Forwarding and Proxying Using OpenSSH

Often, for security reasons, some services are created only on the internal network. At the same time, the issue of connecting to them from other networks becomes relevant.\
In this article, I describe SSH tunneling or SSH port forwarding. It is a method of creating an encrypted SSH connection between a client and a server machine through which service ports can be relayed. Basically, you can forward any TCP port and tunnel the traffic over a secure SSH connection.

### 1. Local Forwarding <a href="#4e3c" id="4e3c"></a>

Local forwarding is used to forward a port from the client machine to the server machine. In this forwarding type, the SSH client listens on a given port and tunnels any connection to that port to the specified port on the remote SSH server, which then connects to a port on the destination machine. The destination machine can be the remote SSH server or any other machine.

In Linux, macOS, and other Unix systems local port forwarding is configured using the **`-L`** option:

<pre class="language-bash"><code class="lang-bash"><strong>ssh -L local_port:destination_server_ip:remote_port ssh_server_hostname
</strong></code></pre>

The options used are as follows:

⦁ _**`-L local_port:destination_server_ip:remote_port`**_ – The local port on the local client is being forwarded to the port of the destination remote server.

⦁ _**`ssh_server_hostname`**_ – This element of the syntax represents the hostname or IP address of the remote SSH server.

_**Example 1:**_

<pre class="language-bash"><code class="lang-bash"><strong>ssh –L 5050:188.171.10.8:4040 user@bastion.host
</strong></code></pre>

All traffic sent to port **5050** on your local host is being forwarded to port _**4040**_ on the remote server located at _**188.171.10.8**_**.**

_**Example 2.**_

Let’s imagine you have a PostgreSQL database server running on the machine _**`db1.host`**_ on an internal (private) network, on port _**5432**_, which is accessible from the machine _**`"remote.host”`**_ and you want to connect using your local machine PostgreSQL client to the database server.

<pre class="language-bash"><code class="lang-bash"><strong>ssh -L 5432:db.host:5432 user@remote.host
</strong></code></pre>

To connect to the second server, you would use _**`127.0.0.1:5432`**_.

_**Example 3**_\
If you need to connect to a remote machine through VNC, which runs on the same server, and it is not accessible from the outside. The command you would use is:

<pre class="language-bash"><code class="lang-bash"><strong>ssh -L 5901:127.0.0.1:5901 -N -f user@remote.host
</strong></code></pre>

⦁ _**`-f`**_ option tells the _**`ssh`**_ command to run in the background

⦁_**`-N`**_ not to execute a remote command.

We are using _**`localhost`**_ because the VNC and the SSH server are running on the same host.

If you are having trouble setting up tunneling, check your remote SSH server configuration and make sure _**`AllowTcpForwarding`**_ is not set to _**`no`**_.

### 2. Remote Forwarding <a href="#3d7b" id="3d7b"></a>

Remote port forwarding is the opposite of local port forwarding. It allows you to forward a port on the remote (ssh server) machine to a port on the local (ssh client) machine, which is then forwarded to a port on the destination machine. In this forwarding type, the SSH server listens on a given port and tunnels any connection to that port to the specified port on the local SSH client, which then connects to a port on the destination machine. The destination machine can be the local or any other machine.

<pre class="language-bash"><code class="lang-bash"><strong>ssh -R remote_port:localhost:local_port user@remote.host
</strong></code></pre>

The options used are as follows:

* _**`remote port`**_- The IP and the port number on the remote SSH server. An empty `REMOTE` means that the remote SSH server will bind on all interfaces.
* _**`local port`**_- The IP or hostname and the port of the local machine.
* _**`user@куьщеу.host`**_- The remote SSH user and server IP address.

_**Example 1**_:

<pre class="language-bash"><code class="lang-bash"><strong>ssh -R 8000:127.0.0.1:3000 -N -f user@remote.host
</strong></code></pre>

The command above will make the ssh server listen on port **`8000`**, and tunnel all traffic from this port to your local machine on port _**`3000`**_.

Now your fellow developer can type **`the_ssh_server_ip:8000`** in the browser and preview your awesome application.

### 3. Dynamic Port Forwarding <a href="#8b93" id="8b93"></a>

Dynamic port forwarding allows you to create a socket on the local (ssh client) machine, which acts as a SOCKS proxy server. When a client connects to this port, the connection is forwarded to the remote (ssh server) machine, which is then forwarded to a dynamic port on the destination machine.

<pre class="language-bash"><code class="lang-bash"><strong>ssh –D local_port ssh_server_hostname
</strong></code></pre>

* By using the **`ssh`** command and the **`–D`** argument, you can use your SSH client to create a SOCKS proxy on your local machine.

_**Example:**_

<pre class="language-bash"><code class="lang-bash"><strong>ssh -D 9090 -N -f user@remote.host
</strong></code></pre>

The following command opens a SOCKS proxy at the port _**`9090`**_ on your local machine. You are now able to configure a local resource, like a browser, to use port `9090`. All traffic originating from that resource is directed through the SSH connections established for the defined port.

**PS.** For killing an SSH session that was started with the -f option (run in the background)

```bash
pkill ssh
```plaintext
