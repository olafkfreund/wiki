---
description: Integrate Kosli with GitHub Actions workflows for automated change tracking and compliance evidence collection
keywords: kosli, github actions, github, ci/cd, compliance, deployment tracking, devops
---

# Kosli GitHub Actions Integration

## Overview

This guide demonstrates how to integrate Kosli with GitHub Actions workflows to automatically track deployments, collect compliance evidence, and maintain audit trails—all without slowing down your delivery pipeline.

## Prerequisites

- Kosli account and API token
- GitHub repository with Actions enabled
- Docker or deployable artifacts
- Kubernetes or deployment target

## Setup

### 1. Configure GitHub Secrets

Add these secrets to your repository (**Settings > Secrets and variables > Actions**):

```
KOSLI_API_TOKEN      # Your Kosli API token
KOSLI_ORG            # Your Kosli organization name
```

### 2. Install Kosli CLI Action

Use the official Kosli setup action in your workflow:

```yaml
- name: Setup Kosli CLI
  uses: kosli-dev/setup-cli-action@v2
  with:
    version: latest
```

## Basic Workflow

### Complete Example

`.github/workflows/deploy.yml`:

```yaml
name: Deploy with Kosli Tracking

on:
  push:
    branches: [main]

env:
  KOSLI_API_TOKEN: ${{ secrets.KOSLI_API_TOKEN }}
  KOSLI_ORG: ${{ secrets.KOSLI_ORG }}
  KOSLI_FLOW: microservice-api
  IMAGE_NAME: myapp:${{ github.sha }}

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Setup Kosli CLI
      - name: Setup Kosli CLI
        uses: kosli-dev/setup-cli-action@v2

      # Build Docker Image
      - name: Build Docker Image
        run: docker build -t ${{ env.IMAGE_NAME }} .

      # Report Artifact to Kosli
      - name: Report Artifact
        run: |
          kosli report artifact ${{ env.IMAGE_NAME }} \
            --flow ${{ env.KOSLI_FLOW }} \
            --artifact-type docker \
            --build-url ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }} \
            --commit ${{ github.sha }} \
            --git-commit-info HEAD

      # Run Tests
      - name: Run Unit Tests
        run: |
          pytest --junitxml=test-results.xml --cov

      # Report Test Evidence
      - name: Report Test Evidence
        run: |
          kosli report evidence test junit \
            --flow ${{ env.KOSLI_FLOW }} \
            --name ${{ env.IMAGE_NAME }} \
            --results-file test-results.xml

      # Security Scan
      - name: Run Trivy Security Scan
        run: |
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image \
            --format json \
            --output trivy-scan.json \
            ${{ env.IMAGE_NAME }}

      # Report Security Evidence
      - name: Report Security Scan
        run: |
          kosli report evidence generic \
            --flow ${{ env.KOSLI_FLOW }} \
            --name ${{ env.IMAGE_NAME }} \
            --evidence-type security-scan \
            --description "Trivy vulnerability scan" \
            --attachments trivy-scan.json

      # Push to Registry
      - name: Push Image
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker push ${{ env.IMAGE_NAME }}

      # Deploy to Kubernetes
      - name: Deploy to Production
        run: |
          kubectl set image deployment/myapp myapp=${{ env.IMAGE_NAME }} -n production
          kubectl rollout status deployment/myapp -n production

      # Report Deployment
      - name: Report Deployment
        run: |
          kosli report deployment production \
            --flow ${{ env.KOSLI_FLOW }} \
            --name ${{ env.IMAGE_NAME }}

      # Snapshot Environment
      - name: Snapshot Production
        run: |
          kosli snapshot k8s production \
            --namespace production
```

## Step-by-Step Integration

### Step 1: Report Artifact

Report your built artifact (Docker image, binary, etc.):

```yaml
- name: Build Application
  run: docker build -t myapp:${{ github.sha }} .

- name: Report Artifact to Kosli
  run: |
    kosli report artifact myapp:${{ github.sha }} \
      --flow microservice-api \
      --artifact-type docker \
      --build-url ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }} \
      --commit ${{ github.sha }} \
      --git-commit-info HEAD
```

**What this does**:
- Creates cryptographic fingerprint of the artifact
- Links artifact to Git commit
- Records build URL for traceability

### Step 2: Report Test Evidence

Report test results as evidence:

```yaml
- name: Run Tests
  run: pytest --junitxml=test-results.xml

- name: Report Test Evidence
  run: |
    kosli report evidence test junit \
      --flow microservice-api \
      --name myapp:${{ github.sha }} \
      --results-file test-results.xml
```

**Supports**:
- JUnit XML format
- Test pass/fail counts
- Test execution time

### Step 3: Report Security Scan

Report security scanning results:

```yaml
- name: Security Scan with Trivy
  run: |
    trivy image --format json -o scan.json myapp:${{ github.sha }}

- name: Report Security Evidence
  run: |
    kosli report evidence generic \
      --flow microservice-api \
      --name myapp:${{ github.sha }} \
      --evidence-type security-scan \
      --description "Trivy security scan" \
      --attachments scan.json
```

**Alternative Scanners**:
- Snyk: `snyk container test --json-file-output=snyk.json`
- Grype: `grype -o json myapp:${{ github.sha }}`
- Anchore: `anchore-cli image scan myapp:${{ github.sha }}`

### Step 4: Report Deployment

Report when artifact is deployed:

```yaml
- name: Deploy to Kubernetes
  run: kubectl apply -f k8s/production/

- name: Report Deployment to Kosli
  run: |
    kosli report deployment production \
      --flow microservice-api \
      --name myapp:${{ github.sha }}
```

### Step 5: Snapshot Environment

Verify what's actually running:

```yaml
- name: Snapshot Production Environment
  run: |
    kosli snapshot k8s production \
      --namespace production
```

## Advanced Patterns

### Matrix Deployments

Deploy to multiple environments:

```yaml
strategy:
  matrix:
    environment: [staging, production]

steps:
  - name: Deploy to ${{ matrix.environment }}
    run: kubectl apply -f k8s/${{ matrix.environment }}/

  - name: Report Deployment
    run: |
      kosli report deployment ${{ matrix.environment }} \
        --flow microservice-api \
        --name myapp:${{ github.sha }}
```

### Conditional Evidence

Only collect certain evidence in specific scenarios:

```yaml
- name: Run Integration Tests
  if: github.ref == 'refs/heads/main'
  run: npm run test:integration

- name: Report Integration Test Evidence
  if: github.ref == 'refs/heads/main'
  run: |
    kosli report evidence test junit \
      --flow microservice-api \
      --name myapp:${{ github.sha }} \
      --results-file integration-results.xml
```

### Reusable Workflow

Create a reusable workflow for Kosli tracking:

`.github/workflows/kosli-report.yml`:

```yaml
name: Kosli Reporting

on:
  workflow_call:
    inputs:
      artifact-name:
        required: true
        type: string
      flow:
        required: true
        type: string
      environment:
        required: false
        type: string
        default: ''

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: kosli-dev/setup-cli-action@v2

      - name: Report Artifact
        run: |
          kosli report artifact ${{ inputs.artifact-name }} \
            --flow ${{ inputs.flow }} \
            --artifact-type docker \
            --commit ${{ github.sha }}

      - name: Report Deployment
        if: inputs.environment != ''
        run: |
          kosli report deployment ${{ inputs.environment }} \
            --flow ${{ inputs.flow }} \
            --name ${{ inputs.artifact-name }}
```

**Use the reusable workflow**:

```yaml
jobs:
  deploy:
    uses: ./.github/workflows/kosli-report.yml
    with:
      artifact-name: myapp:${{ github.sha }}
      flow: microservice-api
      environment: production
    secrets: inherit
```

### Pull Request Evidence

Report PR approvals as evidence:

```yaml
on:
  pull_request:
    types: [closed]

jobs:
  report-pr-approval:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - uses: kosli-dev/setup-cli-action@v2

      - name: Get PR Details
        id: pr
        uses: actions/github-script@v7
        with:
          script: |
            const pr = await github.rest.pulls.get({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            const reviews = await github.rest.pulls.listReviews({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            return {
              approved_by: reviews.data.filter(r => r.state === 'APPROVED').map(r => r.user.login),
              merged_by: pr.data.merged_by.login
            };

      - name: Report PR Evidence
        run: |
          echo '${{ steps.pr.outputs.result }}' > pr-details.json

          kosli report evidence generic \
            --flow microservice-api \
            --name myapp:${{ github.event.pull_request.head.sha }} \
            --evidence-type pull-request \
            --description "PR #${{ github.event.pull_request.number }} approved and merged" \
            --attachments pr-details.json
```

## Scheduled Environment Snapshots

Run periodic snapshots to detect drift:

```yaml
name: Snapshot Production

on:
  schedule:
    - cron: '*/15 * * * *'  # Every 15 minutes
  workflow_dispatch:  # Manual trigger

jobs:
  snapshot:
    runs-on: ubuntu-latest
    steps:
      - uses: kosli-dev/setup-cli-action@v2

      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Snapshot Production
        run: |
          kosli snapshot k8s production \
            --namespace production

      - name: Alert on Drift
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "⚠️ Kosli detected drift in production!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Production Drift Detected*\n\nUnexpected changes found in production environment.\n\n<https://app.kosli.com|View in Kosli>"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Error Handling

### Graceful Failure

Don't fail deployments if Kosli reporting fails (but log the issue):

```yaml
- name: Report to Kosli
  continue-on-error: true
  run: |
    kosli report deployment production \
      --flow microservice-api \
      --name myapp:${{ github.sha }} || \
    echo "⚠️ Failed to report to Kosli, continuing deployment"

- name: Alert on Kosli Failure
  if: failure()
  run: |
    echo "::warning::Kosli reporting failed - deployment proceeded without tracking"
```

### Retry Logic

Implement retry for transient failures:

```yaml
- name: Report with Retry
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 5
    max_attempts: 3
    retry_wait_seconds: 10
    command: |
      kosli report deployment production \
        --flow microservice-api \
        --name myapp:${{ github.sha }}
```

## Best Practices

### 1. Report Early, Deploy Later

Report artifacts and evidence **before** deployment:

✅ **Good**:
```
Build → Report Artifact → Test → Report Evidence → Deploy → Report Deployment
```

❌ **Bad**:
```
Build → Test → Deploy → Report Everything
```

### 2. Include Contextual Information

Provide rich context in your reports:

```yaml
- name: Report Artifact with Context
  run: |
    kosli report artifact myapp:${{ github.sha }} \
      --flow microservice-api \
      --artifact-type docker \
      --build-url ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }} \
      --commit ${{ github.sha }} \
      --git-commit-info HEAD \
      --description "Deploy from PR #${{ github.event.pull_request.number }}: ${{ github.event.head_commit.message }}"
```

### 3. Use Environment-Specific Flows

Separate flows for different criticality levels:

```yaml
- name: Determine Flow
  id: flow
  run: |
    if [ "${{ github.ref }}" == "refs/heads/main" ]; then
      echo "flow=production-api" >> $GITHUB_OUTPUT
    else
      echo "flow=development-api" >> $GITHUB_OUTPUT
    fi

- name: Report with Correct Flow
  run: |
    kosli report artifact myapp:${{ github.sha }} \
      --flow ${{ steps.flow.outputs.flow }}
```

### 4. Snapshot After Deployment

Always snapshot after deploying to verify:

```yaml
- name: Deploy
  run: kubectl apply -f k8s/

- name: Report Deployment
  run: kosli report deployment production ...

- name: Verify with Snapshot
  run: kosli snapshot k8s production --namespace production
```

## Troubleshooting

### Authentication Issues

```yaml
- name: Test Kosli Auth
  run: |
    kosli version
    kosli list flows
```

### Artifact Fingerprint Issues

If fingerprints don't match between report and deployment:

```bash
# Ensure you're using the exact same artifact reference
- name: Set Artifact Name
  id: artifact
  run: echo "name=myapp:${{ github.sha }}" >> $GITHUB_OUTPUT

# Use the same reference everywhere
- run: docker build -t ${{ steps.artifact.outputs.name }} .
- run: kosli report artifact ${{ steps.artifact.outputs.name }} ...
- run: docker push ${{ steps.artifact.outputs.name }}
- run: kubectl set image ... ${{ steps.artifact.outputs.name }}
```

## Next Steps

- [GitLab CI Integration](gitlab-ci.md)
- [Azure DevOps Integration](azure-devops.md)
- [Kosli CLI Reference](cli-reference.md)
- [Best Practices](best-practices.md)

## Additional Resources

- [Kosli GitHub Actions Setup Action](https://github.com/marketplace/actions/setup-kosli-cli)
- [Kosli Documentation](https://docs.kosli.com/)
- [Example Workflows](https://github.com/kosli-dev/examples)
