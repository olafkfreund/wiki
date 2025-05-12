#!/bin/bash

# Script to install GitBook plugins that are compatible with HonKit

echo "Installing plugins for HonKit..."

# Create node_modules directory if it doesn't exist
mkdir -p ./node_modules

# Install plugins with original GitBook names
npm install --save-dev gitbook-plugin-expandable-chapters
npm install --save-dev gitbook-plugin-copy-code-button
npm install --save-dev gitbook-plugin-hints
npm install --save-dev gitbook-plugin-include-codeblock
npm install --save-dev gitbook-plugin-advanced-emoji
npm install --save-dev gitbook-plugin-anchors
npm install --save-dev gitbook-plugin-edit-link
npm install --save-dev gitbook-plugin-include
npm install --save-dev gitbook-plugin-search-pro
npm install --save-dev gitbook-plugin-tabs
npm install --save-dev gitbook-plugin-github
npm install --save-dev gitbook-plugin-theme-comscore
npm install --save-dev gitbook-plugin-insert-logo

# Create a package.json file if it doesn't exist
if [ ! -f "./package.json" ]; then
  echo '{
  "name": "devops-knowledge-base",
  "version": "1.0.0",
  "description": "DevOps Knowledge Base",
  "main": "index.js",
  "scripts": {
    "start": "honkit serve",
    "build": "honkit build"
  },
  "keywords": ["devops", "documentation"],
  "author": "Olaf K Freund",
  "license": "MIT"
}' > ./package.json
fi

echo "Plugin installation completed!"