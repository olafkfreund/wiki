---
description: Integrate ServiceNow with GitHub Actions workflows for automated change management and compliance
keywords: servicenow, github actions, github, ci/cd, change management, devops, automation
---

# ServiceNow GitHub Actions Integration

## Overview

This guide demonstrates how to integrate ServiceNow change management with GitHub Actions workflows. The integration enables automated change request creation, approval gates, and deployment tracking directly from GitHub Actions.

## Integration Architecture

```
┌────────────────────────────────────────────┐
│       GitHub Actions Workflow              │
│                                            │
│  ┌──────┐  ┌──────┐  ┌───────────────┐   │
│  │Build │─→│ Test │─→│ Create SNOW   │   │
│  └──────┘  └──────┘  │ Change Request│   │
│                       └───────┬───────┘   │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Wait for Approval  │ │
│                    └──────────┬─────────┘ │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Deploy Application │ │
│                    └──────────┬─────────┘ │
│                               │           │
│                               ▼           │
│                    ┌────────────────────┐ │
│                    │ Close Change       │ │
│                    └────────────────────┘ │
└────────────────────────────────────────────┘
                        │
                        ▼
              ┌──────────────────┐
              │   ServiceNow     │
              │  Change Request  │
              └──────────────────┘
```

## Prerequisites

### ServiceNow Setup

1. **API Access**: ServiceNow instance with REST API enabled
2. **Service Account**: User with `itil` role for change management
3. **OAuth Configuration** (recommended for production)

### GitHub Setup

1. **Repository Secrets** (Settings > Secrets and variables > Actions):
   ```
   SERVICENOW_INSTANCE     # Your instance name (e.g., dev12345)
   SERVICENOW_USERNAME     # Service account username
   SERVICENOW_PASSWORD     # Service account password
   SERVICENOW_CLIENT_ID    # OAuth client ID (if using OAuth)
   SERVICENOW_CLIENT_SECRET # OAuth client secret (if using OAuth)
   ```

2. **Repository Variables** (optional):
   ```
   ASSIGNMENT_GROUP        # Default assignment group
   CMDB_CI                 # Configuration item reference
   ```

## Method 1: Direct REST API Integration

### Basic Workflow

Create `.github/workflows/deploy-with-servicenow.yml`:

```yaml
name: Deploy with ServiceNow Change Management

on:
  push:
    branches: [main]
    tags:
      - 'v*'

env:
  SERVICENOW_INSTANCE: ${{ secrets.SERVICENOW_INSTANCE }}
  SERVICENOW_URL: https://${{ secrets.SERVICENOW_INSTANCE }}.service-now.com

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Application
        run: |
          echo "Building application..."
          docker build -t myapp:${{ github.sha }} .

      - name: Run Tests
        run: |
          echo "Running tests..."
          npm test -- --coverage --reporters=default --reporters=jest-junit
        continue-on-error: false

      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: junit.xml

  create-change-request:
    runs-on: ubuntu-latest
    needs: build
    outputs:
      change-sys-id: ${{ steps.create-change.outputs.sys_id }}
      change-number: ${{ steps.create-change.outputs.number }}
    steps:
      - name: Create ServiceNow Change Request
        id: create-change
        run: |
          RESPONSE=$(curl -X POST \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{
              \"short_description\": \"Deploy ${{ github.repository }} ${{ github.ref_name }}\",
              \"description\": \"Automated deployment from GitHub Actions\\nWorkflow: ${{ github.workflow }}\\nRun: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}\\nCommit: ${{ github.sha }}\\nAuthor: ${{ github.actor }}\",
              \"assignment_group\": \"DevOps Team\",
              \"type\": \"standard\",
              \"priority\": \"3\",
              \"risk\": \"low\",
              \"impact\": \"2\",
              \"implementation_plan\": \"Deploy containerized application to Kubernetes cluster using Helm\",
              \"backout_plan\": \"Rollback deployment using helm rollback command\",
              \"justification\": \"Deploy commit ${{ github.sha }} from ${{ github.ref_name }}\"
            }")

          # Extract sys_id and change number
          SYS_ID=$(echo "$RESPONSE" | jq -r '.result.sys_id')
          CHANGE_NUMBER=$(echo "$RESPONSE" | jq -r '.result.number')

          echo "Created ServiceNow Change Request: $CHANGE_NUMBER"
          echo "Change SYS_ID: $SYS_ID"
          echo "Change URL: ${{ env.SERVICENOW_URL }}/nav_to.do?uri=change_request.do?sys_id=$SYS_ID"

          # Set outputs
          echo "sys_id=$SYS_ID" >> $GITHUB_OUTPUT
          echo "number=$CHANGE_NUMBER" >> $GITHUB_OUTPUT

      - name: Comment on PR with Change Request
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `🎫 ServiceNow Change Request Created: **${{ steps.create-change.outputs.number }}**\n\n[View in ServiceNow](${{ env.SERVICENOW_URL }}/nav_to.do?uri=change_request.do?sys_id=${{ steps.create-change.outputs.sys_id }})`
            })

  wait-for-approval:
    runs-on: ubuntu-latest
    needs: create-change-request
    steps:
      - name: Wait for Change Approval
        run: |
          echo "⏳ Waiting for approval of change: ${{ needs.create-change-request.outputs.change-number }}"

          TIMEOUT=3600  # 1 hour
          INTERVAL=60   # Check every minute
          ELAPSED=0
          SYS_ID="${{ needs.create-change-request.outputs.change-sys-id }}"

          while [ $ELAPSED -lt $TIMEOUT ]; do
            # Get change status
            RESPONSE=$(curl -s -X GET \
              "${{ env.SERVICENOW_URL }}/api/now/table/change_request/$SYS_ID?sysparm_fields=state,approval,number" \
              -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
              -H "Accept: application/json")

            STATE=$(echo "$RESPONSE" | jq -r '.result.state')
            APPROVAL=$(echo "$RESPONSE" | jq -r '.result.approval')

            echo "⏱️  Change ${{ needs.create-change-request.outputs.change-number }} - State: $STATE, Approval: $APPROVAL"

            # Check if approved (state: -2 = Scheduled, -1 = Implement)
            if [ "$STATE" = "-2" ] || [ "$STATE" = "-1" ]; then
              echo "✅ Change request approved!"
              exit 0
            fi

            # Check if rejected or canceled (state: 4 = Canceled)
            if [ "$STATE" = "4" ] || [ "$APPROVAL" = "rejected" ]; then
              echo "❌ Change request rejected or canceled"
              exit 1
            fi

            # Wait and retry
            sleep $INTERVAL
            ELAPSED=$((ELAPSED + INTERVAL))
          done

          echo "❌ Timeout waiting for approval"
          exit 1

  deploy:
    runs-on: ubuntu-latest
    needs: [create-change-request, wait-for-approval]
    environment:
      name: production
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Production
        run: |
          echo "🚀 Deploying to production..."
          # Add your deployment commands here
          # kubectl apply -f k8s/
          # helm upgrade myapp ./charts/myapp
          echo "✅ Deployment completed"

      - name: Update Change Request - Implementing
        run: |
          curl -X PATCH \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request/${{ needs.create-change-request.outputs.change-sys-id }}" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d "{
              \"state\": \"-1\",
              \"work_notes\": \"Deployment completed at $(date -Iseconds)\\nWorkflow: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}\"
            }"

          echo "✅ Updated change request to 'Implementing' state"

  close-change-request:
    runs-on: ubuntu-latest
    needs: [create-change-request, deploy]
    if: success()
    steps:
      - name: Close Change Request
        run: |
          curl -X PATCH \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request/${{ needs.create-change-request.outputs.change-sys-id }}" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d "{
              \"state\": \"3\",
              \"close_code\": \"successful\",
              \"close_notes\": \"Deployment verified successfully in production.\\nCommit: ${{ github.sha }}\\nDeployed at: $(date -Iseconds)\"
            }"

          echo "✅ Closed change request: ${{ needs.create-change-request.outputs.change-number }}"

  handle-failure:
    runs-on: ubuntu-latest
    needs: [create-change-request, deploy]
    if: failure()
    steps:
      - name: Update Change Request - Failed
        run: |
          curl -X PATCH \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request/${{ needs.create-change-request.outputs.change-sys-id }}" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d "{
              \"state\": \"4\",
              \"close_code\": \"unsuccessful\",
              \"close_notes\": \"Deployment failed. See workflow run for details:\\n${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}\"
            }"

          echo "❌ Marked change request as unsuccessful"
```

## Method 2: Reusable Composite Actions

### Create Custom Action

Create `.github/actions/servicenow-change/action.yml`:

```yaml
name: 'ServiceNow Change Management'
description: 'Create and manage ServiceNow change requests'
inputs:
  action:
    description: 'Action to perform: create, wait, update, close'
    required: true
  instance:
    description: 'ServiceNow instance name'
    required: true
  username:
    description: 'ServiceNow username'
    required: true
  password:
    description: 'ServiceNow password'
    required: true
  change-sys-id:
    description: 'Change request sys_id (for update/close)'
    required: false
  short-description:
    description: 'Short description for change'
    required: false
  state:
    description: 'State for update (implement/review/closed)'
    required: false
    default: 'implement'

outputs:
  change-sys-id:
    description: 'Change request sys_id'
    value: ${{ steps.execute.outputs.sys_id }}
  change-number:
    description: 'Change request number'
    value: ${{ steps.execute.outputs.number }}

runs:
  using: 'composite'
  steps:
    - name: Execute ServiceNow Action
      id: execute
      shell: bash
      env:
        SNOW_URL: https://${{ inputs.instance }}.service-now.com
        SNOW_USER: ${{ inputs.username }}
        SNOW_PASS: ${{ inputs.password }}
      run: |
        case "${{ inputs.action }}" in
          create)
            echo "Creating change request..."
            RESPONSE=$(curl -X POST "$SNOW_URL/api/now/table/change_request" \
              -u "$SNOW_USER:$SNOW_PASS" \
              -H "Content-Type: application/json" \
              -d "{
                \"short_description\": \"${{ inputs.short-description }}\",
                \"type\": \"standard\",
                \"priority\": \"3\"
              }")
            SYS_ID=$(echo "$RESPONSE" | jq -r '.result.sys_id')
            NUMBER=$(echo "$RESPONSE" | jq -r '.result.number')
            echo "sys_id=$SYS_ID" >> $GITHUB_OUTPUT
            echo "number=$NUMBER" >> $GITHUB_OUTPUT
            echo "✅ Created change: $NUMBER"
            ;;

          wait)
            echo "Waiting for approval..."
            SYS_ID="${{ inputs.change-sys-id }}"
            # Polling logic here (abbreviated for space)
            echo "✅ Change approved"
            ;;

          update)
            echo "Updating change..."
            curl -X PATCH "$SNOW_URL/api/now/table/change_request/${{ inputs.change-sys-id }}" \
              -u "$SNOW_USER:$SNOW_PASS" \
              -H "Content-Type: application/json" \
              -d '{"state": "-1", "work_notes": "Updated from GitHub Actions"}'
            echo "✅ Change updated"
            ;;

          close)
            echo "Closing change..."
            curl -X PATCH "$SNOW_URL/api/now/table/change_request/${{ inputs.change-sys-id }}" \
              -u "$SNOW_USER:$SNOW_PASS" \
              -H "Content-Type: application/json" \
              -d '{"state": "3", "close_code": "successful"}'
            echo "✅ Change closed"
            ;;
        esac
```

### Use Custom Action

```yaml
name: Deploy with Custom ServiceNow Action

on:
  push:
    branches: [main]

jobs:
  deploy-with-change:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and Test
        run: npm run build && npm test

      - name: Create Change Request
        id: create-change
        uses: ./.github/actions/servicenow-change
        with:
          action: create
          instance: ${{ secrets.SERVICENOW_INSTANCE }}
          username: ${{ secrets.SERVICENOW_USERNAME }}
          password: ${{ secrets.SERVICENOW_PASSWORD }}
          short-description: "Deploy ${{ github.repository }} ${{ github.ref_name }}"

      - name: Wait for Approval
        uses: ./.github/actions/servicenow-change
        with:
          action: wait
          instance: ${{ secrets.SERVICENOW_INSTANCE }}
          username: ${{ secrets.SERVICENOW_USERNAME }}
          password: ${{ secrets.SERVICENOW_PASSWORD }}
          change-sys-id: ${{ steps.create-change.outputs.change-sys-id }}

      - name: Deploy
        run: kubectl apply -f k8s/

      - name: Close Change Request
        uses: ./.github/actions/servicenow-change
        with:
          action: close
          instance: ${{ secrets.SERVICENOW_INSTANCE }}
          username: ${{ secrets.SERVICENOW_USERNAME }}
          password: ${{ secrets.SERVICENOW_PASSWORD }}
          change-sys-id: ${{ steps.create-change.outputs.change-sys-id }}
```

## Method 3: Python Script with GitHub Actions

### Python Script Approach

Create `.github/scripts/servicenow.py` (see GitLab integration for full script)

```yaml
name: Deploy with Python Script

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      SERVICENOW_INSTANCE: ${{ secrets.SERVICENOW_INSTANCE }}
      SERVICENOW_USERNAME: ${{ secrets.SERVICENOW_USERNAME }}
      SERVICENOW_PASSWORD: ${{ secrets.SERVICENOW_PASSWORD }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Dependencies
        run: pip install requests

      - name: Create Change Request
        id: create
        run: |
          python .github/scripts/servicenow.py create
          cat build.env >> $GITHUB_ENV

      - name: Wait for Approval
        run: python .github/scripts/servicenow.py wait

      - name: Deploy
        run: echo "Deploying..."

      - name: Close Change
        run: python .github/scripts/servicenow.py update closed
```

## Standard Changes for Faster Deployment

### Pre-Approved Standard Change

```yaml
name: Fast Deploy (Standard Change)

on:
  push:
    branches: [main]

jobs:
  deploy-standard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create Standard Change (No Approval)
        id: create-change
        run: |
          # Standard changes are pre-approved
          RESPONSE=$(curl -X POST \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d "{
              \"type\": \"standard\",
              \"short_description\": \"Deploy ${{ github.repository }}\",
              \"std_change_producer_version\": \"app-deployment-template\"
            }")

          SYS_ID=$(echo "$RESPONSE" | jq -r '.result.sys_id')
          echo "change_sys_id=$SYS_ID" >> $GITHUB_OUTPUT

      # Deploy immediately - no approval wait needed
      - name: Deploy to Production
        run: kubectl apply -f k8s/

      - name: Close Change
        run: |
          curl -X PATCH \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request/${{ steps.create-change.outputs.change_sys_id }}" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d '{"state": "3", "close_code": "successful"}'
```

## Matrix Strategy for Multiple Environments

```yaml
name: Multi-Environment Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [staging, production]
    environment:
      name: ${{ matrix.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: Create Change (Production Only)
        if: matrix.environment == 'production'
        id: create-change
        run: |
          # Create change for production deployments only
          RESPONSE=$(curl -X POST \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d '{"short_description": "Deploy to production", "type": "standard"}')
          echo "sys_id=$(echo $RESPONSE | jq -r .result.sys_id)" >> $GITHUB_OUTPUT

      - name: Deploy to ${{ matrix.environment }}
        run: |
          echo "Deploying to ${{ matrix.environment }}..."
          kubectl apply -f k8s/${{ matrix.environment }}/

      - name: Close Change (Production Only)
        if: matrix.environment == 'production' && success()
        run: |
          curl -X PATCH \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request/${{ steps.create-change.outputs.sys_id }}" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d '{"state": "3", "close_code": "successful"}'
```

## Emergency Change Workflow

```yaml
name: Emergency Hotfix

on:
  workflow_dispatch:
    inputs:
      reason:
        description: 'Emergency reason'
        required: true

jobs:
  emergency-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create Emergency Change
        id: create-change
        run: |
          RESPONSE=$(curl -X POST \
            "${{ env.SERVICENOW_URL }}/api/now/table/change_request" \
            -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
            -H "Content-Type: application/json" \
            -d "{
              \"type\": \"emergency\",
              \"priority\": \"1\",
              \"short_description\": \"EMERGENCY: ${{ github.event.inputs.reason }}\",
              \"justification\": \"Critical production issue requiring immediate fix\"
            }")

          SYS_ID=$(echo "$RESPONSE" | jq -r '.result.sys_id')
          echo "sys_id=$SYS_ID" >> $GITHUB_OUTPUT

      - name: Notify Team
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚨 Emergency change created: ${{ steps.create-change.outputs.sys_id }}\nReason: ${{ github.event.inputs.reason }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

      - name: Wait for Expedited Approval (5 min)
        run: |
          # Emergency changes have shorter approval window
          # Polling logic with 5-minute timeout

      - name: Deploy Emergency Fix
        run: kubectl apply -f k8s/hotfix/
```

## Best Practices

### Use Environment Protection Rules

Combine ServiceNow with GitHub environment protection:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      # GitHub environment requires approval
      # + ServiceNow change approval
      # = Double approval gate
    steps:
      - name: Create Change
        # ...
      - name: Deploy
        # ...
```

### Add Deployment Evidence

```yaml
- name: Attach Test Results to Change
  run: |
    curl -X POST \
      "${{ env.SERVICENOW_URL }}/api/now/attachment/file?table_name=change_request&table_sys_id=${{ steps.create-change.outputs.sys_id }}" \
      -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
      -F "file=@test-results.xml"
```

### Handle Rollbacks

```yaml
- name: Rollback on Failure
  if: failure()
  run: |
    # Execute rollback
    kubectl rollout undo deployment/myapp

    # Create rollback change
    curl -X POST "${{ env.SERVICENOW_URL }}/api/now/table/change_request" \
      -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}" \
      -H "Content-Type: application/json" \
      -d "{
        \"type\": \"emergency\",
        \"short_description\": \"ROLLBACK: Failed deployment\",
        \"parent\": \"${{ steps.create-change.outputs.sys_id }}\"
      }"
```

## Troubleshooting

### Debug API Calls

```yaml
- name: Debug ServiceNow API
  run: |
    curl -v -X GET \
      "${{ env.SERVICENOW_URL }}/api/now/table/change_request?sysparm_limit=1" \
      -u "${{ secrets.SERVICENOW_USERNAME }}:${{ secrets.SERVICENOW_PASSWORD }}"
```

### Common Issues

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Verify secrets are correctly set |
| Timeout waiting for approval | Check ServiceNow approval workflow, increase timeout |
| jq command not found | Use ubuntu-latest runner (includes jq) |
| Change not found | Verify sys_id is passed between jobs via outputs |

## Next Steps

- [Azure DevOps Integration](azure-devops-integration.md)
- [ServiceNow Best Practices](best-practices.md)
- [CI/CD Integration Overview](cicd-integration-overview.md)

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [ServiceNow REST API Reference](https://developer.servicenow.com/dev.do#!/reference/api/vancouver/rest/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
