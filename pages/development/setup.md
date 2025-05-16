# Development Setup

## Prerequisites

- Node.js (Version: >=20.6)
- Bun (Version: >=1.2.1)

## Environment Setup

Our development environment is managed through `nix-shell`, which ensures consistent dependencies across all development machines.

To get started:

1. Enter the development environment:

   ```bash
   nix-shell
   ```

2. Set up the GitBook repository:

   ```bash
   setup
   ```

3. Start the development server:

   ```bash
   dev
   ```

## Available Commands

- `dev` - Start the development server
- `gformat` - Format the codebase
- `glint` - Lint the codebase
