# Nix Language Fundamentals

## Why Learn Nix?

Nix is unique because it guarantees reproducible builds, isolates dependencies, and allows you to describe complex systems declaratively. Whether you're managing packages, configuring servers, or developing software, Nix's language is the foundation for creating reliable and repeatable environments.

Learning Nix provides several key advantages for DevOps professionals:

1. **Reproducible Environments**: Create development, testing, and production environments that are identical down to the package version, eliminating "works on my machine" problems.

2. **Atomic Upgrades and Rollbacks**: Deploy changes with confidence, knowing you can roll back instantly if something goes wrong.

3. **Multi-User Package Management**: Allow different users to have different configurations without conflicts.

4. **Declarative Configuration**: Express your entire system as code, making infrastructure truly auditable and version-controlled.

5. **Language-Agnostic Development**: Create consistent development environments for any programming language or framework.

## Nix Language at a Glance

Nix is often described as "JSON with functions." It's a declarative language where you define outcomes, not step-by-step instructions. Instead of writing sequential code, you create expressions that describe data structures, functions, and dependencies. These expressions are evaluated lazily, meaning Nix computes values only when needed, making it efficient for managing large systems.

Let's dive into the key characteristics of Nix:

| Concept | Description |
|---------|-------------|
| Pure | Functions have no side effects, ensuring predictable results |
| Functional | Functions can be passed as arguments or returned, enabling flexible composition |
| Lazy | Expressions are evaluated only when their results are needed |
| Declarative | You describe the desired outcome, not how to achieve it |
| Reproducible | The same inputs always produce the same outputs, ensuring consistency |

## Basic Data Types

Nix supports several primitive data types:

```nix
# Integers
let x = 42;

# Floating point numbers
let pi = 3.14;

# Strings (single or double quotes)
let greeting = "Hello, world!";
let path = ./some/file/path;

# Booleans
let isEnabled = true;

# Lists
let fruits = [ "apple" "banana" "orange" ];

# Attribute sets (similar to dictionaries/objects)
let person = {
  name = "John";
  age = 30;
  address = {
    city = "Portland";
    state = "Oregon";
  };
};
```

## Functions in Nix

Functions are a core concept in Nix, allowing you to create reusable components and abstractions:

```nix
# Simple function
let 
  square = x: x * x;
in
  square 4  # Returns 16

# Function with multiple arguments
let 
  add = a: b: a + b;
in
  add 5 7  # Returns 12

# Function that takes an attribute set
let 
  makeUser = { name, email, ... }@args: {
    inherit name email;
    id = builtins.hashString "md5" name;
  };
in
  makeUser { name = "alice"; email = "alice@example.com"; }
```

## Advanced Language Features

### Let Expressions

The `let` expression allows you to define local variables:

```nix
let
  x = 10;
  y = 20;
  sum = x + y;
in
  "The sum is ${toString sum}"  # Returns "The sum is 30"
```

### With Expressions

The `with` expression brings attributes from a set into scope:

```nix
let
  settings = {
    color = "blue";
    size = "large";
    opacity = 0.8;
  };
in
  with settings; "A ${size} ${color} box with ${toString opacity} opacity"
```

### Inherit Keyword

The `inherit` keyword simplifies creating attribute sets with variables of the same name:

```nix
let
  name = "John";
  age = 42;
in
  {
    inherit name age;  # Equivalent to { name = name; age = age; }
    occupation = "Developer";
  }
```

## Practical Example: Creating a Development Environment

Here's a simple example showing how Nix can define a reproducible development environment:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs-18_x
    yarn
    postgresql_15
    redis
  ];
  
  shellHook = ''
    echo "Node.js development environment ready!"
    echo "Node: $(node --version)"
    echo "Yarn: $(yarn --version)"
    echo "PostgreSQL: $(psql --version)"
  '';
}
```

This simple file creates a complete development environment with specific versions of Node.js, Yarn, PostgreSQL, and Redis, ensuring every developer has identical tooling regardless of their host operating system.

## Importing and Using Packages

In Nix, you import packages and other Nix expressions using the `import` keyword:

```nix
# Import the standard package collection
let
  pkgs = import <nixpkgs> {};
in
  pkgs.hello

# Import a specific file
let 
  myModule = import ./my-module.nix;
in
  myModule.someFunction

# Import with arguments
let
  nixpkgs = import <nixpkgs> { 
    config = { allowUnfree = true; }; 
    system = "x86_64-linux";
  };
in
  nixpkgs.vscode  # Now we can access non-free packages like VSCode
```

## Working with Derivations

Derivations are the core build primitive in Nix. They represent a build action and its inputs:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "my-application";
  version = "1.0.0";
  
  src = ./src;  # Path to source code
  
  buildInputs = with pkgs; [
    gcc
    cmake
    zlib
  ];
  
  configurePhase = ''
    cmake .
  '';
  
  buildPhase = ''
    make
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp my-app $out/bin/
  '';
}
```

## Debugging Nix Expressions

When your Nix expressions don't behave as expected, these techniques can help:

```nix
# Print values for debugging
builtins.trace "The value of x is: ${toString x}" x

# Pretty-print complex data structures
builtins.trace (builtins.toJSON myData) result

# Show the derivation path without building
let
  drv = pkgs.hello;
in
  builtins.trace "Derivation path: ${drv.drvPath}" drv
```

## Best Practices for Nix Development

1. **Keep Functions Pure**: Avoid side effects in functions for predictable behavior.

2. **Use Pin/Lock Files**: Pin your nixpkgs version for reproducibility:

   ```nix
   { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-23.05.tar.gz") {} }:
   ```

3. **Modularize Your Code**: Break complex configurations into separate files:

   ```
   my-project/
   ├── default.nix
   ├── shell.nix
   ├── modules/
   │   ├── development.nix
   │   └── services.nix
   └── overlays/
       └── custom-packages.nix
   ```

4. **Document Your Code**: Add comments to explain complex expressions or non-obvious choices.

5. **Test Configurations**: Use `nix-shell -p nix-diff` to compare derivations before and after changes.

## Next Steps

In the following sections, we'll explore Nix language constructs in more detail, learning how to build increasingly complex and useful configurations for your DevOps workflows.

For deeper dives into specific topics:

- [Nix Functions and Techniques](./nix-functions.md)
- [Building Packages with Nix](./building-packages.md)
- [NixOS Configuration Patterns](./nixos-patterns.md)
- [Flakes: The Future of Nix](./flakes.md)