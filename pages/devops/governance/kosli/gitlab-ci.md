---
description: Integrate Kosli with GitLab CI/CD pipelines for automated change tracking and compliance
keywords: kosli, gitlab, gitlab-ci, cicd, compliance, deployment tracking
---

# Kosli GitLab CI Integration

## Overview

Integrate Kosli with GitLab CI/CD to automatically track deployments and collect compliance evidence.

## Setup

### Configure CI/CD Variables

Add to **Settings > CI/CD > Variables**:
- `KOSLI_API_TOKEN` (Type: Variable, Masked)
- `KOSLI_ORG`

### Basic Pipeline

```yaml
variables:
  KOSLI_FLOW: "microservice-api"
  IMAGE_NAME: "myapp:${CI_COMMIT_SHORT_SHA}"

stages:
  - build
  - evidence
  - deploy
  - report

before_script:
  - |
    # Install Kosli CLI
    curl -sSL https://cli.kosli.com/install.sh | sh
    export PATH=$PATH:$HOME/.kosli/bin

build:
  stage: build
  script:
    - docker build -t ${IMAGE_NAME} .
    - docker push ${IMAGE_NAME}

    # Report artifact to Kosli
    - |
      kosli report artifact ${IMAGE_NAME} \
        --artifact-type docker \
        --flow ${KOSLI_FLOW} \
        --build-url ${CI_PIPELINE_URL} \
        --commit ${CI_COMMIT_SHA} \
        --git-commit-info HEAD

test:
  stage: evidence
  script:
    - pytest --junitxml=test-results.xml

    # Report test evidence
    - |
      kosli report evidence test junit \
        --flow ${KOSLI_FLOW} \
        --name ${IMAGE_NAME} \
        --results-file test-results.xml

security_scan:
  stage: evidence
  script:
    - trivy image --format json -o scan.json ${IMAGE_NAME}

    # Report security scan
    - |
      kosli report evidence generic \
        --flow ${KOSLI_FLOW} \
        --name ${IMAGE_NAME} \
        --evidence-type security-scan \
        --attachments scan.json

deploy_production:
  stage: deploy
  environment:
    name: production
  script:
    - kubectl set image deployment/myapp myapp=${IMAGE_NAME}
    - kubectl rollout status deployment/myapp

    # Report deployment
    - |
      kosli report deployment production \
        --flow ${KOSLI_FLOW} \
        --name ${IMAGE_NAME}

snapshot:
  stage: report
  script:
    - |
      kosli snapshot k8s production \
        --namespace production
  only:
    - main
```

## Advanced Patterns

### Parallel Evidence Collection

```yaml
test:
  stage: evidence
  parallel:
    matrix:
      - TEST_TYPE: [unit, integration, e2e]
  script:
    - npm run test:${TEST_TYPE} -- --reporter=junit > ${TEST_TYPE}-results.xml
    - |
      kosli report evidence test junit \
        --flow ${KOSLI_FLOW} \
        --name ${IMAGE_NAME} \
        --results-file ${TEST_TYPE}-results.xml
```

### Conditional Kosli Reporting

```yaml
.kosli_template:
  before_script:
    - curl -sSL https://cli.kosli.com/install.sh | sh
    - export PATH=$PATH:$HOME/.kosli/bin

report_artifact:
  extends: .kosli_template
  script:
    - kosli report artifact ${IMAGE_NAME} --flow ${KOSLI_FLOW} ...
  only:
    - main  # Only report for production deployments
```

## Next Steps

- [Azure DevOps Integration](azure-devops.md)
- [CLI Reference](cli-reference.md)
- [Best Practices](best-practices.md)
