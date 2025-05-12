#!/bin/bash

# Script to build and preview your GitBook locally

# Create necessary directories
mkdir -p _book

# Check if gitbook-cli is installed
if ! command -v gitbook &> /dev/null; then
    echo "GitBook CLI not found. Installing..."
    npm install -g gitbook-cli
fi

# Install GitBook plugins defined in book.json
echo "Installing GitBook plugins..."
gitbook install

# Build the book
echo "Building GitBook..."
gitbook build

# Serve the book for preview
echo "Starting local server at http://localhost:4000"
echo "Press Ctrl+C to stop the server"
gitbook serve