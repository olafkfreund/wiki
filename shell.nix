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

          # Create publish script
          cat > $PWD/bin/publish << EOFPUBLISH
      #!/usr/bin/env bash
      set -e  # Exit on any error

      echo "📝 Publishing changes..."
      echo ""

      # Step 1: Format markdown files
      echo "1️⃣  Formatting markdown files..."
      if ! prettier --write "**/*.md"; then
        echo "❌ Formatting failed"
        exit 1
      fi
      echo "✅ Formatting complete"
      echo ""

      # Step 2: Lint markdown files
      echo "2️⃣  Linting markdown files..."
      if ! markdownlint "**/*.md"; then
        echo "❌ Linting failed - please fix errors above"
        exit 1
      fi
      echo "✅ Linting complete"
      echo ""

      # Step 3: Check git status
      if [ -z "\$(git status --porcelain)" ]; then
        echo "ℹ️  No changes to commit"
        exit 0
      fi

      # Step 4: Show changes
      echo "3️⃣  Changed files:"
      git status --short
      echo ""

      # Step 5: Prompt for commit message
      echo "4️⃣  Enter commit message (or press Ctrl+C to cancel):"
      read -r commit_message

      if [ -z "\$commit_message" ]; then
        echo "❌ Commit message cannot be empty"
        exit 1
      fi

      # Step 6: Commit changes
      echo ""
      echo "5️⃣  Committing changes..."
      git add -A
      git commit -m "\$commit_message

      🤖 Generated with [Claude Code](https://claude.com/claude-code)

      Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
      echo "✅ Changes committed"
      echo ""

      # Step 7: Push to remote
      echo "6️⃣  Pushing to remote..."
      if ! git push; then
        echo "❌ Push failed - you may need to pull first"
        exit 1
      fi
      echo "✅ Changes pushed successfully"
      echo ""
      echo "🎉 Publish complete!"
      EOFPUBLISH

          # Create pre-commit hook setup script
          cat > $PWD/bin/setup-hooks << EOFHOOKS
      #!/usr/bin/env bash
      echo "Setting up Git hooks..."

      # Create hooks directory if it doesn't exist
      mkdir -p .git/hooks

      # Create pre-commit hook
      cat > .git/hooks/pre-commit << 'EOFPRECOMMIT'
      #!/usr/bin/env bash
      # Pre-commit hook for markdown formatting and linting

      echo "🔍 Running pre-commit checks..."

      # Get list of staged markdown files
      STAGED_MD_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)

      if [ -z "\$STAGED_MD_FILES" ]; then
        echo "ℹ️  No markdown files staged, skipping checks"
        exit 0
      fi

      echo "Checking \$(echo "\$STAGED_MD_FILES" | wc -l) markdown file(s)..."

      # Format staged markdown files
      echo "📝 Formatting..."
      for file in \$STAGED_MD_FILES; do
        if ! prettier --write "\$file"; then
          echo "❌ Failed to format \$file"
          exit 1
        fi
        git add "\$file"
      done

      # Lint staged markdown files
      echo "🔍 Linting..."
      for file in \$STAGED_MD_FILES; do
        if ! markdownlint "\$file"; then
          echo "❌ Linting failed for \$file"
          echo ""
          echo "Fix the errors above or use 'git commit --no-verify' to skip this check"
          exit 1
        fi
      done

      echo "✅ Pre-commit checks passed"
      exit 0
      EOFPRECOMMIT

      # Make pre-commit hook executable
      chmod +x .git/hooks/pre-commit

      echo "✅ Git hooks installed successfully"
      echo ""
      echo "Pre-commit hook will:"
      echo "  - Format staged markdown files with prettier"
      echo "  - Lint staged markdown files with markdownlint"
      echo "  - Prevent commits if linting fails"
      echo ""
      echo "To bypass the hook (not recommended), use: git commit --no-verify"
      EOFHOOKS

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
          chmod +x $PWD/bin/publish
          chmod +x $PWD/bin/setup-hooks

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
          echo "  setup-hooks - Install Git pre-commit hooks for automatic linting"
          echo "  update      - Update existing GitBook repository"
          echo "  dev         - Start development server"
          echo "  gformat     - Format GitBook codebase"
          echo "  glint       - Lint GitBook codebase"
          echo "  fmt         - Format Markdown files"
          echo "  lint        - Lint Markdown files"
          echo "  check       - Check formatting"
          echo "  publish     - Format, lint, commit, and push changes"
          echo ""
          echo "Development server will be available at:"
          echo "  http://localhost:3000/url/docs.gitbook.com"
          echo ""
          echo "💡 Run 'setup-hooks' to enable automatic formatting/linting on commit"
    '';

    # Environment variables
    NODE_ENV = "development";
    LANG = "en_US.UTF-8";
  }
