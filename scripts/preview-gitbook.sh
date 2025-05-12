#!/bin/bash

# Script to build and preview your GitBook locally in a Nix environment

# Ensure we're in the root directory of the wiki
cd "$(dirname "$0")/.." || exit 1

# Create necessary directories
mkdir -p _book

# Check if we're in a Nix environment
if [[ -f "/nix/store" ]]; then
  echo "📦 Nix environment detected"
  
  # Check if we're in a nix-shell
  if [[ -z "$IN_NIX_SHELL" ]]; then
    echo "⚠️ This script should be run inside a nix-shell environment."
    echo "Please run 'nix-shell' first, then run this script again."
    exit 1
  fi
  
  # We're in a nix-shell, check if gitbook-cli is installed in our local prefix
  if ! command -v gitbook &> /dev/null; then
    echo "Installing GitBook CLI to local prefix..."
    npm install -g gitbook-cli
    
    if [ $? -ne 0 ]; then
      echo "❌ Failed to install GitBook CLI. Make sure your NPM_CONFIG_PREFIX is set correctly."
      exit 1
    fi
  fi
else
  # Regular environment handling
  # Get Node.js version
  NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)

  # Check if Node.js version is >= 17
  if [ "$NODE_VERSION" -ge 17 ]; then
    echo "⚠️ Detected Node.js v$(node -v) which has compatibility issues with GitBook CLI"
    echo "Attempting to patch GitBook CLI for compatibility..."
    
    # Check if gitbook-cli is installed
    if ! command -v gitbook &> /dev/null; then
      echo "GitBook CLI not found. Installing..."
      npm install -g gitbook-cli
    fi
    
    # Create patch file
    PATCH_SCRIPT=$(mktemp)
    cat > "$PATCH_SCRIPT" << 'EOF'
const fs = require('fs');
const path = require('path');

function findGracefulFs() {
  // Common paths for global node_modules
  const possiblePaths = [
    path.join(process.env.NODE_PATH || '', 'gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js'),
    '/usr/local/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js',
    '/usr/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js',
    path.join(require('os').homedir(), '.npm-global/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js'),
    // Add more paths if needed
  ];
  
  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      return p;
    }
  }
  return null;
}

const gracefulFsPath = findGracefulFs();

if (!gracefulFsPath) {
  console.error('Could not find graceful-fs polyfills.js file. Manual patching required.');
  process.exit(1);
}

// Read the file content
const content = fs.readFileSync(gracefulFsPath, 'utf8');

// Check if already patched
if (content.includes('typeof cb === "function"')) {
  console.log('Already patched!');
  process.exit(0);
}

// Replace the problematic code
const patchedContent = content.replace(
  'if (cb) cb.apply(this, arguments)',
  'if (cb && typeof cb === "function") cb.apply(this, arguments)'
);

// Write the patched content back
fs.writeFileSync(gracefulFsPath, patchedContent);
console.log('GitBook CLI has been patched successfully!');
EOF

    # Run the patch script
    node "$PATCH_SCRIPT"
    PATCH_RESULT=$?
    rm "$PATCH_SCRIPT"
    
    if [ $PATCH_RESULT -ne 0 ]; then
      echo "⚠️ Automatic patching failed. You have two options:"
      echo "1. Install an older Node.js version (recommended v16.x)"
      echo "   nvm install 16 && nvm use 16"
      echo "2. Use HonKit instead of GitBook CLI:"
      echo "   npm uninstall -g gitbook-cli && npm install -g honkit"
      exit 1
    fi
  else
    # Check if gitbook-cli is installed
    if ! command -v gitbook &> /dev/null; then
      echo "GitBook CLI not found. Installing..."
      npm install -g gitbook-cli
    fi
  fi
fi

echo "📚 Setting up GitBook..."

# Path to the gitbook binary - search in multiple locations
GITBOOK_BIN=$(which gitbook 2>/dev/null || echo "$NPM_CONFIG_PREFIX/bin/gitbook")

if [[ ! -x "$GITBOOK_BIN" ]]; then
  echo "❌ Cannot find gitbook executable. Please ensure it's installed and in your PATH."
  exit 1
fi

# Install GitBook plugins defined in book.json
echo "Installing GitBook plugins..."
"$GITBOOK_BIN" install

# Build the book
echo "Building GitBook..."
"$GITBOOK_BIN" build

# Serve the book for preview
echo "Starting local server at http://localhost:4000"
echo "Press Ctrl+C to stop the server"
"$GITBOOK_BIN" serve