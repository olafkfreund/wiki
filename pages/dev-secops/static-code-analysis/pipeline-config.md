# Static Analysis Pipeline Configuration (2025)

This guide provides comprehensive pipeline configurations for implementing static code analysis in modern CI/CD environments.

## Multi-Platform Pipeline Templates

### GitHub Actions Advanced Configuration

```yaml
name: Comprehensive Static Analysis
on:
  push:
    branches: [main]
  pull_request:
    branches: [main, develop, 'release/*']
  schedule:
    - cron: '0 0 * * 0'  # Weekly full scan

jobs:
  analyze:
    name: Static Analysis
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      actions: read
      contents: read
      
    strategy:
      matrix:
        language: [javascript, python, java, go]
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      # Language-specific setup
      - uses: actions/setup-node@v4
        if: matrix.language == 'javascript'
        with:
          node-version: '20'
          
      - uses: actions/setup-python@v4
        if: matrix.language == 'python'
        with:
          python-version: '3.11'
          
      - uses: actions/setup-java@v3
        if: matrix.language == 'java'
        with:
          distribution: 'temurin'
          java-version: '21'
          
      - uses: actions/setup-go@v4
        if: matrix.language == 'go'
        with:
          go-version: '1.21'
          
      # SAST Analysis
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
          queries: security-extended,security-and-quality
          
      # Dependency Scanning
      - name: Dependency Review
        uses: actions/dependency-review-action@v3
        
      # Custom Rules
      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/ci
            p/security-audit
            p/owasp-top-ten
            p/supply-chain
          timeout: 300
          
      # Quality Gates
      - name: SonarCloud Analysis
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          args: >
            -Dsonar.projectKey=${{ github.repository_owner }}_${{ github.event.repository.name }}
            -Dsonar.organization=${{ github.repository_owner }}
            -Dsonar.sources=.
            -Dsonar.language=${{ matrix.language }}
            
      # Results Processing
      - name: Process Analysis Results
        uses: github/codeql-action/analyze@v2
        with:
          category: "/language:${{ matrix.language }}"
          
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif
```

### Azure DevOps Advanced Pipeline

```yaml
trigger:
  branches:
    include:
      - main
      - develop
      - feature/*
  paths:
    exclude:
      - '**/*.md'
      - 'docs/*'

variables:
  - group: security-scanning-variables
  - name: BUILD_CONFIGURATION
    value: 'Release'

stages:
- stage: StaticAnalysis
  displayName: 'Static Code Analysis'
  jobs:
  - job: SecurityScanning
    strategy:
      matrix:
        Linux:
          vmImage: 'ubuntu-latest'
          platform: 'linux'
        Windows:
          vmImage: 'windows-latest'
          platform: 'windows'
    
    pool:
      vmImage: $(vmImage)
      
    steps:
    # Initialize Analysis
    - task: SonarCloudPrepare@1
      inputs:
        SonarCloud: 'SonarCloud'
        organization: '$(SONAR_ORGANIZATION)'
        scannerMode: 'CLI'
        configMode: 'manual'
        cliProjectKey: '$(Build.Repository.Name)'
        cliProjectName: '$(Build.Repository.Name)'
        
    # Security Scanning
    - task: SecurityAnalysis@1
      inputs:
        toolSelector: 'bandit,snyk,semgrep'
        path: '$(Build.SourcesDirectory)'
        excludePaths: '**/tests/**,**/docs/**'
        
    # Dependency Scanning
    - task: SnykSecurityScan@1
      inputs:
        serviceConnectionEndpoint: 'Snyk'
        testType: 'app'
        severityThreshold: 'high'
        monitorWhen: 'always'
        
    # Custom Rules
    - task: Bash@3
      inputs:
        targetType: 'inline'
        script: |
          curl -sSfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh
          ./bin/gosec -fmt=sarif -out=results.sarif ./...
          
    # Quality Gates
    - task: SonarCloudAnalyze@1
    
    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'
        
    # Results Processing
    - task: PublishSecurityAnalysisLogs@1
      inputs:
        ArtifactName: 'CodeAnalysisLogs'
        
    - task: PostAnalysis@1
      inputs:
        AllTools: false
        APIScan: false
        BinSkim: false
        CodesignValidation: false
        CredScan: true
        FortifySCA: false
        FxCop: false
        ModernCop: false
        PoliCheck: false
        RoslynAnalyzers: true
        SDLNativeRules: false
        Semmle: false

- stage: ComplianceCheck
  displayName: 'Compliance Verification'
  dependsOn: StaticAnalysis
  condition: succeeded()
  jobs:
  - job: ComplianceVerification
    steps:
    - task: ComplianceVerification@1
      inputs:
        scanType: 'Security'
        reportTypes: 'SARIF,PDF,HTML'
        frameworks: 'PCI-DSS,SOC2,GDPR'
```

## Pipeline Configuration Patterns

### 1. Analysis Matrix Configuration
```yaml
analysis_matrix:
  combinations:
    - language: python
      tools: [bandit, pylint, mypy]
      requirements: requirements.txt
      
    - language: javascript
      tools: [eslint, prettier]
      requirements: package.json
      
    - language: java
      tools: [spotbugs, pmd]
      requirements: pom.xml
```

### 2. Quality Gates Configuration
```yaml
quality_gates:
  thresholds:
    coverage:
      minimum: 80
      critical: 70
      
    code_smells:
      maximum: 100
      per_file: 5
      
    duplication:
      maximum_percent: 3
      
    complexity:
      maximum_per_file: 20
      maximum_per_method: 8
```

### 3. Security Policy Configuration
```yaml
security_policy:
  rules:
    - id: secure-defaults
      severity: CRITICAL
      patterns:
        - type: regex
          pattern: "crypto\\.DEFAULT"
          message: "Avoid using crypto defaults"
          
    - id: secure-configs
      severity: HIGH
      patterns:
        - type: regex
          pattern: "config\\.(DEBUG|TESTING)"
          message: "Production-sensitive config detected"
```

## Advanced Pipeline Features

### 1. Incremental Analysis
```yaml
incremental_config:
  enabled: true
  base_branch: main
  cache_key: ${CACHE_VERSION}-${BRANCH_NAME}
  paths:
    - src/**/*.{js,ts,py,java}
    - test/**/*.{js,ts,py,java}
  exclude:
    - '**/generated/**'
    - '**/vendor/**'
```

### 2. Performance Optimization
```yaml
performance:
  parallel_execution:
    max_concurrent: 4
    timeout: 30m
    
  caching:
    enabled: true
    key: ${COMMIT_SHA}
    paths:
      - .sonar/cache
      - .gradle/caches
      - node_modules
      
  resource_limits:
    cpu: 4
    memory: 8Gi
```

### 3. Results Management
```yaml
results_config:
  formats:
    - sarif
    - html
    - json
    
  notifications:
    slack:
      channel: security-alerts
      conditions:
        - severity: CRITICAL
          threshold: 1
    
    email:
      recipients: [security-team@company.com]
      conditions:
        - type: new_vulnerability
          severity: HIGH
```

## Pipeline Integration Points

### 1. Source Control Integration
```yaml
source_control:
  hooks:
    pre_commit:
      - lint
      - security_scan
      
    pre_push:
      - full_analysis
      
  branch_policies:
    - name: main
      require:
        - security_scan
        - quality_gates
```

### 2. Issue Tracking Integration
```yaml
issue_tracking:
  jira:
    project: SECURITY
    issue_type: Security Issue
    labels: [static-analysis, security]
    
  github:
    labels: [security, needs-review]
    assignees: [security-team]
```

### 3. Documentation Integration
```yaml
documentation:
  auto_generate:
    - security_reports
    - compliance_reports
    - trend_analysis
    
  formats:
    - markdown
    - pdf
    - html
```

## Monitoring and Metrics

### 1. Pipeline Metrics
```yaml
metrics:
  collection:
    - name: analysis_duration
      type: gauge
      labels: [language, tool]
      
    - name: issues_found
      type: counter
      labels: [severity, type]
      
    - name: false_positives
      type: counter
      labels: [tool, rule_id]
```

### 2. Performance Monitoring
```yaml
monitoring:
  dashboards:
    - name: Analysis Overview
      provider: grafana
      refresh: 5m
      panels:
        - title: Analysis Duration Trend
          type: graph
          metric: analysis_duration
          
        - title: Issues by Severity
          type: pie
          metric: issues_found
```

## Best Practices Implementation

### 1. Error Handling
```yaml
error_handling:
  retry:
    max_attempts: 3
    initial_delay: 10s
    max_delay: 5m
    
  fallback:
    - skip_non_critical
    - notify_team
    - create_incident
```

### 2. Security Controls
```yaml
security_controls:
  authentication:
    type: service_account
    rotation: 90d
    
  secrets:
    storage: azure_key_vault
    scope: pipeline_only
    
  approval:
    required_for:
      - production_deploy
      - security_override
```

### 3. Compliance Requirements
```yaml
compliance:
  frameworks:
    - standard: PCI-DSS
      controls:
        - 6.2  # Security Patches
        - 6.3.2  # Code Review
        
    - standard: SOC2
      controls:
        - CC7.1  # Security Operations
        - CC8.1  # Change Management
```

Remember to regularly review and update pipeline configurations as security requirements and tools evolve.