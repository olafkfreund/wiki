---
description: Integrate Fides with Azure DevOps Pipelines — record provenance, attach evidence, and block deployment stages on compliance verdicts
keywords: fides, azure devops, azure pipelines, provenance, attestation, compliance gate, variable group, deployment job
---

# Fides + Azure DevOps

The `fides` CLI is platform-agnostic, so the Azure Pipelines integration is the same sequence as [GitHub Actions](github-actions.md) and [GitLab CI](gitlab-ci.md) expressed in ADO YAML:

```
trail start → build → artifact report → attest → GATE → deploy → snapshot → verify-chain
```

## Variable group

Create a variable group (*Pipelines → Library*) named `fides`, and mark the token **secret**:

| Variable | Secret | Purpose |
| --- | --- | --- |
| `FIDES_API_TOKEN` | yes | Writer service-account key |
| `FIDES_ENCRYPTION_KEY` | yes | Only if encrypting attestation payloads |
| `FIDES_SERVER_URL` | no | Fides server base URL |
| `ORG_ID` | no | Org (tenant) UUID |
| `FLOW_ID` | no | Flow UUID for this service |
| `ENV_ID` | no | Environment UUID to gate and snapshot |

Secret variables are **not** exposed to scripts automatically — you must map them explicitly with an `env:` block on each step that needs them. This trips up most first integrations.

## Complete pipeline

```yaml
trigger:
  branches: { include: [main] }

variables:
  - group: fides
  - name: TRAIL_ID
    value: $(Build.SourceVersion)

stages:
  - stage: Build
    jobs:
      - job: BuildAndAttest
        pool: { vmImage: ubuntu-latest }
        steps:
          - checkout: self

          - script: curl -sSfL $(FIDES_SERVER_URL)/cli/install.sh | sh
            displayName: Install Fides CLI

          - script: |
              fides trail start --flow $(FLOW_ID) --trail $(TRAIL_ID) \
                --repository "$(Build.Repository.Uri)" \
                --commit "$(Build.SourceVersion)" \
                --branch "$(Build.SourceBranchName)" \
                --message "$(Build.SourceVersionMessage)"
            displayName: Start trail
            env:
              FIDES_SERVER_URL: $(FIDES_SERVER_URL)
              FIDES_API_TOKEN: $(FIDES_API_TOKEN)

          - script: |
              docker build -t app:$(TRAIL_ID) .
              DIGEST=$(docker inspect --format='{{index .Id}}' app:$(TRAIL_ID))
              echo "##vso[task.setvariable variable=DIGEST;isOutput=true]$DIGEST"
              # ... run tests/scanners producing reports/junit.xml, reports/trivy.json ...
            name: build
            displayName: Build, test and scan

          - script: |
              fides artifact report --org $(ORG_ID) --trail $(TRAIL_ID) \
                --sha256 $(build.DIGEST) --name app --type docker
              fides attest junit --trail $(TRAIL_ID) --file reports/junit.xml --artifact-sha $(build.DIGEST)
              fides attest trivy --trail $(TRAIL_ID) --file reports/trivy.json --artifact-sha $(build.DIGEST)
              fides attest sbom  --artifact-sha $(build.DIGEST) --file sbom.json
            displayName: Report artifact and attest evidence
            env:
              FIDES_SERVER_URL: $(FIDES_SERVER_URL)
              FIDES_API_TOKEN: $(FIDES_API_TOKEN)

          - script: |
              fides assert      --sha256 $(build.DIGEST) --policy production-release-rules
              fides change-gate --trail $(TRAIL_ID)
            displayName: Compliance gate
            env:
              FIDES_SERVER_URL: $(FIDES_SERVER_URL)
              FIDES_API_TOKEN: $(FIDES_API_TOKEN)

  - stage: Deploy
    dependsOn: Build
    condition: succeeded()
    jobs:
      - deployment: DeployProd
        environment: production        # ADO approvals and checks attach here
        pool: { vmImage: ubuntu-latest }
        strategy:
          runOnce:
            deploy:
              steps:
                - script: ./deploy.sh app:$(TRAIL_ID)
                  displayName: Deploy

                - script: |
                    fides snapshot k8s --env $(ENV_ID) --namespace prod
                    fides verify-chain --trail $(TRAIL_ID)
                  displayName: Snapshot runtime and verify chain
                  env:
                    FIDES_SERVER_URL: $(FIDES_SERVER_URL)
                    FIDES_API_TOKEN: $(FIDES_API_TOKEN)
```

Because the gate step exits non-zero on a violation, the `Build` stage fails and `condition: succeeded()` stops `Deploy` from ever starting.

## Human approval

Use an ADO **environment check** on `production` for the approval itself, then record it in Fides so the evidence lives with the trail:

```yaml
                - script: fides approve --trail $(TRAIL_ID) --role approver --reason "Approved by $(Build.RequestedFor)"
                  displayName: Record approval in Fides
                  env:
                    FIDES_SERVER_URL: $(FIDES_SERVER_URL)
                    FIDES_API_TOKEN: $(FIDES_API_TOKEN)
```

Four-eyes needs **two distinct humans**; the `segregation-of-duties` attestation is only `compliant: true` when committer, approver and deployer are pairwise distinct.

## Publishing the audit package

```yaml
          - script: fides audit --trail $(TRAIL_ID) --output $(Build.ArtifactStagingDirectory)/trail-audit.zip
            condition: always()
            displayName: Build audit package
            env:
              FIDES_SERVER_URL: $(FIDES_SERVER_URL)
              FIDES_API_TOKEN: $(FIDES_API_TOKEN)

          - publish: $(Build.ArtifactStagingDirectory)/trail-audit.zip
            artifact: fides-audit
            condition: always()
```

## Azure DevOps specifics worth knowing

- **Secret variables need explicit `env:` mapping.** Unlike normal variables, they are not injected into the script environment automatically.
- **Cross-step variables need `isOutput=true`** and are then referenced as `$(<stepName>.<VAR>)` — hence `$(build.DIGEST)` above.
- **Use `deployment` jobs, not plain jobs, for production.** Only deployment jobs bind to an ADO *environment*, which is where approvals, gates and deployment history live.
- **Register the Git provider** so commit status checks flow back: `fides git-provider config --provider azure-devops --host <host> --api-base <url> --token-path <ref>`.

## See also

- [GitHub Actions Integration](github-actions.md) · [GitLab CI Integration](gitlab-ci.md)
- [Best Practices](best-practices.md) · [CLI Reference](cli-reference.md)
