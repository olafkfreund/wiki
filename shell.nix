{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Use nodejs v20 which has better compatibility with GitBook CLI than v22+
    nodejs_20

    # Optional: Include other tools you might need
    git
  ];

  shellHook = ''
    # Create a local npm prefix directory
    mkdir -p ./.npm-global
    export NPM_CONFIG_PREFIX=$PWD/.npm-global
    export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

    echo "Node.js GitBook environment activated."
    echo "Run 'npm install -g gitbook-cli' to install GitBook CLI locally."
  '';
}
