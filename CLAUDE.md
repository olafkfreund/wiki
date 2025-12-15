# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitBook-based knowledge base** focused on multi-cloud architecture, DevOps practices, and platform engineering. The repository contains comprehensive documentation covering AWS, Azure, GCP, Kubernetes, Infrastructure as Code (Terraform/Bicep), CI/CD, security, and observability.

**Target Audience**: DevOps engineers, SRE practitioners, cloud architects seeking actionable, practical solutions.

**Tech Stack**: GitBook, Markdown, Node.js/Bun, NixOS development environment

## Key Architecture Points

### Content Organization

Content is organized under `/pages/` with the following major sections:
- `devops/` - Core DevOps and SRE practices
- `public-clouds/` - Cloud provider documentation (AWS, Azure, GCP)
- `terraform/`, `bicep/` - Infrastructure as Code
- `containers/kubernetes/` - Container orchestration
- `security/`, `dev-secops/` - Security practices
- `llm/` - AI/LLM integration guides
- `Nixos/` - NixOS system configuration

### Navigation Structure

- **`SUMMARY.md`** - Table of contents and navigation hierarchy (GitBook primary navigation)
- **Every new page MUST be added to SUMMARY.md** to appear in the GitBook navigation
- README.md files serve as section index pages

### Content Standards

From `.github/copilot-instructions.md`, all content must:
- Be written in **Markdown** format
- Include **real-life, practical examples**
- Provide **step-by-step instructions** with code snippets
- Assume reader is an engineer seeking actionable solutions
- Be precise, clear, and easy to understand

### GitBook Features in Use

The project uses advanced GitBook features:
- **Reusable snippets**: `{% include "/_snippets/snippet-name.md" %}`
- **Tabs for multi-option content**: `{% tabs %}` / `{% tab %}` / `{% endtabs %}`
- **Variables**: Reference with `{{ book.variableName }}`
- **Front matter metadata**: YAML headers with `description:` and `keywords:`

## Development Environment

### NixOS Shell Environment

This project uses **NixOS** with `shell.nix` for reproducible development:

```bash
# Enter NixOS development shell
nix-shell

# Available custom commands (created by shell.nix):
setup         # Clone and setup GitBook repository
setup-force   # Force setup (removes existing gitbook directory)
update        # Update existing GitBook repository
dev           # Start development server (http://localhost:3000/url/docs.gitbook.com)
gformat       # Format GitBook codebase
glint         # Lint GitBook codebase
fmt           # Format Markdown files (prettier)
lint          # Lint Markdown files (markdownlint)
check         # Check formatting
```

### Development Dependencies

The shell environment provides:
- Node.js 24
- Bun (JavaScript runtime)
- prettier, markdownlint-cli
- TypeScript and language server
- Git, make

## Common Tasks

### Adding New Content

1. Create the new `.md` file in the appropriate `/pages/` subdirectory
2. Add YAML front matter:
   ```yaml
   ---
   description: Brief description of the page content
   keywords: keyword1, keyword2, keyword3
   ---
   ```
3. **Add entry to `SUMMARY.md`** in the appropriate section with proper indentation
4. Follow markdown standards: ATX headers, fenced code blocks with language tags

### Formatting and Linting

```bash
# Format all markdown files
fmt

# Check markdown formatting without changes
check

# Lint markdown files
lint
```

### Working with GitBook

```bash
# Start local development server
dev

# Access at: http://localhost:3000/url/docs.gitbook.com

# Format GitBook-specific code
gformat

# Lint GitBook-specific code
glint
```

## Content Standards

### Code Examples

- Include **comments** explaining what code does
- Use **clear variable names**
- Provide **context before and after** complex examples
- Specify **language in code fences** (```bash, ```yaml, ```python, etc.)
- Reference **official documentation** where appropriate

### Documentation Style

- **No generic advice**: Focus on specific, actionable guidance
- **Real-life scenarios**: Include practical use cases from finance, public sector, energy
- **Multi-cloud focus**: Cover AWS, Azure, and GCP when relevant
- **Modern practices**: Emphasize 2025-era DevOps patterns (GitOps, Platform Engineering, FinOps)

### Technical Depth

Content covers beginner to advanced topics:
- `[BEGINNER]` - Getting started guides
- `[INTERMEDIATE]` - Standard implementations
- `[ADVANCED]` - Enterprise patterns, multi-cloud, complex architectures

## File Naming and Structure

- Use **lowercase with hyphens** for file names: `kubernetes-best-practices.md`
- Use **README.md** for section index pages
- Place **images** in `/assets/images/[section-name]/`
- Store **reusable content** in `/_snippets/`

## GitBook Configuration

- `.gitbook.yml` - GitBook configuration with GitHub sync
- `SUMMARY.md` - Navigation structure (critical for GitBook)
- Root is `./` with README.md as main landing page

## GitBook Best Practices

For comprehensive guidance on GitBook-specific features, see **[GITBOOK-BEST-PRACTICES.md](./GITBOOK-BEST-PRACTICES.md)**

This guide covers:
- GitBook-specific markdown features (hints, tabs, code blocks, API blocks, math)
- Markdown linting with markdownlint (configuration, rules, CI/CD integration)
- File and folder structure best practices
- Content organization using Diátaxis framework
- Common patterns and quality checklists
- Troubleshooting common issues

**Key highlights:**
- Use hint blocks for important information: `{% hint style="info" %}...{% endhint %}`
- Use tabs for multi-platform examples: `{% tabs %}...{% endtabs %}`
- Configure markdownlint to allow GitBook HTML tags (MD033: false)
- Follow entity-based folder organization (not generic names like "utils")
- Always add YAML front matter (description, keywords) to pages

## Important Notes

- This is a **documentation project**, not application code
- Focus is on **knowledge sharing** for DevOps/SRE practitioners
- Author has **28+ years** of experience across cloud platforms
- Content should reflect **real-world, production-grade** solutions
- Updates should maintain the **professional, technical** tone
- Always ensure new pages are **linked in SUMMARY.md**

## Git Workflow

Standard Git workflow applies:
- Create feature branches for new content
- Commit with descriptive messages
- GitBook syncs with GitHub (configured for bidirectional or gitbook-to-github sync)

## Testing Content

Before committing:
1. Run `fmt` to format markdown
2. Run `check` to verify formatting
3. Run `lint` to check markdown quality
4. Test locally with `dev` if adding GitBook-specific features
