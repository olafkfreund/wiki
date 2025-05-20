# envsubst

`envsubst` is a lightweight Unix command-line tool for substituting environment variables in text files. It's essential for DevOps workflows, especially when templating configuration files for cloud deployments (AWS, Azure, GCP) and Kubernetes manifests.

## What is envsubst?

`envsubst` reads input from standard input or a file, replaces environment variable references (e.g., `$VAR` or `${VAR}`) with their current values, and outputs the result. This is invaluable for generating environment-specific configuration files during CI/CD pipelines.

**Official documentation:** [GNU gettext utilities - envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)

## Practical Use Cases

### 1. Templating Configuration Files

Replace variables in a template and output to a config file:

```bash
envsubst < config.ini.template > config.ini
```

**Best Practice:**
- Store secrets in environment variables, not in templates.
- Use `.template` suffix for files requiring substitution.

### 2. Kubernetes Manifests in CI/CD

Inject environment variables into Kubernetes YAML before applying:

```bash
envsubst < deployment.yaml.template | kubectl apply -f -
```

**Common Pitfall:**
- Only variables present in the environment will be replaced. Unset variables remain as-is.

### 3. Selective Variable Substitution

Limit substitution to specific variables:

```bash
export DB_USER=admin DB_PASS=secret
envsubst '$DB_USER $DB_PASS' < db.yaml.template > db.yaml
```

**Tip:**
- This prevents accidental replacement of unrelated variables.

### 4. Using envsubst in Azure Pipelines

Add a script step to your Azure Pipeline YAML:

```yaml
- script: |
    envsubst < appsettings.json.template > appsettings.json
  displayName: 'Substitute environment variables in appsettings.json'
```

**Reference:** [Azure Pipelines - Bash task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/bash)

## Security Considerations
- Never commit secrets to templates or source control.
- Use secure pipeline variables or secret stores (Azure Key Vault, AWS Secrets Manager, GCP Secret Manager).

## Conclusion

`envsubst` is a must-have tool for DevOps engineers working with cloud-native and containerized applications. It streamlines configuration management, reduces manual errors, and integrates seamlessly with CI/CD pipelines across AWS, Azure, and GCP.
