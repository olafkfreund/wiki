# Creating Modern Documentation Sites with MkDocs

[MkDocs](https://www.mkdocs.org/) is a powerful static site generator designed for creating modern technical documentation. While alternatives like [Sphinx](https://www.sphinx-doc.org/) and [Jekyll](https://jekyllrb.com/) exist, MkDocs stands out for DevOps documentation due to:

1. **Markdown-Native**: Works seamlessly with existing markdown documentation
2. **Python-Based**: Familiar ecosystem for DevOps engineers
3. **Modern Features**: Built-in search, dark mode, and responsive design
4. **CI/CD Friendly**: Easy integration with automation pipelines
5. **Extensible**: Rich plugin ecosystem for advanced features

## Quick Setup Guide

1. Install MkDocs and Material theme:
```bash
pip install mkdocs mkdocs-material
mkdocs new my-docs
cd my-docs
```

2. Configure `mkdocs.yml`:
```yaml
site_name: Your Documentation
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.top
    - search.suggest
    - search.highlight
    - content.code.copy
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

plugins:
  - search
  - git-revision-date
  - mkdocstrings
  - social

markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.superfences
  - admonition
  - pymdownx.details
  - pymdownx.tabbed:
      alternate_style: true
```

## Essential Plugins

1. **Documentation Enhancement**:
   - [mkdocs-material](https://squidfunk.github.io/mkdocs-material/): Modern Material design theme
   - [pymdown-extensions](https://facelessuser.github.io/pymdown-extensions/): Advanced markdown features
   - [mkdocs-git-revision-date-plugin](https://github.com/zhaoterryy/mkdocs-git-revision-date-plugin): Shows last update dates

2. **Code Documentation**:
   - [mkdocstrings](https://mkdocstrings.github.io/): Auto-generates API documentation
   - [mkdocs-jupyter](https://github.com/danielfrg/mkdocs-jupyter): Renders Jupyter notebooks

3. **Navigation & Search**:
   - [mkdocs-section-index](https://github.com/oprypin/mkdocs-section-index): Better section navigation
   - [mkdocs-awesome-pages-plugin](https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin): Custom navigation

## Automated Deployment

### GitHub Actions Workflow
```yaml
name: Deploy Documentation
on:
  push:
    branches:
      - main
permissions:
  contents: write
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-python@v4
        with:
          python-version: 3.x
      - run: |
          pip install -r requirements-docs.txt
      - name: Deploy Documentation
        run: mkdocs gh-deploy --force
```

### Azure Static Web Apps
```yaml
name: Deploy to Azure
on:
  push:
    branches:
      - main
jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Documentation
        run: |
          pip install -r requirements-docs.txt
          mkdocs build
      - name: Deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "site"
          skip_app_build: true
```

### GitLab CI/CD Pipeline
```yaml
pages:
  image: python:3.11-alpine
  stage: deploy
  script:
    - pip install -r requirements-docs.txt
    - mkdocs build --site-dir public
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Best Practices

1. **Organize Content**:
   - Use clear directory structure
   - Implement consistent naming conventions
   - Create topic-based documentation

2. **Navigation**:
   - Keep navigation depth <= 3 levels
   - Use descriptive section names
   - Implement breadcrumbs for deep content

3. **Performance**:
   - Optimize images
   - Use lazy loading for heavy content
   - Implement proper caching headers

4. **Search Optimization**:
   - Add proper meta descriptions
   - Use meaningful headings
   - Include search-friendly titles

## Local Development

1. Start development server:
```bash
mkdocs serve
```

2. Build static site:
```bash
mkdocs build
```

3. Deploy to GitHub Pages:
```bash
mkdocs gh-deploy
```

## Advanced Formatting Examples

MkDocs Material supports rich formatting through admonitions:

!!! note "Note"
    This is a note admonition - use it for general information

!!! tip "Pro Tip"
    Tips provide best practices and shortcuts

!!! warning "Warning"
    Highlight potential pitfalls or important warnings

!!! danger "Critical"
    Use for critical security or deployment warnings

??? example "Collapsible Example (click to expand)"
    ```yaml
    deployment:
      stage: deploy
      environment: production
      script:
        - mkdocs build
        - aws s3 sync site/ s3://my-docs-bucket/
    ```

## Common Patterns

1. **API Documentation**:
   ```yaml
   plugins:
     - mkdocstrings:
         handlers:
           python:
             paths: [src]  # Path to Python source files
             options:
               show_source: false
               show_root_heading: true
   ```

2. **Version Selector**:
   ```yaml
   extra:
     version:
       provider: mike
   ```

3. **Custom Domain**:
   Create a `CNAME` file in `docs/` with your domain:
   ```text
   docs.yourdomain.com
   ```

## Additional Resources

- [Official MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs Reference](https://squidfunk.github.io/mkdocs-material/reference/)
- [MkDocs Plugins](https://github.com/mkdocs/mkdocs/wiki/MkDocs-Plugins)
