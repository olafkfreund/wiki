# Building Packages with Nix

Nix provides powerful tools for building, packaging, and distributing software in a reproducible manner. This guide details practical approaches to building packages with Nix in a DevOps context.

## Anatomy of a Nix Package

A Nix package is defined by a derivation, which specifies all inputs needed to build the package:

```nix
{ stdenv, fetchurl, perl }:

stdenv.mkDerivation {
  name = "hello-2.12";
  
  # Source code
  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz"\;
    hash = "sha256-zoJ2IvKo2ioO2U13kTX780rP2MaGwIGcbFOvG+Oi17Y=";
  };
  
  # Build-time dependencies
  buildInputs = [ perl ];
  
  # Configuration flags
  configureFlags = [ "--with-debug" ];
  
  # Custom build steps (if default is insufficient)
  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';
  
  # Installation instructions
  installPhase = ''
    make install
    mkdir -p $out/share/doc
    cp README* $out/share/doc/
  '';
  
  # Meta information for package discovery and maintenance
  meta = {
    description = "A program that produces a friendly greeting";
    homepage = "https://www.gnu.org/software/hello/"\;
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = [ "example@example.com" ];
    platforms = stdenv.lib.platforms.all;
  };
}
```

## Common Build Phases in Nix

| Phase | Default Action | Custom Example |
|-------|----------------|----------------|
| unpackPhase | Extract source archive | `tar -xf $src; cd myproject-*` |
| patchPhase | Apply patches | `patch -p1 < $patchfile` |
| configurePhase | Run ./configure | `./configure --prefix=$out --enable-feature` |
| buildPhase | Run make | `make -j $NIX_BUILD_CORES CFLAGS="-O3"` |
| checkPhase | Run tests | `make test` |
| installPhase | Run make install | `make install DESTDIR=$out` |
| fixupPhase | Fix runtime paths | Automatic |

## Fetching Source Code

Nix provides several fetchers to obtain source code:

```nix
# From a URL with hash verification
src = fetchurl {
  url = "https://example.org/package-1.0.tar.gz"\;
  hash = "sha256-1234...";
};

# From Git with specific revision
src = fetchGit {
  url = "https://github.com/user/repo.git"\;
  rev = "abcdef123456789";
  sha256 = "sha256-5678...";
};

# From GitHub with simplified syntax
src = fetchFromGitHub {
  owner = "user";
  repo = "project";
  rev = "v1.0.0";
  sha256 = "sha256-9abc...";
};

# From local path (for development)
src = ./path/to/source;
```

## Real-World Package Examples

### Simple Python Application

```nix
{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "myapp";
  version = "0.1.0";
  
  src = fetchFromGitHub {
    owner = "myuser";
    repo = "myapp";
    rev = "v${version}";
    sha256 = "sha256-abc123def456...";
  };
  
  propagatedBuildInputs = with python3.pkgs; [
    requests
    pyyaml
    click
  ];
  
  checkInputs = with python3.pkgs; [
    pytest
    pytest-mock
  ];
  
  checkPhase = ''
    pytest
  '';
  
  meta = with lib; {
    description = "A utility for managing cloud resources";
    homepage = "https://github.com/myuser/myapp"\;
    license = licenses.mit;
    maintainers = with maintainers; [ myuser ];
  };
}
```

### Node.js Web Application

```nix
{ lib
, stdenv
, fetchFromGitHub
, nodejs
, yarn
}:

stdenv.mkDerivation rec {
  pname = "webapp";
  version = "1.2.0";
  
  src = fetchFromGitHub {
    owner = "company";
    repo = "webapp";
    rev = "v${version}";
    sha256 = "sha256-def456...";
  };
  
  buildInputs = [
    nodejs
    yarn
  ];
  
  buildPhase = ''
    # Yarn will attempt to write to $HOME, so we need to set it
    export HOME=$TMPDIR
    
    # Install dependencies
    yarn install --frozen-lockfile --offline --non-interactive
    
    # Build the application
    yarn build
  '';
  
  installPhase = ''
    mkdir -p $out/share/webapp
    cp -r build/* $out/share/webapp/
    
    # Create a wrapper script
    mkdir -p $out/bin
    cat > $out/bin/webapp <<EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/share/webapp/server.js "\$@"
    EOF
    chmod +x $out/bin/webapp
  '';
  
  meta = with lib; {
    description = "Enterprise web application";
    homepage = "https://company.com/webapp"\;
    license = licenses.proprietary;
    platforms = platforms.linux;
  };
}
```

### Go CLI Tool

```nix
{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "mycli";
  version = "2.0.1";
  
  src = fetchFromGitHub {
    owner = "myorg";
    repo = "mycli";
    rev = "v${version}";
    sha256 = "sha256-ghi789...";
  };
  
  vendorSha256 = "sha256-jkl012...";
  
  ldflags = [
    "-s" "-w"
    "-X github.com/myorg/mycli/cmd.Version=${version}"
  ];
  
  # Run specific tests and skip integration tests
  checkFlags = [
    "-short"
    "-skip=TestIntegration"
  ];
  
  meta = with lib; {
    description = "Command-line tool for infrastructure management";
    homepage = "https://github.com/myorg/mycli"\;
    license = licenses.apache2;
    maintainers = with maintainers; [ myname ];
    mainProgram = "mycli";
  };
}
```

## DevOps Patterns for Package Management

### Creating a Private Package Repository

You can create a private Nix package repository for your organization:

```nix
# In your nixpkgs overlay (e.g., overlay.nix)
self: super: {
  companyPackages = {
    internal-tool = self.callPackage ./pkgs/internal-tool {};
    monitoring-agent = self.callPackage ./pkgs/monitoring-agent {};
    custom-nginx = self.callPackage ./pkgs/custom-nginx {
      openssl = self.openssl_1_1;
    };
  };
}

# In your configuration.nix
{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];
  
  environment.systemPackages = with pkgs; [
    companyPackages.internal-tool
    companyPackages.monitoring-agent
  ];
}
```

### Patching Existing Packages

Sometimes you need to patch an existing package from nixpkgs:

```nix
# In your overlay
self: super: {
  # Override an existing package
  nginx = super.nginx.overrideAttrs (oldAttrs: {
    # Add a custom patch
    patches = (oldAttrs.patches or []) ++ [
      ./patches/nginx-custom-header.patch
    ];
    
    # Add build flags
    configureFlags = oldAttrs.configureFlags ++ [
      "--with-http_auth_request_module"
    ];
  });
}
```

### Creating Runtime Wrappers

Wrap executables to set environment variables or provide configuration:

```nix
{ stdenv, makeWrapper, nodejs, postgresql }:

stdenv.mkDerivation {
  name = "my-service-1.0.0";
  
  # ... standard package definition ...
  
  nativeBuildInputs = [ makeWrapper ];
  
  buildInputs = [ nodejs postgresql ];
  
  installPhase = ''
    # Install application files
    mkdir -p $out/lib/my-service
    cp -r . $out/lib/my-service
    
    # Create a wrapper script with environment setup
    makeWrapper ${nodejs}/bin/node $out/bin/my-service \
      --add-flags "$out/lib/my-service/index.js" \
      --set NODE_ENV production \
      --set PATH ${postgresql}/bin:$PATH \
      --set CONFIG_DIR /etc/my-service
  '';
}
```

## Versioning and Dependency Management

### Pinning Dependencies

To ensure reproducible builds, pin your nixpkgs version:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };
  
  outputs = { self, nixpkgs }: {
    # Use the pinned nixpkgs
    packages.x86_64-linux.default = 
      nixpkgs.legacyPackages.x86_64-linux.callPackage ./default.nix {};
  };
}

# Without flakes, using fetchTarball
let
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/23.05.tar.gz"\;
    sha256 = "sha256:0000000000000000000000000000000000000000000000000";
  }) {};
in
  pkgs.callPackage ./default.nix {}
```

### Managing Multiple Versions

Maintain multiple versions of the same package:

```nix
# In your overlay
self: super: {
  postgresql_13 = super.postgresql_13;
  postgresql_14 = super.postgresql_14;
  postgresql_15 = super.postgresql_15;
  
  # Default to latest stable
  postgresql = self.postgresql_15;
  
  # App-specific PostgreSQL configurations
  postgresql-for-legacy = self.postgresql_13.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [
      "--with-libxml"
    ];
  });
}
```

## Testing and CI Integration

### Testing Packages in Isolation

Test packages in isolation using `nix-build` or `nix build`:

```bash
# Build the package
nix-build -A mypackage

# Run a specific test attribute
nix-build -A mypackage.tests.integration

# Build with a specific version of nixpkgs
nix-build -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/23.05.tar.gz -A mypackage
```

### CI Configuration for Package Building

Example GitHub Actions workflow for building Nix packages:

```yaml
name: Build Nix Packages

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
        nix_path: nixpkgs=channel:nixos-23.05
    
    - name: Set up Cachix
      uses: cachix/cachix-action@v12
      with:
        name: my-company-cache
        authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
    
    - name: Build packages
      run: |
        nix-build -A mypackage1 --option substitute true
        nix-build -A mypackage2 --option substitute true
    
    - name: Run tests
      run: nix-build -A mypackage.tests
```

## Advanced Topics

### Cross-Compilation

Build packages for different architectures:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  # Create a custom pkgs instance for the target architecture
  pkgsCross = import pkgs.path {
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
in
  # Build your package using the cross-compilation toolchain
  pkgsCross.callPackage ./default.nix {}
```

### Static Linking

Create statically linked binaries for containerized environments:

```nix
{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "static-app";
  version = "1.0.0";
  
  src = fetchFromGitHub { /* ... */ };
  
  vendorSha256 = "sha256-abc123...";
  
  # Configure Go to build a fully static binary
  ldflags = [
    "-s" "-w"
    "-extldflags '-static'"
  ];
  
  # Ensure CGO is disabled for true static linking
  CGO_ENABLED = 0;
  
  # Additional flags for truly static binaries
  tags = [ "netgo" "osusergo" ];
  
  meta = with lib; {
    description = "Statically linked application for containers";
    platforms = platforms.linux;
  };
}
```

### Creating Minimal Docker Images

Use Nix to create minimal Docker images:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  myapp = pkgs.callPackage ./default.nix {};
in
  pkgs.dockerTools.buildImage {
    name = "myapp";
    tag = "latest";
    
    # Only include the necessary components
    contents = [
      myapp
      pkgs.cacert  # SSL certificates
      pkgs.tzdata  # Timezone data
    ];
    
    # Configure entry point
    config = {
      Cmd = [ "${myapp}/bin/myapp" ];
      WorkingDir = "/data";
      Volumes = {
        "/data" = {};
      };
      ExposedPorts = {
        "8080/tcp" = {};
      };
    };
  }
```

## Best Practices for Package Maintainability

1. **Follow the Nixpkgs Contribution Guidelines**: Even for private packages, following the [Nixpkgs contribution guidelines](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) ensures high-quality packages.

2. **Properly Set Metadata**: Always include complete `meta` attributes:
   ```nix
   meta = with lib; {
     description = "Concise yet comprehensive description";
     homepage = "https://project-website.com/"\;
     license = licenses.mit;  # Or appropriate license
     maintainers = with maintainers; [ yourname ];
     platforms = platforms.linux;
   };
   ```

3. **Version Management**: Use `rec` pattern for version propagation:
   ```nix
   rec {
     pname = "mypackage";
     version = "2.1.0";
     name = "${pname}-${version}";
     
     src = fetchFromGitHub {
       rev = "v${version}";
       # ...
     };
   }
   ```

4. **Avoid Hard-Coded Paths**: Use variables like `$out` instead of hard-coded paths:
   ```nix
   # Good
   installPhase = ''
     mkdir -p $out/bin
     cp build/app $out/bin/
   '';
   
   # Bad
   installPhase = ''
     mkdir -p /usr/local/bin
     cp build/app /usr/local/bin/
   '';
   ```

5. **Minimize Closure Size**: For deployments, especially in containers, minimize runtime dependencies:
   ```nix
   # Only include runtime dependencies, not build-time ones
   propagatedBuildInputs = [ necessary-lib ];
   
   # Strip debug symbols
   postInstall = ''
     $STRIP $out/bin/myapp
   '';
   ```

## Conclusion

Building packages with Nix provides a powerful, reproducible approach to software packaging for DevOps environments. By following these patterns and best practices, you can create reliable builds that work consistently across development, testing, and production environments.

## Further Resources

- [Nixpkgs Contributors Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [Nix Pills: Creating a Basic Package](https://nixos.org/guides/nix-pills/basic-dependencies-and-hooks.html)
- [Nix Manual: Derivations](https://nixos.org/manual/nix/stable/expressions/derivations.html)
- [NixOS Wiki: Packaging Guidelines](https://nixos.wiki/wiki/Nixpkgs/Create_and_debug_packages)
