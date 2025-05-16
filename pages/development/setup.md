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

### GitBook Development

- `setup` - Clone and setup GitBook repository
- `setup-force` - Force setup (removes existing directory)
- `update` - Update existing GitBook repository
- `rebuild` - Rebuild GitBook packages if there are module errors
- `dev` - Start the development server
- `gformat` - Format GitBook codebase
- `glint` - Lint GitBook codebase

### Markdown Formatting

- `fmt` - Format Markdown files
- `lint` - Lint Markdown files
- `check` - Check formatting

## Troubleshooting

### Module Resolution Errors

If you encounter errors like:
```
Error: Cannot find module '/path/to/gitbook/node_modules/@gitbook/colors/dist/index.js'
```

Run the rebuild script:
```bash
rebuild
```

This script:
1. Cleans previous build artifacts
2. Reinstalls dependencies with `bun install --force`
3. Rebuilds all packages

After completion, try running `dev` again to start the development server.

### Repository Already Exists

If you get an error about the GitBook directory already existing:

```
fatal: destination path 'gitbook' already exists and is not an empty directory.
```

Use one of these commands:
- `update` - Pull latest changes if the repository exists
- `setup-force` - Remove existing directory and set up fresh

## Development Server

The GitBook development server will be available at:
```
http://localhost:3000/url/docs.gitbook.com
```

You can access any published GitBook space by prefixing its URL with `http://localhost:3000/url/`.

For example:
- `http://localhost:3000/url/docs.gitbook.com`
- `http://localhost:3000/url/open-source.gitbook.io/midjourney`
