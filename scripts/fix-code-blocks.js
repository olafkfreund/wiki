#!/usr/bin/env node

/**
 * Script to fix code block formatting issues in HonKit documentation
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const { exec } = require('child_process');
const execAsync = promisify(exec);

// Find all markdown files in the project
async function findMarkdownFiles(baseDir) {
  const { stdout } = await execAsync(`find ${baseDir} -name "*.md" -not -path "*/_book/*" -not -path "*/node_modules/*"`);
  return stdout.split('\n').filter(Boolean);
}

// Fix code blocks in a markdown file
function fixCodeBlocks(filePath) {
  console.log(`Processing ${filePath}...`);
  let content = fs.readFileSync(filePath, 'utf-8');
  let modified = false;
  
  // Replace problematic raw/code combinations
  // Pattern 1: {% raw %}```language ... ```{% endraw %}
  const pattern1 = /{%\s*raw\s*%}(```[\s\S]*?```){%\s*endraw\s*%}/g;
  if (pattern1.test(content)) {
    content = content.replace(pattern1, (match, codeBlock) => {
      modified = true;
      return `{% code %}\n${codeBlock}\n{% endcode %}`;
    });
  }
  
  // Pattern 2: Fix when there are raw tags inside code blocks
  const pattern2 = /```([a-zA-Z0-9]+)\n{%\s*raw\s*%}([\s\S]*?){%\s*endraw\s*%}\n```/g;
  if (pattern2.test(content)) {
    content = content.replace(pattern2, (match, lang, code) => {
      modified = true;
      return `{% code lang="${lang}" %}\n\`\`\`${lang}\n${code}\n\`\`\`\n{% endcode %}`;
    });
  }
  
  // Pattern 3: Add proper language to code blocks without language
  const pattern3 = /```\n/g;
  if (pattern3.test(content)) {
    content = content.replace(pattern3, '```plaintext\n');
    modified = true;
  }
  
  // Pattern 4: Fix tabs within code blocks
  const pattern4 = /{%\s*tabs\s*%}([\s\S]*?){%\s*endtabs\s*%}/g;
  if (pattern4.test(content)) {
    content = content.replace(pattern4, (match, tabsContent) => {
      // Fix code blocks within tabs
      return match.replace(/```([a-zA-Z0-9]*)([\s\S]*?)```/g, (m, lang, code) => {
        modified = true;
        return `{% code lang="${lang || 'plaintext'}" %}\n\`\`\`${lang || 'plaintext'}\n${code}\n\`\`\`\n{% endcode %}`;
      });
    });
  }
  
  // Only write back if we made changes
  if (modified) {
    console.log(`Fixed code blocks in ${filePath}`);
    fs.writeFileSync(filePath, content, 'utf-8');
    return true;
  }
  
  return false;
}

async function main() {
  try {
    const baseDir = path.resolve(__dirname, '..');
    console.log(`Searching for markdown files in ${baseDir}...`);
    
    const files = await findMarkdownFiles(baseDir);
    console.log(`Found ${files.length} markdown files`);
    
    let fixedFiles = 0;
    for (const file of files) {
      if (fixCodeBlocks(file)) {
        fixedFiles++;
      }
    }
    
    console.log(`\nFixed code blocks in ${fixedFiles} files`);
    
    if (fixedFiles > 0) {
      console.log('\nYou should now try running your preview script again:');
      console.log('./scripts/preview-gitbook.sh');
    } else {
      console.log('\nNo code block issues were found.');
    }
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

main();