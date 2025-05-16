# Real-World Repository Examples

## Microservice Documentation Example

```markdown
# User Authentication Service

Cloud-native authentication service providing OAuth2 and OIDC capabilities.

## Quick Links
- [API Documentation](https://api-docs.example.com)
- [Metrics Dashboard](https://grafana.example.com/auth-service)
- [On-Call Runbook](./docs/runbook.md)

## Architecture
- Language: Go 1.22
- Database: PostgreSQL 16
- Cache: Redis 7.2
- Message Queue: RabbitMQ 3.12

## Development
1. Prerequisites:
   ```bash
   make setup-dev
   ```

2. Run locally:
   ```bash
   make run-local
   ```

## Production Infrastructure
- Kubernetes-based deployment
- Multi-region active-active
- Automated failover
- Rate limiting enabled

## Security Controls
- [ ] SOC2 compliant
- [ ] PCI-DSS certified
- [ ] GDPR compliant
- [ ] Pen-tested quarterly

## Service Level Objectives (SLOs)
- Availability: 99.99%
- Latency (p95): < 200ms
- Error Rate: < 0.1%
```

## Infrastructure Pipeline Example

```yaml
# .azure/pipelines/infrastructure.yml
trigger:
  branches:
    include:
      - main
      - feature/*
  paths:
    include:
      - terraform/**
      - .azure/pipelines/infrastructure.yml

variables:
  - group: terraform-secrets
  - name: ENVIRONMENT
    value: production

stages:
  - stage: validate
    jobs:
      - job: terraform_validate
        steps:
          - task: TerraformInstaller@1
          - task: TerraformValidate@1
          - task: CheckovScan@1

  - stage: plan
    jobs:
      - job: terraform_plan
        steps:
          - task: TerraformPlan@1
            inputs:
              environmentServiceName: 'azure-$(ENVIRONMENT)'
              commandOptions: '-var-file=environments/$(ENVIRONMENT).tfvars'

  - stage: apply
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: terraform_apply
        environment: $(ENVIRONMENT)
        strategy:
          runOnce:
            deploy:
              steps:
                - task: TerraformApply@1
                  inputs:
                    commandOptions: '-auto-approve'
```

## Service Level Agreement (SLA) Example

```markdown
# Service Level Agreement - Payment Processing API

## Service Commitment
Payment Processing API will provide 99.99% uptime, measured monthly.

## Performance Metrics
1. Request Latency
   - 95th percentile < 300ms
   - 99th percentile < 500ms

2. Error Rates
   - API Errors: < 0.1%
   - Payment Failures: < 0.01%

3. Recovery Time
   - RTO (Recovery Time Objective): 15 minutes
   - RPO (Recovery Point Objective): 5 minutes

## Monitoring & Alerting
- Real-time dashboard: https://grafana.example.com/payments
- PagerDuty integration for P1/P2 incidents
- Monthly SLA reports

## Incident Response
1. Severity Levels:
   - P0: Complete service outage
   - P1: Degraded performance
   - P2: Single region issues
   - P3: Non-critical bugs

2. Response Times:
   - P0: 15 minutes
   - P1: 30 minutes
   - P2: 2 hours
   - P3: Next business day

## Credits
- < 99.99%: 10% credit
- < 99.9%: 25% credit
- < 99%: 100% credit
```