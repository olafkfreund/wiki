# Linux  Tuning

You can use the Linux sysctl command to modify default system network parameters that are set by the operating system.

Example use:

```sh
### KERNEL TUNING ###

# Increase size of file handles and inode cache
fs.file-max = 2097152

# Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2

# Sets the time before the kernel considers migrating a proccess to another core
kernel.sched_migration_cost_ns = 5000000

# Group tasks by TTY
#kernel.sched_autogroup_enabled = 0

### GENERAL NETWORK SECURITY OPTIONS ###

# Number of times SYNACKs for passive TCP connection.
net.ipv4.tcp_synack_retries = 2

# Allowed local port range
net.ipv4.ip_local_port_range = 2000 65535

# Protect Against TCP Time-Wait
net.ipv4.tcp_rfc1337 = 1

# Control Syncookies
net.ipv4.tcp_syncookies = 1

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 15

# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

### TUNING NETWORK PERFORMANCE ###

# Default Socket Receive Buffer
net.core.rmem_default = 31457280

# Maximum Socket Receive Buffer
net.core.rmem_max = 33554432

# Default Socket Send Buffer
net.core.wmem_default = 31457280

# Maximum Socket Send Buffer
net.core.wmem_max = 33554432

# Increase number of incoming connections
net.core.somaxconn = 65535

# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 65536

# Increase the maximum amount of option memory buffers
net.core.optmem_max = 25165824

# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
net.ipv4.tcp_mem = 786432 1048576 26777216
net.ipv4.udp_mem = 65536 131072 262144

# Increase the read-buffer space allocatable
net.ipv4.tcp_rmem = 8192 87380 33554432
net.ipv4.udp_rmem_min = 16384

# Increase the write-buffer-space allocatable
net.ipv4.tcp_wmem = 8192 65536 33554432
net.ipv4.udp_wmem_min = 16384

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
```

**Use **_**TuneD**_** to configure kernel settings**

For Red Hat Enterprise Linux (RHEL) users, the [TuneD](https://tuned-project.org/) throughput-performance profile configures some kernel and CPU settings automatically (except for C-States). Starting with RHEL 8.0, a TuneD profile named `mssql` was codeveloped with Red Hat and offers finer Linux performance-related tunings for SQL Server workloads. This profile includes the RHEL throughput-performance profile, and we present its definitions below for your review with other Linux distributions and RHEL releases without this profile.

```sh
#
# A TuneD configuration for SQL Server on Linux
#

[main]
summary=Optimize for Microsoft SQL Server
include=throughput-performance

[cpu]
force_latency=5

[sysctl]
vm.swappiness = 1
vm.dirty_background_ratio = 3
vm.dirty_ratio = 80
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.transparent_hugepages=always
# For multi-instance SQL deployments, use
# vm.transparent_hugepages=madvise
vm.max_map_count=1600000
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
kernel.numa_balancing=0
#Note: If you are using Linux distributions with kernel versions greater than 4.18, please comment the following options as shown; otherwise, uncomment the following options if you are using distributions with kernel versions less than 4.18.
# kernel.sched_latency_ns = 60000000
# kernel.sched_migration_cost_ns = 500000
# kernel.sched_min_granularity_ns = 15000000
# kernel.sched_wakeup_granularity_ns = 2000000
```
