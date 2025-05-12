#!/bin/bash

# Script to build and preview your documentation locally using HonKit
# HonKit is a maintained fork of GitBook that works with modern Node.js versions

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
fi

# Check if honkit is installed
if ! command -v honkit &> /dev/null; then
  echo "HonKit not found. Installing..."
  npm install -g honkit
  
  if [ $? -ne 0 ]; then
    echo "❌ Failed to install HonKit. Check npm permissions."
    exit 1
  fi
fi

echo "📚 Setting up documentation with HonKit..."

# Run the fix scripts first
echo "🔧 Fixing code blocks in documentation files..."
./scripts/fix-code-blocks.js

echo "🔧 Adding support for additional programming languages..."
./scripts/fix-highlighting.js

# Install the required plugins using our plugin installer script
echo "📦 Installing required plugins..."
./scripts/install-honkit-plugins.sh

# Build the book
echo "🔨 Building documentation..."
honkit build

# Serve the book for preview
echo "🚀 Starting local server at http://localhost:4000"
echo "Press Ctrl+C to stop the server"
honkit serve