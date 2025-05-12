#!/usr/bin/env node

/**
 * Script to add additional language support to HonKit's highlight.js
 */

const fs = require('fs');
const path = require('path');

// Find the highlight.js module path
function findHighlightJsPath() {
  const possiblePaths = [
    path.join(process.env.NPM_CONFIG_PREFIX || '', 'lib/node_modules/honkit/node_modules/highlight.js'),
    '/home/olafkfreund/Source/wiki/.npm-global/lib/node_modules/honkit/node_modules/highlight.js',
    '/usr/local/lib/node_modules/honkit/node_modules/highlight.js',
    './node_modules/highlight.js'
  ];
  
  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      return p;
    }
  }
  return null;
}

// Register additional languages
async function registerLanguages() {
  try {
    const hlJsPath = findHighlightJsPath();
    if (!hlJsPath) {
      console.error('Could not find highlight.js module. Please install it manually.');
      process.exit(1);
    }

    console.log(`Found highlight.js at: ${hlJsPath}`);
    
    // Create directory for custom languages if it doesn't exist
    const customLangDir = path.join(process.cwd(), 'node_modules/custom-languages');
    if (!fs.existsSync(customLangDir)) {
      fs.mkdirSync(customLangDir, { recursive: true });
    }

    // Create HCL language definition
    const hclLangPath = path.join(customLangDir, 'hcl.js');
    fs.writeFileSync(hclLangPath, `
module.exports = function(hljs) {
  return {
    name: 'hcl',
    case_insensitive: true,
    keywords: {
      keyword: 'resource provider variable data terraform module output locals',
      literal: 'true false null'
    },
    contains: [
      hljs.COMMENT('//','$'),
      hljs.COMMENT('#','$'),
      hljs.COMMENT('/\\\\*', '\\\\*/'),
      {
        beginKeywords: 'resource',
        end: '\\\\{',
        contains: [hljs.QUOTE_STRING_MODE]
      },
      {
        className: 'string',
        begin: '"',
        end: '"',
        contains: [{
          className: 'variable',
          begin: '\\\\${',
          end: '\\\\}',
          contains: [hljs.BACKSLASH_ESCAPE]
        }],
        illegal: '\\\\n'
      },
      {
        className: 'number',
        begin: '\\\\b\\\\d+(\\\\.\\\\d+)?',
        relevance: 0
      }
    ]
  };
};
    `);

    // Create Bicep language definition
    const bicepLangPath = path.join(customLangDir, 'bicep.js');
    fs.writeFileSync(bicepLangPath, `
module.exports = function(hljs) {
  return {
    name: 'bicep',
    keywords: {
      keyword: 'param var resource module output targetScope import as existing for if',
      built_in: 'string int bool array object',
      literal: 'true false null'
    },
    contains: [
      hljs.QUOTE_STRING_MODE,
      hljs.NUMBER_MODE,
      hljs.COMMENT('//', '$'),
      hljs.COMMENT('/\\\\*', '\\\\*/'),
      {
        className: 'function',
        beginKeywords: 'resource module',
        end: '\\\\{',
        excludeEnd: true,
        contains: [
          hljs.TITLE_MODE,
          {
            className: 'string',
            begin: "'",
            end: "'"
          },
          {
            className: 'string',
            begin: '@',
            end: '\\\\('
          }
        ]
      }
    ]
  };
};
    `);

    // Create a script to patch highlight.js
    const patchScript = path.join(customLangDir, 'register-languages.js');
    fs.writeFileSync(patchScript, `
// This script registers custom languages with highlight.js
const hcl = require('./hcl');
const bicep = require('./bicep');
const hljs = require('${hlJsPath}');

// Register custom languages
hljs.registerLanguage('hcl', hcl);
hljs.registerLanguage('bicep', bicep);
hljs.registerLanguage('markup', hljs.getLanguage('xml'));

// Alias terraform to hcl
hljs.registerAliases('terraform', { languageName: 'hcl' });

console.log('Custom languages successfully registered with highlight.js!');
    `);

    // Create package.json for custom-languages
    const packageJsonPath = path.join(customLangDir, 'package.json');
    fs.writeFileSync(packageJsonPath, JSON.stringify({
      name: "custom-languages",
      version: "1.0.0",
      description: "Custom language definitions for HonKit syntax highlighting",
      main: "register-languages.js",
      author: "DevOps Knowledge Base",
      license: "MIT"
    }, null, 2));

    console.log('Custom language definitions created successfully!');
    
    // Add a script to modify book.json to load custom languages
    console.log('Now creating script to modify honkit initialization...');

    // Find HonKit plugin highlight path
    const honkitPluginPath = path.join(path.dirname(hlJsPath), '../@honkit/honkit-plugin-highlight/index.js');
    if (fs.existsSync(honkitPluginPath)) {
      console.log(`Found HonKit plugin highlight at: ${honkitPluginPath}`);
      console.log('Backing up original file...');
      
      // Back up original file
      fs.copyFileSync(honkitPluginPath, `${honkitPluginPath}.backup`);
      
      // Read the original file
      const pluginContent = fs.readFileSync(honkitPluginPath, 'utf8');
      
      // Modify to preload our custom languages
      const modifiedContent = pluginContent.replace(
        'module.exports = {',
        `// Load custom languages
require('${customLangDir}/register-languages.js');

module.exports = {`
      );
      
      // Write the modified file
      fs.writeFileSync(honkitPluginPath, modifiedContent);
      console.log('HonKit plugin highlight successfully patched!');
    } else {
      console.log('Could not find HonKit plugin highlight. Manual installation required.');
    }

    console.log('\nCustom language support has been added to HonKit!');
    console.log('Please try running your preview script again.');
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

registerLanguages();