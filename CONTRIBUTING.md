# Contributing to the DevOps Knowledge Base

Thank you for considering contributing to this DevOps knowledge base! This document provides guidelines and best practices for contributions.

## Content Guidelines

### File Structure

- Place new content in the appropriate section under `/pages`
- Create new directories when introducing new major topics
- Use README.md for section index pages

### Markdown Standards

- Use ATX-style headers (`#` for h1, `##` for h2, etc.)
- Use fenced code blocks with language specification:
  ```bash
  # This is a bash code block
  ```plaintext
- Include descriptive alt text for images
- Keep line length under 120 characters

### Metadata

All content pages should include YAML front matter:

```markdown
---
description: Brief description of the page content
keywords: keyword1, keyword2, keyword3
---
```plaintext

## Advanced GitBook Features

### Using Variables

Reference global variables defined in `book.json` using:

```markdown
Kubernetes version: {{ book.kubernetesVersion }}
```plaintext

### Including Reusable Snippets

To include reusable content:

```markdown
{% include "/_snippets/snippet-name.md" %}
```plaintext

### Using Tabs

For comparing multiple implementations:

```markdown
{% tabs %}
{% tab title="Option 1" %}
Content for option 1
{% endtab %}
{% tab title="Option 2" %}
Content for option 2
{% endtab %}
{% endtabs %}
```plaintext

## Submitting Changes

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes following these guidelines
4. Submit a pull request with a clear description of the changes

## Style Conventions

### Code Examples

- Include comments in code examples
- Use clear variable names
- Include explanations before and after complex code blocks

### Screenshots

- Place screenshots in `/assets/images/[section-name]/`
- Use descriptive filenames
- Keep image sizes reasonable (compress when appropriate)