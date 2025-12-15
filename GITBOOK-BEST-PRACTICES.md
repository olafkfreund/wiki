# GitBook Best Practices

> Comprehensive guide for creating and managing GitBook markdown documents
> Last Updated: 2025-12-15

## Overview

This guide covers best practices for working with GitBook, including markdown formatting, linting, special tags, and file/folder structure specific to GitBook projects.

## Core Requirements

### Minimum Required Files

Every GitBook project MUST have:

1. **README.md** - The home page/introduction
2. **SUMMARY.md** - Table of contents that defines navigation structure
3. **.gitbook.yml** (optional but recommended) - Configuration file

### Critical Workflow Rule

**⚠️ EVERY new page MUST be added to SUMMARY.md**

GitBook uses SUMMARY.md to build navigation. Pages not listed will not appear in the table of contents.

## File and Folder Structure

### Best Practices

1. **Entity-based organization** - Name folders after the entities they represent
   - ✅ Good: `users/`, `authentication/`, `api/`
   - ❌ Bad: `utils/`, `helpers/`, `misc/`

2. **Logical hierarchy** - Group related content together
   ```
   pages/
   ├── cloud/
   │   ├── aws/
   │   ├── azure/
   │   └── gcp/
   ├── devops/
   │   ├── cicd/
   │   ├── governance/
   │   └── monitoring/
   └── kubernetes/
       ├── operators/
       └── security/
   ```

3. **README.md as index** - Use README.md in each directory as the overview/index page

4. **Consistent naming** - Use lowercase with hyphens for multi-word files
   - ✅ `getting-started.md`, `best-practices.md`
   - ❌ `GettingStarted.md`, `best_practices.md`

### Recommended Documentation Structure (Diátaxis Framework)

Organize content into four categories:

1. **Tutorials** - Learning-oriented, step-by-step lessons for beginners
2. **How-To Guides** - Task-oriented, practical steps to solve specific problems
3. **Reference** - Information-oriented, technical descriptions and API docs
4. **Explanation** - Understanding-oriented, conceptual clarification

Example structure:
```
docs/
├── tutorials/
│   └── getting-started.md
├── how-to/
│   ├── deployment.md
│   └── troubleshooting.md
├── reference/
│   ├── api.md
│   └── cli.md
└── explanation/
    ├── architecture.md
    └── concepts.md
```

## GitBook-Specific Markdown Features

### 1. Hints and Callouts

GitBook supports special hint blocks for important information:

```markdown
{% hint style="info" %}
This is an informational hint.
{% endhint %}

{% hint style="success" %}
This indicates something positive or successful.
{% endhint %}

{% hint style="warning" %}
This is a warning to pay attention to.
{% endhint %}

{% hint style="danger" %}
This indicates something dangerous or critical.
{% endhint %}
```

**Styles available:**
- `info` (blue) - General information
- `success` (green) - Positive messages
- `warning` (yellow) - Cautions
- `danger` (red) - Critical warnings

### 2. Tabs

Create tabbed content for multiple options (e.g., different programming languages):

```markdown
{% tabs %}
{% tab title="JavaScript" %}
```javascript
console.log('Hello World');
```
{% endtab %}

{% tab title="Python" %}
```python
print('Hello World')
```
{% endtab %}

{% tab title="Go" %}
```go
fmt.Println("Hello World")
```
{% endtab %}
{% endtabs %}
```

### 3. Code Blocks with Syntax Highlighting

GitBook supports extensive language syntax highlighting:

```markdown
```python
def hello_world():
    print("Hello, World!")
```
```

**Supported languages include:** python, javascript, typescript, bash, yaml, json, go, rust, java, cpp, csharp, ruby, php, sql, dockerfile, terraform, and many more.

### 4. File Embeds

Embed content from other files using relative references:

```markdown
{% embed url="path/to/file.md" %}
Description of embedded content
{% endembed %}
```

### 5. API Method Blocks

Document API endpoints with structured blocks:

```markdown
{% swagger method="get" path="/api/users" baseUrl="https://api.example.com" summary="Get all users" %}
{% swagger-description %}
Retrieve a list of all users in the system.
{% endswagger-description %}

{% swagger-parameter in="query" name="limit" type="integer" %}
Number of results to return
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="Success" %}
```json
{
  "users": [...]
}
```
{% endswagger-response %}
{% endswagger %}
```

### 6. Math Equations

GitBook supports LaTeX math rendering:

**Inline math:**
```markdown
This is an inline equation: $$E = mc^2$$
```

**Block math:**
```markdown
$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

### 7. Variables

Define and use variables across your documentation:

In `.gitbook.yml`:
```yaml
variables:
  version: "2.0.0"
  api_url: "https://api.example.com"
```

In markdown:
```markdown
Current version: {{ version }}
API endpoint: {{ api_url }}
```

### 8. Page References

Link to other pages using relative paths:

```markdown
See the [Getting Started Guide](../guides/getting-started.md) for more information.
```

## Markdown Linting

### markdownlint

**markdownlint** is the standard linting tool for markdown files.

#### Installation

**Node.js version (recommended):**
```bash
npm install -g markdownlint-cli
```

**Ruby version:**
```bash
gem install mdl
```

#### Configuration

Create `.markdownlint.json` or `.markdownlint.yaml` in project root:

```json
{
  "default": true,
  "MD001": true,
  "MD003": { "style": "atx" },
  "MD004": { "style": "dash" },
  "MD007": { "indent": 2 },
  "MD013": false,
  "MD024": { "siblings_only": true },
  "MD033": false,
  "MD041": false
}
```

**Key rules explained:**
- `MD001` - Heading levels increment by one
- `MD003` - Heading style (atx = `#` style)
- `MD004` - Unordered list style (dash, asterisk, plus)
- `MD007` - Unordered list indentation (2 or 4 spaces)
- `MD013` - Line length (often disabled for documentation)
- `MD024` - Multiple headings with same content (siblings_only allows in different sections)
- `MD033` - Allow inline HTML (often needed for GitBook tags)
- `MD041` - First line in file should be top-level heading (often disabled)

#### Common .markdownlint.json for GitBook

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false,
  "MD024": {
    "siblings_only": true
  }
}
```

This configuration:
- Disables line length checking (MD013) - GitBook handles wrapping
- Allows HTML (MD033) - Needed for GitBook hint blocks
- Allows files without top-level heading (MD041) - Some pages start with hints
- Allows duplicate headings in different sections (MD024)

#### Running markdownlint

**Command line:**
```bash
# Lint all markdown files
markdownlint '**/*.md'

# Lint specific directory
markdownlint pages/**/*.md

# Auto-fix fixable issues
markdownlint --fix '**/*.md'

# Lint with config file
markdownlint --config .markdownlint.json '**/*.md'
```

**In package.json scripts:**
```json
{
  "scripts": {
    "lint:md": "markdownlint '**/*.md' --ignore node_modules",
    "lint:md:fix": "markdownlint '**/*.md' --ignore node_modules --fix"
  }
}
```

### Integration with Development Workflow

#### Pre-commit Hooks (This Project)

This project uses **native Git hooks** configured via NixOS shell.nix:

**Setup (run once):**
```bash
# Enter nix-shell first
nix-shell

# Install pre-commit hooks
setup-hooks
```

This creates `.git/hooks/pre-commit` that automatically:
- Formats staged markdown files with prettier
- Lints staged markdown files with markdownlint
- Prevents commits if linting fails

**Publish command:**
```bash
# Format, lint, commit, and push in one command
publish
```

The `publish` command workflow:
1. Formats all markdown files with prettier
2. Lints all markdown files with markdownlint
3. Shows changed files
4. Prompts for commit message
5. Commits with standardized format (includes Claude co-author)
6. Pushes to remote repository

**Bypass hook (not recommended):**
```bash
git commit --no-verify
```

#### Alternative: Husky and lint-staged

For projects not using NixOS, use **Husky** and **lint-staged**:

**Install:**
```bash
npm install --save-dev husky lint-staged
npx husky install
```

**package.json:**
```json
{
  "lint-staged": {
    "*.md": [
      "markdownlint --fix",
      "git add"
    ]
  }
}
```

**Create pre-commit hook:**
```bash
npx husky add .husky/pre-commit "npx lint-staged"
```

#### CI/CD Integration

**GitHub Actions:**
```yaml
name: Markdown Lint

on: [push, pull_request]

jobs:
  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run markdownlint
        uses: articulate/actions-markdownlint@v1
        with:
          config: .markdownlint.json
          files: '**/*.md'
          ignore: node_modules
```

**GitLab CI:**
```yaml
markdown-lint:
  image: node:latest
  stage: test
  script:
    - npm install -g markdownlint-cli
    - markdownlint '**/*.md' --ignore node_modules
```

## Content Standards

### YAML Front Matter

Add metadata to each page for better SEO and organization:

```markdown
---
description: Brief description of page content (used for meta tags)
keywords: keyword1, keyword2, keyword3
---

# Page Title

Content starts here...
```

### Code Examples

Follow these principles for code examples:

1. **Complete and runnable** - Provide full working examples
2. **Commented** - Explain non-obvious parts
3. **Real-world** - Use realistic scenarios, not foo/bar
4. **Multiple platforms** - Use tabs when showing platform-specific code

**Example:**
```markdown
{% tabs %}
{% tab title="Bash" %}
```bash
# Install dependencies
apt-get update && apt-get install -y curl

# Download and install tool
curl -sSL https://example.com/install.sh | bash
```
{% endtab %}

{% tab title="PowerShell" %}
```powershell
# Install dependencies
Install-Package curl

# Download and install tool
Invoke-WebRequest -Uri https://example.com/install.ps1 | Invoke-Expression
```
{% endtab %}
{% endtabs %}
```

### Step-by-Step Instructions

Use numbered lists for sequential steps:

```markdown
## Installation

1. **Install prerequisites**

   ```bash
   npm install -g @gitbook/cli
   ```

2. **Initialize GitBook project**

   ```bash
   gitbook init
   ```

3. **Serve locally**

   ```bash
   gitbook serve
   ```

4. **Access the documentation**

   Open your browser to http://localhost:4000
```

### Links and Cross-References

1. **Use relative paths** for internal links
2. **Use descriptive text** for link text (not "click here")
3. **Link to related content** at the end of sections

**Example:**
```markdown
For more information, see:
- [Getting Started Guide](../getting-started.md)
- [API Reference](../reference/api.md)
- [Troubleshooting](../guides/troubleshooting.md)
```

### Images and Assets

1. **Store in assets/ directory** at appropriate level
2. **Use descriptive filenames** - `kubernetes-architecture.png` not `image1.png`
3. **Add alt text** for accessibility
4. **Optimize file sizes** - compress images before committing

**Example:**
```markdown
![Kubernetes cluster architecture diagram](../../assets/kubernetes-architecture.png)
```

## GitBook Configuration (.gitbook.yml)

### Essential Configuration

```yaml
# Project root
root: ./

# Structure files
structure:
  readme: README.md
  summary: SUMMARY.md

# Redirects (when moving/renaming pages)
redirects:
  previous/path.md: new/path.md

# Variables
variables:
  version: 1.0.0
  api_url: https://api.example.com
```

### GitHub Sync Configuration

```yaml
# GitHub integration
integrations:
  github:
    enabled: true

# Git sync settings
gitSync:
  # Sync changes from GitBook to GitHub
  enabled: true

  # Bidirectional sync
  direction: bidirectional

  # Branch to sync with
  branch: main
```

### Advanced Configuration

```yaml
# Plugins (if using legacy GitBook)
plugins:
  - mermaid-gb3
  - katex
  - code
  - splitter

# PDF generation options
pdf:
  fontSize: 12
  paperSize: a4
  margin:
    top: 56
    bottom: 56
    left: 62
    right: 62
```

## Common Patterns

### Landing Page Pattern

**README.md:**
```markdown
# Welcome to [Project Name]

Brief introduction to the project.

## Quick Start

- [Getting Started](getting-started.md)
- [Installation Guide](guides/installation.md)
- [Tutorials](tutorials/README.md)

## Core Concepts

- [Architecture Overview](concepts/architecture.md)
- [Key Features](concepts/features.md)

## Resources

- [API Reference](reference/api.md)
- [FAQ](resources/faq.md)
- [Changelog](resources/changelog.md)
```

### Section Overview Pattern

**pages/section/README.md:**
```markdown
# Section Name

Overview of what this section covers.

## In This Section

- [Topic 1](topic-1.md) - Brief description
- [Topic 2](topic-2.md) - Brief description
- [Topic 3](topic-3.md) - Brief description

## Prerequisites

List any prerequisites needed before reading this section.

## Related Sections

- [Other Section](../other-section/README.md)
```

### Tutorial Pattern

```markdown
# Tutorial: [Objective]

**Time Required:** 15 minutes
**Difficulty:** Beginner

## What You'll Learn

- Objective 1
- Objective 2
- Objective 3

## Prerequisites

- Prerequisite 1
- Prerequisite 2

## Step 1: [First Step]

Instructions...

```bash
code example
```

## Step 2: [Second Step]

Instructions...

## Verification

How to verify success...

## Next Steps

- [Related Tutorial](../next-tutorial.md)
- [Advanced Guide](../../guides/advanced.md)
```

### Reference Pattern

```markdown
# API Reference: [Component]

## Overview

Brief description of the component.

## Methods

### methodName()

**Description:** What the method does

**Syntax:**
```language
methodName(param1, param2)
```

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| param1 | string | Yes | Description |
| param2 | number | No | Description |

**Returns:** Description of return value

**Example:**
```language
const result = methodName('value', 42);
```

**See Also:**
- [Related Method](related-method.md)
```

## Quality Checklist

Before committing documentation changes:

- [ ] All new pages added to SUMMARY.md
- [ ] YAML front matter included (description, keywords)
- [ ] Code examples are complete and tested
- [ ] Links to related content included
- [ ] Images have descriptive alt text
- [ ] Markdown linting passes (`markdownlint`)
- [ ] No broken internal links
- [ ] Proper heading hierarchy (H1 → H2 → H3)
- [ ] Consistent formatting throughout
- [ ] Spell check completed

## Troubleshooting

### Common Issues

**Page doesn't appear in navigation**
- Verify page is listed in SUMMARY.md
- Check that path in SUMMARY.md matches actual file path
- Ensure proper indentation in SUMMARY.md

**Markdown not rendering correctly**
- Check for unclosed code blocks (```)
- Verify GitBook tag syntax ({% ... %})
- Look for special characters that need escaping

**Images not displaying**
- Verify relative path is correct
- Check file extension case (image.PNG vs image.png)
- Ensure image file is committed to repository

**Linting errors**
- Review .markdownlint.json configuration
- Check specific error code in markdownlint documentation
- Use `--fix` flag to auto-correct simple issues

## Resources

- [GitBook Official Documentation](https://docs.gitbook.com/)
- [Markdown Guide](https://www.markdownguide.org/)
- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Diátaxis Documentation Framework](https://diataxis.fr/)

---

**Note:** This guide is specific to GitBook projects. For general Markdown best practices, refer to the Markdown Guide. For project-specific standards, see CONTRIBUTING.md and .github/copilot-instructions.md.
