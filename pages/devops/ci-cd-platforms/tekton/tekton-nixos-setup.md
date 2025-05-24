# Tekton on NixOS: Complete Setup Guide (2025)

This comprehensive guide demonstrates how to configure and automate Tekton deployment on NixOS using declarative configuration management. NixOS's unique approach allows us to define the entire Tekton infrastructure as code, ensuring reproducible and maintainable CI/CD environments.

## Why NixOS for Tekton?

NixOS provides several advantages for Tekton deployments:

- **Declarative Configuration**: Define your entire Tekton stack in configuration files
- **Reproducibility**: Identical deployments across environments
- **Rollback Capability**: Easy system rollbacks if configurations fail
- **Package Management**: Integrated package management with Nix
- **Immutable Infrastructure**: System state is predictable and consistent

## Prerequisites

Before starting, ensure you have:

1. **NixOS 23.11+** installed and configured
2. **Root/sudo access** for system configuration changes
3. **Internet connectivity** for downloading Tekton components
4. **Basic NixOS knowledge** (understanding of `/etc/nixos/configuration.nix`)

## Complete NixOS Configuration Example

Below is a complete NixOS configuration that automatically sets up Tekton with all required components:

```nix
{ config, pkgs, lib, ... }:

let
  # Tekton versions (2025)
  tektonPipelinesVersion = "v0.55.0";
  tektonTriggersVersion = "v0.26.0";
  tektonDashboardVersion = "v0.40.0";
  tektonCLIVersion = "v0.35.0";
  
  # Custom Tekton installer script
  tektonInstaller = pkgs.writeShellScriptBin "install-tekton" ''
    #!/bin/bash
    set -euo pipefail
    
    echo "Installing Tekton Pipelines ${tektonPipelinesVersion}..."
    ${pkgs.kubectl}/bin/kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/${tektonPipelinesVersion}/release.yaml
    
    echo "Installing Tekton Triggers ${tektonTriggersVersion}..."
    ${pkgs.kubectl}/bin/kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/${tektonTriggersVersion}/release.yaml
    ${pkgs.kubectl}/bin/kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/${tektonTriggersVersion}/interceptors.yaml
    
    echo "Installing Tekton Dashboard ${tektonDashboardVersion}..."
    ${pkgs.kubectl}/bin/kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/${tektonDashboardVersion}/release.yaml
    
    echo "Waiting for Tekton components to be ready..."
    ${pkgs.kubectl}/bin/kubectl wait --for=condition=ready pod --all -n tekton-pipelines --timeout=300s
    ${pkgs.kubectl}/bin/kubectl wait --for=condition=ready pod --all -n tekton-pipelines-resolvers --timeout=300s
    
    echo "Installing Tekton Hub tasks..."
    ${pkgs.tkn}/bin/tkn hub install task git-clone
    ${pkgs.tkn}/bin/tkn hub install task kaniko
    
    echo "Tekton installation completed successfully!"
  '';

  # Tekton cluster setup script
  tektonClusterSetup = pkgs.writeShellScriptBin "setup-tekton-cluster" ''
    #!/bin/bash
    set -euo pipefail
    
    # Create local k3s cluster if not exists
    if ! ${pkgs.kubectl}/bin/kubectl cluster-info &> /dev/null; then
      echo "Setting up local Kubernetes cluster with k3s..."
      sudo ${pkgs.k3s}/bin/k3s server --disable traefik --write-kubeconfig-mode 644 &
      sleep 30
      
      export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
      echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
    fi
    
    # Install Tekton
    ${tektonInstaller}/bin/install-tekton
    
    # Setup RBAC for Tekton
    ${pkgs.kubectl}/bin/kubectl apply -f - <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tekton-admin
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: default
      namespace: default
    EOF
    
    # Create development namespace
    ${pkgs.kubectl}/bin/kubectl create namespace tekton-dev --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
    
    echo "Tekton cluster setup completed!"
  '';

  # Tekton pipeline examples generator
  tektonExamples = pkgs.writeShellScriptBin "generate-tekton-examples" ''
    #!/bin/bash
    set -euo pipefail
    
    EXAMPLES_DIR="$HOME/tekton-examples"
    mkdir -p "$EXAMPLES_DIR"
    
    # Generate security scanning pipeline
    cat > "$EXAMPLES_DIR/security-pipeline.yaml" <<'EOF'
    apiVersion: tekton.dev/v1beta1
    kind: Pipeline
    metadata:
      name: secure-build-pipeline
      namespace: tekton-dev
    spec:
      params:
      - name: repo-url
        type: string
        default: "https://github.com/your-org/your-app.git"
      - name: image-reference
        type: string
        default: "registry.local/your-app:latest"
      workspaces:
      - name: shared-data
      - name: docker-credentials
      tasks:
      - name: fetch-source
        taskRef:
          name: git-clone
          kind: ClusterTask
        workspaces:
        - name: output
          workspace: shared-data
        params:
        - name: url
          value: $(params.repo-url)
      - name: security-scan
        runAfter: ["fetch-source"]
        taskSpec:
          workspaces:
          - name: source
          steps:
          - name: trivy-scan
            image: aquasec/trivy:latest
            workingDir: $(workspaces.source.path)
            script: |
              #!/bin/sh
              trivy fs --security-checks vuln,secret,config .
      - name: build-push
        runAfter: ["security-scan"]
        taskRef:
          name: kaniko
          kind: ClusterTask
        workspaces:
        - name: source
          workspace: shared-data
        - name: dockerconfig
          workspace: docker-credentials
        params:
        - name: IMAGE
          value: $(params.image-reference)
    EOF
    
    # Generate PipelineRun
    cat > "$EXAMPLES_DIR/security-pipelinerun.yaml" <<'EOF'
    apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      generateName: secure-build-run-
      namespace: tekton-dev
    spec:
      pipelineRef:
        name: secure-build-pipeline
      workspaces:
      - name: shared-data
        volumeClaimTemplate:
          spec:
            accessModes:
            - ReadWriteOnce
            resources:
              requests:
                storage: 2Gi
      - name: docker-credentials
        secret:
          secretName: docker-credentials
    EOF
    
    echo "Tekton examples generated in $EXAMPLES_DIR"
  '';

in {
  # Enable container runtime
  virtualisation.docker.enable = true;
  virtualisation.containerd.enable = true;
  
  # Install required packages
  environment.systemPackages = with pkgs; [
    # Kubernetes tools
    kubectl
    kubernetes-helm
    k3s
    
    # Tekton CLI
    tkn
    
    # Container tools
    docker
    docker-compose
    buildah
    skopeo
    
    # Security tools
    cosign
    trivy
    
    # Development tools
    git
    curl
    jq
    yq-go
    
    # Custom scripts
    tektonInstaller
    tektonClusterSetup
    tektonExamples
  ];
  
  # Enable required services
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--disable=traefik"
      "--write-kubeconfig-mode=644"
    ];
  };
  
  # Configure user groups
  users.users.${config.users.users.olafkfreund.name or "olafkfreund"} = {
    extraGroups = [ "docker" "wheel" ];
  };
  
  # Environment variables
  environment.variables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    TEKTON_VERSION = tektonPipelinesVersion;
  };
  
  # Systemd service for automatic Tekton setup
  systemd.services.tekton-setup = {
    description = "Automated Tekton Setup";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${tektonClusterSetup}/bin/setup-tekton-cluster";
      User = "root";
    };
    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      PATH = lib.makeBinPath [ pkgs.kubectl pkgs.tkn ];
    };
  };
  
  # Auto-enable the service
  systemd.services.tekton-setup.wantedBy = [ "multi-user.target" ];
}
```

## Configuration Breakdown

### 1. Version Management

```nix
tektonPipelinesVersion = "v0.55.0";
tektonTriggersVersion = "v0.26.0";
tektonDashboardVersion = "v0.40.0";
tektonCLIVersion = "v0.35.0";
```

**Purpose**: Centralized version management ensures consistency across all Tekton components and makes upgrades manageable.

### 2. Custom Installation Scripts

The configuration creates three custom scripts:

#### `tektonInstaller`
- Installs Tekton Pipelines, Triggers, and Dashboard
- Waits for pods to be ready
- Installs essential tasks from Tekton Hub

#### `tektonClusterSetup`
- Sets up k3s cluster if needed
- Installs Tekton components
- Configures RBAC permissions
- Creates development namespace

#### `tektonExamples`
- Generates example pipelines for testing
- Creates security-focused pipeline templates
- Provides PipelineRun examples

### 3. Package Installation

```nix
environment.systemPackages = with pkgs; [
  kubectl kubernetes-helm k3s tkn
  docker docker-compose buildah skopeo
  cosign trivy
  git curl jq yq-go
  tektonInstaller tektonClusterSetup tektonExamples
];
```

**Includes**:
- **Kubernetes tools**: kubectl, helm, k3s
- **Tekton CLI**: tkn for pipeline management
- **Container tools**: Docker, Buildah, Skopeo for image handling
- **Security tools**: Cosign for signing, Trivy for scanning
- **Development tools**: Git, curl, jq for general development

### 4. Service Configuration

```nix
services.k3s = {
  enable = true;
  role = "server";
  extraFlags = [
    "--disable=traefik"
    "--write-kubeconfig-mode=644"
  ];
};
```

**Configuration**:
- Enables k3s as a systemd service
- Disables Traefik (using Tekton's built-in ingress)
- Sets kubeconfig permissions for user access

### 5. Automated Setup

```nix
systemd.services.tekton-setup = {
  description = "Automated Tekton Setup";
  after = [ "k3s.service" ];
  wants = [ "k3s.service" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = "${tektonClusterSetup}/bin/setup-tekton-cluster";
    User = "root";
  };
};
```

**Features**:
- Runs after k3s service starts
- One-time execution with persistent state
- Automatic Tekton installation on system boot

## Installation Steps

### 1. Create Configuration File

Save the complete configuration as `/etc/nixos/tekton.nix`:

```bash
sudo nano /etc/nixos/tekton.nix
# Paste the complete configuration above
```

### 2. Import in Main Configuration

Edit your main NixOS configuration:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add the import:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./tekton.nix  # Add this line
  ];
  
  # ...existing configuration...
}
```

### 3. Rebuild System

Apply the new configuration:

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch

# Verify services are running
systemctl status k3s
systemctl status tekton-setup
```

### 4. Verify Installation

Check that Tekton is properly installed:

```bash
# Check cluster status
kubectl cluster-info

# Verify Tekton pods
kubectl get pods -n tekton-pipelines

# Test Tekton CLI
tkn version

# Generate example pipelines
generate-tekton-examples
```

## Post-Installation Configuration

### 1. Configure Docker Registry Access

Create Docker credentials for private registries:

```bash
# Create secret for Docker Hub
kubectl create secret docker-registry docker-credentials \
  --docker-server=docker.io \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@example.com

# For other registries (ECR, GCR, ACR)
kubectl create secret docker-registry registry-credentials \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-token
```

### 2. Set Up Image Signing

Configure Cosign for image signing:

```bash
# Generate signing keys
cosign generate-key-pair

# Create Kubernetes secret
kubectl create secret generic cosign-keys \
  --from-file=cosign.key=cosign.key \
  --from-file=cosign.pub=cosign.pub
```

### 3. Access Tekton Dashboard

Forward the dashboard port to access the web UI:

```bash
# Forward dashboard port
kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097

# Access at http://localhost:9097
```

## Advanced Configuration Options

### 1. Custom Resource Limits

Add resource limits for production environments:

```nix
# Add to tekton.nix
systemd.services.tekton-resource-limits = {
  description = "Apply Tekton Resource Limits";
  after = [ "tekton-setup.service" ];
  wants = [ "tekton-setup.service" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = pkgs.writeScript "apply-limits" ''
      #!/bin/bash
      kubectl patch deployment tekton-pipelines-controller -n tekton-pipelines -p '{"spec":{"template":{"spec":{"containers":[{"name":"tekton-pipelines-controller","resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"100m","memory":"100Mi"}}}]}}}}'
    '';
  };
};
```

### 2. Persistent Storage Configuration

Configure persistent storage for pipeline artifacts:

```nix
# Add storage class configuration
systemd.services.tekton-storage = {
  description = "Configure Tekton Storage";
  after = [ "tekton-setup.service" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = pkgs.writeScript "setup-storage" ''
      kubectl apply -f - <<EOF
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        name: tekton-storage
      provisioner: rancher.io/local-path
      volumeBindingMode: WaitForFirstConsumer
      reclaimPolicy: Delete
      EOF
    '';
  };
};
```

### 3. Monitoring Integration

Add Prometheus monitoring for Tekton:

```nix
# Add monitoring tools
environment.systemPackages = with pkgs; [
  # ...existing packages...
  prometheus
  grafana
];

# Configure Tekton metrics
systemd.services.tekton-monitoring = {
  description = "Enable Tekton Monitoring";
  after = [ "tekton-setup.service" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = pkgs.writeScript "enable-monitoring" ''
      kubectl patch configmap config-observability -n tekton-pipelines --patch '{"data":{"metrics.backend-destination":"prometheus"}}'
    '';
  };
};
```

## Troubleshooting

### Common Issues and Solutions

#### 1. k3s Service Not Starting

```bash
# Check k3s logs
journalctl -u k3s -f

# Restart k3s service
sudo systemctl restart k3s

# Verify cluster
kubectl get nodes
```

#### 2. Tekton Pods Not Ready

```bash
# Check pod status
kubectl get pods -n tekton-pipelines

# Describe failing pods
kubectl describe pod <pod-name> -n tekton-pipelines

# Check events
kubectl get events -n tekton-pipelines --sort-by='.lastTimestamp'
```

#### 3. Permission Issues

```bash
# Check RBAC
kubectl auth can-i '*' '*' --as=system:serviceaccount:default:default

# Apply cluster admin binding
kubectl create clusterrolebinding tekton-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default
```

#### 4. Network Connectivity Issues

```bash
# Test cluster connectivity
kubectl run test-pod --image=busybox --rm -it -- nslookup kubernetes.default

# Check k3s networking
sudo k3s check-config
```

## Maintenance and Updates

### 1. Updating Tekton Versions

Update versions in configuration and rebuild:

```nix
# Edit /etc/nixos/tekton.nix
tektonPipelinesVersion = "v0.56.0";  # Update version
tektonTriggersVersion = "v0.27.0";   # Update version
```

```bash
# Rebuild system
sudo nixos-rebuild switch

# Restart Tekton setup service
sudo systemctl restart tekton-setup
```

### 2. Backup and Recovery

```bash
# Backup Tekton resources
kubectl get pipelines,tasks,pipelineruns -o yaml > tekton-backup.yaml

# Backup persistent volumes
kubectl get pv,pvc -o yaml > storage-backup.yaml

# Restore from backup
kubectl apply -f tekton-backup.yaml
kubectl apply -f storage-backup.yaml
```

### 3. System Rollback

If issues occur, rollback using NixOS generations:

```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or switch to specific generation
sudo /nix/var/nix/profiles/system-42-link/bin/switch-to-configuration switch
```

## Best Practices

### 1. Version Pinning
- Always pin Tekton versions in configuration
- Test updates in development before production
- Keep a compatibility matrix for components

### 2. Resource Management
- Set appropriate resource limits for tasks
- Use node selectors for specific workloads
- Implement proper cleanup policies

### 3. Security
- Regular security scans with Trivy
- Image signing with Cosign
- RBAC principle of least privilege

### 4. Monitoring
- Enable Tekton metrics
- Set up alerts for failed pipelines
- Monitor resource usage trends

This configuration provides a complete, production-ready Tekton setup on NixOS with automated installation, security features, and maintenance tools. The declarative approach ensures reproducible deployments and easy management of your CI/CD infrastructure.