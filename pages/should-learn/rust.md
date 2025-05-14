# Rust

## Introduction
Rust is a systems programming language that focuses on safety, concurrency, and performance. It provides memory safety without garbage collection and thread safety without data races.

## Key Features
- 🔒 Memory safety without garbage collection
- 🔄 Concurrency without data races
- 🚀 Zero-cost abstractions
- 📦 Package management via Cargo
- 🛠️ Cross-platform development

## Pros
1. **Memory Safety**
   - Compile-time memory management
   - No null pointer dereferences
   - No data races

2. **Performance**
   - Zero-cost abstractions
   - Direct hardware access
   - Minimal runtime overhead

3. **Modern Tooling**
   - Built-in package manager (Cargo)
   - Integrated testing framework
   - Documentation generator (rustdoc)

## Cons
1. **Learning Curve**
   - Strict compiler
   - Complex ownership model
   - Different paradigm from other languages

2. **Compilation Time**
   - Longer compile times compared to Go/C++
   - Complex template resolution

3. **Ecosystem Maturity**
   - Younger ecosystem compared to C++
   - Fewer third-party libraries

## Installation Guide

### Linux (Ubuntu/Debian)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### NixOS
```nix
# Add to configuration.nix
environment.systemPackages = with pkgs; [
  rustc
  cargo
  rustfmt
  rust-analyzer
];
```

### Windows Subsystem for Linux (WSL)
```bash
# Install build essentials first
sudo apt update
sudo apt install build-essential

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Development Environment Setup

### VS Code Extensions
- rust-analyzer: Intelligent Rust language support
- CodeLLDB: Debugging support
- crates: Dependency management

### Essential Tools
```bash
# Install common tools
rustup component add rustfmt  # Code formatter
rustup component add clippy   # Linter
rustup component add rls      # Legacy language server
cargo install cargo-edit     # Dependency management
```

## Real-Life Examples

### 1. HTTP Server
```rust
use actix_web::{web, App, HttpResponse, HttpServer};

async fn hello() -> HttpResponse {
    HttpResponse::Ok().body("Hello, World!")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new().route("/", web::get().to(hello))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

To run:
```bash
cargo new my_server
cd my_server
# Add to Cargo.toml:
# [dependencies]
# actix-web = "4.0"
cargo run
```

### 2. System Monitor
```rust
use sysinfo::{System, SystemExt};

fn main() {
    let mut sys = System::new_all();
    sys.refresh_all();

    println!("Memory: {} used / {} total", 
        sys.used_memory(),
        sys.total_memory());
    
    println!("CPU Usage: {}%", 
        sys.global_cpu_info().cpu_usage());
}
```

To run:
```bash
cargo new system_monitor
cd system_monitor
# Add to Cargo.toml:
# [dependencies]
# sysinfo = "0.29"
cargo run
```

### 3. Concurrent File Processing
```rust
use tokio::fs;
use futures::stream::{StreamExt};
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let mut entries = fs::read_dir(".").await?;
    let mut handles = vec![];

    while let Some(entry) = entries.next_entry().await? {
        let handle = tokio::spawn(async move {
            let metadata = entry.metadata().await?;
            println!("{}: {} bytes", 
                entry.file_name().to_string_lossy(),
                metadata.len());
            Ok::<(), std::io::Error>(())
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.await??;
    }

    Ok(())
}
```

To run:
```bash
cargo new file_processor
cd file_processor
# Add to Cargo.toml:
# [dependencies]
# tokio = { version = "1.0", features = ["full"] }
# futures = "0.3"
cargo run
```

## Building and Testing

### Debug Build
```bash
cargo build        # Debug build
cargo run         # Build and run
cargo test        # Run tests
```

### Release Build
```bash
cargo build --release  # Optimized build
cargo run --release   # Run optimized build
```

### Cross-Compilation
```bash
# Add target
rustup target add x86_64-unknown-linux-musl

# Build for target
cargo build --target x86_64-unknown-linux-musl
```

## Best Practices

1. **Error Handling**
   - Use Result for recoverable errors
   - Use panic! for unrecoverable errors
   - Implement custom error types

2. **Project Structure**
   - Follow the standard cargo project layout
   - Use modules to organize code
   - Separate binary and library crates

3. **Testing**
   - Write unit tests in the same file as code
   - Use integration tests for external behavior
   - Implement benchmark tests for performance

4. **Documentation**
   - Document public APIs
   - Include examples in documentation
   - Use cargo doc to generate documentation

## Popular Rust Tools and Libraries

- **Web Frameworks**: Actix-web, Rocket, Warp
- **ORMs**: Diesel, SQLx
- **Async Runtime**: Tokio, async-std
- **CLI Tools**: clap, structopt
- **Serialization**: serde
- **HTTP Client**: reqwest
- **Testing**: proptest, mockall

## Resources

1. **Official**
   - [The Rust Book](https://doc.rust-lang.org/book/)
   - [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
   - [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/)

2. **Community**
   - [Rust Forum](https://users.rust-lang.org/)
   - [This Week in Rust](https://this-week-in-rust.org/)
   - [/r/rust](https://reddit.com/r/rust)

