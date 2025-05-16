{pkgs ? import <nixpkgs> {}}: let
  bun = pkgs.bun;
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      # Core dependencies
      nodejs_24
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
          # Ensure bin directory exists
          mkdir -p $PWD/bin
          export PATH=$PWD/bin:$PATH

          # Create local directories
          mkdir -p ./.npm-global
          mkdir -p ./.bun-global
          export NPM_CONFIG_PREFIX=$PWD/.npm-global
          export BUN_INSTALL=$PWD/.bun-global
          export PATH=$NPM_CONFIG_PREFIX/bin:$BUN_INSTALL/bin:$PATH

          # Create setup script in bin directory
          cat > $PWD/bin/setup << EOFSETUP
      #!/usr/bin/env bash
      echo "Setting up GitBook development environment..."
      git clone https://github.com/gitbookIO/gitbook.git
      cd gitbook
      bun install
      echo "✅ GitBook setup complete"
      EOFSETUP

          # Create dev script
          cat > $PWD/bin/dev << EOFDEV
      #!/usr/bin/env bash
      cd gitbook
      bun dev:v2
      EOFDEV

          # Create format script
          cat > $PWD/bin/gformat << EOFFORMAT
      #!/usr/bin/env bash
      cd gitbook
      bun format
      EOFFORMAT

          # Create lint script
          cat > $PWD/bin/glint << EOFLINT
      #!/usr/bin/env bash
      cd gitbook
      bun lint
      EOFLINT

          # Create markdown formatting scripts
          cat > $PWD/bin/fmt << EOFFMT
      #!/usr/bin/env bash
      prettier --write "**/*.md"
      EOFFMT

          cat > $PWD/bin/lint << EOFLINTMD
      #!/usr/bin/env bash
      markdownlint "**/*.md"
      EOFLINTMD

          cat > $PWD/bin/check << EOFCHECK
      #!/usr/bin/env bash
      prettier --check "**/*.md"
      EOFCHECK

          # Create update script
          cat > $PWD/bin/update << EOFUPDATE
      #!/usr/bin/env bash
      echo "Updating GitBook development environment..."
      if [ -d "gitbook" ] && [ -d "gitbook/.git" ]; then
        cd gitbook
        git pull
        bun install
        echo "✅ GitBook update complete"
      else
        echo "❌ GitBook directory not properly initialized."
        echo "   Consider running 'setup-force' to reinitialize."
      fi
      EOFUPDATE

          # Create force setup script
          cat > $PWD/bin/setup-force << EOFSETUPFORCE
      #!/usr/bin/env bash
      echo "Force setting up GitBook development environment..."
      if [ -d "gitbook" ]; then
        echo "Removing existing GitBook directory..."
        rm -rf gitbook
      fi
      git clone https://github.com/gitbookIO/gitbook.git
      cd gitbook
      bun install
      echo "✅ GitBook setup complete"
      EOFSETUPFORCE

          chmod +x $PWD/bin/setup
          chmod +x $PWD/bin/setup-force
          chmod +x $PWD/bin/update
          chmod +x $PWD/bin/dev
          chmod +x $PWD/bin/gformat
          chmod +x $PWD/bin/glint
          chmod +x $PWD/bin/fmt
          chmod +x $PWD/bin/lint
          chmod +x $PWD/bin/check

          # Create configuration files
          if [ ! -f .prettierrc ]; then
            cat > .prettierrc << EOFPRETTIER
      {
        "proseWrap": "preserve",
        "tabWidth": 2,
        "useTabs": false,
        "singleQuote": false,
        "printWidth": 100
      }
      EOFPRETTIER
          fi

          if [ ! -f .env.local ]; then
            cat > .env.local << EOFENV
      PORT=3000
      NODE_ENV=development
      EOFENV
          fi

          echo "GitBook Development Environment"
          echo ""
          echo "Available commands:"
          echo "  setup       - Clone and setup GitBook repository ( only for empty gitbook )"
          echo "  setup-force - Force setup (removes existing directory gitbook )"
          echo "  update      - Update existing GitBook repository"
          echo "  dev         - Start development server"
          echo "  gformat     - Format GitBook codebase"
          echo "  glint       - Lint GitBook codebase"
          echo "  fmt         - Format Markdown files"
          echo "  lint        - Lint Markdown files"
          echo "  check       - Check formatting"
          echo ""
          echo "Development server will be available at:"
          echo "  http://localhost:3000/url/docs.gitbook.com"
    '';

    # Environment variables
    NODE_ENV = "development";
    LANG = "en_US.UTF-8";
  }
