---
description: Best practices for implementing Kosli in DevOps workflows for optimal compliance and deployment tracking
keywords: kosli, best practices, devops, compliance, deployment, evidence
---

# Kosli Best Practices

## Flow Organization

### One Flow Per Deployable Unit

Create separate flows for each independently deployable application:

✅ **Good**:
```
payment-api
user-service
notification-worker
web-frontend
```

❌ **Bad**:
```
all-microservices  # Too broad
backend            # Too vague
```

### Flow Naming Conventions

Use consistent, descriptive names:

```
<team>-<service>-<component>
examples:
- platform-auth-api
- payments-processing-worker
- customer-web-app
```

## Evidence Collection Strategy

### Collect Evidence Early

Report evidence as soon as it's available:

```
Build → Report Artifact → Test → Report Tests → Scan → Report Scan → Deploy → Report Deployment
```

Don't wait until deployment to report all evidence.

### Required Evidence Types

At minimum, collect these evidence types:

1. **Test Results** - Prove testing occurred
2. **Security Scans** - Prove vulnerability scanning
3. **Code Review** - Prove peer review (PR approval)
4. **Build Info** - Link to CI/CD build

### Evidence Completeness

Ensure all artifacts have complete evidence before production deployment:

```yaml
# GitHub Actions example
- name: Check Compliance
  run: |
    COMPLIANCE=$(kosli get artifact myapp:${{ github.sha }} --flow myapp --output json | jq -r '.compliant')
    if [ "$COMPLIANCE" != "true" ]; then
      echo "❌ Artifact is not compliant - missing required evidence"
      exit 1
    fi
```

## Deployment Tracking

### Always Report Deployments

Report every deployment, not just production:

```bash
# Development
kosli report deployment dev --flow myapp --name myapp:v1.0

# Staging
kosli report deployment staging --flow myapp --name myapp:v1.0

# Production
kosli report deployment production --flow myapp --name myapp:v1.0
```

### Use Exact Artifact References

Ensure the artifact name reported matches exactly what's deployed:

```bash
# Set once
ARTIFACT="myapp:${VERSION}"

# Use everywhere
kosli report artifact ${ARTIFACT} ...
docker push ${ARTIFACT}
kubectl set image ... ${ARTIFACT}
kosli report deployment ... --name ${ARTIFACT}
```

### Report Deployment Timing

Report deployments at the right time:

```yaml
# After successful deployment
- name: Deploy
  run: kubectl apply -f k8s/

- name: Wait for Rollout
  run: kubectl rollout status deployment/myapp

- name: Report Deployment  # Only after successful rollout
  run: kosli report deployment production --name myapp:v1.0
```

## Environment Snapshots

### Regular Snapshots

Snapshot environments regularly to detect drift:

```yaml
# Every 15 minutes
schedule:
  - cron: '*/15 * * * *'

jobs:
  snapshot:
    steps:
      - run: kosli snapshot k8s production --namespace production
```

### Snapshot After Deployment

Always snapshot after deploying to verify:

```bash
# Deploy
kubectl apply -f k8s/

# Report deployment
kosli report deployment production --name myapp:v1.0

# Verify with snapshot (within minutes)
kosli snapshot k8s production --namespace production
```

### Multiple Namespaces

Snapshot all relevant namespaces:

```bash
kosli snapshot k8s production \
  --namespace app,database,monitoring,logging
```

## Security and Authentication

### Secure API Token Storage

- ✅ Store in CI/CD secrets
- ✅ Use environment variables
- ✅ Rotate tokens every 90 days
- ❌ Never commit tokens to code
- ❌ Don't log tokens

### Least Privilege

Use dedicated service accounts:
- Create separate tokens for each CI/CD system
- Name tokens descriptively: "GitHub Actions - payment-api"
- Revoke unused tokens

## Performance Optimization

### Parallel Evidence Collection

Collect evidence in parallel when possible:

```yaml
# GitLab CI
test_unit:
  stage: evidence
  script:
    - pytest --junitxml=unit-results.xml
    - kosli report evidence test junit --results-file unit-results.xml

test_integration:
  stage: evidence
  script:
    - npm test --reporter=junit > integration-results.xml
    - kosli report evidence test junit --results-file integration-results.xml

# Both run in parallel
```

### Batch Operations

Don't make unnecessary API calls:

```bash
# Report artifact once with all metadata
kosli report artifact myapp:v1.0 \
  --artifact-type docker \
  --flow payment-api \
  --commit $GIT_SHA \
  --build-url $BUILD_URL \
  --git-commit-info HEAD
```

## Error Handling

### Graceful Degradation

Don't fail deployments if Kosli is temporarily unavailable:

```bash
# Option 1: Continue on error
kosli report deployment production --name myapp:v1.0 || \
  echo "⚠️ Kosli reporting failed, continuing deployment"

# Option 2: Retry logic
for i in {1..3}; do
  kosli report deployment production --name myapp:v1.0 && break
  sleep 5
done
```

**Note**: Only use if your compliance requirements allow deployments without tracking.

### Alerting on Failures

Alert teams when Kosli reporting fails:

```yaml
- name: Report Deployment
  id: kosli
  run: kosli report deployment production --name myapp:v1.0
  continue-on-error: true

- name: Alert on Failure
  if: steps.kosli.outcome == 'failure'
  run: |
    curl -X POST $SLACK_WEBHOOK \
      -d '{"text": "⚠️ Kosli reporting failed for deployment"}'
```

## Compliance and Audit

### Audit Trail Documentation

Ensure complete audit trails:

1. **Artifact fingerprint** - Cryptographic proof of what was built
2. **Test evidence** - Proof testing occurred and passed
3. **Security evidence** - Proof of vulnerability scanning
4. **Review evidence** - Proof of code review
5. **Deployment record** - When, where, and by whom

### Policy as Code

Define compliance policies explicitly:

```yaml
# Example policy (conceptual)
policies:
  - name: production-requirements
    rules:
      - type: test-evidence
        required: true
      - type: security-scan
        required: true
        max-critical-vulnerabilities: 0
      - type: code-review
        required: true
```

### Regular Compliance Reports

Generate compliance reports regularly:

```bash
# Get compliance status for all artifacts in flow
kosli get flow payment-api --output json | \
  jq '.artifacts[] | {name, compliant, evidence_count}'
```

## Team Adoption

### Start Small

Begin with a single application/flow:

1. Week 1: Report artifacts and deployments
2. Week 2: Add test evidence
3. Week 3: Add security scan evidence
4. Week 4: Add code review evidence
5. Week 5: Implement environment snapshots

### Document Your Setup

Create team documentation:

```markdown
# Kosli Setup for Payment API

## Flow Name
payment-api

## Required Evidence
- JUnit test results
- Trivy security scan
- GitHub PR approval

## Environments
- dev
- staging
- production

## Snapshot Schedule
Every 15 minutes in production
```

### Monitor Adoption

Track Kosli usage metrics:
- % of deployments with Kosli tracking
- Average evidence count per artifact
- Time from build to deployment
- Drift detection alerts

## Common Pitfalls

### ❌ Don't: Report Wrong Artifact Names

```bash
# Bad - inconsistent names
kosli report artifact myapp:latest ...
kubectl set image ... myapp:v1.2.3  # Different!
```

✅ **Do: Use consistent references**

```bash
ARTIFACT="myapp:v1.2.3"
kosli report artifact ${ARTIFACT} ...
kubectl set image ... ${ARTIFACT}
```

### ❌ Don't: Skip Environment Snapshots

Snapshots verify what's actually running - don't skip them.

### ❌ Don't: Report After Failed Deployments

Only report successful deployments:

```bash
# Deploy
if kubectl apply -f k8s/; then
  # Only report if deployment succeeded
  kosli report deployment production --name myapp:v1.0
fi
```

## Real-World Example

**Scenario**: SaaS company with 20 microservices, SOC 2 requirement

**Implementation**:

```yaml
# .github/workflows/deploy.yml
name: Deploy with Kosli

on:
  push:
    branches: [main]

env:
  KOSLI_API_TOKEN: ${{ secrets.KOSLI_API_TOKEN }}
  KOSLI_ORG: ${{ secrets.KOSLI_ORG }}
  KOSLI_FLOW: ${{ github.event.repository.name }}
  ARTIFACT: ${{ github.event.repository.name }}:${{ github.sha }}

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: kosli-dev/setup-cli-action@v2

      - name: Build
        run: docker build -t $ARTIFACT .

      - name: Report Artifact
        run: |
          kosli report artifact $ARTIFACT \
            --artifact-type docker \
            --build-url ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }} \
            --commit ${{ github.sha }} \
            --git-commit-info HEAD

      - name: Test
        run: pytest --junitxml=tests.xml

      - name: Report Tests
        run: |
          kosli report evidence test junit \
            --name $ARTIFACT \
            --results-file tests.xml

      - name: Security Scan
        run: trivy image --format json -o scan.json $ARTIFACT

      - name: Report Scan
        run: |
          kosli report evidence generic \
            --name $ARTIFACT \
            --evidence-type security-scan \
            --attachments scan.json

      - name: Deploy
        run: kubectl apply -f k8s/

      - name: Report Deployment
        run: kosli report deployment production --name $ARTIFACT

      - name: Snapshot
        run: kosli snapshot k8s production --namespace production
```

**Results**:
- 100% deployment tracking
- Complete SOC 2 compliance
- Zero manual documentation
- Passed audit on first attempt

## Next Steps

- [Kosli Overview](README.md)
- [Getting Started](getting-started.md)
- [CLI Reference](cli-reference.md)
- [GitHub Actions Integration](github-actions.md)
