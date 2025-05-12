{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Use nodejs v20 which has better compatibility with GitBook CLI than v22+
    nodejs_20

    # Markdown formatting and linting tools
    nodePackages.prettier
    nodePackages.markdownlint-cli

    # Optional: Include other tools you might need
    git
    gnumake # For the makefile commands
  ];

  shellHook = ''
        # Create a local npm prefix directory
        mkdir -p ./.npm-global
        export NPM_CONFIG_PREFIX=$PWD/.npm-global
        export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

        # Create helpful functions for formatting Markdown
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

        # Create local aliases for the commands
        alias fmt='fmt-md'
        alias lint='lint-md'
        alias check='fmt-check'

        # Create or update a .prettierrc file if it doesn't exist
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

        echo "Node.js GitBook environment activated."
        echo "Run 'npm install -g @gitbook/cli' to install GitBook CLI locally."
        echo ""
        echo "Markdown formatting commands:"
        echo "  fmt      - Format all Markdown files"
        echo "  lint     - Lint all Markdown files"
        echo "  check    - Check formatting without modifying files"
  '';
}
