# Installing Gemini on NixOS

This guide covers setting up Google Gemini on NixOS, a purely functional Linux distribution that offers reproducible system configurations through the Nix package manager.

## Advantages of NixOS for Gemini Deployments

NixOS provides several benefits for DevOps professionals working with AI tools like Gemini:

- **Reproducible environments**: Identical deployment across all systems
- **Declarative configuration**: System configuration as code
- **Isolated dependencies**: Prevent conflicts between different Python versions or libraries
- **Rollbacks**: Easy recovery if something breaks
- **Development shells**: Isolated environments for different AI projects

## Installation Methods

### Method 1: Using Nix Flakes (Recommended)

[Nix Flakes](https://nixos.wiki/wiki/Flakes) provide a modern, reproducible approach to Nix packages.

1. First, ensure flakes are enabled in your NixOS configuration:

```nix
# In your configuration.nix
{ pkgs, ... }: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
```

2. Create a new flake for your Gemini project:

```bash
mkdir -p ~/projects/gemini-devops
cd ~/projects/gemini-devops
```

3. Create a `flake.nix` file:

```nix
{
  description = "Gemini AI Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;
        pythonEnv = python.withPackages (ps: with ps; [
          google-generativeai
          google-cloud-aiplatform
          jupyter
          pandas
          matplotlib
          pygments
          (
            buildPythonPackage rec {
              pname = "notebookml";
              version = "0.4.0";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; # Replace with actual hash
              };
              doCheck = false;
              propagatedBuildInputs = [ ps.jupyter ps.pandas ];
            }
          )
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            google-cloud-sdk
          ];
          
          shellHook = ''
            export PYTHONPATH=${pythonEnv}/${python.sitePackages}:$PYTHONPATH
            export PATH=${pythonEnv}/bin:$PATH
            echo "Gemini development environment activated!"
          '';
        };
      }
    );
}
```

4. Enter the development shell:

```bash
nix develop
```

### Method 2: Using configuration.nix (System-wide)

Add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python311.withPackages (ps: with ps; [
      pip
      google-generativeai
      google-cloud-aiplatform
      jupyter
      # Other packages you need
    ]))
    google-cloud-sdk
  ];
}
```

Then rebuild your system:

```bash
sudo nixos-rebuild switch
```

### Method 3: Using nix-shell (Project-specific)

Create a `shell.nix` file in your project directory:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  python = pkgs.python311;
  pythonEnv = python.withPackages (ps: with ps; [
    google-generativeai
    google-cloud-aiplatform
    jupyter
    pandas
    # Other packages you need
  ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    pythonEnv
    google-cloud-sdk
  ];
  
  shellHook = ''
    export PYTHONPATH=${pythonEnv}/${python.sitePackages}:$PYTHONPATH
    export GOOGLE_API_KEY="YOUR_API_KEY_HERE"  # Only for development!
  '';
}
```

Activate it with:

```bash
nix-shell
```

## Authentication Configuration

### Managing API Keys Securely with NixOS

For development, use environment variables:

```nix
# In your shell.nix
shellHook = ''
  # Load from a file not in version control
  export GOOGLE_API_KEY=$(cat ~/.config/gemini/api-key)
'';
```

For system-wide deployment, use NixOS secrets management:

```nix
{ config, ... }:

{
  age.secrets.gemini-api-key = {
    file = ./secrets/gemini-api-key.age;
    owner = "your-service-user";
  };
  
  systemd.services.your-gemini-service = {
    description = "Gemini AI Service";
    environment = {
      GOOGLE_API_KEY = "!cat ${config.age.secrets.gemini-api-key.path}";
    };
    # Service configuration continues...
  };
}
```

## Service Integration

### Creating a Gemini Service with systemd in NixOS

```nix
# In configuration.nix
{ config, pkgs, ... }:

{
  systemd.services.gemini-agent = {
    description = "Gemini AI Agent Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "gemini-service";
      WorkingDirectory = "/var/lib/gemini-agent";
      ExecStart = "${pkgs.python311.withPackages (ps: with ps; [google-generativeai])}/bin/python /var/lib/gemini-agent/agent.py";
      Restart = "on-failure";
    };
    
    environment = {
      # Use agenix or similar for production secrets
      GOOGLE_API_KEY = "!cat /run/secrets/gemini-api-key";
    };
  };

  users.users.gemini-service = {
    isSystemUser = true;
    group = "gemini-service";
    home = "/var/lib/gemini-agent";
    createHome = true;
  };
  
  users.groups.gemini-service = {};
}
```

## Verification & Testing

Test your setup with a simple script:

```python
#!/usr/bin/env python
import google.generativeai as genai
import os

# Configure the API key
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Test the API with a NixOS-related prompt
model = genai.GenerativeModel('gemini-pro')
result = model.generate_content("Explain how Nix's reproducibility benefits DevOps teams.")

print(result.text)
```

Save as `test.py` and run:

```bash
chmod +x test.py
./test.py
```