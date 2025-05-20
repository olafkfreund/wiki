# Cloud-init Examples

Cloud-init is the industry-standard tool for automating the initial configuration of cloud instances across AWS, Azure, GCP, and other platforms. It enables declarative provisioning of users, groups, packages, files, disks, and more, using simple YAML syntax. This page provides real-world, production-ready cloud-init examples for DevOps engineers.

---

## What is Cloud-init?

Cloud-init is an open-source tool that automates the early initialization of cloud servers. It reads user data (YAML or shell scripts) provided at instance launch and applies configuration such as:
- Creating users and groups
- Installing packages
- Writing files and templates
- Configuring SSH keys and access
- Setting up disks, filesystems, and mounts
- Running custom commands or scripts

Cloud-init is supported by all major cloud providers (AWS EC2, Azure VMs, GCP Compute Engine, OpenStack, etc.) and is essential for repeatable, automated infrastructure provisioning.

---

## Best Practices
- Always validate your YAML with a linter before deploying.
- Use version control (Git) for your cloud-init templates.
- Avoid hardcoding secrets; use cloud provider secrets managers or encrypted values.
- Test cloud-init scripts in a staging environment before production.
- Use modules (e.g., `users`, `write_files`, `runcmd`) for clarity and maintainability.

---

## Example: Including Users and Groups

```yaml
#cloud-config
# Add groups to the system
# The following example adds the 'admingroup' group with members 'root' and 'sys'
# and the empty group cloud-users.
groups:
  - admingroup: [root,sys]
  - cloud-users

# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: foobar
    gecos: Foo B. Bar
    primary_group: foobar
    groups: users
    selinux_user: staff_u
    expiredate: '2032-09-01'
    ssh_import_id:
      - lp:falcojr
      - gh:TheRealFalcon
    lock_passwd: false
    passwd: $6$j212wezy$7H/1LT4f9/N3wpgNunhsIqtMj62OKiS3nyNwuizouQc3u7MbYCarYeAHWYPYb2FT.lbioDm2RrkJPb9BZMN1O/
  - name: barfoo
    gecos: Bar B. Foo
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    ssh_import_id:
      - lp:falcojr
      - gh:TheRealFalcon
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSL7uWGj8cgWyIOaspgKdVy0cKJ+UTjfv7jBOjG2H/GN8bJVXy72XAvnhM0dUM+CCs8FOf0YlPX+Frvz2hKInrmRhZVwRSL129PasD12MlI3l44u6IwS1o/W86Q+tkQYEljtqDOo0a+cOsaZkvUNzUyEXUwz/lmYa6G4hMKZH4NBj7nbAAF96wsMCoyNwbWryBnDYUr6wMbjRR1J9Pw7Xh7WRC73wy4Va2YuOgbD3V/5ZrFPLbWZW/7TFXVrql04QVbyei4aiFR5n//GvoqwQDNe58LmbzX/xvxyKJYdny2zXmdAhMxbrpFQsfpkJ9E/H5w0yOdSvnWbUoG5xNGoOB csmith@fringe
  - name: cloudy
    gecos: Magic Cloud App Daemon User
    inactive: '5'
    system: true
  - name: fizzbuzz
    sudo: false
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSL7uWGj8cgWyIOaspgKdVy0cKJ+UTjfv7jBOjG2H/GN8bJVXy72XAvnhM0dUM+CCs8FOf0YlPX+Frvz2hKInrmRhZVwRSL129PasD12MlI3l44u6IwS1o/W86Q+tkQYEljtqDOo0a+cOsaZkvUNzUyEXUwz/lmYa6G4hMKZH4NBj7nbAAF96wsMCoyNwbWryBnDYUr6wMbjRR1J9Pw7Xh7WRC73wy4Va2YuOgbD3V/5ZrFPLbWZW/7TFXVrql04QVbyei4aiFR5n//GvoqwQDNe58LmbzX/xvxyKJYdny2zXmdAhMxbrpFQsfpkJ9E/H5w0yOdSvnWbUoG5xNGoOB csmith@fringe
  - snapuser: joe@joeuser.io
  - name: nosshlogins
    ssh_redirect_user: true
```

---

### Writing out arbitrary files

```plaintext
 1#cloud-config
 2# vim: syntax=yaml
 3#
 4# This is the configuration syntax that the write_files module
 5# will know how to understand. Encoding can be given b64 or gzip or (gz+b64).
 6# The content will be decoded accordingly and then written to the path that is
 7# provided. 
 8#
 9# Note: Content strings here are truncated for example purposes.
10write_files:
11- encoding: b64
12  content: CiMgVGhpcyBmaWxlIGNvbnRyb2xzIHRoZSBzdGF0ZSBvZiBTRUxpbnV4...
13  owner: root:root
14  path: /etc/sysconfig/selinux
15  permissions: '0644'
16- content: |
17    # My new /etc/sysconfig/samba file
18
19    SMBDOPTIONS="-D"
20  path: /etc/sysconfig/samba
21- content: !!binary |
22    f0VMRgIBAQAAAAAAAAAAAAIAPgABAAAAwARAAAAAAABAAAAAAAAAAJAVAAAAAAAAAAAAAEAAOAAI
23    AEAAHgAdAAYAAAAFAAAAQAAAAAAAAABAAEAAAAAAAEAAQAAAAAAAwAEAAAAAAADAAQAAAAAAAAgA
24    AAAAAAAAAwAAAAQAAAAAAgAAAAAAAAACQAAAAAAAAAJAAAAAAAAcAAAAAAAAABwAAAAAAAAAAQAA
25    ....
26  path: /bin/arch
27  permissions: '0555'
28- encoding: gzip
29  content: !!binary |
30    H4sIAIDb/U8C/1NW1E/KzNMvzuBKTc7IV8hIzcnJVyjPL8pJ4QIA6N+MVxsAAAA=
31  path: /usr/bin/hello
32  permissions: '0755'
```plaintext

### Adding a yum repository

```plaintext
 1#cloud-config
 2# vim: syntax=yaml
 3#
 4# Add yum repository configuration to the system
 5#
 6# The following example adds the file /etc/yum.repos.d/epel_testing.repo
 7# which can then subsequently be used by yum for later operations.
 8yum_repos:
 9  # The name of the repository
10  epel-testing:
11    # Any repository configuration options
12    # See: man yum.conf
13    #
14    # This one is required!
15    baseurl: http://download.fedoraproject.org/pub/epel/testing/5/$basearch
16    enabled: false
17    failovermethod: priority
18    gpgcheck: true
19    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
20    name: Extra Packages for Enterprise Linux 5 - Testing
```plaintext

### Configure an instance’s trusted CA certificates

```plaintext
 1#cloud-config
 2#
 3# This is an example file to configure an instance's trusted CA certificates
 4# system-wide for SSL/TLS trust establishment when the instance boots for the
 5# first time.
 6#
 7# Make sure that this file is valid yaml before starting instances.
 8# It should be passed as user-data when starting the instance.
 9
10ca_certs:
11  # If present and set to True, the 'remove_defaults' parameter will either
12  # disable all the trusted CA certifications normally shipped with
13  # Alpine, Debian or Ubuntu. On RedHat, this action will delete those
14  # certificates.
15  # This is mainly for very security-sensitive use cases - most users will not
16  # need this functionality.
17  remove_defaults: true
18
19  # If present, the 'trusted' parameter should contain a certificate (or list
20  # of certificates) to add to the system as trusted CA certificates.
21  # Pay close attention to the YAML multiline list syntax.  The example shown
22  # here is for a list of multiline certificates.
23  trusted: 
24  - |
25   -----BEGIN CERTIFICATE-----
26   YOUR-ORGS-TRUSTED-CA-CERT-HERE
27   -----END CERTIFICATE-----
28  - |
29   -----BEGIN CERTIFICATE-----
30   YOUR-ORGS-TRUSTED-CA-CERT-HERE
31   -----END CERTIFICATE-----
```plaintext

### Install and run [chef](http://www.chef.io/chef/) recipes

```plaintext
  1#cloud-config
  2#
  3# This is an example file to automatically install chef-client and run a
  4# list of recipes when the instance boots for the first time.
  5# Make sure that this file is valid yaml before starting instances.
  6# It should be passed as user-data when starting the instance.
  7
  8# The default is to install from packages.
  9
 10# Key from https://packages.chef.io/chef.asc
 11apt:
 12  sources:
 13    source1:
 14      source: "deb http://packages.chef.io/repos/apt/stable $RELEASE main"
 15      key: |
 16        -----BEGIN PGP PUBLIC KEY BLOCK-----
 17        Version: GnuPG v1.4.12 (Darwin)
 18        Comment: GPGTools - http://gpgtools.org
 19
 20        mQGiBEppC7QRBADfsOkZU6KZK+YmKw4wev5mjKJEkVGlus+NxW8wItX5sGa6kdUu
 21        twAyj7Yr92rF+ICFEP3gGU6+lGo0Nve7KxkN/1W7/m3G4zuk+ccIKmjp8KS3qn99
 22        dxy64vcji9jIllVa+XXOGIp0G8GEaj7mbkixL/bMeGfdMlv8Gf2XPpp9vwCgn/GC
 23        JKacfnw7MpLKUHOYSlb//JsEAJqao3ViNfav83jJKEkD8cf59Y8xKia5OpZqTK5W
 24        ShVnNWS3U5IVQk10ZDH97Qn/YrK387H4CyhLE9mxPXs/ul18ioiaars/q2MEKU2I
 25        XKfV21eMLO9LYd6Ny/Kqj8o5WQK2J6+NAhSwvthZcIEphcFignIuobP+B5wNFQpe
 26        DbKfA/0WvN2OwFeWRcmmd3Hz7nHTpcnSF+4QX6yHRF/5BgxkG6IqBIACQbzPn6Hm
 27        sMtm/SVf11izmDqSsQptCrOZILfLX/mE+YOl+CwWSHhl+YsFts1WOuh1EhQD26aO
 28        Z84HuHV5HFRWjDLw9LriltBVQcXbpfSrRP5bdr7Wh8vhqJTPjrQnT3BzY29kZSBQ
 29        YWNrYWdlcyA8cGFja2FnZXNAb3BzY29kZS5jb20+iGAEExECACAFAkppC7QCGwMG
 30        CwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRApQKupg++Caj8sAKCOXmdG36gWji/K
 31        +o+XtBfvdMnFYQCfTCEWxRy2BnzLoBBFCjDSK6sJqCu0IENIRUYgUGFja2FnZXMg
 32        PHBhY2thZ2VzQGNoZWYuaW8+iGIEExECACIFAlQwYFECGwMGCwkIBwMCBhUIAgkK
 33        CwQWAgMBAh4BAheAAAoJEClAq6mD74JqX94An26z99XOHWpLN8ahzm7cp13t4Xid
 34        AJ9wVcgoUBzvgg91lKfv/34cmemZn7kCDQRKaQu0EAgAg7ZLCVGVTmLqBM6njZEd
 35        Zbv+mZbvwLBSomdiqddE6u3eH0X3GuwaQfQWHUVG2yedyDMiG+EMtCdEeeRebTCz
 36        SNXQ8Xvi22hRPoEsBSwWLZI8/XNg0n0f1+GEr+mOKO0BxDB2DG7DA0nnEISxwFkK
 37        OFJFebR3fRsrWjj0KjDxkhse2ddU/jVz1BY7Nf8toZmwpBmdozETMOTx3LJy1HZ/
 38        Te9FJXJMUaB2lRyluv15MVWCKQJro4MQG/7QGcIfrIZNfAGJ32DDSjV7/YO+IpRY
 39        IL4CUBQ65suY4gYUG4jhRH6u7H1p99sdwsg5OIpBe/v2Vbc/tbwAB+eJJAp89Zeu
 40        twADBQf/ZcGoPhTGFuzbkcNRSIz+boaeWPoSxK2DyfScyCAuG41CY9+g0HIw9Sq8
 41        DuxQvJ+vrEJjNvNE3EAEdKl/zkXMZDb1EXjGwDi845TxEMhhD1dDw2qpHqnJ2mtE
 42        WpZ7juGwA3sGhi6FapO04tIGacCfNNHmlRGipyq5ZiKIRq9mLEndlECr8cwaKgkS
 43        0wWu+xmMZe7N5/t/TK19HXNh4tVacv0F3fYK54GUjt2FjCQV75USnmNY4KPTYLXA
 44        dzC364hEMlXpN21siIFgB04w+TXn5UF3B4FfAy5hevvr4DtV4MvMiGLu0oWjpaLC
 45        MpmrR3Ny2wkmO0h+vgri9uIP06ODWIhJBBgRAgAJBQJKaQu0AhsMAAoJEClAq6mD
 46        74Jq4hIAoJ5KrYS8kCwj26SAGzglwggpvt3CAJ0bekyky56vNqoegB+y4PQVDv4K
 47        zA==
 48        =IxPr
 49        -----END PGP PUBLIC KEY BLOCK-----
 50
 51chef:
 52
 53  # Valid values are 'accept' and 'accept-no-persist'
 54  chef_license: "accept"
 55
 56  # Valid values are 'gems' and 'packages' and 'omnibus'
 57  install_type: "packages"
 58
 59  # Boolean: run 'install_type' code even if chef-client
 60  #          appears already installed.
 61  force_install: false
 62
 63  # Chef settings
 64  server_url: "https://chef.yourorg.com"
 65
 66  # Node Name
 67  # Defaults to the instance-id if not present
 68  node_name: "your-node-name"
 69
 70  # Environment
 71  # Defaults to '_default' if not present
 72  environment: "production"
 73
 74  # Default validation name is chef-validator
 75  validation_name: "yourorg-validator"
 76  # if validation_cert's value is "system" then it is expected
 77  # that the file already exists on the system.
 78  validation_cert: |
 79    -----BEGIN RSA PRIVATE KEY-----
 80    YOUR-ORGS-VALIDATION-KEY-HERE
 81    -----END RSA PRIVATE KEY-----
 82
 83  # A run list for a first boot json, an example (not required)
 84  run_list:
 85    - "recipe[apache2]"
 86    - "role[db]"
 87
 88  # Specify a list of initial attributes used by the cookbooks
 89  initial_attributes:
 90    apache:
 91      prefork:
 92        maxclients: 100
 93      keepalive: "off"
 94
 95  # if install_type is 'omnibus', change the url to download
 96  omnibus_url: "https://www.chef.io/chef/install.sh"
 97
 98  # if install_type is 'omnibus', pass pinned version string
 99  # to the install script
100  omnibus_version: "12.3.0"
101
102  # If encrypted data bags are used, the client needs to have a secrets file
103  # configured to decrypt them
104  encrypted_data_bag_secret: "/etc/chef/encrypted_data_bag_secret"
105
106# Capture all subprocess output into a logfile
107# Useful for troubleshooting cloud-init issues
108output: {all: '| tee -a /var/log/cloud-init-output.log'}
```plaintext

### Install and run _ansible-pull_

```plaintext
 1#cloud-config
 2package_update: true
 3package_upgrade: true
 4
 5# if you're already installing other packages, you may
 6# wish to manually install ansible to avoid multiple calls
 7# to your package manager
 8packages:
 9  - git
10ansible:
11  install_method: pip
12  pull:
13    url: "https://github.com/holmanb/vmboot.git"
14    playbook_name: ubuntu.yml
```plaintext

### Configure instance to be managed by Ansible

```plaintext
 1#cloud-config
 2#
 3# A common use-case for cloud-init is to bootstrap user and ssh
 4# settings to be managed by a remote configuration management tool,
 5# such as ansible.
 6#
 7# This example assumes a default Ubuntu cloud image, which should contain
 8# the required software to be managed remotely by Ansible.
 9#
10ssh_pwauth: false
11
12users:
13- name: ansible
14  gecos: Ansible User
15  groups: users,admin,wheel
16  sudo: ALL=(ALL) NOPASSWD:ALL
17  shell: /bin/bash
18  lock_passwd: true
19  ssh_authorized_keys:
20    - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRCJCQ1UD9QslWDSw5Pwsvba0Wsf1pO4how5BtNaZn0xLZpTq2nqFEJshUkd/zCWF7DWyhmNphQ8c+U+wcmdNVcg2pI1kPxq0VZzBfZ7cDwhjgeLsIvTXvU+HVRtsXh4c5FlUXpRjf/x+a3vqFRvNsRd1DE+5ZqQHbOVbnsStk3PZppaByMg+AZZMx56OUk2pZCgvpCwj6LIixqwuxNKPxmJf45RyOsPUXwCwkq9UD4me5jksTPPkt3oeUWw1ZSSF8F/141moWsGxSnd5NxCbPUWGoRfYcHc865E70nN4WrZkM7RFI/s5mvQtuj8dRL67JUEwvdvEDO0EBz21FV/iOracXd2omlTUSK+wYrWGtiwQwEgr4r5bimxDKy9L8UlaJZ+ONhLTP8ecTHYkaU1C75sLX9ZYd5YtqjiNGsNF+wdW6WrXrQiWeyrGK7ZwbA7lagSxIa7yeqnKDjdkcJvQXCYGLM9AMBKWeJaOpwqZ+dOunMDLd5VZrDCU2lpCSJ1M="
21
22
23# use the following passwordless demonstration key for testing or
24# replace with your own key pair
25#
26# -----BEGIN OPENSSH PRIVATE KEY-----
27# b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
28# NhAAAAAwEAAQAAAYEA0QiQkNVA/ULJVg0sOT8LL22tFrH9aTuIaMOQbTWmZ9MS2aU6tp6h
29# RCbIVJHf8wlhew1soZjaYUPHPlPsHJnTVXINqSNZD8atFWcwX2e3A8IY4Hi7CL0171Ph1U
30# bbF4eHORZVF6UY3/8fmt76hUbzbEXdQxPuWakB2zlW57ErZNz2aaWgcjIPgGWTMeejlJNq
31# WQoL6QsI+iyIsasLsTSj8ZiX+OUcjrD1F8AsJKvVA+JnuY5LEzz5Ld6HlFsNWUkhfBf9eN
32# ZqFrBsUp3eTcQmz1FhqEX2HB3POuRO9JzeFq2ZDO0RSP7OZr0Lbo/HUS+uyVBML3bxAztB
33# Ac9tRVf4jq2nF3dqJpU1EivsGK1hrYsEMBIK+K+W4psQysvS/FJWiWfjjYS0z/HnEx2JGl
34# NQu+bC1/WWHeWLao4jRrDRfsHVulq160Ilnsqxiu2cGwO5WoEsSGu8nqpyg43ZHCb0FwmB
35# izPQDASlniWjqcKmfnTrpzAy3eVWawwlNpaQkidTAAAFgGKSj8diko/HAAAAB3NzaC1yc2
36# EAAAGBANEIkJDVQP1CyVYNLDk/Cy9trRax/Wk7iGjDkG01pmfTEtmlOraeoUQmyFSR3/MJ
37# YXsNbKGY2mFDxz5T7ByZ01VyDakjWQ/GrRVnMF9ntwPCGOB4uwi9Ne9T4dVG2xeHhzkWVR
38# elGN//H5re+oVG82xF3UMT7lmpAds5VuexK2Tc9mmloHIyD4BlkzHno5STalkKC+kLCPos
39# iLGrC7E0o/GYl/jlHI6w9RfALCSr1QPiZ7mOSxM8+S3eh5RbDVlJIXwX/XjWahawbFKd3k
40# 3EJs9RYahF9hwdzzrkTvSc3hatmQztEUj+zma9C26Px1EvrslQTC928QM7QQHPbUVX+I6t
41# pxd3aiaVNRIr7BitYa2LBDASCvivluKbEMrL0vxSVoln442EtM/x5xMdiRpTULvmwtf1lh
42# 3li2qOI0aw0X7B1bpatetCJZ7KsYrtnBsDuVqBLEhrvJ6qcoON2Rwm9BcJgYsz0AwEpZ4l
43# o6nCpn5066cwMt3lVmsMJTaWkJInUwAAAAMBAAEAAAGAEuz77Hu9EEZyujLOdTnAW9afRv
44# XDOZA6pS7yWEufjw5CSlMLwisR83yww09t1QWyvhRqEyYmvOBecsXgaSUtnYfftWz44apy
45# /gQYvMVELGKaJAC/q7vjMpGyrxUPkyLMhckALU2KYgV+/rj/j6pBMeVlchmk3pikYrffUX
46# JDY990WVO194Dm0buLRzJvfMKYF2BcfF4TvarjOXWAxSuR8www050oJ8HdKahW7Cm5S0po
47# FRnNXFGMnLA62vN00vJW8V7j7vui9ukBbhjRWaJuY5rdG/UYmzAe4wvdIEnpk9xIn6JGCp
48# FRYTRn7lTh5+/QlQ6FXRP8Ir1vXZFnhKzl0K8Vqh2sf4M79MsIUGAqGxg9xdhjIa5dmgp8
49# N18IEDoNEVKUbKuKe/Z5yf8Z9tmexfH1YttjmXMOojBvUHIjRS5hdI9NxnPGRLY2kjAzcm
50# gV9Rv3vtdF/+zalk3fAVLeK8hXK+di/7XTvYpfJ2EZBWiNrTeagfNNGiYydsQy3zjZAAAA
51# wBNRak7UrqnIHMZn7pkCTgceb1MfByaFtlNzd+Obah54HYIQj5WdZTBAITReMZNt9S5NAR
52# M8sQB8UoZPaVSC3ppILIOfLhs6KYj6RrGdiYwyIhMPJ5kRWF8xGCLUX5CjwH2EOq7XhIWt
53# MwEFtd/gF2Du7HUNFPsZGnzJ3e7pDKDnE7w2khZ8CIpTFgD769uBYGAtk45QYTDo5JroVM
54# ZPDq08Gb/RhIgJLmIpMwyreVpLLLe8SwoMJJ+rihmnJZxO8gAAAMEA0lhiKezeTshht4xu
55# rWc0NxxD84a29gSGfTphDPOrlKSEYbkSXhjqCsAZHd8S8kMr3iF6poOk3IWSvFJ6mbd3ie
56# qdRTgXH9Thwk4KgpjUhNsQuYRHBbI59Mo+BxSI1B1qzmJSGdmCBL54wwzZmFKDQPQKPxiL
57# n0Mlc7GooiDMjT1tbuW/O1EL5EqTRqwgWPTKhBA6r4PnGF150hZRIMooZkD2zX6b1sGojk
58# QpvKkEykTwnKCzF5TXO8+wJ3qbcEo9AAAAwQD+Z0r68c2YMNpsmyj3ZKtZNPSvJNcLmyD/
59# lWoNJq3djJN4s2JbK8l5ARUdW3xSFEDI9yx/wpfsXoaqWnygP3PoFw2CM4i0EiJiyvrLFU
60# r3JLfDUFRy3EJ24RsqbigmEsgQOzTl3xfzeFPfxFoOhokSvTG88PQji1AYHz5kA7p6Zfaz
61# Ok11rJYIe7+e9B0lhku0AFwGyqlWQmS/MhIpnjHIk5tP4heHGSmzKQWJDbTskNWd6aq1G7
62# 6HWfDpX4HgoM8AAAALaG9sbWFuYkBhcmM=
63# -----END OPENSSH PRIVATE KEY-----
64#
```plaintext

### Configure instance to be an Ansible controller

```plaintext
  1#cloud-config
  2#
  3# Demonstrate setting up an ansible controller host on boot.
  4# This example installs a playbook repository from a remote private repository
  5# and then runs two of the plays.
  6
  7package_update: true
  8package_upgrade: true
  9packages:
 10  - git
 11  - python3-pip
 12
 13# Set up an ansible user
 14# ----------------------
 15# In this case I give the local ansible user passwordless sudo so that ansible
 16# may write to a local root-only file.
 17users:
 18- name: ansible
 19  gecos: Ansible User
 20  shell: /bin/bash
 21  groups: users,admin,wheel,lxd
 22  sudo: ALL=(ALL) NOPASSWD:ALL
 23
 24# Initialize lxd using cloud-init.
 25# --------------------------------
 26# In this example, a lxd container is
 27# started using ansible on boot, so having lxd initialized is required.
 28lxd:
 29  init:
 30    storage_backend: dir
 31
 32# Configure and run ansible on boot
 33# ---------------------------------
 34# Install ansible using pip, ensure that community.general collection is
 35# installed [1].
 36# Use a deploy key to clone a remote private repository then run two playbooks.
 37# The first playbook starts a lxd container and creates a new inventory file.
 38# The second playbook connects to and configures the container using ansible.
 39# The public version of the playbooks can be inspected here [2]
 40#
 41# [1] community.general is likely already installed by pip
 42# [2] https://github.com/holmanb/ansible-lxd-public
 43#
 44ansible:
 45  install_method: pip
 46  package_name: ansible
 47  run_user: ansible
 48  galaxy:
 49    actions:
 50      - ["ansible-galaxy", "collection", "install", "community.general"]
 51
 52  setup_controller:
 53    repositories:
 54      - path: /home/ansible/my-repo/
 55        source: git@github.com:holmanb/ansible-lxd-private.git
 56    run_ansible:
 57      - playbook_dir: /home/ansible/my-repo
 58        playbook_name: start-lxd.yml
 59        timeout: 120
 60        forks: 1
 61        private_key: /home/ansible/.ssh/id_rsa
 62      - playbook_dir: /home/ansible/my-repo
 63        playbook_name: configure-lxd.yml
 64        become_user: ansible
 65        timeout: 120
 66        forks: 1
 67        private_key: /home/ansible/.ssh/id_rsa
 68        inventory: new_ansible_hosts
 69
 70# Write a deploy key to the filesystem for ansible.
 71# -------------------------------------------------
 72# This deploy key is tied to a private github repository [1]
 73# This key exists to demonstrate deploy key usage in ansible
 74# a duplicate public copy of the repository exists here[2]
 75#
 76# [1] https://github.com/holmanb/ansible-lxd-private
 77# [2] https://github.com/holmanb/ansible-lxd-public
 78#
 79write_files:
 80  - path: /home/ansible/.ssh/known_hosts
 81    owner: ansible:ansible
 82    permissions: 0o600
 83    defer: true
 84    content: |
 85      |1|YJEFAk6JjnXpUjUSLFiBQS55W9E=|OLNePOn3eBa1PWhBBmt5kXsbGM4= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
 86      |1|PGGnpCpqi0aakERS4BWnYxMkMwM=|Td0piZoS4ZVC0OzeuRwKcH1MusM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
 87      |1|OJ89KrsNcFTOvoCP/fPGKpyUYFo=|cu7mNzF+QB/5kR0spiYmUJL7DAI= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
 88
 89  - path: /home/ansible/.ssh/id_rsa
 90    owner: ansible:ansible
 91    permissions: 0o600
 92    defer: true
 93    encoding: base64
 94    content: |
 95      LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFB
 96      QUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJsd0FBQUFkemMyZ3RjbgpOaEFBQUFB
 97      d0VBQVFBQUFZRUEwUWlRa05WQS9VTEpWZzBzT1Q4TEwyMnRGckg5YVR1SWFNT1FiVFdtWjlNUzJh
 98      VTZ0cDZoClJDYklWSkhmOHdsaGV3MXNvWmphWVVQSFBsUHNISm5UVlhJTnFTTlpEOGF0Rldjd1gy
 99      ZTNBOElZNEhpN0NMMDE3MVBoMVUKYmJGNGVIT1JaVkY2VVkzLzhmbXQ3NmhVYnpiRVhkUXhQdVdh
100      a0IyemxXNTdFclpOejJhYVdnY2pJUGdHV1RNZWVqbEpOcQpXUW9MNlFzSStpeUlzYXNMc1RTajha
101      aVgrT1VjanJEMUY4QXNKS3ZWQStKbnVZNUxFeno1TGQ2SGxGc05XVWtoZkJmOWVOClpxRnJCc1Vw
102      M2VUY1FtejFGaHFFWDJIQjNQT3VSTzlKemVGcTJaRE8wUlNQN09acjBMYm8vSFVTK3V5VkJNTDNi
103      eEF6dEIKQWM5dFJWZjRqcTJuRjNkcUpwVTFFaXZzR0sxaHJZc0VNQklLK0srVzRwc1F5c3ZTL0ZK
104      V2lXZmpqWVMwei9IbkV4MkpHbApOUXUrYkMxL1dXSGVXTGFvNGpSckRSZnNIVnVscTE2MElsbnNx
105      eGl1MmNHd081V29Fc1NHdThucXB5ZzQzWkhDYjBGd21CCml6UFFEQVNsbmlXanFjS21mblRycHpB
106      eTNlVldhd3dsTnBhUWtpZFRBQUFGZ0dLU2o4ZGlrby9IQUFBQUIzTnphQzF5YzIKRUFBQUdCQU5F
107      SWtKRFZRUDFDeVZZTkxEay9DeTl0clJheC9XazdpR2pEa0cwMXBtZlRFdG1sT3JhZW9VUW15RlNS
108      My9NSgpZWHNOYktHWTJtRkR4ejVUN0J5WjAxVnlEYWtqV1EvR3JSVm5NRjludHdQQ0dPQjR1d2k5
109      TmU5VDRkVkcyeGVIaHprV1ZSCmVsR04vL0g1cmUrb1ZHODJ4RjNVTVQ3bG1wQWRzNVZ1ZXhLMlRj
110      OW1tbG9ISXlENEJsa3pIbm81U1RhbGtLQytrTENQb3MKaUxHckM3RTBvL0dZbC9qbEhJNnc5UmZB
111      TENTcjFRUGlaN21PU3hNOCtTM2VoNVJiRFZsSklYd1gvWGpXYWhhd2JGS2QzawozRUpzOVJZYWhG
112      OWh3ZHp6cmtUdlNjM2hhdG1RenRFVWorem1hOUMyNlB4MUV2cnNsUVRDOTI4UU03UVFIUGJVVlgr
113      STZ0CnB4ZDNhaWFWTlJJcjdCaXRZYTJMQkRBU0N2aXZsdUtiRU1yTDB2eFNWb2xuNDQyRXRNL3g1
114      eE1kaVJwVFVMdm13dGYxbGgKM2xpMnFPSTBhdzBYN0IxYnBhdGV0Q0paN0tzWXJ0bkJzRHVWcUJM
115      RWhydko2cWNvT04yUndtOUJjSmdZc3owQXdFcFo0bApvNm5DcG41MDY2Y3dNdDNsVm1zTUpUYVdr
116      SkluVXdBQUFBTUJBQUVBQUFHQUV1ejc3SHU5RUVaeXVqTE9kVG5BVzlhZlJ2ClhET1pBNnBTN3lX
117      RXVmanc1Q1NsTUx3aXNSODN5d3cwOXQxUVd5dmhScUV5WW12T0JlY3NYZ2FTVXRuWWZmdFd6NDRh
118      cHkKL2dRWXZNVkVMR0thSkFDL3E3dmpNcEd5cnhVUGt5TE1oY2tBTFUyS1lnVisvcmovajZwQk1l
119      VmxjaG1rM3Bpa1lyZmZVWApKRFk5OTBXVk8xOTREbTBidUxSekp2Zk1LWUYyQmNmRjRUdmFyak9Y
120      V0F4U3VSOHd3dzA1MG9KOEhkS2FoVzdDbTVTMHBvCkZSbk5YRkdNbkxBNjJ2TjAwdkpXOFY3ajd2
121      dWk5dWtCYmhqUldhSnVZNXJkRy9VWW16QWU0d3ZkSUVucGs5eEluNkpHQ3AKRlJZVFJuN2xUaDUr
122      L1FsUTZGWFJQOElyMXZYWkZuaEt6bDBLOFZxaDJzZjRNNzlNc0lVR0FxR3hnOXhkaGpJYTVkbWdw
123      OApOMThJRURvTkVWS1ViS3VLZS9aNXlmOFo5dG1leGZIMVl0dGptWE1Pb2pCdlVISWpSUzVoZEk5
124      TnhuUEdSTFkya2pBemNtCmdWOVJ2M3Z0ZEYvK3phbGszZkFWTGVLOGhYSytkaS83WFR2WXBmSjJF
125      WkJXaU5yVGVhZ2ZOTkdpWXlkc1F5M3pqWkFBQUEKd0JOUmFrN1VycW5JSE1abjdwa0NUZ2NlYjFN
126      ZkJ5YUZ0bE56ZCtPYmFoNTRIWUlRajVXZFpUQkFJVFJlTVpOdDlTNU5BUgpNOHNRQjhVb1pQYVZT
127      QzNwcElMSU9mTGhzNktZajZSckdkaVl3eUloTVBKNWtSV0Y4eEdDTFVYNUNqd0gyRU9xN1hoSVd0
128      Ck13RUZ0ZC9nRjJEdTdIVU5GUHNaR256SjNlN3BES0RuRTd3MmtoWjhDSXBURmdENzY5dUJZR0F0
129      azQ1UVlURG81SnJvVk0KWlBEcTA4R2IvUmhJZ0pMbUlwTXd5cmVWcExMTGU4U3dvTUpKK3JpaG1u
130      Slp4TzhnQUFBTUVBMGxoaUtlemVUc2hodDR4dQpyV2MwTnh4RDg0YTI5Z1NHZlRwaERQT3JsS1NF
131      WWJrU1hoanFDc0FaSGQ4UzhrTXIzaUY2cG9PazNJV1N2Rko2bWJkM2llCnFkUlRnWEg5VGh3azRL
132      Z3BqVWhOc1F1WVJIQmJJNTlNbytCeFNJMUIxcXptSlNHZG1DQkw1NHd3elptRktEUVBRS1B4aUwK
133      bjBNbGM3R29vaURNalQxdGJ1Vy9PMUVMNUVxVFJxd2dXUFRLaEJBNnI0UG5HRjE1MGhaUklNb29a
134      a0Qyelg2YjFzR29qawpRcHZLa0V5a1R3bktDekY1VFhPOCt3SjNxYmNFbzlBQUFBd1FEK1owcjY4
135      YzJZTU5wc215ajNaS3RaTlBTdkpOY0xteUQvCmxXb05KcTNkakpONHMySmJLOGw1QVJVZFczeFNG
136      RURJOXl4L3dwZnNYb2FxV255Z1AzUG9GdzJDTTRpMEVpSml5dnJMRlUKcjNKTGZEVUZSeTNFSjI0
137      UnNxYmlnbUVzZ1FPelRsM3hmemVGUGZ4Rm9PaG9rU3ZURzg4UFFqaTFBWUh6NWtBN3A2WmZhegpP
138      azExckpZSWU3K2U5QjBsaGt1MEFGd0d5cWxXUW1TL01oSXBuakhJazV0UDRoZUhHU216S1FXSkRi
139      VHNrTldkNmFxMUc3CjZIV2ZEcFg0SGdvTThBQUFBTGFHOXNiV0Z1WWtCaGNtTT0KLS0tLS1FTkQg
140      T1BFTlNTSCBQUklWQVRFIEtFWS0tLS0tCg==
```plaintext

### Add primary apt repositories

```plaintext
 1#cloud-config
 2
 3# Add primary apt repositories
 4#
 5# To add 3rd party repositories, see cloud-config-apt.txt or the
 6# Additional apt configuration and repositories section.
 7#
 8#
 9# Default: auto select based on cloud metadata
10#  in ec2, the default is <region>.archive.ubuntu.com
11# apt:
12#   primary:
13#     - arches [default]
14#       uri:
15#     use the provided mirror
16#       search:
17#     search the list for the first mirror.
18#     this is currently very limited, only verifying that
19#     the mirror is dns resolvable or an IP address
20#
21# if neither mirror is set (the default)
22# then use the mirror provided by the DataSource found.
23# In EC2, that means using <region>.ec2.archive.ubuntu.com
24#
25# if no mirror is provided by the DataSource, but 'search_dns' is
26# true, then search for dns names '<distro>-mirror' in each of
27# - fqdn of this host per cloud metadata
28# - localdomain
29# - no domain (which would search domains listed in /etc/resolv.conf)
30# If there is a dns entry for <distro>-mirror, then it is assumed that there
31# is a distro mirror at http://<distro>-mirror.<domain>/<distro>
32#
33# That gives the cloud provider the opportunity to set mirrors of a distro
34# up and expose them only by creating dns entries.
35#
36# if none of that is found, then the default distro mirror is used
37apt:
38  primary:
39    - arches: [default]
40      uri: http://us.archive.ubuntu.com/ubuntu/
41# or
42apt:
43  primary:
44    - arches: [default]
45      search:
46        - http://local-mirror.mydomain
47        - http://archive.ubuntu.com
48# or
49apt:
50  primary:
51    - arches: [default]
52      search_dns: True
```plaintext

### Run commands on first boot

```plaintext
 1#cloud-config
 2
 3# boot commands
 4# default: none
 5# this is very similar to runcmd, but commands run very early
 6# in the boot process, only slightly after a 'boothook' would run.
 7# bootcmd should really only be used for things that could not be
 8# done later in the boot process.  bootcmd is very much like
 9# boothook, but possibly with more friendly.
10# - bootcmd will run on every boot
11# - the INSTANCE_ID variable will be set to the current instance id.
12# - you can use 'cloud-init-per' command to help only run once
13bootcmd:
14  - echo 192.168.1.130 us.archive.ubuntu.com >> /etc/hosts
15  - [ cloud-init-per, once, mymkfs, mkfs, /dev/vdb ]
```plaintext

```plaintext
 1#cloud-config
 2
 3# run commands
 4# default: none
 5# runcmd contains a list of either lists or a string
 6# each item will be executed in order at rc.local like level with
 7# output to the console
 8# - runcmd only runs during the first boot
 9# - if the item is a list, the items will be properly executed as if
10#   passed to execve(3) (with the first arg as the command).
11# - if the item is a string, it will be simply written to the file and
12#   will be interpreted by 'sh'
13#
14# Note, that the list has to be proper yaml, so you have to quote
15# any characters yaml would eat (':' can be problematic)
16runcmd:
17 - [ ls, -l, / ]
18 - [ sh, -xc, "echo $(date) ': hello world!'" ]
19 - [ sh, -c, echo "=========hello world=========" ]
20 - ls -l /root
21 # Note: Don't write files to /tmp from cloud-init use /run/somedir instead.
22 # Early boot environments can race systemd-tmpfiles-clean LP: #1707222.
23 - mkdir /run/mydir
24 - [ wget, "http://slashdot.org", -O, /run/mydir/index.html ]
```plaintext

### Install arbitrary packages

```plaintext
 1#cloud-config
 2
 3# Install additional packages on first boot
 4#
 5# Default: none
 6#
 7# if packages are specified, then package_update will be set to true
 8#
 9# packages may be supplied as a single package name or as a list
10# with the format [<package>, <version>] wherein the specific
11# package version will be installed.
12packages:
13 - pwgen
14 - pastebinit
15 - [libpython2.7, 2.7.3-0ubuntu3.1]
```plaintext

### Update apt database on first boot

```plaintext
1#cloud-config
2# Update apt database on first boot (run 'apt-get update').
3# Note, if packages are given, or package_upgrade is true, then
4# update will be done independent of this setting.
5#
6# Default: false
7package_update: true
```plaintext

### Run apt or yum upgrade

```plaintext
1#cloud-config
2
3# Upgrade the instance on first boot
4#
5# Default: false
6package_upgrade: true
```plaintext

### Adjust mount points mounted

```plaintext
 1#cloud-config
 2
 3# set up mount points
 4# 'mounts' contains a list of lists
 5#  the inner list are entries for an /etc/fstab line
 6#  ie : [ fs_spec, fs_file, fs_vfstype, fs_mntops, fs-freq, fs_passno ]
 7#
 8# default:
 9# mounts:
10#  - [ ephemeral0, /mnt ]
11#  - [ swap, none, swap, sw, 0, 0 ]
12#
13# in order to remove a previously listed mount (ie, one from defaults)
14# list only the fs_spec.  For example, to override the default, of
15# mounting swap:
16# - [ swap ]
17# or
18# - [ swap, null ]
19#
20# - if a device does not exist at the time, an entry will still be
21#   written to /etc/fstab.
22# - '/dev' can be omitted for device names that begin with: xvd, sd, hd, vd
23# - if an entry does not have all 6 fields, they will be filled in
24#   with values from 'mount_default_fields' below.
25#
26# Note, that you should set 'nofail' (see man fstab) for volumes that may not
27# be attached at instance boot (or reboot).
28#
29mounts:
30 - [ ephemeral0, /mnt, auto, "defaults,noexec" ]
31 - [ sdc, /opt/data ]
32 - [ xvdh, /opt/data, "auto", "defaults,nofail", "0", "0" ]
33 - [ dd, /dev/zero ]
34
35# mount_default_fields
36# These values are used to fill in any entries in 'mounts' that are not
37# complete.  This must be an array, and must have 6 fields.
38mount_default_fields: [ None, None, "auto", "defaults,nofail", "0", "2" ]
39
40
41# swap can also be set up by the 'mounts' module
42# default is to not create any swap files, because 'size' is set to 0
43swap:
44  filename: /swap.img
45  size: "auto" # or size in bytes
46  maxsize: 10485760   # size in bytes
```plaintext

### `Configure instance's SSH keys`

```plaintext
 1#cloud-config
 2
 3# add each entry to ~/.ssh/authorized_keys for the configured user or the
 4# first user defined in the user definition directive.
 5ssh_authorized_keys:
 6  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEA3FSyQwBI6Z+nCSjUUk8EEAnnkhXlukKoUPND/RRClWz2s5TCzIkd3Ou5+Cyz71X0XmazM3l5WgeErvtIwQMyT1KjNoMhoJMrJnWqQPOt5Q8zWd9qG7PBl9+eiH5qV7NZ mykey@host
 7  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3I7VUf2l5gSn5uavROsc5HRDpZdQueUq5ozemNSj8T7enqKHOEaFoU2VoPgGEWC9RyzSQVeyD6s7APMcE82EtmW4skVEgEGSbDc1pvxzxtchBj78hJP6Cf5TCMFSXw+Fz5rF1dR23QDbN1mkHs7adr8GW4kSWqU7Q7NDwfIrJJtO7Hi42GyXtvEONHbiRPOe8stqUly7MvUoN+5kfjBM8Qqpfl2+FNhTYWpMfYdPUnE7u536WqzFmsaqJctz3gBxH9Ex7dFtrxR4qiqEr9Qtlu3xGn7Bw07/+i1D+ey3ONkZLN+LQ714cgj8fRS4Hj29SCmXp5Kt5/82cD/VN3NtHw== smoser@brickies
 8
 9# Send pre-generated SSH private keys to the server
10# If these are present, they will be written to /etc/ssh and
11# new random keys will not be generated
12#  in addition to 'rsa' and 'dsa' as shown below, 'ecdsa' is also supported
13ssh_keys:
14  rsa_private: |
15    -----BEGIN RSA PRIVATE KEY-----
16    MIIBxwIBAAJhAKD0YSHy73nUgysO13XsJmd4fHiFyQ+00R7VVu2iV9Qcon2LZS/x
17    1cydPZ4pQpfjEha6WxZ6o8ci/Ea/w0n+0HGPwaxlEG2Z9inNtj3pgFrYcRztfECb
18    1j6HCibZbAzYtwIBIwJgO8h72WjcmvcpZ8OvHSvTwAguO2TkR6mPgHsgSaKy6GJo
19    PUJnaZRWuba/HX0KGyhz19nPzLpzG5f0fYahlMJAyc13FV7K6kMBPXTRR6FxgHEg
20    L0MPC7cdqAwOVNcPY6A7AjEA1bNaIjOzFN2sfZX0j7OMhQuc4zP7r80zaGc5oy6W
21    p58hRAncFKEvnEq2CeL3vtuZAjEAwNBHpbNsBYTRPCHM7rZuG/iBtwp8Rxhc9I5w
22    ixvzMgi+HpGLWzUIBS+P/XhekIjPAjA285rVmEP+DR255Ls65QbgYhJmTzIXQ2T9
23    luLvcmFBC6l35Uc4gTgg4ALsmXLn71MCMGMpSWspEvuGInayTCL+vEjmNBT+FAdO
24    W7D4zCpI43jRS9U06JVOeSc9CDk2lwiA3wIwCTB/6uc8Cq85D9YqpM10FuHjKpnP
25    REPPOyrAspdeOAV+6VKRavstea7+2DZmSUgE
26    -----END RSA PRIVATE KEY-----
27
28  rsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEAoPRhIfLvedSDKw7XdewmZ3h8eIXJD7TRHtVW7aJX1ByifYtlL/HVzJ09nilCl+MSFrpbFnqjxyL8Rr/DSf7QcY/BrGUQbZn2Kc22PemAWthxHO18QJvWPocKJtlsDNi3 smoser@localhost
29
30  dsa_private: |
31    -----BEGIN DSA PRIVATE KEY-----
32    MIIBuwIBAAKBgQDP2HLu7pTExL89USyM0264RCyWX/CMLmukxX0Jdbm29ax8FBJT
33    pLrO8TIXVY5rPAJm1dTHnpuyJhOvU9G7M8tPUABtzSJh4GVSHlwaCfycwcpLv9TX
34    DgWIpSj+6EiHCyaRlB1/CBp9RiaB+10QcFbm+lapuET+/Au6vSDp9IRtlQIVAIMR
35    8KucvUYbOEI+yv+5LW9u3z/BAoGBAI0q6JP+JvJmwZFaeCMMVxXUbqiSko/P1lsa
36    LNNBHZ5/8MOUIm8rB2FC6ziidfueJpqTMqeQmSAlEBCwnwreUnGfRrKoJpyPNENY
37    d15MG6N5J+z81sEcHFeprryZ+D3Ge9VjPq3Tf3NhKKwCDQ0240aPezbnjPeFm4mH
38    bYxxcZ9GAoGAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ/yiI4DI3
39    8UzTCOXLhUA7ybmZha+D/csj15Y9/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC
40    /QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQCFEIsKKWv
41    99iziAH0KBMVbxy03Trz
42    -----END DSA PRIVATE KEY-----
43
44  dsa_public: ssh-dss AAAAB3NzaC1kc3MAAACBAM/Ycu7ulMTEvz1RLIzTbrhELJZf8Iwua6TFfQl1ubb1rHwUElOkus7xMhdVjms8AmbV1Meem7ImE69T0bszy09QAG3NImHgZVIeXBoJ/JzByku/1NcOBYilKP7oSIcLJpGUHX8IGn1GJoH7XRBwVub6Vqm4RP78C7q9IOn0hG2VAAAAFQCDEfCrnL1GGzhCPsr/uS1vbt8/wQAAAIEAjSrok/4m8mbBkVp4IwxXFdRuqJKSj8/WWxos00Ednn/ww5QibysHYULrOKJ1+54mmpMyp5CZICUQELCfCt5ScZ9GsqgmnI80Q1h3Xkwbo3kn7PzWwRwcV6muvJn4PcZ71WM+rdN/c2EorAINDTbjRo97NueM94WbiYdtjHFxn0YAAACAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ/yiI4DI38UzTCOXLhUA7ybmZha+D/csj15Y9/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC/QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQ= smoser@localhost
45
46# By default, the fingerprints of the authorized keys for the users
47# cloud-init adds are printed to the console. Setting
48# no_ssh_fingerprints to true suppresses this output.
49no_ssh_fingerprints: false
50
51# By default, (most) ssh host keys are printed to the console. Setting
52# emit_keys_to_console to false suppresses this output.
53ssh:
54  emit_keys_to_console: false
```plaintext

### Additional apt configuration and repositories

```plaintext
  1#cloud-config
  2# apt_pipelining (configure Acquire::http::Pipeline-Depth)
  3# Default: disables HTTP pipelining. Certain web servers, such
  4# as S3 do not pipeline properly (LP: #948461).
  5# Valid options:
  6#   False/default: Disables pipelining for APT
  7#   None/Unchanged: Use OS default
  8#   Number: Set pipelining to some number (not recommended)
  9apt_pipelining: False
 10
 11## apt config via system_info:
 12# under the 'system_info', you can customize cloud-init's interaction
 13# with apt.
 14#  system_info:
 15#    apt_get_command: [command, argument, argument]
 16#    apt_get_upgrade_subcommand: dist-upgrade
 17#
 18# apt_get_command:
 19#  To specify a different 'apt-get' command, set 'apt_get_command'.
 20#  This must be a list, and the subcommand (update, upgrade) is appended to it.
 21#  default is:
 22#    ['apt-get', '--option=Dpkg::Options::=--force-confold',
 23#     '--option=Dpkg::options::=--force-unsafe-io', '--assume-yes', '--quiet']
 24#
 25# apt_get_upgrade_subcommand: "dist-upgrade"
 26#  Specify a different subcommand for 'upgrade. The default is 'dist-upgrade'.
 27#  This is the subcommand that is invoked for package_upgrade.
 28#
 29# apt_get_wrapper:
 30#   command: eatmydata
 31#   enabled: [True, False, "auto"]
 32#
 33
 34# Install additional packages on first boot
 35#
 36# Default: none
 37#
 38# if packages are specified, then package_update will be set to true
 39
 40packages: ['pastebinit']
 41
 42apt:
 43  # The apt config consists of two major "areas".
 44  #
 45  # On one hand there is the global configuration for the apt feature.
 46  #
 47  # On one hand (down in this file) there is the source dictionary which allows
 48  # to define various entries to be considered by apt.
 49
 50  ##############################################################################
 51  # Section 1: global apt configuration
 52  #
 53  # The following examples number the top keys to ease identification in
 54  # discussions.
 55
 56  # 1.1 preserve_sources_list
 57  #
 58  # Preserves the existing /etc/apt/sources.list
 59  # Default: false - do overwrite sources_list. If set to true then any
 60  # "mirrors" configuration will have no effect.
 61  # Set to true to avoid affecting sources.list. In that case only
 62  # "extra" source specifications will be written into
 63  # /etc/apt/sources.list.d/*
 64  preserve_sources_list: true
 65
 66  # 1.2 disable_suites
 67  #
 68  # This is an empty list by default, so nothing is disabled.
 69  #
 70  # If given, those suites are removed from sources.list after all other
 71  # modifications have been made.
 72  # Suites are even disabled if no other modification was made,
 73  # but not if is preserve_sources_list is active.
 74  # There is a special alias "$RELEASE" as in the sources that will be replace
 75  # by the matching release.
 76  #
 77  # To ease configuration and improve readability the following common ubuntu
 78  # suites will be automatically mapped to their full definition.
 79  # updates   => $RELEASE-updates
 80  # backports => $RELEASE-backports
 81  # security  => $RELEASE-security
 82  # proposed  => $RELEASE-proposed
 83  # release   => $RELEASE
 84  #
 85  # There is no harm in specifying a suite to be disabled that is not found in
 86  # the source.list file (just a no-op then)
 87  #
 88  # Note: Lines don't get deleted, but disabled by being converted to a comment.
 89  # The following example disables all usual defaults except $RELEASE-security.
 90  # On top it disables a custom suite called "mysuite"
 91  disable_suites: [$RELEASE-updates, backports, $RELEASE, mysuite]
 92
 93  # 1.3 primary/security archives
 94  #
 95  # Default: none - instead it is auto select based on cloud metadata
 96  # so if neither "uri" nor "search", nor "search_dns" is set (the default)
 97  # then use the mirror provided by the DataSource found.
 98  # In EC2, that means using <region>.ec2.archive.ubuntu.com
 99  #
100  # define a custom (e.g. localized) mirror that will be used in sources.list
101  # and any custom sources entries for deb / deb-src lines.
102  #
103  # One can set primary and security mirror to different uri's
104  # the child elements to the keys primary and secondary are equivalent
105  primary:
106    # arches is list of architectures the following config applies to
107    # the special keyword "default" applies to any architecture not explicitly
108    # listed.
109    - arches: [amd64, i386, default]
110      # uri is just defining the target as-is
111      uri: http://us.archive.ubuntu.com/ubuntu
112      #
113      # via search one can define lists that are tried one by one.
114      # The first with a working DNS resolution (or if it is an IP) will be
115      # picked. That way one can keep one configuration for multiple
116      # subenvironments that select the working one.
117      search:
118        - http://cool.but-sometimes-unreachable.com/ubuntu
119        - http://us.archive.ubuntu.com/ubuntu
120      # if no mirror is provided by uri or search but 'search_dns' is
121      # true, then search for dns names '<distro>-mirror' in each of
122      # - fqdn of this host per cloud metadata
123      # - localdomain
124      # - no domain (which would search domains listed in /etc/resolv.conf)
125      # If there is a dns entry for <distro>-mirror, then it is assumed that
126      # there is a distro mirror at http://<distro>-mirror.<domain>/<distro>
127      #
128      # That gives the cloud provider the opportunity to set mirrors of a distro
129      # up and expose them only by creating dns entries.
130      #
131      # if none of that is found, then the default distro mirror is used
132      search_dns: true
133      #
134      # If multiple of a category are given
135      #   1. uri
136      #   2. search
137      #   3. search_dns
138      # the first defining a valid mirror wins (in the order as defined here,
139      # not the order as listed in the config).
140      #
141      # Additionally, if the repository requires a custom signing key, it can be
142      # specified via the same fields as for custom sources:
143      #   'keyid': providing a key to import via shortid or fingerprint
144      #   'key': providing a raw PGP key
145      #   'keyserver': specify an alternate keyserver to pull keys from that
146      #                were specified by keyid
147    - arches: [s390x, arm64]
148      # as above, allowing to have one config for different per arch mirrors
149  # security is optional, if not defined it is set to the same value as primary
150  security:
151    - uri: http://security.ubuntu.com/ubuntu
152      arches: [default]
153  # If search_dns is set for security the searched pattern is:
154  #   <distro>-security-mirror
155
156  # if no mirrors are specified at all, or all lookups fail it will try
157  # to get them from the cloud datasource and if those neither provide one fall
158  # back to:
159  #   primary: http://archive.ubuntu.com/ubuntu
160  #   security: http://security.ubuntu.com/ubuntu
161
162  # 1.4 sources_list
163  #
164  # Provide a custom template for rendering sources.list
165  # without one provided cloud-init uses builtin templates for
166  # ubuntu and debian.
167  # Within these sources.list templates you can use the following replacement
168  # variables (all have sane Ubuntu defaults, but mirrors can be overwritten
169  # as needed (see above)):
170  # => $RELEASE, $MIRROR, $PRIMARY, $SECURITY
171  sources_list: | # written by cloud-init custom template
172    deb $MIRROR $RELEASE main restricted
173    deb-src $MIRROR $RELEASE main restricted
174    deb $PRIMARY $RELEASE universe restricted
175    deb $SECURITY $RELEASE-security multiverse
176
177  # 1.5 conf
178  #
179  # Any apt config string that will be made available to apt
180  # see the APT.CONF(5) man page for details what can be specified
181  conf: | # APT config
182    APT {
183      Get {
184        Assume-Yes "true";
185        Fix-Broken "true";
186      };
187    };
188
189  # 1.6 (http_|ftp_|https_)proxy
190  #
191  # Proxies are the most common apt.conf option, so that for simplified use
192  # there is a shortcut for those. Those get automatically translated into the
193  # correct Acquire::*::Proxy statements.
194  #
195  # note: proxy actually being a short synonym to http_proxy
196  proxy: http://[[user][:pass]@]host[:port]/
197  http_proxy: http://[[user][:pass]@]host[:port]/
198  ftp_proxy: ftp://[[user][:pass]@]host[:port]/
199  https_proxy: https://[[user][:pass]@]host[:port]/
200
201  # 1.7 add_apt_repo_match
202  #
203  # 'source' entries in apt-sources that match this python regex
204  # expression will be passed to add-apt-repository
205  # The following example is also the builtin default if nothing is specified
206  add_apt_repo_match: '^[\w-]+:\w'
207
208
209  ##############################################################################
210  # Section 2: source list entries
211  #
212  # This is a dictionary (unlike most block/net which are lists)
213  #
214  # The key of each source entry is the filename and will be prepended by
215  # /etc/apt/sources.list.d/ if it doesn't start with a '/'.
216  # If it doesn't end with .list it will be appended so that apt picks up its
217  # configuration.
218  #
219  # Whenever there is no content to be written into such a file, the key is
220  # not used as filename - yet it can still be used as index for merging
221  # configuration.
222  #
223  # The values inside the entries consist of the following optional entries:
224  #   'source': a sources.list entry (some variable replacements apply)
225  #   'keyid': providing a key to import via shortid or fingerprint
226  #   'key': providing a raw PGP key
227  #   'keyserver': specify an alternate keyserver to pull keys from that
228  #                were specified by keyid
229
230  # This allows merging between multiple input files than a list like:
231  # cloud-config1
232  # sources:
233  #   s1: {'key': 'key1', 'source': 'source1'}
234  # cloud-config2
235  # sources:
236  #   s2: {'key': 'key2'}
237  #   s1: {'keyserver': 'foo'}
238  # This would be merged to
239  # sources:
240  #   s1:
241  #     keyserver: foo
242  #     key: key1
243  #     source: source1
244  #   s2:
245  #     key: key2
246  #
247  # The following examples number the subfeatures per sources entry to ease
248  # identification in discussions.
249
250
251  sources:
252    curtin-dev-ppa.list:
253      # 2.1 source
254      #
255      # Creates a file in /etc/apt/sources.list.d/ for the sources list entry
256      # based on the key: "/etc/apt/sources.list.d/curtin-dev-ppa.list"
257      source: "deb http://ppa.launchpad.net/curtin-dev/test-archive/ubuntu bionic main"
258
259      # 2.2 keyid
260      #
261      # Importing a gpg key for a given key id. Used keyserver defaults to
262      # keyserver.ubuntu.com
263      keyid: F430BBA5 # GPG key ID published on a key server
264
265    ignored1:
266      # 2.3 PPA shortcut
267      #
268      # Setup correct apt sources.list line and Auto-Import the signing key
269      # from LP
270      #
271      # See https://help.launchpad.net/Packaging/PPA for more information
272      # this requires 'add-apt-repository'. This will create a file in
273      # /etc/apt/sources.list.d automatically, therefore the key here is
274      # ignored as filename in those cases.
275      source: "ppa:curtin-dev/test-archive"    # Quote the string
276
277    my-repo2.list:
278      # 2.4 replacement variables
279      #
280      # sources can use $MIRROR, $PRIMARY, $SECURITY, $RELEASE and $KEY_FILE
281      # replacement variables.
282      # They will be replaced with the default or specified mirrors and the
283      # running release.
284      # The entry below would be possibly turned into:
285      #   source: deb http://archive.ubuntu.com/ubuntu bionic multiverse
286      source: deb [signed-by=$KEY_FILE] $MIRROR $RELEASE multiverse
287      keyid: F430BBA5
288
289    my-repo3.list:
290      # this would have the same end effect as 'ppa:curtin-dev/test-archive'
291      source: "deb http://ppa.launchpad.net/curtin-dev/test-archive/ubuntu bionic main"
292      keyid: F430BBA5 # GPG key ID published on the key server
293      filename: curtin-dev-ppa.list
294
295    ignored2:
296      # 2.5 key only
297      #
298      # this would only import the key without adding a ppa or other source spec
299      # since this doesn't generate a source.list file the filename key is ignored
300      keyid: F430BBA5 # GPG key ID published on a key server
301
302    ignored3:
303      # 2.6 key id alternatives
304      #
305      # Keyid's can also be specified via their long fingerprints
306      keyid: B59D 5F15 97A5 04B7 E230  6DCA 0620 BBCF 0368 3F77
307
308    ignored4:
309      # 2.7 alternative keyservers
310      #
311      # One can also specify alternative keyservers to fetch keys from.
312      keyid: B59D 5F15 97A5 04B7 E230  6DCA 0620 BBCF 0368 3F77
313      keyserver: pgp.mit.edu
314
315    ignored5:
316      # 2.8 signed-by
317      #
318      # One can specify [signed-by=$KEY_FILE] in the source definition, which
319      # will make the key be installed in the directory /etc/cloud-init.gpg.d/
320      # and the $KEY_FILE replacement variable will be replaced with the path
321      # to the specified key. If $KEY_FILE is used, but no key is specified,
322      # apt update will (rightfully) fail due to an invalid value.
323      source: deb [signed-by=$KEY_FILE] $MIRROR $RELEASE multiverse
324      keyid: B59D 5F15 97A5 04B7 E230  6DCA 0620 BBCF 0368 3F77
325
326    my-repo4.list:
327      # 2.9 raw key
328      #
329      # The apt signing key can also be specified by providing a pgp public key
330      # block. Providing the PGP key this way is the most robust method for
331      # specifying a key, as it removes dependency on a remote key server.
332      #
333      # As with keyid's this can be specified with or without some actual source
334      # content.
335      key: | # The value needs to start with -----BEGIN PGP PUBLIC KEY BLOCK-----
336        -----BEGIN PGP PUBLIC KEY BLOCK-----
337        Version: SKS 1.0.10
338
339        mI0ESpA3UQEEALdZKVIMq0j6qWAXAyxSlF63SvPVIgxHPb9Nk0DZUixn+akqytxG4zKCONz6
340        qLjoBBfHnynyVLfT4ihg9an1PqxRnTO+JKQxl8NgKGz6Pon569GtAOdWNKw15XKinJTDLjnj
341        9y96ljJqRcpV9t/WsIcdJPcKFR5voHTEoABE2aEXABEBAAG0GUxhdW5jaHBhZCBQUEEgZm9y
342        IEFsZXN0aWOItgQTAQIAIAUCSpA3UQIbAwYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEA7H
343        5Qi+CcVxWZ8D/1MyYvfj3FJPZUm2Yo1zZsQ657vHI9+pPouqflWOayRR9jbiyUFIn0VdQBrP
344        t0FwvnOFArUovUWoKAEdqR8hPy3M3APUZjl5K4cMZR/xaMQeQRZ5CHpS4DBKURKAHC0ltS5o
345        uBJKQOZm5iltJp15cgyIkBkGe8Mx18VFyVglAZey
346        =Y2oI
347        -----END PGP PUBLIC KEY BLOCK-----
```plaintext

### Disk setup

```plaintext
  1#cloud-config
  2# Cloud-init supports the creation of simple partition tables and filesystems
  3# on devices.
  4
  5# Default disk definitions for AWS
  6# --------------------------------
  7# (Not implemented yet, but provided for future documentation)
  8
  9disk_setup:
 10  ephemeral0:
 11    table_type: 'mbr'
 12    layout: True
 13    overwrite: False
 14
 15fs_setup:
 16  - label: None,
 17    filesystem: ext3
 18    device: ephemeral0
 19    partition: auto
 20
 21# Default disk definitions for Microsoft Azure
 22# ------------------------------------------
 23
 24device_aliases: {'ephemeral0': '/dev/sdb'}
 25disk_setup:
 26  ephemeral0:
 27    table_type: mbr
 28    layout: True
 29    overwrite: False
 30
 31fs_setup:
 32  - label: ephemeral0
 33    filesystem: ext4
 34    device: ephemeral0.1
 35    replace_fs: ntfs
 36
 37
 38# Data disks definitions for Microsoft Azure
 39# ------------------------------------------
 40
 41disk_setup:
 42  /dev/disk/azure/scsi1/lun0:
 43    table_type: gpt
 44    layout: True
 45    overwrite: True
 46
 47fs_setup:
 48  - device: /dev/disk/azure/scsi1/lun0
 49    partition: 1
 50    filesystem: ext4
 51
 52
 53# Default disk definitions for SmartOS
 54# ------------------------------------
 55
 56device_aliases: {'ephemeral0': '/dev/vdb'}
 57disk_setup:
 58  ephemeral0:
 59    table_type: mbr
 60    layout: False
 61    overwrite: False
 62
 63fs_setup:
 64  - label: ephemeral0
 65    filesystem: ext4
 66    device: ephemeral0.0
 67
 68# Caveat for SmartOS: if ephemeral disk is not defined, then the disk will
 69#    not be automatically added to the mounts.
 70
 71
 72# The default definition is used to make sure that the ephemeral storage is
 73# setup properly.
 74
 75# "disk_setup": disk partitioning
 76# --------------------------------
 77
 78# The disk_setup directive instructs Cloud-init to partition a disk. The format is:
 79
 80disk_setup:
 81  ephemeral0:
 82    table_type: 'mbr'
 83    layout: true
 84  /dev/xvdh:
 85    table_type: 'mbr'
 86    layout:
 87      - 33
 88      - [33, 82]
 89      - 33
 90    overwrite: True
 91
 92# The format is a list of dicts of dicts. The first value is the name of the
 93# device and the subsequent values define how to create and layout the
 94# partition.
 95# The general format is:
 96#   disk_setup:
 97#     <DEVICE>:
 98#       table_type: 'mbr'
 99#       layout: <LAYOUT|BOOL>
100#       overwrite: <BOOL>
101#
102# Where:
103#   <DEVICE>: The name of the device. 'ephemeralX' and 'swap' are special
104#               values which are specific to the cloud. For these devices
105#               Cloud-init will look up what the real devices is and then
106#               use it.
107#
108#               For other devices, the kernel device name is used. At this
109#               time only simply kernel devices are supported, meaning
110#               that device mapper and other targets may not work.
111#
112#               Note: At this time, there is no handling or setup of
113#               device mapper targets.
114#
115#   table_type=<TYPE>: Currently the following are supported:
116#                   'mbr': default and setups a MS-DOS partition table
117#                   'gpt': setups a GPT partition table
118#
119#               Note: At this time only 'mbr' and 'gpt' partition tables
120#                   are allowed. It is anticipated in the future that
121#                   we'll also have "RAID" to create a mdadm RAID.
122#
123#   layout={...}: The device layout. This is a list of values, with the
124#               percentage of disk that partition will take.
125#               Valid options are:
126#                   [<SIZE>, [<SIZE>, <PART_TYPE]]
127#
128#               Where <SIZE> is the _percentage_ of the disk to use, while
129#               <PART_TYPE> is the numerical value of the partition type.
130#
131#               The following setups two partitions, with the first
132#               partition having a swap label, taking 1/3 of the disk space
133#               and the remainder being used as the second partition.
134#                 /dev/xvdh':
135#                   table_type: 'mbr'
136#                   layout:
137#                     - [33,82]
138#                     - 66
139#                   overwrite: True
140#
141#               When layout is "true" it means single partition the entire
142#               device.
143#
144#               When layout is "false" it means don't partition or ignore
145#               existing partitioning.
146#
147#               If layout is set to "true" and overwrite is set to "false",
148#               it will skip partitioning the device without a failure.
149#
150#   overwrite=<BOOL>: This describes whether to ride with safetys on and
151#               everything holstered.
152#
153#               'false' is the default, which means that:
154#                   1. The device will be checked for a partition table
155#                   2. The device will be checked for a filesystem
156#                   3. If either a partition of filesystem is found, then
157#                       the operation will be _skipped_.
158#
159#               'true' is cowboy mode. There are no checks and things are
160#                   done blindly. USE with caution, you can do things you
161#                   really, really don't want to do.
162#
163#
164# fs_setup: Setup the filesystem
165# ------------------------------
166#
167# fs_setup describes the how the filesystems are supposed to look.
168
169fs_setup:
170  - label: ephemeral0
171    filesystem: 'ext3'
172    device: 'ephemeral0'
173    partition: 'auto'
174  - label: mylabl2
175    filesystem: 'ext4'
176    device: '/dev/xvda1'
177  - cmd: mkfs -t %(filesystem)s -L %(label)s %(device)s
178    label: mylabl3
179    filesystem: 'btrfs'
180    device: '/dev/xvdh'
181
182# The general format is:
183#   fs_setup:
184#     - label: <LABEL>
185#       filesystem: <FS_TYPE>
186#       device: <DEVICE>
187#       partition: <PART_VALUE>
188#       overwrite: <OVERWRITE>
189#       replace_fs: <FS_TYPE>
190#
191# Where:
192#   <LABEL>: The filesystem label to be used. If set to None, no label is
193#     used.
194#
195#   <FS_TYPE>: The filesystem type. It is assumed that the there
196#     will be a "mkfs.<FS_TYPE>" that behaves likes "mkfs". On a standard
197#     Ubuntu Cloud Image, this means that you have the option of ext{2,3,4},
198#     and vfat by default.
199#
200#   <DEVICE>: The device name. Special names of 'ephemeralX' or 'swap'
201#     are allowed and the actual device is acquired from the cloud datasource.
202#     When using 'ephemeralX' (i.e. ephemeral0), make sure to leave the
203#     label as 'ephemeralX' otherwise there may be issues with the mounting
204#     of the ephemeral storage layer.
205#
206#     If you define the device as 'ephemeralX.Y' then Y will be interpetted
207#     as a partition value. However, ephermalX.0 is the _same_ as ephemeralX.
208#
209#   <PART_VALUE>:
210#     Partition definitions are overwritten if you use the '<DEVICE>.Y' notation.
211#
212#     The valid options are:
213#     "auto|any": tell cloud-init not to care whether there is a partition
214#       or not. Auto will use the first partition that does not contain a
215#       filesystem already. In the absence of a partition table, it will
216#       put it directly on the disk.
217#
218#       "auto": If a filesystem that matches the specification in terms of
219#       label, filesystem and device, then cloud-init will skip the creation
220#       of the filesystem.
221#
222#       "any": If a filesystem that matches the filesystem type and device,
223#       then cloud-init will skip the creation of the filesystem.
224#
225#       Devices are selected based on first-detected, starting with partitions
226#       and then the raw disk. Consider the following:
227#           NAME     FSTYPE LABEL
228#           xvdb
229#           |-xvdb1  ext4
230#           |-xvdb2
231#           |-xvdb3  btrfs  test
232#           \-xvdb4  ext4   test
233#
234#         If you ask for 'auto', label of 'test, and filesystem of 'ext4'
235#         then cloud-init will select the 2nd partition, even though there
236#         is a partition match at the 4th partition.
237#
238#         If you ask for 'any' and a label of 'test', then cloud-init will
239#         select the 1st partition.
240#
241#         If you ask for 'auto' and don't define label, then cloud-init will
242#         select the 1st partition.
243#
244#         In general, if you have a specific partition configuration in mind,
245#         you should define either the device or the partition number. 'auto'
246#         and 'any' are specifically intended for formatting ephemeral storage
247#         or for simple schemes.
248#
249#       "none": Put the filesystem directly on the device.
250#
251#       <NUM>: where NUM is the actual partition number.
252#
253#   <OVERWRITE>: Defines whether or not to overwrite any existing
254#     filesystem.
255#
256#     "true": Indiscriminately destroy any pre-existing filesystem. Use at
257#         your own peril.
258#
259#     "false": If an existing filesystem exists, skip the creation.
260#
261#   <REPLACE_FS>: This is a special directive, used for Microsoft Azure that
262#     instructs cloud-init to replace a filesystem of <FS_TYPE>. NOTE:
263#     unless you define a label, this requires the use of the 'any' partition
264#     directive.
265#
266# Behavior Caveat: The default behavior is to _check_ if the filesystem exists.
267#   If a filesystem matches the specification, then the operation is a no-op.
```plaintext

### Configure data sources

```plaintext
 1#cloud-config
 2
 3# Documentation on data sources configuration options
 4datasource:
 5  # Ec2 
 6  Ec2:
 7    # timeout: the timeout value for a request at metadata service
 8    timeout : 50
 9    # The length in seconds to wait before giving up on the metadata
10    # service.  The actual total wait could be up to 
11    #   len(resolvable_metadata_urls)*timeout
12    max_wait : 120
13
14    #metadata_url: a list of URLs to check for metadata services
15    metadata_urls:
16     - http://169.254.169.254:80
17     - http://instance-data:8773
18
19  MAAS:
20    timeout : 50
21    max_wait : 120
22
23    # there are no default values for metadata_url or oauth credentials
24    # If no credentials are present, non-authed attempts will be made.
25    metadata_url: http://mass-host.localdomain/source
26    consumer_key: Xh234sdkljf
27    token_key: kjfhgb3n
28    token_secret: 24uysdfx1w4
29
30  NoCloud:
31    # default seedfrom is None
32    # if found, then it should contain a url with:
33    #    <url>/user-data and <url>/meta-data
34    # seedfrom: http://my.example.com/i-abcde/
35    seedfrom: None
36
37    # fs_label: the label on filesystems to be searched for NoCloud source
38    fs_label: cidata
39
40    # these are optional, but allow you to basically provide a datasource
41    # right here
42    user-data: |
43      # This is the user-data verbatim
44    meta-data:
45      instance-id: i-87018aed
46      local-hostname: myhost.internal
47
48  SmartOS:
49    # For KVM guests:
50    # Smart OS datasource works over a serial console interacting with
51    # a server on the other end. By default, the second serial console is the
52    # device. SmartOS also uses a serial timeout of 60 seconds.
53    serial_device: /dev/ttyS1
54    serial_timeout: 60
55
56    # For LX-Brand Zones guests:
57    # Smart OS datasource works over a socket interacting with
58    # the host on the other end. By default, the socket file is in
59    # the native .zoncontrol directory.
60    metadata_sockfile: /native/.zonecontrol/metadata.sock
61
62    # a list of keys that will not be base64 decoded even if base64_all
63    no_base64_decode: ['root_authorized_keys', 'motd_sys_info',
64                       'iptables_disable']
65    # a plaintext, comma delimited list of keys whose values are b64 encoded
66    base64_keys: []
67    # a boolean indicating that all keys not in 'no_base64_decode' are encoded
68    base64_all: False
```plaintext

### Create partitions and filesystems

```plaintext
  1#cloud-config
  2# Cloud-init supports the creation of simple partition tables and filesystems
  3# on devices.
  4
  5# Default disk definitions for AWS
  6# --------------------------------
  7# (Not implemented yet, but provided for future documentation)
  8
  9disk_setup:
 10  ephemeral0:
 11    table_type: 'mbr'
 12    layout: True
 13    overwrite: False
 14
 15fs_setup:
 16  - label: None,
 17    filesystem: ext3
 18    device: ephemeral0
 19    partition: auto
 20
 21# Default disk definitions for Microsoft Azure
 22# ------------------------------------------
 23
 24device_aliases: {'ephemeral0': '/dev/sdb'}
 25disk_setup:
 26  ephemeral0:
 27    table_type: mbr
 28    layout: True
 29    overwrite: False
 30
 31fs_setup:
 32  - label: ephemeral0
 33    filesystem: ext4
 34    device: ephemeral0.1
 35    replace_fs: ntfs
 36
 37
 38# Data disks definitions for Microsoft Azure
 39# ------------------------------------------
 40
 41disk_setup:
 42  /dev/disk/azure/scsi1/lun0:
 43    table_type: gpt
 44    layout: True
 45    overwrite: True
 46
 47fs_setup:
 48  - device: /dev/disk/azure/scsi1/lun0
 49    partition: 1
 50    filesystem: ext4
 51
 52
 53# Default disk definitions for SmartOS
 54# ------------------------------------
 55
 56device_aliases: {'ephemeral0': '/dev/vdb'}
 57disk_setup:
 58  ephemeral0:
 59    table_type: mbr
 60    layout: False
 61    overwrite: False
 62
 63fs_setup:
 64  - label: ephemeral0
 65    filesystem: ext4
 66    device: ephemeral0.0
 67
 68# Caveat for SmartOS: if ephemeral disk is not defined, then the disk will
 69#    not be automatically added to the mounts.
 70
 71
 72# The default definition is used to make sure that the ephemeral storage is
 73# setup properly.
 74
 75# "disk_setup": disk partitioning
 76# --------------------------------
 77
 78# The disk_setup directive instructs Cloud-init to partition a disk. The format is:
 79
 80disk_setup:
 81  ephemeral0:
 82    table_type: 'mbr'
 83    layout: true
 84  /dev/xvdh:
 85    table_type: 'mbr'
 86    layout:
 87      - 33
 88      - [33, 82]
 89      - 33
 90    overwrite: True
 91
 92# The format is a list of dicts of dicts. The first value is the name of the
 93# device and the subsequent values define how to create and layout the
 94# partition.
 95# The general format is:
 96#   disk_setup:
 97#     <DEVICE>:
 98#       table_type: 'mbr'
 99#       layout: <LAYOUT|BOOL>
100#       overwrite: <BOOL>
101#
102# Where:
103#   <DEVICE>: The name of the device. 'ephemeralX' and 'swap' are special
104#               values which are specific to the cloud. For these devices
105#               Cloud-init will look up what the real devices is and then
106#               use it.
107#
108#               For other devices, the kernel device name is used. At this
109#               time only simply kernel devices are supported, meaning
110#               that device mapper and other targets may not work.
111#
112#               Note: At this time, there is no handling or setup of
113#               device mapper targets.
114#
115#   table_type=<TYPE>: Currently the following are supported:
116#                   'mbr': default and setups a MS-DOS partition table
117#                   'gpt': setups a GPT partition table
118#
119#               Note: At this time only 'mbr' and 'gpt' partition tables
120#                   are allowed. It is anticipated in the future that
121#                   we'll also have "RAID" to create a mdadm RAID.
122#
123#   layout={...}: The device layout. This is a list of values, with the
124#               percentage of disk that partition will take.
125#               Valid options are:
126#                   [<SIZE>, [<SIZE>, <PART_TYPE]]
127#
128#               Where <SIZE> is the _percentage_ of the disk to use, while
129#               <PART_TYPE> is the numerical value of the partition type.
130#
131#               The following setups two partitions, with the first
132#               partition having a swap label, taking 1/3 of the disk space
133#               and the remainder being used as the second partition.
134#                 /dev/xvdh':
135#                   table_type: 'mbr'
136#                   layout:
137#                     - [33,82]
138#                     - 66
139#                   overwrite: True
140#
141#               When layout is "true" it means single partition the entire
142#               device.
143#
144#               When layout is "false" it means don't partition or ignore
145#               existing partitioning.
146#
147#               If layout is set to "true" and overwrite is set to "false",
148#               it will skip partitioning the device without a failure.
149#
150#   overwrite=<BOOL>: This describes whether to ride with safetys on and
151#               everything holstered.
152#
153#               'false' is the default, which means that:
154#                   1. The device will be checked for a partition table
155#                   2. The device will be checked for a filesystem
156#                   3. If either a partition of filesystem is found, then
157#                       the operation will be _skipped_.
158#
159#               'true' is cowboy mode. There are no checks and things are
160#                   done blindly. USE with caution, you can do things you
161#                   really, really don't want to do.
162#
163#
164# fs_setup: Setup the filesystem
165# ------------------------------
166#
167# fs_setup describes the how the filesystems are supposed to look.
168
169fs_setup:
170  - label: ephemeral0
171    filesystem: 'ext3'
172    device: 'ephemeral0'
173    partition: 'auto'
174  - label: mylabl2
175    filesystem: 'ext4'
176    device: '/dev/xvda1'
177  - cmd: mkfs -t %(filesystem)s -L %(label)s %(device)s
178    label: mylabl3
179    filesystem: 'btrfs'
180    device: '/dev/xvdh'
181
182# The general format is:
183#   fs_setup:
184#     - label: <LABEL>
185#       filesystem: <FS_TYPE>
186#       device: <DEVICE>
187#       partition: <PART_VALUE>
188#       overwrite: <OVERWRITE>
189#       replace_fs: <FS_TYPE>
190#
191# Where:
192#   <LABEL>: The filesystem label to be used. If set to None, no label is
193#     used.
194#
195#   <FS_TYPE>: The filesystem type. It is assumed that the there
196#     will be a "mkfs.<FS_TYPE>" that behaves likes "mkfs". On a standard
197#     Ubuntu Cloud Image, this means that you have the option of ext{2,3,4},
198#     and vfat by default.
199#
200#   <DEVICE>: The device name. Special names of 'ephemeralX' or 'swap'
201#     are allowed and the actual device is acquired from the cloud datasource.
202#     When using 'ephemeralX' (i.e. ephemeral0), make sure to leave the
203#     label as 'ephemeralX' otherwise there may be issues with the mounting
204#     of the ephemeral storage layer.
205#
206#     If you define the device as 'ephemeralX.Y' then Y will be interpetted
207#     as a partition value. However, ephermalX.0 is the _same_ as ephemeralX.
208#
209#   <PART_VALUE>:
210#     Partition definitions are overwritten if you use the '<DEVICE>.Y' notation.
211#
212#     The valid options are:
213#     "auto|any": tell cloud-init not to care whether there is a partition
214#       or not. Auto will use the first partition that does not contain a
215#       filesystem already. In the absence of a partition table, it will
216#       put it directly on the disk.
217#
218#       "auto": If a filesystem that matches the specification in terms of
219#       label, filesystem and device, then cloud-init will skip the creation
220#       of the filesystem.
221#
222#       "any": If a filesystem that matches the filesystem type and device,
223#       then cloud-init will skip the creation of the filesystem.
224#
225#       Devices are selected based on first-detected, starting with partitions
226#       and then the raw disk. Consider the following:
227#           NAME     FSTYPE LABEL
228#           xvdb
229#           |-xvdb1  ext4
230#           |-xvdb2
231#           |-xvdb3  btrfs  test
232#           \-xvdb4  ext4   test
233#
234#         If you ask for 'auto', label of 'test, and filesystem of 'ext4'
235#         then cloud-init will select the 2nd partition, even though there
236#         is a partition match at the 4th partition.
237#
238#         If you ask for 'any' and a label of 'test', then cloud-init will
239#         select the 1st partition.
240#
241#         If you ask for 'auto' and don't define label, then cloud-init will
242#         select the 1st partition.
243#
244#         In general, if you have a specific partition configuration in mind,
245#         you should define either the device or the partition number. 'auto'
246#         and 'any' are specifically intended for formatting ephemeral storage
247#         or for simple schemes.
248#
249#       "none": Put the filesystem directly on the device.
250#
251#       <NUM>: where NUM is the actual partition number.
252#
253#   <OVERWRITE>: Defines whether or not to overwrite any existing
254#     filesystem.
255#
256#     "true": Indiscriminately destroy any pre-existing filesystem. Use at
257#         your own peril.
258#
259#     "false": If an existing filesystem exists, skip the creation.
260#
261#   <REPLACE_FS>: This is a special directive, used for Microsoft Azure that
262#     instructs cloud-init to replace a filesystem of <FS_TYPE>. NOTE:
263#     unless you define a label, this requires the use of the 'any' partition
264#     directive.
265#
266# Behavior Caveat: The default behavior is to _check_ if the filesystem exists.
267
```plaintext
