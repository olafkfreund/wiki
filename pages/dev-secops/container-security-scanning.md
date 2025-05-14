# Container Security Scanning in CI/CD (2025)

Modern container security requires a comprehensive approach that integrates security scanning throughout the container lifecycle, from development to runtime.

## Multi-Layer Container Security

### 1. Base Image Scanning
```yaml
# GitHub Actions Example
name: Base Image Scan
on:
  schedule:
    - cron: '0 0 * * *'  # Daily scan
  workflow_dispatch:

jobs:
  scan-base-images:
    runs-on: ubuntu-latest
    steps:
      - name: Scan Ubuntu base image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ubuntu:22.04'
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'
```

### 2. Build-Time Security

#### Azure DevOps Pipeline
```yaml
trigger:
  - main

variables:
  containerRegistry: 'production.azurecr.io'
  imageRepository: 'myapp'
  tag: '$(Build.BuildNumber)'

stages:
- stage: SecurityScan
  jobs:
  - job: ContainerScan
    steps:
    - task: Docker@2
      inputs:
        command: build
        dockerfile: '**/Dockerfile'
        tags: |
          $(tag)
          latest
    
    - task: ContainerScan@0
      inputs:
        imageName: '$(containerRegistry)/$(imageRepository):$(tag)'
        scanType: 'vulnerability'
        severityThreshold: 'CRITICAL'
        
    - task: Snyk@1
      inputs:
        command: container test
        dockerImageName: '$(containerRegistry)/$(imageRepository):$(tag)'
        monitorWhen: always
        failOnIssues: true
```

## Advanced Scanning Features

### 1. SBOM Generation
```yaml
# Syft SBOM Generation
steps:
- task: Bash@3
  inputs:
    script: |
      syft $(containerRegistry)/$(imageRepository):$(tag) \
        -o spdx-json \
        --file sbom.json
      
      # Validate SBOM
      grype sbom:./sbom.json \
        --fail-on high \
        --config grype.yaml
```

### 2. Runtime Security Policies
```yaml
# Kubernetes Security Policies
apiVersion: security.kubernetes.io/v1beta1
kind: SecurityProfile
metadata:
  name: restricted-containers
spec:
  restrictedCapabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
```

## Automated Security Gates

### 1. Quality Gates Configuration
```yaml
security_gates:
  container_scan:
    critical_vulnerabilities: 0
    high_vulnerabilities: 3
    medium_vulnerabilities: 10
    compliance:
      - cis_benchmark
      - pci_dss
    sbom_validation: required
    signing_required: true
```

### 2. Policy Enforcement
```yaml
# OPA/Conftest Policy
package container

deny[msg] {
    input.type == "Container"
    not input.spec.securityContext.runAsNonRoot
    msg = "Containers must not run as root"
}

deny[msg] {
    input.type == "Container"
    not input.spec.securityContext.readOnlyRootFilesystem
    msg = "Root filesystem must be read-only"
}
```

## Continuous Monitoring

### 1. Runtime Threat Detection
```yaml
# Falco Rules Configuration
- rule: Unauthorized Container Image
  desc: Detect containers not from approved registry
  condition: >
    container.image.repository != "production.azurecr.io/*"
  output: Unauthorized container image (user=%user.name %container.image)
  priority: CRITICAL
  tags: [runtime, container]
```

### 2. Security Metrics
```yaml
# Prometheus Metrics
- name: container_vulnerabilities_total
  help: Total number of container vulnerabilities by severity
  type: gauge
  labels:
    - severity
    - image
    - registry

- name: container_compliance_score
  help: Container security compliance score
  type: gauge
  labels:
    - image
    - benchmark
```

## Integration with DevSecOps Tools

### 1. Vulnerability Management
```yaml
# Vulnerability Management Integration
vulnerability_tracking:
  providers:
    - name: defectdojo
      api_url: https://defectdojo.internal
      product_name: container-security
      
    - name: security_hub
      region: us-west-2
      findings_filter:
        ProductName: container-scanning
        SeverityLabel: CRITICAL
```

### 2. Security Notifications
```yaml
# Security Alert Configuration
notifications:
  channels:
    slack:
      channel: security-alerts
      triggers:
        - new_critical_vulnerability
        - compliance_violation
    
    email:
      recipients: [security-team@company.com]
      triggers:
        - weekly_security_report
        - critical_security_event
```

## Best Practices

### 1. Container Build Security
- Use minimal base images
- Multi-stage builds
- No secrets in images
- Pin dependency versions
- Regularly update base images

### 2. Runtime Security
- Implement pod security standards
- Use network policies
- Enable audit logging
- Implement admission controllers
- Regular security assessments

### 3. Supply Chain Security
- Sign container images
- Verify image signatures
- Generate and verify SBOMs
- Use trusted registries
- Implement image promotion policies

## Compliance Requirements

### 1. Container Compliance Standards
```yaml
compliance_requirements:
  - standard: CIS_DOCKER_BENCHMARK
    version: "1.3.1"
    controls:
      - "4.1"  # Image Build
      - "4.2"  # Runtime
      - "4.3"  # Network
      - "4.4"  # Storage
      
  - standard: PCI_DSS
    version: "4.0"
    controls:
      - "6.2"  # Security Patches
      - "6.4"  # Change Control
      - "10.2" # Audit Logging
```

### 2. Audit Requirements
```yaml
audit_configuration:
  retention_period: 365d
  audit_events:
    - container_launch
    - image_pull
    - security_violation
  audit_trail:
    - timestamp
    - user
    - action
    - resource
    - result
```

## Conclusion

Container security scanning in CI/CD pipelines requires:

1. **Comprehensive Coverage**
   - Base image scanning
   - Build-time security
   - Runtime protection
   - Supply chain security

2. **Automation**
   - Automated scanning
   - Policy enforcement
   - Continuous monitoring
   - Automated remediation

3. **Integration**
   - DevSecOps tools
   - Compliance frameworks
   - Security monitoring
   - Incident response

4. **Documentation**
   - Security policies
   - Compliance requirements
   - Incident procedures
   - Best practices

Remember to regularly update security tools and policies to address new container security threats and vulnerabilities.