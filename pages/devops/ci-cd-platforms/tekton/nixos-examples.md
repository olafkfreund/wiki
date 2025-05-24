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