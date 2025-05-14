# Static Code Analysis Tool Integration Guide

## Modern Tool Integration (2025)

### IDE Integration

#### VS Code Setup
```json
{
  "sonarlint.connectedMode.project": {
    "projectKey": "my-project",
    "serverId": "my-sonar-server"
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "codeQL.cli.executablePath": "/usr/local/bin/codeql",
  "semgrep.languages": [
    "python",
    "javascript",
    "go",
    "java"
  ]
}
```

#### JetBrains Setup
```xml
<component name="SonarLintProjectSettings">
  <option name="bindingEnabled" value="true" />
  <option name="projectKey" value="my-project" />
  <option name="serverId" value="my-sonar-server" />
</component>
```

### CI/CD Integration

#### GitHub Actions Integration
```yaml
name: Static Analysis
on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          
      - name: CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          languages: [javascript, python, java]
          queries: security-extended
          
      - name: Semgrep Scan
        uses: semgrep/semgrep-action@v1
        with:
          config: p/ci
          
      - name: Upload Results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: semgrep.sarif
```

#### Azure DevOps Pipeline
```yaml
trigger:
  - main
  - feature/*

variables:
  sonar.projectKey: 'my-project'
  
stages:
- stage: StaticAnalysis
  jobs:
  - job: CodeAnalysis
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: SonarCloudPrepare@1
      inputs:
        SonarCloud: 'SonarCloud'
        organization: 'my-org'
        scannerMode: 'CLI'
        
    - task: DotNetCoreCLI@2
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration Release'
        
    - task: SonarCloudAnalyze@1
    
    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'
        
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '**/coverage.xml'
```

### Git Hook Integration

#### Pre-commit Configuration
```yaml
# .pre-commit-config.yaml
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.5.0
  hooks:
    - id: trailing-whitespace
    - id: end-of-file-fixer
    - id: check-yaml
    - id: check-added-large-files

- repo: https://github.com/PyCQA/bandit
  rev: '1.7.5'
  hooks:
    - id: bandit
      args: ["-c", "pyproject.toml"]
      additional_dependencies: ["bandit[toml]"]

- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.1.5
  hooks:
    - id: ruff
      args: [--fix]
    - id: ruff-format

- repo: https://github.com/pre-commit/mirrors-mypy
  rev: v1.7.0
  hooks:
    - id: mypy
      additional_dependencies: [types-all]
```

### Container Integration

#### Docker Integration
```dockerfile
# Analysis Stage
FROM sonarqube:latest as analyzer

WORKDIR /usr/src/app
COPY . .

RUN sonar-scanner \
    -Dsonar.projectKey=my-project \
    -Dsonar.sources=. \
    -Dsonar.host.url=http://sonarqube:9000 \
    -Dsonar.login=$SONAR_TOKEN

# Development Stage
FROM node:18-alpine

COPY --from=analyzer /usr/src/app/analysis-results /analysis
RUN npm install -g eslint prettier
```

### Kubernetes Integration

#### Static Analysis Operator
```yaml
apiVersion: analysis.security.io/v1beta1
kind: StaticAnalysis
metadata:
  name: code-analysis
spec:
  schedule: "0 0 * * *"
  scanners:
    - name: sonarqube
      image: sonarqube:latest
      env:
        - name: SONAR_TOKEN
          valueFrom:
            secretKeyRef:
              name: sonar-credentials
              key: token
    - name: semgrep
      image: returntocorp/semgrep:latest
      volumeMounts:
        - name: source
          mountPath: /src
  volumes:
    - name: source
      persistentVolumeClaim:
        claimName: source-code
```

### API Integration

#### REST API Integration
```python
import requests

class StaticAnalysisAPI:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.headers = {"Authorization": f"Bearer {token}"}
    
    def trigger_analysis(self, project_key):
        endpoint = f"{self.base_url}/api/analysis/start"
        payload = {
            "projectKey": project_key,
            "branch": "main"
        }
        return requests.post(endpoint, json=payload, headers=self.headers)
    
    def get_results(self, analysis_id):
        endpoint = f"{self.base_url}/api/analysis/{analysis_id}/results"
        return requests.get(endpoint, headers=self.headers)
```

### Message Queue Integration

#### RabbitMQ Configuration
```yaml
analysis_queue:
  name: static-analysis
  exchange: code-analysis
  routing_key: analysis.start
  consumer:
    prefetch_count: 1
    auto_ack: false
  publisher:
    confirm_delivery: true
    mandatory: true
  retry:
    max_attempts: 3
    initial_interval: 1000
```

### Monitoring Integration

#### Prometheus Metrics
```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'static-analysis'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['analyzer:9090']
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: static-analysis
```

### Dashboard Integration

#### Grafana Dashboard
```json
{
  "dashboard": {
    "id": null,
    "title": "Static Analysis Overview",
    "panels": [
      {
        "title": "Issues by Severity",
        "type": "gauge",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "sum(static_analysis_issues) by (severity)"
          }
        ]
      },
      {
        "title": "Analysis Duration",
        "type": "graph",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "rate(static_analysis_duration_seconds[5m])"
          }
        ]
      }
    ]
  }
}
```

## Integration Best Practices

### 1. Authentication & Security
- Use service accounts
- Implement least privilege
- Rotate credentials
- Encrypt sensitive data
- Audit access logs

### 2. Performance Optimization
- Implement caching
- Use incremental analysis
- Configure timeouts
- Set resource limits
- Monitor performance

### 3. Error Handling
- Implement retries
- Log errors properly
- Set up alerting
- Define fallbacks
- Document recovery

### 4. Maintenance
- Version control configs
- Document integrations
- Monitor health
- Update regularly
- Backup configurations

## Troubleshooting Guide

### Common Issues

1. **Connection Problems**
```yaml
troubleshooting:
  connection:
    steps:
      - verify_network_access
      - check_credentials
      - validate_endpoints
      - test_connectivity
    resolution:
      - check_firewall_rules
      - verify_service_status
      - update_certificates
```

2. **Performance Issues**
```yaml
performance:
  checks:
    - resource_usage
    - analysis_duration
    - queue_depth
    - cache_hit_rate
  solutions:
    - optimize_configuration
    - increase_resources
    - implement_caching
    - reduce_scope
```

## Integration Checklist

### Initial Setup
- [ ] Tool selection
- [ ] Authentication configuration
- [ ] Network access
- [ ] Resource allocation
- [ ] Monitoring setup

### Validation
- [ ] Test connections
- [ ] Verify permissions
- [ ] Check performance
- [ ] Validate results
- [ ] Test error handling

### Documentation
- [ ] Setup procedures
- [ ] Configuration details
- [ ] Troubleshooting guides
- [ ] Recovery procedures
- [ ] Contact information

Remember to regularly review and update integrations as tools and requirements evolve.