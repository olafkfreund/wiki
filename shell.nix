{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_24
    bun
    nodePackages.prettier
    nodePackages.markdownlint-cli
    nodePackages.typescript
    nodePackages.typescript-language-server
    git
    gnumake
  ];

  shellHook = ''
    # Tracked, editable scripts live in ./scripts — put them on PATH.
    export PATH="$PWD/scripts:$PATH"

    # Per-shell package caches kept inside the repo (gitignored).
    mkdir -p ./.npm-global ./.bun-global
    export NPM_CONFIG_PREFIX="$PWD/.npm-global"
    export BUN_INSTALL="$PWD/.bun-global"
    export PATH="$NPM_CONFIG_PREFIX/bin:$BUN_INSTALL/bin:$PATH"

    if [ ! -f .env.local ]; then
      printf 'PORT=3000\nNODE_ENV=development\n' > .env.local
    fi

    cat <<'BANNER'
    GitBook Development Environment

    Commands (from ./scripts):
      setup       - Clone the upstream GitBook repo
      setup-force - Re-clone, removing any existing checkout
      setup-hooks - Install the markdown pre-commit hook
      update      - git pull + bun install inside ./gitbook
      dev         - Start the GitBook dev server (http://localhost:3000)
      gformat     - Run GitBook's own formatter
      glint       - Run GitBook's own linter
      fmt         - Format Markdown (prettier)
      lint        - Lint Markdown (markdownlint)
      check       - Verify Markdown formatting without changes
      publish     - Format, lint, commit, and push markdown changes

    Tip: run 'setup-hooks' once to format/lint staged markdown on every commit.
    BANNER
  '';

  NODE_ENV = "development";
  LANG = "en_US.UTF-8";
}
