---
description: Integrate ServiceNow with GitLab CI/CD pipelines for automated change management and deployment tracking
keywords: servicenow, gitlab, gitlab-ci, cicd, change management, devops, integration
---

# ServiceNow GitLab Integration

## Overview

This guide shows how to integrate ServiceNow change management with GitLab CI/CD pipelines. The integration automates change request creation, approval gates, and deployment tracking directly from GitLab pipelines.

## Integration Architecture

```
┌─────────────────────────────────────────────┐
│         GitLab CI/CD Pipeline               │
│                                             │
│  ┌──────┐  ┌──────┐  ┌────────────────┐   │
│  │Build │─→│ Test │─→│ Create SNOW CR │   │
│  └──────┘  └──────┘  └────────┬───────┘   │
│                                 │           │
│                    ┌────────────┘           │
│                    ▼                        │
│          ┌──────────────────┐              │
│          │ Wait for Approval│              │
│          └────────┬─────────┘              │
│                   │ (Poll/Webhook)         │
│                   ▼                        │
│          ┌──────────────────┐              │
│          │ Deploy to Prod   │              │
│          └────────┬─────────┘              │
│                   │                        │
│                   ▼                        │
│          ┌──────────────────┐              │
│          │ Update SNOW CR   │              │
│          └──────────────────┘              │
└─────────────────────────────────────────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │  ServiceNow          │
         │  Change Request      │
         └─────────────────────┘
```

## Prerequisites

### ServiceNow Setup

1. **API Access**: ServiceNow instance with REST API enabled
2. **User Account**: Service account with `itil` role for change management
3. **OAuth Application** (Recommended):
   - Navigate to **System OAuth > Application Registry**
   - Create new **OAuth API endpoint for external clients**
   - Note Client ID and Client Secret

### GitLab Setup

1. **CI/CD Variables** (Settings > CI/CD > Variables):
   - `SERVICENOW_INSTANCE`: Your ServiceNow instance name (e.g., `dev12345`)
   - `SERVICENOW_CLIENT_ID`: OAuth client ID (Type: Variable, Masked)
   - `SERVICENOW_CLIENT_SECRET`: OAuth client secret (Type: Variable, Masked)
   - `SERVICENOW_USERNAME`: ServiceNow username (if using basic auth)
   - `SERVICENOW_PASSWORD`: ServiceNow password (if using basic auth, Masked)

2. **Repository Variables**:
   - `ASSIGNMENT_GROUP`: ServiceNow assignment group name
   - `CMDB_CI`: Configuration item sys_id

## Integration Method 1: REST API with cURL

### Simple Change Creation

```yaml
stages:
  - build
  - test
  - change_management
  - deploy

variables:
  SNOW_URL: "https://${SERVICENOW_INSTANCE}.service-now.com"

create_change_request:
  stage: change_management
  image: curlimages/curl:latest
  script:
    - |
      # Create change request
      RESPONSE=$(curl -X POST "${SNOW_URL}/api/now/table/change_request" \
        -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{
          \"short_description\": \"Deploy ${CI_PROJECT_NAME} v${CI_COMMIT_TAG:-${CI_COMMIT_SHORT_SHA}}\",
          \"description\": \"Automated deployment from GitLab pipeline ${CI_PIPELINE_URL}\",
          \"assignment_group\": \"${ASSIGNMENT_GROUP}\",
          \"type\": \"standard\",
          \"priority\": \"3\",
          \"risk\": \"low\",
          \"impact\": \"2\",
          \"cmdb_ci\": \"${CMDB_CI}\",
          \"implementation_plan\": \"Deploy via Kubernetes using Helm chart\",
          \"backout_plan\": \"Rollback using 'helm rollback' command\",
          \"justification\": \"Deploy commit ${CI_COMMIT_SHORT_SHA} from branch ${CI_COMMIT_BRANCH}\"
        }")

      # Extract sys_id and change number
      CHANGE_SYS_ID=$(echo $RESPONSE | jq -r '.result.sys_id')
      CHANGE_NUMBER=$(echo $RESPONSE | jq -r '.result.number')

      echo "Created ServiceNow Change Request: $CHANGE_NUMBER"
      echo "Change SYS_ID: $CHANGE_SYS_ID"

      # Save for next stages
      echo "CHANGE_SYS_ID=$CHANGE_SYS_ID" >> build.env
      echo "CHANGE_NUMBER=$CHANGE_NUMBER" >> build.env
  artifacts:
    reports:
      dotenv: build.env
  only:
    - main
    - production

wait_for_approval:
  stage: change_management
  image: curlimages/curl:latest
  script:
    - |
      echo "Waiting for approval of change request: $CHANGE_NUMBER"
      TIMEOUT=3600  # 1 hour
      INTERVAL=60   # Check every minute
      ELAPSED=0

      while [ $ELAPSED -lt $TIMEOUT ]; do
        # Get change status
        RESPONSE=$(curl -s -X GET \
          "${SNOW_URL}/api/now/table/change_request/${CHANGE_SYS_ID}?sysparm_fields=state,approval,number" \
          -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
          -H "Accept: application/json")

        STATE=$(echo $RESPONSE | jq -r '.result.state')
        APPROVAL=$(echo $RESPONSE | jq -r '.result.approval')

        echo "Change $CHANGE_NUMBER - State: $STATE, Approval: $APPROVAL"

        # Check if approved (state: -2 = Scheduled, -1 = Implement)
        if [ "$STATE" = "-2" ] || [ "$STATE" = "-1" ]; then
          echo "✓ Change request approved!"
          exit 0
        fi

        # Check if rejected or canceled
        if [ "$STATE" = "4" ] || [ "$APPROVAL" = "rejected" ]; then
          echo "✗ Change request rejected or canceled"
          exit 1
        fi

        # Wait and retry
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done

      echo "✗ Timeout waiting for approval"
      exit 1
  needs:
    - create_change_request
  only:
    - main
    - production

deploy_application:
  stage: deploy
  image: alpine/k8s:1.28.0
  script:
    - echo "Deploying application to production..."
    - kubectl apply -f k8s/production/
    - kubectl rollout status deployment/${CI_PROJECT_NAME} -n production
    - echo "Deployment completed successfully"
  needs:
    - wait_for_approval
  only:
    - main
    - production

update_change_request:
  stage: deploy
  image: curlimages/curl:latest
  script:
    - |
      # Update change to "Implement" state
      curl -X PATCH "${SNOW_URL}/api/now/table/change_request/${CHANGE_SYS_ID}" \
        -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "{
          \"state\": \"-1\",
          \"work_notes\": \"Deployment completed successfully at $(date -Iseconds). Pipeline: ${CI_PIPELINE_URL}\"
        }"

      echo "✓ Updated ServiceNow change request: $CHANGE_NUMBER"
  needs:
    - deploy_application
  when: on_success
  only:
    - main
    - production

close_change_request:
  stage: deploy
  image: curlimages/curl:latest
  script:
    - |
      # Close change request
      curl -X PATCH "${SNOW_URL}/api/now/table/change_request/${CHANGE_SYS_ID}" \
        -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "{
          \"state\": \"3\",
          \"close_code\": \"successful\",
          \"close_notes\": \"Deployment verified successfully in production. Commit: ${CI_COMMIT_SHORT_SHA}\"
        }"

      echo "✓ Closed ServiceNow change request: $CHANGE_NUMBER"
  needs:
    - update_change_request
  when: on_success
  only:
    - main
    - production
```

## Integration Method 2: Python Script

### Advanced Change Management Script

Create `.gitlab/scripts/servicenow.py`:

```python
#!/usr/bin/env python3
"""
ServiceNow Change Management Integration for GitLab CI/CD
"""
import os
import sys
import time
import requests
from datetime import datetime

class ServiceNowClient:
    def __init__(self):
        self.instance = os.environ['SERVICENOW_INSTANCE']
        self.base_url = f"https://{self.instance}.service-now.com"
        self.username = os.environ['SERVICENOW_USERNAME']
        self.password = os.environ['SERVICENOW_PASSWORD']
        self.session = requests.Session()
        self.session.auth = (self.username, self.password)
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })

    def create_change(self, data):
        """Create a change request"""
        url = f"{self.base_url}/api/now/table/change_request"

        # Add GitLab context
        data.update({
            'correlation_id': os.environ['CI_PIPELINE_ID'],
            'correlation_display': f"GitLab Pipeline {os.environ['CI_PIPELINE_ID']}"
        })

        response = self.session.post(url, json=data)
        response.raise_for_status()
        result = response.json()['result']

        print(f"✓ Created change request: {result['number']}")
        print(f"  SYS_ID: {result['sys_id']}")
        print(f"  URL: {self.base_url}/nav_to.do?uri=change_request.do?sys_id={result['sys_id']}")

        return result

    def get_change(self, sys_id):
        """Get change request details"""
        url = f"{self.base_url}/api/now/table/change_request/{sys_id}"
        response = self.session.get(url)
        response.raise_for_status()
        return response.json()['result']

    def update_change(self, sys_id, data):
        """Update change request"""
        url = f"{self.base_url}/api/now/table/change_request/{sys_id}"
        response = self.session.patch(url, json=data)
        response.raise_for_status()
        return response.json()['result']

    def wait_for_approval(self, sys_id, timeout=3600, interval=60):
        """Wait for change approval"""
        print(f"⏳ Waiting for change approval (timeout: {timeout}s)...")
        start_time = time.time()

        while (time.time() - start_time) < timeout:
            change = self.get_change(sys_id)
            state = change['state']
            approval = change['approval']
            number = change['number']

            print(f"  Change {number} - State: {state}, Approval: {approval}")

            # State: -2 = Scheduled, -1 = Implement
            if state in ['-2', '-1']:
                print(f"✓ Change {number} approved!")
                return True

            # State: 4 = Canceled
            if state == '4' or approval == 'rejected':
                print(f"✗ Change {number} rejected or canceled")
                return False

            time.sleep(interval)

        print(f"✗ Timeout waiting for approval")
        return False

    def attach_file(self, sys_id, file_path, file_name=None):
        """Attach file to change request"""
        if not file_name:
            file_name = os.path.basename(file_path)

        url = f"{self.base_url}/api/now/attachment/file?table_name=change_request&table_sys_id={sys_id}"

        with open(file_path, 'rb') as f:
            files = {'file': (file_name, f)}
            # Remove Content-Type header for file upload
            headers = dict(self.session.headers)
            headers.pop('Content-Type', None)
            response = self.session.post(url, files=files, headers=headers)
            response.raise_for_status()

        print(f"✓ Attached file: {file_name}")

def main():
    command = sys.argv[1] if len(sys.argv) > 1 else 'create'

    client = ServiceNowClient()

    if command == 'create':
        # Create change request
        change_data = {
            'short_description': f"Deploy {os.environ['CI_PROJECT_NAME']} {os.environ.get('CI_COMMIT_TAG', os.environ['CI_COMMIT_SHORT_SHA'])}",
            'description': f"Automated deployment from GitLab pipeline\nPipeline: {os.environ['CI_PIPELINE_URL']}\nCommit: {os.environ['CI_COMMIT_SHA']}",
            'assignment_group': os.environ.get('ASSIGNMENT_GROUP', ''),
            'cmdb_ci': os.environ.get('CMDB_CI', ''),
            'type': 'standard',
            'priority': '3',
            'risk': 'low',
            'impact': '2',
            'implementation_plan': 'Deploy application using Kubernetes Helm chart',
            'backout_plan': 'Rollback to previous Helm release using helm rollback command',
            'justification': f"Deploy commit {os.environ['CI_COMMIT_SHORT_SHA']} from branch {os.environ['CI_COMMIT_BRANCH']}"
        }

        change = client.create_change(change_data)

        # Output for GitLab (dotenv format)
        with open('build.env', 'w') as f:
            f.write(f"CHANGE_SYS_ID={change['sys_id']}\n")
            f.write(f"CHANGE_NUMBER={change['number']}\n")

        # Attach test results if available
        if os.path.exists('test-results.xml'):
            client.attach_file(change['sys_id'], 'test-results.xml', 'Test Results')

    elif command == 'wait':
        # Wait for approval
        sys_id = os.environ['CHANGE_SYS_ID']
        approved = client.wait_for_approval(sys_id)
        sys.exit(0 if approved else 1)

    elif command == 'update':
        # Update change state
        sys_id = os.environ['CHANGE_SYS_ID']
        status = sys.argv[2] if len(sys.argv) > 2 else 'implement'

        state_map = {
            'implement': '-1',
            'review': '0',
            'closed': '3'
        }

        update_data = {
            'state': state_map.get(status, '-1'),
            'work_notes': f"Pipeline update at {datetime.now().isoformat()}\nPipeline: {os.environ['CI_PIPELINE_URL']}"
        }

        if status == 'closed':
            update_data.update({
                'close_code': 'successful',
                'close_notes': f"Deployment completed successfully. Commit: {os.environ['CI_COMMIT_SHORT_SHA']}"
            })

        client.update_change(sys_id, update_data)
        print(f"✓ Updated change to: {status}")

if __name__ == '__main__':
    main()
```

### Using the Python Script

```yaml
.servicenow_template:
  image: python:3.11-alpine
  before_script:
    - pip install requests

create_change:
  extends: .servicenow_template
  stage: change_management
  script:
    - python .gitlab/scripts/servicenow.py create
  artifacts:
    reports:
      dotenv: build.env
  only:
    - main

wait_approval:
  extends: .servicenow_template
  stage: change_management
  script:
    - python .gitlab/scripts/servicenow.py wait
  needs:
    - create_change
  only:
    - main

deploy:
  stage: deploy
  script:
    - echo "Deploying..."
    - kubectl apply -f k8s/
  needs:
    - wait_approval
  only:
    - main

update_change:
  extends: .servicenow_template
  stage: deploy
  script:
    - python .gitlab/scripts/servicenow.py update implement
  needs:
    - deploy
  when: on_success
  only:
    - main

close_change:
  extends: .servicenow_template
  stage: deploy
  script:
    - python .gitlab/scripts/servicenow.py update closed
  needs:
    - update_change
  when: on_success
  only:
    - main
```

## Integration Method 3: GitLab Webhooks

### ServiceNow Inbound Webhook

Configure ServiceNow to receive GitLab webhook events:

**ServiceNow Configuration**:

1. Navigate to **System Web Services > Scripted REST APIs**
2. Create new API: `GitLab Integration`
3. Create resource: `deployment_event`
4. Method: POST

**Script**:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var body = request.body.data;

    // Parse GitLab webhook payload
    var project = body.project.name;
    var commit = body.commit.id;
    var ref = body.ref;
    var user = body.user_name;

    // Create change request
    var gr = new GlideRecord('change_request');
    gr.initialize();
    gr.short_description = 'Deploy ' + project + ' - ' + commit.substring(0, 8);
    gr.description = 'GitLab deployment event\nProject: ' + project + '\nCommit: ' + commit + '\nBranch: ' + ref;
    gr.type = 'standard';
    gr.assignment_group = 'DevOps Team'; // Lookup by name
    gr.insert();

    // Return response
    var result = {
        success: true,
        change_number: gr.number.toString(),
        sys_id: gr.sys_id.toString()
    };

    response.setBody(result);
})(request, response);
```

**GitLab Configuration**:

Add webhook in **Settings > Webhooks**:
- URL: `https://instance.service-now.com/api/x_custom/gitlab_integration/deployment_event`
- Trigger: Pipeline events
- Enable SSL verification

## OAuth 2.0 Authentication

### Setup OAuth in ServiceNow

1. **Create OAuth Application**:
   - Navigate to **System OAuth > Application Registry**
   - Click **New** > **Create an OAuth API endpoint for external clients**
   - Fill in:
     - Name: `GitLab CI/CD Integration`
     - Client ID: (auto-generated, copy this)
     - Client Secret: (auto-generated, copy this)
     - Refresh Token Lifespan: 8640000 (100 days)
     - Access Token Lifespan: 1800 (30 minutes)

2. **Grant Access**:
   - Accessible from: All application scopes
   - Active: Yes

### Use OAuth in GitLab

```yaml
variables:
  SNOW_URL: "https://${SERVICENOW_INSTANCE}.service-now.com"

.get_token:
  script:
    - |
      # Get OAuth token
      TOKEN_RESPONSE=$(curl -X POST "${SNOW_URL}/oauth_token.do" \
        -d "grant_type=password" \
        -d "client_id=${SERVICENOW_CLIENT_ID}" \
        -d "client_secret=${SERVICENOW_CLIENT_SECRET}" \
        -d "username=${SERVICENOW_USERNAME}" \
        -d "password=${SERVICENOW_PASSWORD}")

      ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.access_token')
      echo "SNOW_TOKEN=$ACCESS_TOKEN" >> token.env
  artifacts:
    reports:
      dotenv: token.env

create_change_oauth:
  stage: change_management
  image: curlimages/curl:latest
  needs:
    - job: .get_token
      artifacts: true
  script:
    - |
      curl -X POST "${SNOW_URL}/api/now/table/change_request" \
        -H "Authorization: Bearer ${SNOW_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"short_description": "Deploy via OAuth"}'
```

## Best Practices

### Standard Changes for Speed

Pre-approve common deployment patterns:

```yaml
variables:
  CHANGE_TYPE: "standard"  # No approval needed
  STANDARD_TEMPLATE: "app-deployment-v1"

create_standard_change:
  stage: change_management
  script:
    - |
      curl -X POST "${SNOW_URL}/api/now/table/change_request" \
        -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "{
          \"type\": \"${CHANGE_TYPE}\",
          \"std_change_producer_version\": \"${STANDARD_TEMPLATE}\",
          \"short_description\": \"Deploy ${CI_PROJECT_NAME}\"
        }"
    - echo "Standard change created - no approval needed"
  only:
    - main

# Deploy immediately after creating standard change
deploy_immediate:
  stage: deploy
  script:
    - kubectl apply -f k8s/
  needs:
    - create_standard_change
```

### Error Handling and Rollback

```yaml
.on_failure_update_change:
  stage: .post
  image: curlimages/curl:latest
  script:
    - |
      if [ -n "$CHANGE_SYS_ID" ]; then
        curl -X PATCH "${SNOW_URL}/api/now/table/change_request/${CHANGE_SYS_ID}" \
          -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
          -H "Content-Type: application/json" \
          -d "{
            \"state\": \"4\",
            \"close_code\": \"unsuccessful\",
            \"close_notes\": \"Pipeline failed: ${CI_PIPELINE_URL}\"
          }"
      fi
  when: on_failure
```

### Include Testing Evidence

```yaml
attach_test_results:
  stage: change_management
  image: python:3.11-alpine
  before_script:
    - pip install requests
  script:
    - python .gitlab/scripts/servicenow.py create
    - |
      # Attach test results
      python3 << EOF
      import os, requests
      sys_id = os.environ['CHANGE_SYS_ID']
      url = f"https://{os.environ['SERVICENOW_INSTANCE']}.service-now.com/api/now/attachment/file?table_name=change_request&table_sys_id={sys_id}"
      auth = (os.environ['SERVICENOW_USERNAME'], os.environ['SERVICENOW_PASSWORD'])
      with open('test-results.xml', 'rb') as f:
          requests.post(url, files={'file': ('test-results.xml', f)}, auth=auth)
      EOF
  dependencies:
    - test_job
  artifacts:
    reports:
      dotenv: build.env
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Check credentials in GitLab CI/CD variables |
| 403 Forbidden | Verify ServiceNow user has `itil` role |
| Timeout waiting for approval | Increase timeout, check ServiceNow approval workflow |
| Change not found | Verify `CHANGE_SYS_ID` is passed correctly via artifacts |
| SSL verification failed | Update curl/Python requests, check ServiceNow SSL cert |

### Debug Mode

Enable detailed logging:

```yaml
create_change_debug:
  stage: change_management
  script:
    - set -x  # Enable bash debug mode
    - |
      RESPONSE=$(curl -v -X POST "${SNOW_URL}/api/now/table/change_request" \
        -u "${SERVICENOW_USERNAME}:${SERVICENOW_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d '{"short_description": "Test"}')
      echo "Full response: $RESPONSE"
```

## Next Steps

- [GitHub Actions Integration](github-integration.md)
- [Azure DevOps Integration](azure-devops-integration.md)
- [ServiceNow Best Practices](best-practices.md)

## Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [ServiceNow REST API Guide](https://developer.servicenow.com/dev.do#!/reference/api/vancouver/rest/)
- [GitLab ServiceNow Integration (Official)](https://docs.gitlab.com/ee/solutions/integrations/servicenow.html)
