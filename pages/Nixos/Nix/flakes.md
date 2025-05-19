# Flakes: The Future of Nix

Nix Flakes represent the next evolution in Nix package management, providing a more structured, reproducible approach to managing dependencies. This guide explores how to use Flakes effectively in DevOps workflows.

## What Are Flakes?

Flakes are a Nix feature that provides a standardized approach to:

1. **Dependency Management**: Lock exact versions of dependencies
2. **Composable Configuration**: Create modular, reusable configurations
3. **Reproducible Builds**: Guarantee identical environments every time
4. **Self-Contained Projects**: Define complete development environments

A Flake is defined by a `flake.nix` file and a corresponding `flake.lock` file that pins exact dependency versions.

## Basic Flake Structure

A minimal `flake.nix` file looks like this:

```nix
{
  description = "My project flake";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Additional dependencies
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Development environment
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            yarn
          ];
        };
        
        # Packages
        packages = {
          default = self.packages.${system}.myapp;
          
          myapp = pkgs.stdenv.mkDerivation {
            name = "myapp";
            version = "1.0.0";
            src = ./src;
            
            buildPhase = ''
              # Build commands
            '';
            
            installPhase = ''
              mkdir -p $out/bin
              cp myapp $out/bin/
            '';
          };
        };
        
        # Apps (runnable packages)
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.myapp}/bin/myapp";
        };
      }
    );
}
```

## Flake Inputs and Outputs

### Inputs

The `inputs` section defines external dependencies:

```nix
inputs = {
  # From GitHub
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  
  # From a specific commit
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/5233fd2ba76a3accb05b4104bd6e6dda4061a396";
  
  # From local path
  utils = {
    url = "path:./nix-utils";
    inputs.nixpkgs.follows = "nixpkgs"; # Ensure consistent nixpkgs
  };
  
  # With flake = false for non-flake repos
  legacy-project = {
    url = "github:example/legacy-project";
    flake = false;
  };
}
```

### Outputs

The `outputs` section defines what the flake provides:

```nix
outputs = { self, nixpkgs, ... }:
  let
    # Systems to support
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    
    # Helper to generate per-system outputs
    forAllSystems = nixpkgs.lib.genAttrs systems;
    
    # Package set for each system
    pkgsFor = system: import nixpkgs { inherit system; };
  in {
    # NixOS configurations
    nixosConfigurations = {
      myserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/configuration.nix ];
      };
    };
    
    # Per-system outputs
    packages = forAllSystems (system: {
      default = self.packages.${system}.myapp;
      myapp = (pkgsFor system).callPackage ./pkgs/myapp.nix {};
    });
    
    # Development shells
    devShells = forAllSystems (system: {
      default = (pkgsFor system).mkShell {
        buildInputs = with (pkgsFor system); [ go gopls ];
      };
    });
    
    # Formatter for nix files
    formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);
  };
```

## Using Flakes in DevOps Workflows

### Development Environment Flake

Create consistent development environments across your team:

```nix
{
  description = "Development environment for our microservices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define project-specific variables
        projectName = "acme-services";
        
        # Define common dependencies
        commonDeps = with pkgs; [
          docker-compose
          kubectl
          kubernetes-helm
          jq
          yq
          git
        ];
        
        # Define language-specific dependencies
        goDeps = with pkgs; [ go gopls golangci-lint ];
        nodeDeps = with pkgs; [ nodejs_20 yarn nodePackages.typescript ];
        pythonDeps = with pkgs; [
          (python311.withPackages (ps: with ps; [ 
            pytest 
            requests 
            pyyaml
            black
            mypy
          ]))
        ];
        
      in {
        # Define multiple development shells
        devShells = {
          default = pkgs.mkShell {
            name = "${projectName}-default";
            buildInputs = commonDeps;
            
            shellHook = ''
              echo "${projectName} development environment"
              echo "Run 'nix develop .#backend' for Go development"
              echo "Run 'nix develop .#frontend' for Node.js development"
              echo "Run 'nix develop .#scripts' for Python scripts development"
            '';
          };
          
          # Backend (Go) development shell
          backend = pkgs.mkShell {
            name = "${projectName}-backend";
            buildInputs = commonDeps ++ goDeps;
            
            shellHook = ''
              echo "Backend (Go) development environment ready!"
              export GOPATH=$PWD/.go
              export PATH=$GOPATH/bin:$PATH
              mkdir -p $GOPATH/bin
            '';
          };
          
          # Frontend (Node.js) development shell
          frontend = pkgs.mkShell {
            name = "${projectName}-frontend";
            buildInputs = commonDeps ++ nodeDeps;
            
            shellHook = ''
              echo "Frontend (Node.js) development environment ready!"
              export PATH=$PWD/node_modules/.bin:$PATH
              
              # Set up local node_modules bin directory
              mkdir -p ./.npm-global/bin
              export NPM_CONFIG_PREFIX=$PWD/.npm-global
              export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
              
              # Disable update notifier to keep environment clean
              export NO_UPDATE_NOTIFIER=1
            '';
          };
          
          # Scripts (Python) development shell
          scripts = pkgs.mkShell {
            name = "${projectName}-scripts";
            buildInputs = commonDeps ++ pythonDeps;
            
            shellHook = ''
              echo "Scripts (Python) development environment ready!"
              
              # Create and activate a virtual environment if it doesn't exist
              if [ ! -d .venv ]; then
                echo "Creating Python virtual environment..."
                python -m venv .venv
              fi
              
              source .venv/bin/activate
            '';
          };
        };
      }
    );
}
```

### CI/CD Pipeline Flake

Define CI/CD configurations in a Flake:

```nix
{
  description = "CI/CD pipeline configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define shared CI dependencies
        ciDeps = with pkgs; [
          docker
          git
          jq
          curl
          gnumake
          openssh
        ];
        
        # Create a common CI environment
        mkCiEnv = extraPkgs: pkgs.buildEnv {
          name = "ci-environment";
          paths = ciDeps ++ extraPkgs;
        };
        
      in {
        # CI environments for different jobs
        packages = {
          default = self.packages.${system}.build-env;
          
          # Environment for building code
          build-env = mkCiEnv (with pkgs; [ 
            nodejs_20
            yarn
            typescript
          ]);
          
          # Environment for testing
          test-env = mkCiEnv (with pkgs; [
            nodejs_20
            yarn
            chromium
            xvfb-run
          ]);
          
          # Environment for deployment
          deploy-env = mkCiEnv (with pkgs; [
            kubectl
            kubernetes-helm
            awscli2
            terraform
            sops
          ]);
        };
        
        # CI/CD scripts as apps
        apps = {
          default = self.apps.${system}.ci-build;
          
          ci-build = {
            type = "app";
            program = toString (pkgs.writeShellScript "ci-build" ''
              set -euo pipefail
              
              echo "Building application..."
              cd $GITHUB_WORKSPACE
              yarn install --frozen-lockfile
              yarn build
              
              echo "Running tests..."
              yarn test
              
              echo "Build successful!"
            '');
          };
          
          ci-deploy = {
            type = "app";
            program = toString (pkgs.writeShellScript "ci-deploy" ''
              set -euo pipefail
              
              echo "Deploying to Kubernetes..."
              
              # Configure kubectl
              echo "$KUBE_CONFIG" | base64 -d > kubeconfig.yaml
              export KUBECONFIG="$PWD/kubeconfig.yaml"
              
              # Deploy with Helm
              helm upgrade --install myapp ./helm/myapp \
                --namespace $DEPLOY_NAMESPACE \
                --set image.tag=$GITHUB_SHA \
                --set environment=$DEPLOY_ENV \
                --wait
              
              echo "Deployment successful!"
            '');
          };
        };
      }
    );
}
```

### Microservices Flake

Manage multiple services in a single repository:

```nix
{
  description = "Microservices architecture";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    
    # Additional tools
    crane = {
      url = "github:ipetkov/crane/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, crane, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.lib.${system};
        
        # Common dependencies for all services
        commonDeps = with pkgs; [
          docker-compose
          openssl
        ];
        
        # Build a Docker image for a service
        buildDockerImage = { name, dir, port ? 8080 }: 
          pkgs.dockerTools.buildImage {
            inherit name;
            tag = "latest";
            
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [ 
                self.packages.${system}.${name}
                pkgs.cacert
                pkgs.tzdata
              ];
              pathsToLink = [ "/bin" "/etc" "/tmp" ];
            };
            
            config = {
              Cmd = [ "/bin/${name}" ];
              ExposedPorts = {
                "${toString port}/tcp" = {};
              };
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "TZ=UTC"
              ];
              WorkingDir = "/app";
              Volumes = {
                "/data" = {};
              };
            };
          };
        
        # Helper for Go services
        buildGoService = { name, dir, port ? 8080 }: {
          # Build the Go binary
          ${name} = craneLib.buildPackage {
            pname = name;
            version = "1.0.0";
            src = ./${dir};
            
            buildInputs = with pkgs; [ go_1_20 ];
          };
          
          # Build the Docker image
          "${name}-image" = buildDockerImage {
            inherit name dir port;
          };
        };
        
        # Helper for Node.js services
        buildNodeService = { name, dir, port ? 3000 }: {
          # Build the Node.js package
          ${name} = pkgs.buildNpmPackage {
            pname = name;
            version = "1.0.0";
            src = ./${dir};
            
            npmDepsHash = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
            
            installPhase = ''
              mkdir -p $out/bin
              cp -r dist $out/dist
              cp package.json $out/
              cat > $out/bin/${name} << EOF
              #!/bin/sh
              exec ${pkgs.nodejs_20}/bin/node $out/dist/index.js "\$@"
              EOF
              chmod +x $out/bin/${name}
            '';
          };
          
          # Build the Docker image
          "${name}-image" = buildDockerImage {
            inherit name dir port;
          };
        };
        
        # Generate Terraform provider configurations
        terraformConfig = pkgs.writeTextFile {
          name = "terraform-providers.tf";
          text = ''
            terraform {
              required_providers {
                aws = {
                  source  = "hashicorp/aws"
                  version = "~> 5.0"
                }
                kubernetes = {
                  source  = "hashicorp/kubernetes"
                  version = "~> 2.0"
                }
              }
              required_version = ">= 1.0"
            }
            
            provider "aws" {
              region = var.aws_region
            }
            
            provider "kubernetes" {
              config_path = var.kubeconfig_path
            }
          '';
        };
        
        # Define services
        services = {
          auth = { name = "auth-service"; dir = "services/auth"; port = 8081; };
          api = { name = "api-gateway"; dir = "services/api"; port = 8080; };
          users = { name = "user-service"; dir = "services/users"; port = 8082; };
          frontend = { name = "frontend"; dir = "services/frontend"; port = 3000; };
        };
        
      in {
        # Packages for all services
        packages = {
          default = self.packages.${system}.all;
          
          # Meta-package for building all services
          all = pkgs.runCommandNoCC "all-services" {} ''
            mkdir -p $out
            echo "All services built successfully" > $out/success
          '';
          
          # Terraform configuration
          terraform = terraformConfig;
          
          # Build individual Go services
          auth-service = (buildGoService services.auth).auth-service;
          api-gateway = (buildGoService services.api).api-gateway;
          user-service = (buildGoService services.users).user-service;
          
          # Build individual Node.js services
          frontend = (buildNodeService services.frontend).frontend;
          
          # Docker images
          auth-service-image = (buildGoService services.auth)."auth-service-image";
          api-gateway-image = (buildGoService services.api)."api-gateway-image";
          user-service-image = (buildGoService services.users)."user-service-image";
          frontend-image = (buildNodeService services.frontend)."frontend-image";
        };
        
        # Development environments
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              go_1_20
              nodejs_20
              yarn
              docker-compose
              kubectl
              terraform
            ];
          };
        };
        
        # Apps for development
        apps = {
          # Development launcher
          dev = {
            type = "app";
            program = toString (pkgs.writeShellScript "launch-dev" ''
              ${pkgs.docker-compose}/bin/docker-compose -f docker-compose.dev.yaml up
            '');
          };
          
          # Service runner
          auth = {
            type = "app";
            program = "${self.packages.${system}.auth-service}/bin/auth-service";
          };
          
          api = {
            type = "app";
            program = "${self.packages.${system}.api-gateway}/bin/api-gateway";
          };
          
          users = {
            type = "app";
            program = "${self.packages.${system}.user-service}/bin/user-service";
          };
        };
      }
    );
}
```

## NixOS System Configuration with Flakes

Define your entire NixOS system in a flake:

```nix
{
  description = "My NixOS configurations";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # System management
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware detection
    hardware.url = "github:NixOS/nixos-hardware";
    
    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hardware, agenix, ... }:
    let
      lib = nixpkgs.lib;
      
      # System types to support
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs systems;
      
      # Nixpkgs configuration
      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "openssl-1.1.1u" ];
      };
      
      # Helper for creating system configurations
      mkSystem = { system, hostname, username ? "admin", extraModules ? [] }:
        lib.nixosSystem {
          inherit system;
          
          modules = [
            # Base configuration
            ./nixos/configuration.nix
            
            # Machine-specific configuration
            ./nixos/hosts/${hostname}
            
            # Hardware configuration
            ./nixos/hardware/${hostname}.nix
            
            # User configuration via home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/${username}.nix;
            }
            
            # Secrets management
            agenix.nixosModules.default
            
            # Hostname configuration
            {
              networking.hostName = hostname;
              nixpkgs.config = nixpkgsConfig;
              
              # Make flake inputs accessible in NixOS configuration
              _module.args = {
                flake-self = self;
                inputs = {
                  nixpkgs-unstable = nixpkgs-unstable;
                  agenix = agenix;
                  hardware = hardware;
                };
              };
            }
          ] ++ extraModules;
        };
        
      # Define overlay for accessing unstable packages
      overlays = {
        default = final: prev: {
          unstable = import nixpkgs-unstable {
            system = prev.system;
            config = nixpkgsConfig;
          };
        };
      };
      
    in {
      # NixOS system configurations
      nixosConfigurations = {
        # Desktop system
        desktop = mkSystem {
          system = "x86_64-linux";
          hostname = "desktop";
          username = "developer";
          extraModules = [
            # Use desktop hardware profile
            hardware.nixosModules.dell-xps-15-9500
            
            # Desktop-specific modules
            ./nixos/modules/desktop.nix
            ./nixos/modules/gaming.nix
          ];
        };
        
        # Server configuration
        server = mkSystem {
          system = "x86_64-linux";
          hostname = "server";
          extraModules = [
            ./nixos/modules/server.nix
            ./nixos/modules/monitoring.nix
            ./nixos/modules/services/web.nix
            ./nixos/modules/services/database.nix
          ];
        };
        
        # Raspberry Pi configuration
        rpi4 = mkSystem {
          system = "aarch64-linux";
          hostname = "rpi4";
          extraModules = [
            hardware.nixosModules.raspberry-pi-4
            ./nixos/modules/iot-gateway.nix
          ];
        };
      };
      
      # Overlays
      overlays = overlays;
      
      # Development shells available on all platforms
      devShells = forAllSystems (system: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              nil
              nixos-rebuild
            ];
          };
        }
      );
      
      # Formatter for all platforms
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
```

## Advanced Flake Techniques

### Multi-Environment Deployments

Define different environments (dev, staging, production) with shared configurations:

```nix
{
  description = "Multi-environment deployment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      
      # Define supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Helper to create per-system attributes
      forAllSystems = lib.genAttrs supportedSystems;
      
      # Helper to create full system configurations
      mkSystem = { system, hostname, environment, region ? "us-east-1" }:
        let
          # Base nixosSystem configuration
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          
          # Environment-specific settings
          envSettings = {
            dev = {
              logLevel = "debug";
              monitoring = true;
              highAvailability = false;
              instanceType = "t3.medium";
              domain = "dev.example.com";
              replicas = 1;
            };
            
            staging = {
              logLevel = "info";
              monitoring = true;
              highAvailability = true;
              instanceType = "t3.large";
              domain = "staging.example.com";
              replicas = 2;
            };
            
            prod = {
              logLevel = "warn";
              monitoring = true;
              highAvailability = true;
              instanceType = "m5.large";
              domain = "example.com";
              replicas = 3;
            };
          };
          
          # Get environment settings with defaults
          env = envSettings.${environment};
          
        in lib.nixosSystem {
          inherit system;
          
          modules = [
            # Base configuration that applies to all instances
            ./modules/base.nix
            
            # Role-specific configuration
            ./modules/roles/${hostname}.nix
            
            # Environment-specific configuration
            ./modules/environments/${environment}.nix
            
            # System configuration
            {
              networking.hostName = "${hostname}-${environment}";
              
              # Pass environment settings to the configuration
              _module.args = {
                inherit env;
                inherit environment;
                inherit region;
                
                # Create a unique name for the instance
                instanceName = "${hostname}-${environment}-${region}";
              };
              
              # Define environment variables for the system
              environment.variables = {
                ENV = environment;
                LOG_LEVEL = env.logLevel;
                DOMAIN = env.domain;
              };
            }
          ];
        };
        
      # Define all the hosts we need to create
      allHosts = [
        { hostname = "api"; role = "application"; }
        { hostname = "worker"; role = "worker"; }
        { hostname = "db"; role = "database"; }
      ];
      
      # Define all environments
      allEnvironments = [ "dev" "staging" "prod" ];
      
      # Define all regions (for multi-region deployments)
      allRegions = {
        dev = [ "us-east-1" ];
        staging = [ "us-east-1" ];
        prod = [ "us-east-1" "eu-west-1" ];
      };
      
      # Generate all possible combinations of hosts/environments/regions
      mkSystemConfigurations = system:
        lib.listToAttrs (
          lib.flatten (
            builtins.map (environment:
              builtins.map (region:
                builtins.map (host:
                  lib.nameValuePair
                    # Generate a unique name for this configuration
                    "${host.hostname}-${environment}-${region}"
                    # Create the system configuration
                    (mkSystem {
                      inherit system environment region;
                      hostname = host.hostname;
                    })
                ) allHosts
              ) (allRegions.${environment} or [ "us-east-1" ])
            ) allEnvironments
          )
        );
        
      # Generate deployment scripts for each environment
      mkDeployScript = environment: system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Get list of systems for this environment
          systems = builtins.filter (name: builtins.match ".*-${environment}-.*" name != null)
                    (builtins.attrNames self.nixosConfigurations);
        in
          pkgs.writeShellScriptBin "deploy-${environment}" ''
            set -e
            echo "Deploying ${environment} environment..."
            
            # Deploy all systems for this environment
            ${lib.concatMapStringsSep "\n" (system: ''
              echo "Deploying ${system}..."
              nixos-rebuild switch --flake .#${system} --target-host ${system}.${environment}.example.com
            '') systems}
            
            echo "Deployment complete!"
          '';
          
    in {
      # Define all NixOS system configurations
      nixosConfigurations = 
        (mkSystemConfigurations "x86_64-linux") //
        (mkSystemConfigurations "aarch64-linux");
      
      # Provide deployment scripts for each environment and system
      packages = forAllSystems (system: {
        default = self.packages.${system}."deploy-dev";
        
        # Create deployment scripts for each environment
        "deploy-dev" = mkDeployScript "dev" system;
        "deploy-staging" = mkDeployScript "staging" system;
        "deploy-prod" = mkDeployScript "prod" system;
      });
      
      # Provide formatters and checks
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      
      # Simple checks to validate configurations
      checks = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          # Check Nix formatting
          format = pkgs.runCommand "check-format" {} ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            touch $out
          '';
        }
      );
    };
}
```

### Composing Flakes with Registry Overrides

Compose multiple flakes with registry overrides to create a unified system:

```nix
{
  description = "Composite flake with registry overrides";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Additional flakes with own nixpkgs inputs
    monitoring-flake = {
      url = "github:my-org/monitoring-flake";
      # Override its nixpkgs to use ours
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    kubernetes-flake = {
      url = "github:my-org/kubernetes-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    database-flake = {
      url = "github:my-org/database-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, monitoring-flake, kubernetes-flake, database-flake, ... }:
    let
      # Systems to support
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Helper to create system configurations
      mkSystem = { system, modules ? [] }:
        nixpkgs.lib.nixosSystem {
          inherit system modules;
        };
        
    in {
      # Registry overrides
      nixosConfigurations = {
        # Composite system that combines all flakes
        full-system = mkSystem {
          system = "x86_64-linux";
          modules = [
            # Base configuration
            ./modules/configuration.nix
            
            # Import modules from other flakes
            monitoring-flake.nixosModules.prometheus
            monitoring-flake.nixosModules.grafana
            kubernetes-flake.nixosModules.kubernetes
            database-flake.nixosModules.postgresql
            
            # Configure with settings specific to our deployment
            {
              services.prometheus = {
                enable = true;
                scrapeConfigs = [
                  {
                    job_name = "node";
                    static_configs = [{
                      targets = [ "localhost:9100" ];
                    }];
                  }
                ];
              };
              
              services.kubernetes = {
                roles = [ "master" "node" ];
                addons.dashboard.enable = true;
              };
              
              services.postgresql = {
                enable = true;
                package = nixpkgs.legacyPackages.x86_64-linux.postgresql_14;
              };
            }
          ];
        };
      };
      
      # Make modules from this flake available to others
      nixosModules = {
        default = ./modules/default.nix;
        customService = ./modules/custom-service.nix;
      };
      
      # Expose packages from all flakes
      packages = forAllSystems (system: {
        default = self.packages.${system}.combined-tools;
        
        # Combine tools from all flakes into one meta-package
        combined-tools = nixpkgs.legacyPackages.${system}.buildEnv {
          name = "combined-tools";
          paths = [
            # Local packages
            (nixpkgs.legacyPackages.${system}.callPackage ./pkgs/local-tool {})
            
            # Packages from other flakes
            monitoring-flake.packages.${system}.prometheus-toolbox
            kubernetes-flake.packages.${system}.k8s-tools
            database-flake.packages.${system}.db-migration-tool
          ];
        };
      });
      
      # Expose apps from all flakes
      apps = forAllSystems (system: {
        default = self.apps.${system}.manage;
        
        # Our own apps
        manage = {
          type = "app";
          program = toString (nixpkgs.legacyPackages.${system}.writeShellScript "manage" ''
            echo "Management interface for combined system"
            echo "1. Monitoring tools"
            echo "2. Kubernetes tools"
            echo "3. Database tools"
            read -p "Select an option: " option
            
            case $option in
              1) ${monitoring-flake.apps.${system}.monitor.program} ;;
              2) ${kubernetes-flake.apps.${system}.kubectl-wrapper.program} ;;
              3) ${database-flake.apps.${system}.db-cli.program} ;;
              *) echo "Invalid option" ;;
            esac
          '');
        };
        
        # Re-export apps from other flakes
        monitor = monitoring-flake.apps.${system}.monitor;
        kubectl = kubernetes-flake.apps.${system}.kubectl-wrapper;
        db-cli = database-flake.apps.${system}.db-cli;
      });
    };
}
```

## Managing Flake Dependencies

### Dependency Locking and Updates

Flakes use a `flake.lock` file to pin exact dependencies:

```bash
# Create or update the lock file based on flake.nix
nix flake update

# Update a specific input
nix flake update nixpkgs

# Update with specific commits
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/5233fd2ba76a3accb05b4104bd6e6dda4061a396
```

### Dependency Visualization

Visualize your flake dependencies:

```bash
nix flake show
nix flake metadata --json | jq
```

## Flakes in CI/CD Pipelines

Configure CI/CD pipelines to use flakes:

```yaml
# .github/workflows/build.yml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Nix
        uses: cachix/install-nix-action@v20
        with:
          nix_path: nixpkgs=channel:nixos-23.11
          extra_nix_config: |
            experimental-features = nix-command flakes
      
      - name: Set up Cachix
        uses: cachix/cachix-action@v12
        with:
          name: my-project
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Build application
        run: nix build .#app
      
      - name: Run tests
        run: nix flake check
      
      # Deployment step for main branch only
      - name: Deploy
        if: github.ref == 'refs/heads/main'
        run: nix run .#deploy
```

## Real-World DevOps Projects with Flakes

### NixOS Server Fleet Management

Example of a flake for managing a fleet of servers:

```nix
{
  description = "Server Fleet Management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # For secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Deploy-rs for multi-target deployments
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, deploy-rs, ... }:
    let
      # Helper for creating server configurations
      mkServer = { name, ip, system ? "x86_64-linux", roles ? [], region ? "us-east-1" }:
        let
          # Standard NixOS configuration
          nixosConfig = nixpkgs.lib.nixosSystem {
            inherit system;
            
            modules = [
              # Base configuration for all servers
              ./modules/base.nix
              
              # Role-specific configurations
              (nixpkgs.lib.mkIf (builtins.elem "web" roles) ./modules/roles/web.nix)
              (nixpkgs.lib.mkIf (builtins.elem "db" roles) ./modules/roles/database.nix)
              (nixpkgs.lib.mkIf (builtins.elem "cache" roles) ./modules/roles/cache.nix)
              (nixpkgs.lib.mkIf (builtins.elem "monitoring" roles) ./modules/roles/monitoring.nix)
              
              # Region-specific configuration
              ./modules/regions/${region}.nix
              
              # Load secrets management
              agenix.nixosModules.default
              
              # Server-specific configuration
              {
                networking = {
                  hostName = name;
                  inherit ip;
                  firewall.enable = true;
                };
                
                # Make some contextual variables available to all modules
                _module.args = {
                  serverName = name;
                  serverRoles = roles;
                  serverRegion = region;
                };
              }
            ];
          };
          
        in {
          # NixOS configuration
          config = nixosConfig;
          
          # Deploy-rs node configuration
          deploy.node = {
            hostname = ip;
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos nixosConfig;
            };
          };
        };
        
      # Define all servers in the fleet
      servers = {
        # Web servers
        web-1 = mkServer {
          name = "web-1";
          ip = "10.0.1.11";
          roles = [ "web" ];
        };
        
        web-2 = mkServer {
          name = "web-2";
          ip = "10.0.1.12";
          roles = [ "web" ];
        };
        
        # Database servers
        db-1 = mkServer {
          name = "db-1";
          ip = "10.0.2.11";
          roles = [ "db" ];
        };
        
        db-2 = mkServer {
          name = "db-2";
          ip = "10.0.2.12";
          roles = [ "db" ];
        };
        
        # Cache server
        cache-1 = mkServer {
          name = "cache-1";
          ip = "10.0.3.11";
          roles = [ "cache" ];
        };
        
        # Monitoring server
        monitor = mkServer {
          name = "monitor";
          ip = "10.0.4.11";
          roles = [ "monitoring" ];
        };
        
        # European region server
        eu-web-1 = mkServer {
          name = "eu-web-1";
          ip = "10.1.1.11";
          roles = [ "web" ];
          region = "eu-west-1";
        };
      };
      
    in {
      # Export NixOS configurations
      nixosConfigurations = nixpkgs.lib.mapAttrs 
        (name: server: server.config) 
        servers;
      
      # Export deploy-rs node configurations
      deploy.nodes = nixpkgs.lib.mapAttrs 
        (name: server: server.deploy.node) 
        servers;
      
      # Add some checks to ensure the deployments are valid
      checks = builtins.mapAttrs
        (system: deploy-rs.lib.${system}.deployChecks self.deploy)
        { x86_64-linux = {}; aarch64-linux = {}; };
      
      # Helper apps for administration
      apps.x86_64-linux = {
        # Deploy all servers
        deploy-all = {
          type = "app";
          program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-all" ''
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .
          '');
        };
        
        # Deploy only web servers
        deploy-web = {
          type = "app";
          program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-web" ''
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .#web-1
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .#web-2
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .#eu-web-1
          '');
        };
        
        # Deploy only database servers
        deploy-db = {
          type = "app";
          program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-db" ''
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .#db-1
            ${deploy-rs.defaultPackage.x86_64-linux}/bin/deploy .#db-2
          '');
        };
      };
    };
}
```

## Best Practices for Flakes in Production

1. **Pin Dependencies**: Always commit your `flake.lock` and update dependencies deliberately.

2. **Modularize Configurations**: Use the module system to break down complex configurations.

3. **Layered Architecture**: Structure flakes with clear layering:
   - Base system configuration
   - Role-specific modules (web server, database, etc.)
   - Environment-specific modules (dev, staging, prod)
   - Host-specific overrides

4. **Test Before Deployment**: Use `nix flake check` and write tests for your configurations.

5. **Use CI/CD Pipelines**: Integrate flake-based builds into your CI/CD pipelines.

6. **Document Inputs and Outputs**: Add good descriptions and documentation to your flakes.

7. **Use Flake Registry**: Consider registering frequently used flakes in the global registry.

8. **Cache Aggressively**: Use binary caches (like Cachix) to speed up builds and deployments.

9. **Prefer Small, Focused Flakes**: Create separate flakes for different concerns and compose them.

10. **Version Your Flakes**: Tag releases for important configurations to enable rollbacks.

## Flakes Command Reference

```bash
# Build a flake output
nix build .#<output>

# Run a flake app
nix run .#<app>

# Develop with a flake shell
nix develop .#<devShell>

# Check a flake
nix flake check

# Show flake outputs
nix flake show

# Update flake lock file
nix flake update

# Lock a specific input
nix flake lock --override-input <input> <value>
```

## Conclusion

Nix Flakes represent a significant improvement in Nix's dependency management and reproducibility story. As a DevOps engineer, Flakes provide the tools needed to:

- Create truly reproducible development environments
- Manage complex system configurations
- Deploy consistent infrastructure across environments
- Maintain a fleet of machines with confidence

While Flakes are still evolving, they have rapidly become the preferred approach for serious Nix users. By embracing Flakes, you can leverage Nix's full power with a more structured, composable approach.

## Further Resources

- [Nix Flakes: Official Documentation](https://nixos.wiki/wiki/Flakes)
- [Nix Flake Tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/flakes.html)
- [Nixpkgs Flake Examples](https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name)
- [Flake Community Templates](https://github.com/nix-community/templates)
- [Flakes Book](https://nixos-cookbook.osiris.cyber.nyu.edu/recipies/nix/flakes)
