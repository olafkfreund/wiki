#!/bin/bash

# Script to install HonKit plugins that are compatible with your configuration

echo "Installing HonKit plugins..."

# Create node_modules directory if it doesn't exist
mkdir -p ./node_modules

# Install HonKit-compatible plugins
npm install --save-dev honkit-plugin-expandable-chapters
npm install --save-dev honkit-plugin-copy-code-button
npm install --save-dev honkit-plugin-hints
npm install --save-dev honkit-plugin-include-codeblock
npm install --save-dev honkit-plugin-advanced-emoji
npm install --save-dev honkit-plugin-anchors
npm install --save-dev honkit-plugin-edit-link
npm install --save-dev honkit-plugin-include
npm install --save-dev honkit-plugin-search-pro
npm install --save-dev honkit-plugin-tabs
npm install --save-dev honkit-plugin-github
npm install --save-dev honkit-plugin-theme-comscore

# Note: Some plugins might not have direct HonKit equivalents
# In that case, you might need to use GitBook plugins that are compatible with HonKit

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

echo "HonKit plugins installation completed!"