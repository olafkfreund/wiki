{pkgs ? import <nixpkgs> {}}: let
  bun = pkgs.bun;
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      # Core dependencies
      nodejs_20
      bun

      # Development tools
      nodePackages.prettier
      nodePackages.markdownlint-cli
      nodePackages.typescript
      nodePackages.typescript-language-server

      # Build tools
      git
      gnumake
    ];

    shellHook = ''
          # Create local directories
          mkdir -p ./.npm-global
          mkdir -p ./.bun-global
          export NPM_CONFIG_PREFIX=$PWD/.npm-global
          export BUN_INSTALL=$PWD/.bun-global
          export PATH=$NPM_CONFIG_PREFIX/bin:$BUN_INSTALL/bin:$PATH

          # GitBook development functions
          function gitbook-setup() {
            echo "Setting up GitBook development environment..."
            git clone https://github.com/gitbookIO/gitbook.git
            cd gitbook
            bun install
            echo "✅ GitBook setup complete"
          }

          function gitbook-dev() {
            echo "Starting GitBook development server..."
            bun dev:v2
          }

          function gitbook-format() {
            echo "Formatting GitBook codebase..."
            bun format
          }

          function gitbook-lint() {
            echo "Linting GitBook codebase..."
            bun lint
          }

          # Markdown formatting functions
          function fmt-md() {
            echo "Formatting Markdown files..."
            prettier --write "**/*.md"
            echo "✅ Markdown formatting complete"
          }

          function lint-md() {
            echo "Linting Markdown files..."
            markdownlint "**/*.md"
            echo "✅ Markdown linting complete"
          }

          function fmt-check() {
            echo "Checking Markdown formatting..."
            prettier --check "**/*.md"
          }

          # Aliases
          alias setup='gitbook-setup'
          alias dev='gitbook-dev'
          alias gformat='gitbook-format'
          alias glint='gitbook-lint'
          alias fmt='fmt-md'
          alias lint='lint-md'
          alias check='fmt-check'

          # Create configuration files
          if [ ! -f .prettierrc ]; then
            cat > .prettierrc <<EOF
      {
        "proseWrap": "preserve",
        "tabWidth": 2,
        "useTabs": false,
        "singleQuote": false,
        "printWidth": 100
      }
      EOF
            echo "Created .prettierrc configuration file"
          fi

          if [ ! -f .env.local ]; then
            cat > .env.local <<EOF
      PORT=3000
      NODE_ENV=development
      EOF
            echo "Created .env.local configuration file"
          fi

          echo "GitBook Development Environment"
          echo ""
          echo "Available commands:"
          echo "  setup    - Clone and setup GitBook repository"
          echo "  dev      - Start development server"
          echo "  gformat  - Format GitBook codebase"
          echo "  glint    - Lint GitBook codebase"
          echo "  fmt      - Format Markdown files"
          echo "  lint     - Lint Markdown files"
          echo "  check    - Check formatting"
          echo ""
          echo "Development server will be available at:"
          echo "  http://localhost:3000/url/docs.gitbook.com"
    '';

    # Environment variables
    NODE_ENV = "development";
    LANG = "en_US.UTF-8";
  }
