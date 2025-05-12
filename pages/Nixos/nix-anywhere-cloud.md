---
description: Deploying NixOS to AWS, GCP, and Azure with nix-anywhere
---

# Deploying NixOS to Cloud Platforms with nix-anywhere

nix-anywhere is a powerful tool for deploying NixOS systems to remote machines. This guide shows how to use it for provisioning NixOS on major cloud platforms: AWS, GCP, and Azure.

## What is nix-anywhere?

nix-anywhere is a tool that lets you deploy NixOS configurations to any machine with SSH access. It has several advantages for cloud deployments:

- **No NixOS Required**: Target machines only need a Linux kernel and SSH access
- **Safe Upgrades**: Atomic upgrades with automatic rollback on failure
- **Simple Deployment**: Single command to deploy your configuration
- **Infrastructure as Code**: Fully declarative configuration of your cloud instances
- **Multi-Platform**: Works with any cloud provider

## Prerequisites

1. Install Nix with flakes enabled
   ```bash
   # Install Nix if you haven't already
   sh <(curl -L https://nixos.org/nix/install) --daemon
   
   # Enable flakes (add to ~/.config/nix/nix.conf)
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. Install cloud provider CLI tools
   ```bash
   # For AWS
   nix-env -i awscli2
   
   # For GCP
   nix-env -i google-cloud-sdk
   
   # For Azure
   nix-env -i azure-cli
   ```

## Setup Project Structure

Create a project directory with the following structure:

```
nixos-cloud-deploy/
├── flake.nix
├── hosts/
│   ├── aws.nix
│   ├── gcp.nix
│   └── azure.nix
└── modules/
    └── cloud-config.nix
```

## Base flake.nix

```nix
{
  description = "NixOS Cloud Deployment with nix-anywhere";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-anywhere, ... }: {
    nixosConfigurations = {
      aws-instance = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/aws.nix ];
      };
      
      gcp-instance = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/gcp.nix ];
      };
      
      azure-instance = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; 
        modules = [ ./hosts/azure.nix ];
      };
    };
  };
}
```

## AWS Deployment

### 1. Create the AWS host configuration file

Create the file `hosts/aws.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/cloud-config.nix
  ];
  
  # System configuration
  system.stateVersion = "23.11";
  
  # AWS-specific configuration
  boot.loader.grub.device = lib.mkForce "/dev/nvme0n1";
  fileSystems."/" = { 
    device = "/dev/nvme0n1p1";
    fsType = "ext4";
  };
  
  # Networking
  networking = {
    hostName = "nixos-aws";
    networkmanager.enable = true;
  };
  
  # User configuration
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3..." # Replace with your SSH public key
    ];
    initialPassword = "changeme";
  };
  
  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  
  # AWS specific packages
  environment.systemPackages = with pkgs; [
    aws-cli-v2
    ec2-instance-connect
  ];
}
```

### 2. Provision an EC2 instance

```bash
# Create an EC2 instance with Amazon Linux 2 (minimum req)
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --key-name your-key-name \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=nixos-instance}]'
```

### 3. Deploy NixOS with nix-anywhere

```bash
# Get your instance IP
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nixos-instance" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text)

# Deploy using nix-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake .#aws-instance \
  root@$INSTANCE_IP \
  --build-on-remote \
  --password-prompt
```

## GCP Deployment

### 1. Create the GCP host configuration file

Create the file `hosts/gcp.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/cloud-config.nix
  ];
  
  # System configuration
  system.stateVersion = "23.11";
  
  # GCP-specific configuration
  boot.loader.grub.device = lib.mkForce "/dev/sda";
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  
  # Networking
  networking = {
    hostName = "nixos-gcp";
    networkmanager.enable = true;
  };
  
  # User configuration
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3..." # Replace with your SSH public key
    ];
    initialPassword = "changeme";
  };
  
  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  
  # GCP specific packages
  environment.systemPackages = with pkgs; [
    google-cloud-sdk
  ];
}
```

### 2. Provision a GCP Instance

```bash
# Create a VM instance with Debian
gcloud compute instances create nixos-instance \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --machine-type=e2-medium \
  --zone=us-central1-a \
  --metadata="ssh-keys=admin:$(cat ~/.ssh/id_ed25519.pub)"
```

### 3. Deploy NixOS with nix-anywhere

```bash
# Get your instance IP
INSTANCE_IP=$(gcloud compute instances describe nixos-instance \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Deploy using nix-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake .#gcp-instance \
  root@$INSTANCE_IP \
  --build-on-remote \
  --password-prompt
```

## Azure Deployment

### 1. Create the Azure host configuration file

Create the file `hosts/azure.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/cloud-config.nix
  ];
  
  # System configuration
  system.stateVersion = "23.11";
  
  # Azure-specific configuration
  boot.loader.grub.device = lib.mkForce "/dev/sda";
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  
  # Networking
  networking = {
    hostName = "nixos-azure";
    networkmanager.enable = true;
  };
  
  # User configuration
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3..." # Replace with your SSH public key
    ];
    initialPassword = "changeme";
  };
  
  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  
  # Azure specific packages
  environment.systemPackages = with pkgs; [
    azure-cli
  ];
}
```

### 2. Provision an Azure VM

```bash
# Set variables
RESOURCE_GROUP="nixos-rg"
VM_NAME="nixos-vm"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create VM with Ubuntu (minimum req)
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys
```

### 3. Deploy NixOS with nix-anywhere

```bash
# Get your instance IP
INSTANCE_IP=$(az vm show -d \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --query publicIps \
  --output tsv)

# Deploy using nix-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake .#azure-instance \
  azureuser@$INSTANCE_IP \
  --build-on-remote \
  --password-prompt
```

## Common Modules: cloud-config.nix

Create a shared configuration file in `modules/cloud-config.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  # Common cloud configuration for all instances
  
  # Base packages for all instances
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    tmux
    jq
  ];
  
  # Security settings
  security.sudo.wheelNeedsPassword = false;
  
  # Auto-upgrade settings
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };
  
  # Timezone and locale settings
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Automatically collect garbage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## Advanced Usage

### Automatic Rollback on Failure

nix-anywhere automatically attempts to roll back if the system can't boot after a deployment. You can configure this behavior with:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#aws-instance \
  root@$INSTANCE_IP \
  --build-on-remote \
  --rollback-reboot-timeout 5m \
  --password-prompt
```

### CI/CD Pipeline Integration

For GitOps-style deployments, you can integrate nix-anywhere in a CI/CD pipeline:

```yaml
# Example GitHub Action
name: Deploy NixOS to Cloud

on:
  push:
    branches: [ main ]
    paths:
      - 'flake.nix'
      - 'hosts/**'
      - 'modules/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Nix
        uses: cachix/install-nix-action@v20
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      
      - name: Deploy to AWS
        run: |
          echo "${{ secrets.SSH_KEY }}" > id_ed25519
          chmod 600 id_ed25519
          nix run github:nix-community/nixos-anywhere -- \
            --flake .#aws-instance \
            --ssh-key ./id_ed25519 \
            root@${{ secrets.AWS_INSTANCE_IP }} \
            --build-on-remote
```

## Troubleshooting

1. **SSH Connection Issues**
   - Ensure the security groups (AWS), firewall rules (GCP), or network security groups (Azure) allow SSH access on port 22
   - Verify your SSH key is correctly added to the authorized_keys list

2. **Disk Device Name Differences**
   - Cloud providers may use different device names. AWS NVMe is usually `/dev/nvme0n1`, GCP generally uses `/dev/sda`, Azure may use `/dev/sda` or `/dev/sdb`
   - Run `lsblk` after connecting via SSH to determine the correct device name

3. **Deployment Timeouts**
   - Increase the timeout for large deployments:
     ```bash
     nix run github:nix-community/nixos-anywhere -- \
       --flake .#aws-instance \
       --build-on-remote \
       --kexec-timeout 5m \
       root@$INSTANCE_IP
     ```

## References

- [NixOS Anywhere GitHub](https://github.com/nix-community/nixos-anywhere)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)
- [GCP Compute Engine Documentation](https://cloud.google.com/compute/docs/quickstart-linux)
- [Azure VMs Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-cli)