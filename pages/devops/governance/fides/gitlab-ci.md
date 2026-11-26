---
description: Integrate Fides with GitLab CI — stage-by-stage provenance recording, evidence attestation and compliance gating before deploy
keywords: fides, gitlab ci, pipeline, provenance, attestation, compliance gate, dotenv, masked variables
---

# Fides + GitLab CI

The pipeline maps cleanly onto GitLab stages: **build** records provenance, **gate** decides, **deploy** ships, **verify** proves what landed.

## CI/CD variables

Set these under *Settings → CI/CD → Variables*. Mark `FIDES_API_TOKEN` as **masked** and **protected**:

| Variable | Masked | Purpose |
| --- | --- | --- |
| `FIDES_API_TOKEN` | yes | Writer service-account key |
| `FIDES_ENCRYPTION_KEY` | yes | Only if encrypting attestation payloads |
| `ORG_ID` | no | Org (tenant) UUID |
| `FLOW_ID` | no | Flow UUID for this service |
| `ENV_ID` | no | Environment UUID to gate and snapshot |

## Complete pipeline

```yaml
stages: [build, gate, deploy, verify]

variables:
  FIDES_SERVER_URL: "https://fides.example.com"
  TRAIL_ID: "$CI_COMMIT_SHA"
  # FIDES_API_TOKEN, ORG_ID, FLOW_ID, ENV_ID set as (masked) CI/CD variables

build:
  stage: build
  script:
    - curl -sSfL $FIDES_SERVER_URL/cli/install.sh | sh
    - fides trail start --flow $FLOW_ID --trail $TRAIL_ID
        --repository $CI_PROJECT_URL --commit $CI_COMMIT_SHA --branch $CI_COMMIT_REF_NAME
    - docker build -t app:$CI_COMMIT_SHA .
    - DIGEST=$(docker inspect --format='{{index .Id}}' app:$CI_COMMIT_SHA)
    - echo "DIGEST=$DIGEST" > dig.env
    - fides artifact report --org $ORG_ID --trail $TRAIL_ID --sha256 $DIGEST --name app --type docker
    - fides attest junit --trail $TRAIL_ID --file reports/junit.xml --artifact-sha $DIGEST
    - fides attest trivy --trail $TRAIL_ID --file reports/trivy.json --artifact-sha $DIGEST
  artifacts: { reports: { dotenv: dig.env } }

gate:
  stage: gate
  script:
    - fides assert --sha256 $DIGEST --policy production-release-rules
    - fides policy check --env $ENV_ID --trail $TRAIL_ID
    - fides change-gate --trail $TRAIL_ID       # exit 2 => job fails => deploy blocked

deploy:
  stage: deploy
  script: ["./deploy.sh app:$CI_COMMIT_SHA"]

verify:
  stage: verify
  script:
    - fides snapshot k8s --env $ENV_ID --namespace prod
    - fides verify-chain --trail $TRAIL_ID
```

### Passing the digest between stages

The `dotenv` report is the important detail. GitLab jobs run in separate containers, so `DIGEST` computed in `build` will not exist in `gate` unless you export it:

```yaml
  artifacts:
    reports:
      dotenv: dig.env
```

Every later job in the pipeline then has `$DIGEST` in its environment automatically.

## Manual approval as a pipeline gate

`change-gate` holds until a human signs off. Model that as a manual job so the approval is a deliberate, attributable click:

```yaml
approve:
  stage: gate
  when: manual
  allow_failure: false
  script:
    - fides approve --trail $TRAIL_ID --role approver --reason "Release board sign-off ($GITLAB_USER_LOGIN)"
```

Four-eyes requires **two distinct humans**; the resulting `segregation-of-duties` attestation is only `compliant: true` when committer, approver and deployer are pairwise distinct.

## Ingesting GitLab's native SLSA attestations

```yaml
provenance:
  stage: build
  script:
    - fides attest fetch --trail $TRAIL_ID --artifact-sha $DIGEST --provider gitlab --repo $CI_PROJECT_PATH
```

## Publishing the audit package

```yaml
audit:
  stage: verify
  when: always
  script:
    - fides audit --trail $TRAIL_ID --output trail-audit.zip
  artifacts:
    paths: [trail-audit.zip]
    expire_in: 1 year
```

## Gate exit-code contract

| Gate | Fails the job when |
| --- | --- |
| `fides assert --sha256 $DIGEST --policy <name>` | artifact violates policy (**exit 1**) |
| `fides policy check --env $ENV --trail $TRAIL` | an applicable environment policy is unsatisfied (**exit 2**) |
| `fides allowlist check --env $ENV --sha $DIGEST` | digest not approved for the environment (**exit 2**) |
| `fides change-gate --trail $TRAIL` | verdict is HOLD (**exit 2**) |
| `fides verify-chain --trail $TRAIL` | attestation chain broken/tampered (**exit 2**) |

Because every gate fails the job on a non-zero exit, `deploy` simply never runs — you do not need extra conditional logic.

## See also

- [GitHub Actions Integration](github-actions.md) · [Azure DevOps Integration](azure-devops.md)
- [Best Practices](best-practices.md) · [CLI Reference](cli-reference.md)
