# NixOS Configuration Patterns

NixOS allows you to describe your entire system configuration declaratively. This guide explores practical patterns and techniques for managing NixOS systems in production environments.

## The NixOS Module System

NixOS uses a modular configuration system that allows you to organize settings into reusable modules:

```nix
# Basic structure of a NixOS module
{ config, pkgs, lib, ... }:

with lib;

{
  # Module options (schema)
  options.services.myservice = {
    enable = mkEnableOption "myservice";
    
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };
    
    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "Logging verbosity level";
    };
  };

  # Module implementation
  config = mkIf config.services.myservice.enable {
    systemd.services.myservice = {
      description = "My Custom Service";
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.myservice}/bin/myservice --port ${toString config.services.myservice.port} --log-level ${config.services.myservice.logLevel}";
        Restart = "always";
        User = "myservice";
      };
    };
    
    # Create the system user
    users.users.myservice = {
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/myservice";
      group = "myservice";
    };
    
    users.groups.myservice = {};
    
    # Ensure data directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/myservice 0750 myservice myservice -"
    ];
  };
}
```

## System Architecture Patterns

### Layered System Configuration

Structure your configuration in layers, from most general to most specific:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    # Hardware-specific configuration
    ./hardware-configuration.nix
    
    # Base system configuration
    ./modules/base.nix
    
    # Role-specific configuration
    ./modules/roles/webserver.nix
    
    # Environment-specific (dev/staging/prod)
    ./modules/environments/production.nix
    
    # Instance-specific configuration
    ./modules/instances/web-01.nix
  ];
  
  # Host-specific overrides
  networking.hostName = "web-01";
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
```

### Multi-Environment Configuration

Manage development, staging, and production environments using conditionals:

```nix
# modules/environments/default.nix
{ config, pkgs, lib, ... }:

with lib;

let
  # Current environment from a file or environment variable
  currentEnv = builtins.getEnv "DEPLOY_ENV";
  environment = if currentEnv == "" then "dev" else currentEnv;
  
  # Environment-specific settings
  environmentSettings = {
    dev = {
      services.myapp.logLevel = "debug";
      services.myapp.enableDevTools = true;
      networking.firewall.enable = false;
    };
    
    staging = {
      services.myapp.logLevel = "info";
      services.myapp.enableDevTools = false;
      networking.firewall.enable = true;
    };
    
    prod = {
      services.myapp.logLevel = "warn";
      services.myapp.enableDevTools = false;
      networking.firewall.enable = true;
      security.acme.email = "devops@mycompany.com";
      security.acme.acceptTerms = true;
    };
  };
  
  # Select the current environment's settings
  envSettings = environmentSettings.${environment};
  
in {
  config = mkMerge [
    # Common settings for all environments
    {
      networking.domain = "mycompany.com";
      time.timeZone = "UTC";
    }
    
    # Environment-specific settings
    envSettings
    
    # Environment indicator
    {
      # Set prompt color based on environment
      programs.bash.promptInit = ''
        PS1_COLOR=${if environment == "prod" then "31" # Red
                    else if environment == "staging" then "33" # Yellow
                    else "32" # Green for dev
                   }
        PS1="\[\e[$PS1_COLOR;1m\][\u@\h:\w]$\[\e[0m\] "
      '';
    }
  ];
}
```

## Service Configuration Patterns

### Service Factory Pattern

Create a factory function to generate consistent service configurations:

```nix
# modules/lib/make-service.nix
{ config, lib, pkgs, ... }:

with lib;

# Service factory function
serviceOpts = { name, description, port, ... }@args:
  let
    # Default settings that can be overridden
    settings = {
      user = name;
      group = name;
      dataDir = "/var/lib/${name}";
      configFile = "/etc/${name}/config.json";
      logDir = "/var/log/${name}";
      openFirewall = true;
      environmentFile = null;
    } // args;
  in {
    systemd.services.${name} = {
      description = description;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        User = settings.user;
        Group = settings.group;
        ExecStart = "${pkgs.${name}}/bin/${name} --config ${settings.configFile}";
        Restart = "always";
        RestartSec = "10s";
        WorkingDirectory = settings.dataDir;
        StateDirectory = baseNameOf settings.dataDir;
        LogsDirectory = baseNameOf settings.logDir;
        RuntimeDirectory = name;
      } // (optionalAttrs (settings.environmentFile != null) {
        EnvironmentFile = settings.environmentFile;
      });
    };
    
    # Create user/group
    users.users.${settings.user} = mkIf (settings.user == name) {
      isSystemUser = true;
      group = settings.group;
      home = settings.dataDir;
      createHome = true;
    };
    
    users.groups.${settings.group} = mkIf (settings.group == name) {};
    
    # Open firewall port if needed
    networking.firewall.allowedTCPPorts = mkIf settings.openFirewall [ port ];
  };

# Export the factory function
in {
  inherit serviceOpts;
}
```

Usage example:

```nix
# modules/services/api-server.nix
{ config, lib, pkgs, ... }:

with lib;
with import ../lib/make-service.nix { inherit config lib pkgs; };

{
  imports = [];
  
  # Use the service factory
  config = mkMerge [
    (serviceOpts {
      name = "api-server";
      description = "API Server for our platform";
      port = 3000;
      environmentFile = "/etc/api-server/env";
      openFirewall = true;
    })
    
    # Additional service-specific configuration
    {
      systemd.services.api-server.serviceConfig.MemoryLimit = "2G";
      
      # Ensure config directory exists
      system.activationScripts.api-server-conf = ''
        mkdir -p /etc/api-server
        chmod 750 /etc/api-server
        chown api-server:api-server /etc/api-server
      '';
    }
  ];
}
```

### Consistent Database Services

Create a standard pattern for database services:

```nix
# modules/services/databases.nix
{ config, lib, pkgs, ... }:

with lib;

let
  # Database factory function
  mkDatabase = { type, name, port ? null, memoryPercent ? 25, backupEnable ? true }:
    let
      defaultPort = {
        "postgresql" = 5432;
        "mysql" = 3306;
        "mongodb" = 27017;
        "redis" = 6379;
      };
      
      servicePort = if port == null then defaultPort.${type} else port;
      
      # Calculate memory limit based on total system memory
      systemMemoryMB = 
        builtins.div
          (builtins.mul 
            (builtins.div 
              (builtins.mul 
                (builtins.head 
                  (builtins.match "MemTotal:[[:space:]]+([[:digit:]]+) kB" 
                    (builtins.readFile "/proc/meminfo"))) 1024) 100) 
            memoryPercent);
    in
    {
      # Common configuration for all database types
      services.${type}.enable = true;
      services.${type}.port = servicePort;
      
      # Type-specific configurations
      ${optionalString (type == "postgresql") ''
        services.postgresql = {
          enableTCPIP = true;
          authentication = pkgs.lib.mkOverride 10 ''
            local all all trust
            host all all 127.0.0.1/32 md5
            host all all ::1/128 md5
          '';
          settings = {
            max_connections = 200;
            shared_buffers = "${toString (systemMemoryMB / 4)}MB";
            effective_cache_size = "${toString (systemMemoryMB / 2)}MB";
          };
        };
      ''}
      
      ${optionalString (type == "mysql") ''
        services.mysql = {
          package = pkgs.mariadb;
          settings = {
            mysqld = {
              innodb_buffer_pool_size = "${toString (systemMemoryMB / 2)}M";
              max_connections = 200;
            };
          };
        };
      ''}
      
      ${optionalString (type == "redis") ''
        services.redis.settings = {
          maxmemory = "${toString systemMemoryMB}mb";
          maxmemory-policy = "allkeys-lru";
        };
      ''}
      
      # Enable regular backups if requested
      ${optionalString backupEnable ''
        services.${type}.backup = {
          enable = true;
          calendar = "*-*-* 02:00:00"; # Daily at 2 AM
          location = "/var/backup/${type}";
          user = "${type}";
        };
        
        # Ensure backup directory exists
        system.activationScripts."backup-${type}" = ''
          mkdir -p /var/backup/${type}
          chmod 700 /var/backup/${type}
          chown ${type}:${type} /var/backup/${type}
        '';
      ''}
      
      # Open firewall port
      networking.firewall.allowedTCPPorts = [ servicePort ];
    };
in {
  # Export the database factory function
  options.factory.database = mkOption {
    default = {};
    description = "Database factory function";
  };
  
  config = {
    factory.database = mkDatabase;
  };
}
```

Usage example:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [ ./modules/services/databases.nix ];
  
  # Use the database factory
  config = lib.mkMerge [
    (config.factory.database {
      type = "postgresql";
      name = "appdb";
      memoryPercent = 30;
    })
    
    # Additional PostgreSQL-specific configuration
    {
      services.postgresql.initialScript = pkgs.writeText "init.sql" ''
        CREATE DATABASE myapp;
        CREATE USER myapp WITH PASSWORD 'mypassword';
        GRANT ALL PRIVILEGES ON DATABASE myapp TO myapp;
      '';
    }
  ];
}
```

## Security Patterns

### Defense in Depth Configuration

Apply multiple layers of security:

```nix
{ config, pkgs, lib, ... }:

{
  # Base security settings
  security = {
    # Protect against buffer overflows and other memory attacks
    protectKernelImage = true;
    
    # Trusted Platform Module support
    tpm2 = {
      enable = true;
      abrmd.enable = true;
    };
    
    # AIDE file integrity monitoring
    aide = {
      enable = true;
      settings = {
        database = "/var/lib/aide/aide.db";
        database_out = "/var/lib/aide/aide.db.new";
        report_url = "stdout";
        gzip_dbout = false;
      };
    };
    
    # Stricter SSH defaults
    ssh = {
      permitRootLogin = "no";
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowGroups ssh-users admins
        LoginGraceTime 30
        MaxAuthTries 3
        AuthenticationMethods publickey
        X11Forwarding no
      '';
    };
    
    # AppArmor for additional application isolation
    apparmor = {
      enable = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    
    # Linux Security Modules
    audit.enable = true;
    auditd.enable = true;
  };
  
  # Add security-oriented kernel parameters
  boot.kernel.sysctl = {
    # Protect against SYN flood attacks
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv4.tcp_max_syn_backlog" = 2048;
    "net.ipv4.tcp_synack_retries" = 3;
    
    # Disable packet forwarding
    "net.ipv4.ip_forward" = false;
    
    # Disable source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    
    # Enable ASLR
    "kernel.randomize_va_space" = 2;
    
    # Restrict ptrace scope
    "kernel.yama.ptrace_scope" = 1;
    
    # Prevent unauthorized access to runtime kernel memory
    "kernel.kptr_restrict" = 2;
    
    # Restrict unprivileged access to kernel logs
    "kernel.dmesg_restrict" = 1;
  };
  
  # Mandatory Access Control
  security.polkit.enable = true;
  
  # Firewall with sane defaults
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH only by default
    allowPing = false;
    logRefusedConnections = true;
    logRefusedPackets = true;
    
    # Advanced filtering - use nftables
    extraCommands = ''
      # Rate limit SSH connections
      nft add table inet filter
      nft add chain inet filter input { type filter hook input priority 0 \; }
      nft add rule inet filter input tcp dport 22 limit rate 3/minute counter accept
    '';
  };
  
  # Fail2Ban to protect SSH and other services
  services.fail2ban = {
    enable = true;
    jails = {
      ssh-iptables = ''
        enabled = true
        filter = sshd
        maxretry = 3
        findtime = 600
        bantime = 3600
      '';
    };
  };
  
  # Stricter file permissions
  system.activationScripts.strictPermissions = ''
    chmod 700 /root
    chmod 700 /var/log/journal
    chmod 750 /etc/ssh/keys
  '';
}
```

## Networking Patterns

### Multi-Environment Network Configuration

Manage network configurations across different environments:

```nix
{ config, lib, ... }:

with lib;

let
  # Define environments
  environments = {
    dev = {
      domain = "dev.mycompany.local";
      vpnEnabled = false;
      firewallStrictness = "low";
      internalSubnets = [ "10.0.0.0/8" "172.16.0.0/12" ];
    };
    
    staging = {
      domain = "staging.mycompany.com";
      vpnEnabled = true;
      firewallStrictness = "medium";
      internalSubnets = [ "10.0.0.0/8" "172.16.0.0/12" ];
    };
    
    prod = {
      domain = "mycompany.com";
      vpnEnabled = true;
      firewallStrictness = "high";
      internalSubnets = [ "10.0.0.0/8" "172.16.0.0/12" ];
    };
  };
  
  # Current environment from metadata
  environmentFile = "/etc/nixos/environment";
  currentEnv = 
    if builtins.pathExists environmentFile
    then builtins.readFile environmentFile
    else "dev";
  
  # Get environment settings
  env = environments.${currentEnv};
  
  # Define firewall rules based on strictness
  firewallRules = {
    low = {
      allowedTCPPorts = [ 22 80 443 8080 ];
      allowPing = true;
      logRefusedConnections = false;
    };
    
    medium = {
      allowedTCPPorts = [ 22 80 443 ];
      allowPing = true;
      logRefusedConnections = true;
    };
    
    high = {
      allowedTCPPorts = [ 22 443 ];
      allowPing = false;
      logRefusedConnections = true;
      extraCommands = ''
        # Rate limit all incoming connections
        iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 4 -j ACCEPT
        iptables -A INPUT -p tcp --syn -j DROP
      '';
    };
  };
  
in {
  # Base network configuration
  networking = {
    # Domain based on environment
    domain = env.domain;
    
    # Get DNS configuration based on environment
    nameservers = if currentEnv == "dev"
      then [ "8.8.8.8" "1.1.1.1" ]
      else [ "10.0.0.1" "10.0.0.2" ];
    
    # Firewall configuration based on strictness level
    firewall = firewallRules.${env.firewallStrictness};
    
    # VPN configuration
    wireguard = mkIf env.vpnEnabled {
      enable = true;
      interfaces.wg0 = {
        ips = [ "10.100.0.2/24" ];
        privateKeyFile = "/etc/wireguard/private.key";
        peers = [
          {
            publicKey = "WgVjLc18GbJVtKIZAVF+bBfGXB+NpqIGzFTlnHKGgXs=";
            endpoint = "vpn.${env.domain}:51820";
            allowedIPs = env.internalSubnets;
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
  
  # Environment-specific network settings
  services.nginx.virtualHosts."api.${env.domain}" = {
    enableACME = currentEnv != "dev";
    forceSSL = currentEnv != "dev";
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000"\;
    };
  };
}
```

## Storage and Filesystem Patterns

### Resilient Storage Configuration

Configure storage with reliability in mind:

```nix
{ config, pkgs, lib, ... }:

with lib;

let
  # Environment-specific storage configuration
  storageConfigs = {
    dev = {
      enableRaid = false;
      enableSnapshots = false;
      backupSchedule = "weekly";
      filesystems = [
        { mountPoint = "/var/data"; device = "/dev/vdb1"; fsType = "ext4"; }
      ];
    };
    
    prod = {
      enableRaid = true;
      enableSnapshots = true;
      backupSchedule = "daily";
      filesystems = [
        { mountPoint = "/var/data"; device = "data-volume"; fsType = "btrfs"; }
      ];
    };
  };
  
  # Get current environment
  currentEnv = if builtins.getEnv "NIXOS_ENVIRONMENT" == "" 
    then "dev" 
    else builtins.getEnv "NIXOS_ENVIRONMENT";
  
  # Select storage config
  storage = storageConfigs.${currentEnv};
  
in {
  # RAID configuration for production
  boot.initrd.mdadmConf = mkIf storage.enableRaid ''
    DEVICE partitions
    ARRAY /dev/md0 level=raid1 devices=/dev/sda1,/dev/sdb1
    ARRAY /dev/md1 level=raid1 devices=/dev/sda2,/dev/sdb2
  '';
  
  # LVM configuration
  boot.initrd.luks.devices = mkIf (currentEnv == "prod") {
    encrypted-lvm = {
      device = "/dev/md1";
      preLVM = true;
    };
  };
  
  # ZFS configuration for advanced storage needs
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = mkIf (currentEnv == "prod") [ "datapool" ];
  
  # Define filesystem mounts
  fileSystems = builtins.listToAttrs (map 
    (fs: {
      name = fs.mountPoint;
      value = {
        device = fs.device;
        fsType = fs.fsType;
        options = [
          "defaults"
          "noatime"
        ] ++ optionals (fs.fsType == "btrfs") [
          "compress=zstd"
          "autodefrag"
        ];
      };
    })
    storage.filesystems
  );
  
  # Snapshot configuration
  services.btrfs.autoScrub = mkIf (storage.enableSnapshots && any (fs: fs.fsType == "btrfs") storage.filesystems) {
    enable = true;
    interval = "weekly";
    fileSystems = map (fs: fs.mountPoint) (builtins.filter (fs: fs.fsType == "btrfs") storage.filesystems);
  };
  
  # Backup service configuration
  services.borgbackup.jobs = mkIf (currentEnv == "prod") {
    system-backup = {
      paths = [ "/etc" "/home" "/var" ];
      exclude = [ 
        "/var/cache" 
        "/var/tmp" 
        "/var/lib/docker"
      ];
      repo = "ssh://backup@backup-server/system";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /etc/backup-passphrase";
      };
      compression = "auto,zstd";
      startAt = storage.backupSchedule;
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };
}
```

## Deployment and Upgrade Patterns

### Atomic Upgrades and Rollbacks

Leverage NixOS's atomic upgrade capabilities:

```nix
{ config, pkgs, lib, ... }:

with lib;

{
  # Boot configuration for multiple generations
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Automatic garbage collection to prevent disk space issues
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # Keep important system generations for emergency rollbacks
  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "04:00";
    };
    flags = [
      "--no-build-output"
      "--keep-going"
    ];
    channel = "https://nixos.org/channels/nixos-23.05"\;
  };
  
  # Custom pre/post upgrade actions
  system.activationScripts = {
    preUpgrade = {
      deps = [ "users" "groups" ];
      text = ''
        echo "Running pre-upgrade tasks at $(date)" >> /var/log/nixos-upgrade.log
        
        # Take database backups before upgrade
        if systemctl is-active postgresql; then
          echo "Backing up PostgreSQL databases" >> /var/log/nixos-upgrade.log
          sudo -u postgres pg_dumpall > /var/backups/pg_dump_$(date +%Y%m%d).sql
        fi
        
        # Notify monitoring system about upgrade
        curl -X POST https://monitoring.example.com/api/v1/events \
          -d '{"title": "NixOS upgrade starting", "host": "'$(hostname)'"}' \
          -H 'Content-Type: application/json'
      '';
    };
    
    postUpgrade = {
      deps = [ "specialfs" ];
      text = ''
        echo "Running post-upgrade tasks at $(date)" >> /var/log/nixos-upgrade.log
        
        # Check service health after upgrade
        for service in nginx postgresql redis; do
          if ! systemctl is-active $service; then
            echo "Service $service failed to start after upgrade" >> /var/log/nixos-upgrade.log
            
            # Attempt automatic rollback for critical services
            if [[ "$service" =~ ^(postgresql|nginx)$ ]]; then
              echo "Critical service $service is down, attempting rollback" >> /var/log/nixos-upgrade.log
              /run/current-system/sw/bin/switch-to-configuration boot
              exit 1
            fi
          fi
        done
        
        # Notify monitoring system about upgrade completion
        curl -X POST https://monitoring.example.com/api/v1/events \
          -d '{"title": "NixOS upgrade completed", "host": "'$(hostname)'"}' \
          -H 'Content-Type: application/json'
      '';
    };
  };
  
  # Create a rollback script for administrators
  environment.systemPackages = [
    (pkgs.writeScriptBin "system-rollback" ''
      #!/bin/sh
      set -e
      
      # Show available generations
      echo "Available system generations:"
      sudo nix-env -p /nix/var/nix/profiles/system --list-generations
      
      echo ""
      echo "Enter generation number to roll back to, or Ctrl+C to abort:"
      read generation
      
      if [[ "$generation" =~ ^[0-9]+$ ]]; then
        echo "Rolling back to generation $generation..."
        sudo nix-env -p /nix/var/nix/profiles/system --switch-generation $generation
        sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
        echo "Rollback complete. Please reboot to fully apply changes."
      else
        echo "Invalid generation number."
        exit 1
      fi
    '')
  ];
}
```

## Infrastructure as Code Integration

### Terraform Integration

Use NixOS to provision and configure cloud resources:

```nix
{ config, pkgs, lib, ... }:

with lib;

let
  # Import Terraform outputs
  tfOutputs = 
    if builtins.pathExists "/etc/nixos/terraform-outputs.json"
    then builtins.fromJSON (builtins.readFile "/etc/nixos/terraform-outputs.json")
    else {};
    
  # Extract values with safe defaults
  region = tfOutputs.region or "us-west-2";
  dbHost = tfOutputs.db_host or "localhost";
  dbPort = tfOutputs.db_port or 5432;
  redisHost = tfOutputs.redis_host or "localhost";
  redisPort = tfOutputs.redis_port or 6379;
  vpcCidr = tfOutputs.vpc_cidr or "10.0.0.0/16";
  
  # Define environment from Terraform workspace
  environment = tfOutputs.environment or "dev";
  
in {
  # Network configuration based on Terraform-managed VPC
  networking = {
    # Set domain based on environment
    domain = "${environment}.example.com";
    
    # Configure firewall to allow internal VPC traffic
    firewall.extraCommands = ''
      # Allow all traffic from VPC CIDR
      iptables -A INPUT -s ${vpcCidr} -j ACCEPT
    '';
  };
  
  # Application configuration using Terraform outputs
  services.myapp = {
    enable = true;
    databaseUrl = "postgresql://myapp@${dbHost}:${toString dbPort}/myapp";
    redisUrl = "redis://${redisHost}:${toString redisPort}/0";
    
    # Scale based on instance type
    workers = 
      if tfOutputs.instance_type or "" == "t3.micro" then 2
      else if tfOutputs.instance_type or "" == "t3.small" then 4
      else if tfOutputs.instance_type or "" == "t3.medium" then 8
      else 2;
  };
  
  # Create service discovery script for Terraform-managed resources
  environment.systemPackages = [
    (pkgs.writeScriptBin "tf-resources" ''
      #!/bin/sh
      cat << EOF
      Terraform-Managed Resources:
        Region: ${region}
        Environment: ${environment}
        Database: ${dbHost}:${toString dbPort}
        Redis: ${redisHost}:${toString redisPort}
        VPC CIDR: ${vpcCidr}
        Instance Type: ${tfOutputs.instance_type or "unknown"}
      EOF
    '')
  ];
  
  # Set up instance monitoring based on Terraform configuration
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" "filesystem" ];
      port = 9100;
    };
    
    # Push metrics to managed Prometheus if configured
    pushgateway = mkIf (tfOutputs.prometheus_endpoint or "" != "") {
      enable = true;
      web.listen-address = ":9091";
    };
  };
  
  # Set up log shipping to centralized logging
  services.journald.extraConfig = mkIf (tfOutputs.logs_endpoint or "" != "") ''
    ForwardToSyslog=yes
    ForwardToWall=no
  '';
  
  services.rsyslogd = mkIf (tfOutputs.logs_endpoint or "" != "") {
    enable = true;
    extraConfig = ''
      # Send logs to central logging service
      *.* action(type="omfwd" target="${tfOutputs.logs_endpoint}" port="514" protocol="tcp")
    '';
  };
}
```

## Monitoring and Observability Patterns

### Comprehensive System Monitoring

Set up robust monitoring for system health:

```nix
{ config, pkgs, lib, ... }:

with lib;

let
  # Define monitoring targets based on environment
  monitoringConfig = {
    dev = {
      prometheusRetention = "1d";
      scrapeInterval = "30s";
      alertingEnabled = false;
      diskAlertThreshold = 95;
      grafanaAdminPassword = "admin";
    };
    
    prod = {
      prometheusRetention = "30d";
      scrapeInterval = "15s";
      alertingEnabled = true;
      diskAlertThreshold = 85;
      grafanaAdminPassword = "please-change-me";
    };
  };
  
  # Get current environment
  environment = if builtins.getEnv "NIXOS_ENVIRONMENT" == "" 
    then "dev" 
    else builtins.getEnv "NIXOS_ENVIRONMENT";
  
  # Select monitoring config
  monitoring = monitoringConfig.${environment};
  
in {
  # Prometheus for metrics collection
  services.prometheus = {
    enable = true;
    
    # Configure retention and scrape intervals
    retentionTime = monitoring.prometheusRetention;
    globalConfig = {
      scrape_interval = monitoring.scrapeInterval;
      evaluation_interval = "30s";
    };
    
    # Enable built-in exporters
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ 
          "cpu" "diskstats" "filesystem" "loadavg" 
          "meminfo" "netdev" "stat" "time" "vmstat" 
        ];
      };
      
      systemd = {
        enable = true;
      };
      
      blackbox = {
        enable = true;
        configFile = pkgs.writeText "blackbox-exporter.yaml" ''
          modules:
            http_2xx:
              prober: http
              timeout: 5s
              http:
                valid_http_versions: ["HTTP/1.1", "HTTP/2"]
                valid_status_codes: [200]
                method: GET
        '';
      };
    };
    
    # Scrape configs
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "systemd";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.systemd.port}" ];
        }];
      }
      {
        job_name = "blackbox";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [{
          targets = [ "https://example.com" "http://localhost:3000" ];
        }];
        relabel_configs = [{
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
        }];
      }
    ];
    
    # Alerting rules
    alerting = mkIf monitoring.alertingEnabled {
      rules = [
        (builtins.toJSON {
          groups = [{
            name = "node-alerts";
            rules = [
              {
                alert = "HighCpuLoad";
                expr = "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80";
                for = "10m";
                labels = {
                  severity = "warning";
                };
                annotations = {
                  summary = "CPU load is high";
                  description = "CPU load on {{ $labels.instance }} has been above 80% for more than 10 minutes.";
                };
              }
              {
                alert = "DiskSpaceLow";
                expr = "100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100) > ${toString monitoring.diskAlertThreshold}";
                for = "5m";
                labels = {
                  severity = "critical";
                };
                annotations = {
                  summary = "Disk space low";
                  description = "Disk usage on {{ $labels.instance }} {{ $labels.mountpoint }} is above ${toString monitoring.diskAlertThreshold}%.";
                };
              }
              {
                alert = "SystemdServiceFailed";
                expr = "node_systemd_unit_state{state=\"failed\"} == 1";
                for = "1m";
                labels = {
                  severity = "critical";
                };
                annotations = {
                  summary = "Systemd service failed";
                  description = "Service {{ $labels.name }} on {{ $labels.instance }} has failed.";
                };
              }
            ];
          }];
        })
      ];
      
      # Alertmanager configuration
      alertmanagers = [{
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.alertmanager.port}" ];
        }];
      }];
    };
    
    # Enable alertmanager
    alertmanager = mkIf monitoring.alertingEnabled {
      enable = true;
      configuration = {
        global = {
          resolve_timeout = "5m";
        };
        
        route = {
          group_by = [ "alertname" "job" ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
          receiver = "email-alerts";
        };
        
        receivers = [
          {
            name = "email-alerts";
            email_configs = [
              {
                to = "alerts@example.com";
                from = "prometheus@${config.networking.hostName}.${config.networking.domain}";
                smarthost = "smtp.example.com:587";
                auth_username = "alerts@example.com";
                auth_password = "$SMTP_PASSWORD"; # Set via environment file
                require_tls = true;
              }
            ];
          }
        ];
      };
    };
  };
  
  # Grafana for metric visualization
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.${config.networking.domain}";
        root_url = "https://grafana.${config.networking.domain}"\;
      };
      
      security = {
        admin_user = "admin";
        admin_password = monitoring.grafanaAdminPassword;
        disable_gravatar = true;
      };
      
      analytics = {
        reporting_enabled = false;
      };
    };
    
    # Provision datasources
    provision = {
      enable = true;
      datasources = {
        settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://localhost:${toString config.services.prometheus.port}"\;
              isDefault = true;
            }
          ];
        };
      };
    };
  };
  
  # Loki for log aggregation
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      
      server = {
        http_listen_port = 3100;
      };
      
      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };
      
      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "boltdb";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "168h";
            };
          }
        ];
      };
      
      storage_config = {
        boltdb = {
          directory = "/var/lib/loki/index";
        };
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
      
      limits_config = {
        enforce_metric_name = false;
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
    };
  };
  
  # Promtail to ship logs to Loki
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      
      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };
      
      clients = [
        {
          url = "http://localhost:${toString config.services.loki.port}/loki/api/v1/push"\;
        }
      ];
      
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
              environment = environment;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "nodename";
            }
          ];
        }
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [ "localhost" ];
              labels = {
                job = "nginx";
                host = config.networking.hostName;
                environment = environment;
                __path__ = "/var/log/nginx/*.log";
              };
            }
          ];
        }
      ];
    };
  };
  
  # Nginx for exposing monitoring UIs
  services.nginx.virtualHosts = {
    "prometheus.${config.networking.domain}" = {
      enableACME = environment == "prod";
      forceSSL = environment == "prod";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.prometheus.port}"\;
        extraConfig = ''
          auth_basic "Prometheus";
          auth_basic_user_file /etc/nginx/.prometheus_htpasswd;
        '';
      };
    };
    
    "grafana.${config.networking.domain}" = {
      enableACME = environment == "prod";
      forceSSL = environment == "prod";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.grafana.settings.server.http_port}"\;
      };
    };
    
    "alertmanager.${config.networking.domain}" = mkIf monitoring.alertingEnabled {
      enableACME = environment == "prod";
      forceSSL = environment == "prod";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.prometheus.alertmanager.port}"\;
        extraConfig = ''
          auth_basic "Alertmanager";
          auth_basic_user_file /etc/nginx/.prometheus_htpasswd;
        '';
      };
    };
  };
  
  # Create HTTP basic auth password
  system.activationScripts.setupMonitoringHttpAuth = ''
    if [ ! -f /etc/nginx/.prometheus_htpasswd ]; then
      mkdir -p /etc/nginx
      ${pkgs.apacheHttpd}/bin/htpasswd -bc /etc/nginx/.prometheus_htpasswd admin "${monitoring.grafanaAdminPassword}" 
      chown nginx:nginx /etc/nginx/.prometheus_htpasswd
      chmod 400 /etc/nginx/.prometheus_htpasswd
    fi
  '';
}
```

## Conclusion

These NixOS configuration patterns help build maintainable and reliable systems for DevOps environments. They leverage NixOS's declarative approach to create consistent, reproducible infrastructure that can easily scale from development to production environments.

By using these patterns, you can develop a standard approach to system configuration that reduces maintenance overhead, improves security, and makes your infrastructure more predictable across all environments.

## Further Resources

- [NixOS Manual: Module System](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules)
- [NixOS Wiki: Configuration Collection](https://nixos.wiki/wiki/Configuration_Collection)
- [Nix Patterns: Practical Designs](https://github.com/nix-community/nix-patterns)
- [NixOS Handbook: Best Practices](https://nixos-handbook.com/)
