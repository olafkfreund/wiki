# NixOS Containers

NixOS containers are lightweight virtualization solutions that leverage the Nix package manager's declarative approach. They provide system-level isolation without the overhead of traditional virtual machines.

## Overview

NixOS containers (not to be confused with Docker or OCI containers) are a built-in feature of NixOS that:

- Utilize Linux namespaces for isolation
- Share the kernel with the host system
- Can be defined and managed declaratively through NixOS configuration
- Provide an efficient way to run isolated NixOS systems

## Key Features

- **Declarative Configuration**: Define containers in your NixOS configuration files
- **System-Level Isolation**: Full system isolation similar to VMs, but lighter weight
- **Nix Store Sharing**: Efficient resource usage by sharing the Nix store with the host
- **Seamless Integration**: Direct integration with NixOS tooling and ecosystem
- **Reproducible Environments**: Guaranteed consistency through Nix's deterministic builds

## Setting Up NixOS Containers

### Basic Container Definition

Add to your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # Other system configuration...
  
  containers.mycontainer = {
    config = { config, pkgs, ... }: {
      system.stateVersion = "23.11";
      
      # Container configuration
      services.openssh.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];
      
      # Container packages
      environment.systemPackages = with pkgs; [
        vim
        curl
        htop
      ];
    };
    
    # Container properties
    privateNetwork = true;
    hostAddress = "10.100.0.1";
    localAddress = "10.100.0.2";
    autoStart = true;
  };
}
```

### Container Management Commands

```bash
# Start a container
nixos-container start mycontainer

# Stop a container
nixos-container stop mycontainer

# Execute commands in a container
nixos-container run mycontainer -- command-to-run

# Get a shell in a container
nixos-container root-login mycontainer

# List all containers
nixos-container list

# Create an imperative container (without config file)
nixos-container create newcontainer

# Destroy a container
nixos-container destroy mycontainer
```

## Container Configuration Options

### Networking

```nix
containers.mycontainer = {
  # Private virtual Ethernet connection
  privateNetwork = true;
  
  # Host side of the Ethernet pair
  hostAddress = "10.0.0.1";
  
  # Container side of the Ethernet pair
  localAddress = "10.0.0.2";
  
  # Forward specific host ports to container
  forwardPorts = [
    { hostPort = 8080; containerPort = 80; protocol = "tcp"; }
  ];
  
  # Use the host's network namespace
  # privateNetwork = false;
};
```

### Resource Limits

```nix
containers.mycontainer = {
  # Set CPU limits
  config = { config, pkgs, ... }: {
    systemd.slices.container.sliceConfig = {
      CPUQuota = "50%";  # Limit to 50% CPU
    };
  };
  
  # Memory limits can be set via the host's systemd configuration
  extraFlags = [ "--memory-limit=1G" ];
};
```

### Bindmounts and Storage

```nix
containers.mycontainer = {
  # Bind mount host directories to container
  bindMounts = {
    "/host/data" = {
      hostPath = "/path/on/host";
      isReadOnly = false;
    };
  };
  
  # You can also use ephemeralRootfs for temporary containers
  ephemeralRootfs = true;
};
```

## Differences from OCI Containers

NixOS containers differ from Docker/OCI containers in several ways:

| Feature | NixOS Containers | OCI (Docker) Containers |
|---------|------------------|-------------------------|
| Isolation | System-level, full NixOS environment | Process-level isolation |
| Configuration | Declarative Nix expressions | Dockerfile or docker-compose |
| Init System | systemd (full init) | Usually simple PID 1 processes |
| Packaging | Nix packages | Container images with layers |
| Network | Various networking options | Docker bridge, host, overlay networks |
| Portability | NixOS specific | Run on any system with OCI runtime |

## Best Practices

- Use ephemeralRootfs for short-lived, immutable containers
- Define clear resource limits to avoid host resource contention
- Use bindMounts for persistent data
- Leverage Nix expressions for container reusability

## Advanced Features

### Accessing the Container

```bash
# Get an interactive shell
nixos-container root-login mycontainer

# Attach to container console
machinectl shell mycontainer  # Containers integrate with systemd-machined
```

### Container Updates

```bash
# Update the container after configuration changes
nixos-rebuild switch

# Rebuild a specific container
nixos-container update mycontainer
```

## Related Tools

- **nixos2container**: Convert NixOS configurations to OCI containers
- **nix2container**: Build OCI images from Nix expressions
- **nixery**: On-demand container generation service for Nix

## Resources

- [NixOS Manual: Containers](https://nixos.org/manual/nixos/stable/#ch-containers)
- [NixOS Wiki: NixOS Containers](https://nixos.wiki/wiki/NixOS_Containers)
- [Nix.dev Tutorials](https://nix.dev/)