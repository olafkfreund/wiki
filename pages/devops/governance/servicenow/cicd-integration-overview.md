---
description: Overview of ServiceNow integration patterns and concepts for CI/CD pipelines
keywords: servicenow, ci/cd, integration patterns, rest api, webhooks, devops automation
---

# ServiceNow CI/CD Integration Overview

## Introduction

This guide provides platform-agnostic concepts and patterns for integrating ServiceNow with any CI/CD platform. Use this as a foundation before implementing platform-specific integrations.

## Integration Architecture

### High-Level Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline                             │
│                                                               │
│  ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────────┐  │
│  │Build │──→│ Test │──→│ Scan │──→│Stage │──→│Production│  │
│  └──────┘   └──────┘   └──────┘   └───┬──┘   └────┬─────┘  │
│                                        │           │         │
└────────────────────────────────────────┼───────────┼─────────┘
                                         │           │
                    ┌────────────────────┘           │
                    │                                │
                    ▼                                ▼
         ┌──────────────────────┐       ┌──────────────────────┐
         │ Create Change        │       │ Update Change        │
         │ Request              │       │ (Deployed)           │
         │                      │       │                      │
         │ POST /change_request │       │ PATCH /change_request│
         └──────────┬───────────┘       └──────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ Wait for Approval    │
         │                      │
         │ GET /change_request  │
         │ (Poll or Webhook)    │
         └──────────┬───────────┘
                    │
                    ▼
              Approved? ──Yes──→ Continue Pipeline
                    │
                    No
                    │
                    ▼
              Block/Fail Pipeline
```

## Integration Methods

### Method 1: Direct REST API Integration

**Description**: Pipeline makes direct HTTP calls to ServiceNow REST API

**When to Use**:
- Full control over integration logic
- Simple change management workflows
- No ServiceNow Integration Hub available
- Custom retry and error handling needed

**Pros**:
- ✓ Complete control
- ✓ No ServiceNow middleware required
- ✓ Works with any CI/CD platform
- ✓ Easy to debug and test

**Cons**:
- ✗ Pipeline must handle all logic
- ✗ Need to implement retry mechanisms
- ✗ Authentication management in pipeline
- ✗ More code to maintain

**Example Flow**:
```
Pipeline → ServiceNow REST API
    │
    ├─→ Create change (POST)
    ├─→ Poll for approval (GET, loop)
    ├─→ Update status (PATCH)
    └─→ Close change (PATCH)
```

### Method 2: ServiceNow Integration Hub

**Description**: ServiceNow Integration Hub orchestrates the integration with pre-built spokes

**When to Use**:
- Complex workflows with multiple systems
- Enterprise ServiceNow deployment
- Need robust error handling and retry
- Reusable integration patterns

**Pros**:
- ✓ Pre-built change management spokes
- ✓ Built-in error handling and retry
- ✓ Visual workflow designer (Flow Designer)
- ✓ Reusable across multiple pipelines
- ✓ ServiceNow-managed updates

**Cons**:
- ✗ Requires Integration Hub license
- ✗ More initial setup complexity
- ✗ Limited customization vs. direct API
- ✗ Debugging can be challenging

**Example Flow**:
```
Pipeline → Integration Hub → Change Management Spoke
                │
                ├─→ Create change
                ├─→ Handle approvals
                ├─→ Update CMDB
                └─→ Send notifications
```

### Method 3: Event-Driven (Webhooks)

**Description**: CI/CD events trigger ServiceNow webhooks, which execute Flow Designer workflows

**When to Use**:
- Event-driven architecture preferred
- Asynchronous processing acceptable
- Need to trigger multiple ServiceNow workflows
- Loose coupling between systems

**Pros**:
- ✓ Decoupled systems
- ✓ Scalable (async processing)
- ✓ No polling required
- ✓ Supports fan-out to multiple workflows

**Cons**:
- ✗ More complex setup
- ✗ Harder to debug
- ✗ Network firewall considerations
- ✗ Webhook endpoint security critical

**Example Flow**:
```
Pipeline Event → Webhook → ServiceNow → Flow Designer Workflow
                                │
                                ├─→ Create change
                                ├─→ Send notification
                                └─→ Update CMDB
```

### Method 4: Platform-Specific Plugins

**Description**: Use official ServiceNow plugins/extensions for your CI/CD platform

**When to Use**:
- Platform has official ServiceNow support
- Want simplest setup
- No custom workflow requirements
- Standard change management patterns

**Available Platforms**:
- **Azure DevOps**: Official ServiceNow extension
- **Jenkins**: ServiceNow plugin
- **GitHub Actions**: Community actions
- **GitLab**: REST API integration (no official plugin)

**Pros**:
- ✓ Easiest setup
- ✓ Platform-native configuration
- ✓ Maintained by ServiceNow or community
- ✓ Built-in best practices

**Cons**:
- ✗ Limited to available platforms
- ✗ Less customization
- ✗ Plugin update dependencies
- ✗ May not fit complex workflows

## Core Integration Patterns

### Pattern 1: Change Request Lifecycle

**Complete change management flow**:

```yaml
# Pseudo-code for any CI/CD platform

job: deploy-to-production
  steps:
    - name: Create Change Request
      action: servicenow-create-change
      inputs:
        short_description: "Deploy ${APP_NAME} v${VERSION}"
        assignment_group: "DevOps Team"
        cmdb_ci: "production-k8s-cluster"
        type: "standard"
        implementation_plan: "Deploy via Helm chart"
        backout_plan: "Rollback to previous Helm release"
      outputs:
        change_sys_id: $CHANGE_ID

    - name: Wait for Approval
      action: servicenow-wait-approval
      inputs:
        change_sys_id: $CHANGE_ID
        timeout: 3600  # 1 hour
        poll_interval: 60  # Check every minute

    - name: Deploy Application
      action: kubectl-apply
      inputs:
        manifest: k8s/production/

    - name: Update Change Status
      action: servicenow-update-change
      inputs:
        change_sys_id: $CHANGE_ID
        state: "implement"
        work_notes: "Deployment completed successfully"

    - name: Close Change Request
      action: servicenow-update-change
      inputs:
        change_sys_id: $CHANGE_ID
        state: "closed"
        close_code: "successful"
        close_notes: "Deployment verified in production"
```

### Pattern 2: Emergency Change

**Expedited process for critical fixes**:

```yaml
job: emergency-patch
  when: manual  # Requires manual trigger
  steps:
    - name: Create Emergency Change
      action: servicenow-create-change
      inputs:
        type: "emergency"
        priority: "1 - Critical"
        short_description: "EMERGENCY: Security patch ${CVE_ID}"
        risk: "high"
        justification: "Critical security vulnerability"
        # Emergency changes have expedited approval

    - name: Notify On-Call Manager
      action: send-notification
      inputs:
        channel: "slack"
        message: "Emergency change ${CHANGE_ID} requires immediate approval"

    - name: Wait for Expedited Approval
      action: servicenow-wait-approval
      inputs:
        change_sys_id: $CHANGE_ID
        timeout: 300  # 5 minutes only

    - name: Deploy Emergency Fix
      action: deploy

    - name: Close Emergency Change
      action: servicenow-update-change
```

### Pattern 3: Standard Pre-Approved Change

**Fast path for low-risk, repeatable changes**:

```yaml
job: deploy-standard-app
  steps:
    - name: Create Standard Change
      action: servicenow-create-change
      inputs:
        type: "standard"
        # Standard changes are pre-approved, no waiting
        short_description: "Deploy ${APP_NAME} (Standard Change)"
        standard_change_template: "app-deployment-template"

    - name: Deploy Immediately
      # No approval wait needed for standard changes
      action: deploy

    - name: Close Change
      action: servicenow-update-change
```

### Pattern 4: Change with Attachments

**Include test results and security scan reports**:

```yaml
job: deploy-with-evidence
  steps:
    - name: Run Tests
      action: pytest
      outputs:
        results_file: test-results.xml

    - name: Security Scan
      action: trivy-scan
      outputs:
        scan_file: security-scan.json

    - name: Create Change with Attachments
      action: servicenow-create-change
      inputs:
        short_description: "Deploy with test evidence"
        attachments:
          - name: "Test Results"
            file: test-results.xml
          - name: "Security Scan"
            file: security-scan.json
```

### Pattern 5: Rollback Change

**Document rollback as a separate change**:

```yaml
job: rollback-deployment
  when: on_failure  # Triggered by deployment failure
  steps:
    - name: Create Rollback Change
      action: servicenow-create-change
      inputs:
        type: "standard"
        short_description: "ROLLBACK: ${APP_NAME} due to deployment failure"
        parent_change: $ORIGINAL_CHANGE_ID  # Link to failed deployment
        implementation_plan: "Rollback to previous version"

    - name: Execute Rollback
      action: helm-rollback

    - name: Close Rollback Change
      action: servicenow-update-change
      inputs:
        state: "closed"
        close_code: "successful"
```

## ServiceNow REST API Essentials

### Authentication

**Basic Authentication** (not recommended for production):
```bash
curl -u username:password \
  https://instance.service-now.com/api/now/table/change_request
```

**OAuth 2.0** (recommended):
```bash
# Get token
curl -X POST https://instance.service-now.com/oauth_token.do \
  -d "grant_type=client_credentials" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}"

# Use token
curl -H "Authorization: Bearer ${TOKEN}" \
  https://instance.service-now.com/api/now/table/change_request
```

### Create Change Request

```bash
curl -X POST \
  "https://${INSTANCE}.service-now.com/api/now/table/change_request" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "short_description": "Deploy microservice-api v2.3.0",
    "description": "Automated deployment from GitLab pipeline",
    "assignment_group": "DevOps Team",
    "cmdb_ci": "prod-k8s-cluster",
    "type": "standard",
    "priority": "3",
    "risk": "low",
    "implementation_plan": "Deploy via Helm chart",
    "backout_plan": "Helm rollback to previous release",
    "justification": "New features and bug fixes"
  }'
```

**Response**:
```json
{
  "result": {
    "sys_id": "a9e0c5f21bf45110d4e27f86624bcb24",
    "number": "CHG0030001",
    "state": "new",
    "approval": "not requested"
  }
}
```

### Get Change Status

```bash
curl -X GET \
  "https://${INSTANCE}.service-now.com/api/now/table/change_request/${SYS_ID}" \
  -H "Authorization: Bearer ${TOKEN}"
```

### Update Change Request

```bash
curl -X PATCH \
  "https://${INSTANCE}.service-now.com/api/now/table/change_request/${SYS_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "implement",
    "work_notes": "Deployment in progress"
  }'
```

### Attach File to Change

```bash
curl -X POST \
  "https://${INSTANCE}.service-now.com/api/now/attachment/file?table_name=change_request&table_sys_id=${SYS_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: text/plain" \
  -F "file=@test-results.xml"
```

## Change Request States

Understanding ServiceNow change states:

| State | Value | Description | Pipeline Action |
|-------|-------|-------------|-----------------|
| New | -5 | Change created | Wait for approval |
| Assess | -4 | Under assessment | Continue waiting |
| Authorize | -3 | Awaiting authorization | Continue waiting |
| Scheduled | -2 | Approved and scheduled | Can proceed |
| Implement | -1 | Implementation in progress | Deployment happening |
| Review | 0 | Post-implementation review | Deployment complete |
| Closed | 3 | Change closed | Final state |
| Canceled | 4 | Change canceled | Abort deployment |

**Pipeline Logic**:
```
if state in ['scheduled', 'implement', 'review']:
    proceed_with_deployment()
elif state == 'canceled':
    abort_deployment()
else:
    wait_for_approval()
```

## Error Handling

### Retry Strategy

**Implement exponential backoff**:

```python
import time
import requests

def create_change_with_retry(data, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = requests.post(
                f"https://{instance}.service-now.com/api/now/table/change_request",
                headers=headers,
                json=data,
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise
            wait_time = 2 ** attempt  # Exponential backoff
            time.sleep(wait_time)
```

### Common Error Scenarios

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid credentials | Check token/credentials, refresh if expired |
| 403 Forbidden | Insufficient permissions | Verify ServiceNow user has change_request role |
| 404 Not Found | Invalid endpoint/sys_id | Verify URL and change request exists |
| 429 Too Many Requests | Rate limiting | Implement backoff, reduce request frequency |
| 500 Internal Server Error | ServiceNow issue | Retry with exponential backoff |

## Approval Polling Pattern

**Best practice for waiting on approvals**:

```python
import time

def wait_for_approval(sys_id, timeout=3600, interval=60):
    """
    Poll change request until approved or timeout

    Args:
        sys_id: Change request sys_id
        timeout: Maximum wait time in seconds (default 1 hour)
        interval: Polling interval in seconds (default 60)

    Returns:
        True if approved, False if timeout or rejected
    """
    start_time = time.time()

    while (time.time() - start_time) < timeout:
        change = get_change_request(sys_id)
        state = change['result']['state']
        approval = change['result']['approval']

        # Check if approved (state: scheduled or higher)
        if state in ['scheduled', 'implement', 'review']:
            print(f"Change {sys_id} approved!")
            return True

        # Check if rejected or canceled
        if state == 'canceled' or approval == 'rejected':
            print(f"Change {sys_id} rejected or canceled")
            return False

        # Still pending, wait and retry
        time.sleep(interval)

    # Timeout reached
    print(f"Timeout waiting for approval of change {sys_id}")
    return False
```

## Security Best Practices

### Credential Management

**Do**:
- ✓ Store ServiceNow credentials in secrets management (Vault, CI/CD secrets)
- ✓ Use OAuth 2.0 with client credentials flow
- ✓ Rotate credentials regularly
- ✓ Use least-privilege ServiceNow roles
- ✓ Audit ServiceNow API access logs

**Don't**:
- ✗ Hardcode credentials in pipeline code
- ✗ Use admin accounts for API access
- ✗ Share credentials across teams
- ✗ Log credentials in pipeline output

### Network Security

- Use HTTPS for all ServiceNow API calls
- Whitelist CI/CD IPs in ServiceNow if possible
- Implement mutual TLS for enterprise deployments
- Use ServiceNow IP allowlists

## Performance Optimization

### Reduce API Calls

**Instead of**:
```python
# Multiple API calls
change = create_change(data)
attach_file(change['sys_id'], 'tests.xml')
attach_file(change['sys_id'], 'scan.json')
update_change(change['sys_id'], {'state': 'implement'})
```

**Do**:
```python
# Batch operations where possible
change = create_change_with_attachments(data, files=['tests.xml', 'scan.json'])
# Update only when state changes
```

### Caching

Cache ServiceNow metadata (assignment groups, CMDB CIs) that doesn't change frequently:

```python
# Cache assignment group sys_id
ASSIGNMENT_GROUPS = {
    'DevOps Team': 'a9e0c5f21bf45110d4e27f86624bcb24',
    'Platform Team': 'b2f1d6g32cg56221e5f38g97735cdc35'
}

# Use cached value instead of lookup
change_data['assignment_group'] = ASSIGNMENT_GROUPS['DevOps Team']
```

## Testing ServiceNow Integration

### Development Environment

1. **ServiceNow Developer Instance**: Free instance for testing
2. **Mock ServiceNow API**: Use tools like WireMock for local testing
3. **Test Change Requests**: Create and close changes in non-production

### Integration Tests

```python
def test_create_change_request():
    """Test change creation"""
    data = {
        "short_description": "Test Change",
        "type": "standard"
    }
    response = create_change(data)
    assert response['result']['number'].startswith('CHG')
    assert response['result']['state'] == 'new'

def test_approval_workflow():
    """Test approval polling"""
    change = create_change({"short_description": "Test", "type": "normal"})
    sys_id = change['result']['sys_id']

    # Simulate approval in ServiceNow
    approve_change(sys_id)  # Test helper function

    # Verify polling detects approval
    approved = wait_for_approval(sys_id, timeout=120)
    assert approved == True
```

## Monitoring and Observability

### Metrics to Track

- **Change Creation Time**: Time to create change via API
- **Approval Wait Time**: Duration waiting for approvals
- **API Error Rate**: Percentage of failed ServiceNow API calls
- **Change Success Rate**: Percentage of changes closed successfully
- **Pipeline Duration Impact**: Extra time added by ServiceNow integration

### Alerts

Set up alerts for:
- ServiceNow API failures (>5% error rate)
- Approval timeouts (>1 hour wait)
- Rejected changes (immediate notification)
- Change creation failures (blocks deployment)

### Logging

Log all ServiceNow interactions:

```python
import logging

logger = logging.getLogger('servicenow')

def create_change(data):
    logger.info(f"Creating change request: {data['short_description']}")
    try:
        response = requests.post(url, json=data)
        logger.info(f"Change created: {response.json()['result']['number']}")
        return response.json()
    except Exception as e:
        logger.error(f"Failed to create change: {str(e)}")
        raise
```

## Next Steps

Now that you understand the core concepts, proceed to platform-specific integration guides:

- [GitLab Integration →](gitlab-integration.md)
- [GitHub Actions Integration →](github-integration.md)
- [Azure DevOps Integration →](azure-devops-integration.md)

## Additional Resources

- [ServiceNow REST API Reference](https://developer.servicenow.com/dev.do#!/reference/api/vancouver/rest/)
- [Change Management Best Practices](best-practices.md)
- [DevOps Governance Overview](../README.md)
