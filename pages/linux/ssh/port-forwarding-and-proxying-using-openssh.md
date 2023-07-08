# Port Forwarding and Proxying Using OpenSsh

### Introduction <a href="#introduction" id="introduction"></a>

SSH, also known as Secure Shell, can be used for much more than obtaining a remote shell. This article will demonstrate how SSH can be used for port forwarding and proxying.

### Purpose <a href="#purpose" id="purpose"></a>

An SSH proxy is used to proxy web traffic. For example, it can be used to secure your web traffic against an unsafe local network.

SSH port forwarding is often used to access services that are not publicly accessible. For instance, you could have a system administration web interface running on your server, but only listening for connections on localhost for security reasons. In that case, you can use SSH to forward connections on a chosen port from your local machine to the port on which the service is listening to server-side, thus granting you remote access to this service through the SSH tunnel. Another common scenario where SSH port forwarding is used, is accessing services on a remote private network through an SSH tunnel to a host on that private network.

### Usage <a href="#usage" id="usage"></a>

Both proxying and port forwarding do not require any special configuration on your server. However, the usage of key-based authentication is always recommended with SSH.&#x20;

#### SSH proxy

Creating an SSH proxy is imple, the general syntax is as follows:

```bash
ssh -D [bind-address]:[port] [username]@[server]
```

Where `[bind-address]` is the local address to listen on, `[port]` is the local port to listen on, `[username]` is your username on your server, and `[server]` is the IP address or hostname of your server.

If `[bind-address]` is not specified, SSH will default to `localhost` which is desirable in most cases.

Here's a practical example:

```bash
ssh -D 8080 user@your_server
```

In order to use this proxy, you have to configure your browser to use `SOCKSv5` as proxy type and `8080` as the proxy port.

#### SSH port forwarding

The general syntax of the command is the ensuing:

```bash
ssh -L [localport]:[remotehost]:[remoteport] [username]@[server]
```

Where `[localport]` is the port on which the SSH client will listen, `[remotehost]` is the IP address of the host to which the connections will be forwarded. This would be `127.0.0.1` if you are tunneling connections to your server. Finally, `[remoteport]` is the port number on the server that is used by the service you're connecting to.

**Example :**

Consider having an important web service running on port `10000` on your server, but it is not publicly accessible. The following command would be used to establish an SSH tunnel to that service.

```bash
ssh -L 80:127.0.0.1:10000 useryour_server
```

You will now be able to connect by typing `http://127.0.0.1` in your local browser.
