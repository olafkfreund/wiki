# Linux File system hierarchy

## Linux File system hierarchy <a href="#5440" id="5440"></a>

Linux has only the parent directory (/) and all other directories are available under this.

* **/ (Root):**
* Primary hierarchy root and root directory of the entire file system hierarchy.
* The only root user has the right to write under this directory
* /root is the root user’s home directory, which is different from /
* **/etc:**
* Host-specific system-wide configuration files.
* Contains configuration files required by all programs.
* This also contains startup and shutdown shell scripts used to start/stop individual programs.
* Example: /etc/resolv.conf, /etc/logrotate.conf.
* **/home:**
* Users’ home directories, containing saved files, personal settings, etc.
* Home directories for all users to store their personal files.
* example: /home/kishlay, /home/kv
* **/var:**
* Variable Value file
* Files that have an unexpected size and whose content is expected to change continuously during normal operation of the system are stored here.
* For example, log files, spool files and cache files.
* **/opt:**
* Optional application software packages.
* Contains add-on applications from individual vendors.
* Add-on applications should be installed under either /opt/ or /opt/ sub-directory.
* **/lib:**
* Libraries essential for the binaries in /bin/ and /sbin/.
* Library filenames are either ld\* or lib\*.so.\*
* Example: ld-2.11.1.so, libncurses.so.5.7
* **/lib64:**
* Same as /lib but is for 64 bit
* **/temp:**
* Temporary files. Often not preserved between system reboots and may be severely size restricted.
* Directory that contains temporary files created by system and users.
* Files under this directory are deleted when system is rebooted.
* **/mnt:**
* Temporarily mounted filesystems.
* Temporary mount directory where sysadmins can mount filesystems.
* **/srv:**
* Site-specific data served by this system, such as data and scripts for web servers, data offered by FTP servers, and repositories for version control systems.
* srv stands for service.
* Contains server specific services related data.
* Example, /srv/cvs contains CVS related data.
* **/usr:**
* Secondary hierarchy for read-only user data; contains the majority of (multi-)user utilities and applications.
* Contains binaries, libraries, documentation, and source-code for second level programs.
* /usr/bin contains binary files for user programs. If you can’t find a user binary under /bin, look under /usr/bin. For example: at, awk, cc, less, scp
* /usr/sbin contains binary files for system administrators. If you can’t find a system binary under /sbin, look under /usr/sbin. For example: atd, cron, sshd, useradd, userdel
* /usr/lib contains libraries for /usr/bin and /usr/sbin
* /usr/local contains users programs that you install from source. For example, when you install apache from source, it goes under /usr/local/apache2
* /usr/src holds the Linux kernel sources, header-files and documentation.
* **/dev:**
* Essential device files, e.g., /dev/null.
* These include terminal devices, usb, or any device attached to the system.
* Example: /dev/tty1, /dev/usbmon0
* **/proc:**
* Virtual filesystem providing process and kernel information as files. In Linux, corresponds to a procfs mount. Generally, automatically generated and populated by the system, on the fly.
* Contains information about system process.
* This is a pseudo filesystem contains information about running process. For example: /proc/{pid} directory contains information about the process with that particular pid.
* This is a virtual filesystem with text information about system resources. For example: /proc/uptime
* **/bin:**
* Contains binary executables
* Commands used by all the users of the system are located here e.g. ps, ls, ping, grep, cp
* **/sbin:**
* Essential system binaries, e.g., fsck, init, route.
* Just like /bin, /sbin also contains binary executables.
* The linux commands located under this directory are used typically by system administrator, for system maintenance purpose.
* Example: iptables, reboot, fdisk, ifconfig, swapon
* **/media:**
* Mount points for removable media such as CD-ROMs (appeared in FHS-2.3).
* Temporary mount directory for removable devices.
* Examples, /media/cdrom for CD-ROM; /media/floppy for floppy drives; /media/cdrecorder for CD writer
* **/boot:**
* Boot loader files, e.g., kernels, initrd
* Kernel initrd, vmlinux, grub files are located under /boot

<figure><img src="https://miro.medium.com/v2/resize:fit:602/0*9uDnWn-KfmXZU6DY" alt="" height="623" width="602"><figcaption></figcaption></figure>

[\
](https://medium.com/tag/linux?source=post\_page-----cc74a96e27a2---------------linux-----------------)
