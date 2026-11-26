---
description: Integrate Fides with GitHub Actions — record build provenance, attach test and scan evidence, and gate deployments on compliance verdicts
keywords: fides, github actions, ci/cd, provenance, attestation, compliance gate, slsa, cosign, oidc
---

# Fides + GitHub Actions

The canonical flow is the same on every platform:

```
trail start → build → artifact report → attest (tests/scans/SBOM)
    → GATE → deploy → snapshot → verify-chain
```

Two rules matter more than the YAML:

1. **`TRAIL_ID` is a value you set** — the Git SHA by convention — and pass to every `--trail`. Do not try to capture IDs from `fides` stdout.
2. **Gates signal by exit code.** Never parse stdout to decide pass/fail.

## Secrets and variables

Use a **Writer** service-account key, not a personal token:

| Name | Kind | Purpose |
| --- | --- | --- |
| `FIDES_CI_KEY` | secret | Service-account key (`fides_<prefix>_<secret>`) |
| `FIDES_ENC_KEY` | secret | Only if you encrypt attestation payloads |
| `FIDES_ORG_ID` | variable | Org (tenant) UUID |
| `FIDES_FLOW_ID` | variable | Flow UUID for this service |
| `FIDES_PROD_ENV_ID` | variable | Environment UUID to snapshot |

## Complete workflow

```yaml
name: build-and-attest
on: { push: { branches: [main] } }

env:
  FIDES_SERVER_URL: https://fides.example.com
  FIDES_API_TOKEN: ${{ secrets.FIDES_CI_KEY }}
  FIDES_ENCRYPTION_KEY: ${{ secrets.FIDES_ENC_KEY }}   # only if encrypting payloads
  ORG_ID:   ${{ vars.FIDES_ORG_ID }}
  FLOW_ID:  ${{ vars.FIDES_FLOW_ID }}
  ENV_ID:   ${{ vars.FIDES_PROD_ENV_ID }}
  TRAIL_ID: ${{ github.sha }}

jobs:
  ship:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Fides CLI
        run: curl -sSfL $FIDES_SERVER_URL/cli/install.sh | sh

      - name: Start trail
        run: |
          fides trail start --flow $FLOW_ID --trail $TRAIL_ID \
            --repository "${{ github.repository }}" --commit "${{ github.sha }}" \
            --branch "${{ github.ref_name }}" --message "${{ github.event.head_commit.message }}"

      - name: Build + test + scan
        run: |
          docker build -t app:${{ github.sha }} .
          echo "DIGEST=$(docker inspect --format='{{index .Id}}' app:${{ github.sha }})" >> $GITHUB_ENV
          # ... run tests/scanners producing reports/junit.xml, reports/trivy.json ...

      - name: Report artifact + attest evidence
        run: |
          fides artifact report --org $ORG_ID --trail $TRAIL_ID --sha256 $DIGEST --name app --type docker
          fides attest junit --trail $TRAIL_ID --file reports/junit.xml --artifact-sha $DIGEST
          fides attest trivy --trail $TRAIL_ID --file reports/trivy.json --artifact-sha $DIGEST

      - name: Compliance gate         # fails the job on non-compliance / HOLD
        run: |
          fides assert      --sha256 $DIGEST --policy production-release-rules
          fides change-gate --trail $TRAIL_ID

      - name: Deploy
        run: ./deploy.sh app:${{ github.sha }}

      - name: Record runtime + verify
        run: |
          fides snapshot k8s --env $ENV_ID --namespace prod
          fides verify-chain --trail $TRAIL_ID
```

## Gate exit-code contract

| Gate | Fails the step when |
| --- | --- |
| `fides assert --sha256 $DIGEST --policy <name>` | artifact violates policy (**exit 1**) |
| `fides policy check --env $ENV --trail $TRAIL` | an applicable environment policy is unsatisfied (**exit 2**) |
| `fides allowlist check --env $ENV --sha $DIGEST` | digest not approved for the environment (**exit 2**) |
| `fides change-gate --trail $TRAIL` | verdict is HOLD (**exit 2**) |
| `fides verify-chain --trail $TRAIL` | attestation chain broken/tampered (**exit 2**) |
| `fides verify-image --sha256 $DIGEST --signer <id> --issuer <oidc>` | cosign/Sigstore signature invalid (**exit 2**) |

## Supply-chain provenance with GitHub's native attestations

GitHub can produce SLSA provenance for you. Fides ingests it directly, so you do not have to generate provenance twice:

```yaml
      - name: Ingest GitHub SLSA provenance + verify signature
        run: |
          fides attest fetch --trail $TRAIL_ID --artifact-sha $DIGEST --provider github \
            --repo "${{ github.repository }}"
          fides verify-image --sha256 $DIGEST \
            --signer "https://github.com/${{ github.repository }}/.github/workflows/build.yml@refs/heads/main" \
            --issuer "https://token.actions.githubusercontent.com" \
            --trail $TRAIL_ID
```

Both feed the `SLSA` framework controls (`slsa-provenance`, `cosign-verification`, `sbom-cyclonedx`). Import that catalog with `fides control import --framework SLSA`.

## Publishing the audit package

Give auditors a self-service artifact rather than a support request:

```yaml
      - name: Build audit package
        if: always()
        run: fides audit --trail $TRAIL_ID --output trail-audit.zip

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: fides-audit-${{ github.sha }}
          path: trail-audit.zip
```

## Modelling human approval

`change-gate` holds until a human has signed off. In GitHub Actions, model that with a job-level [environment protection rule](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) plus an explicit approval record:

```yaml
  approve:
    needs: ship
    runs-on: ubuntu-latest
    environment: production      # requires a reviewer in GitHub
    steps:
      - name: Record the approval in Fides
        run: fides approve --trail ${{ github.sha }} --role approver --reason "Release board sign-off"
```

Four-eyes needs **two distinct humans**, and the recorded `segregation-of-duties` attestation is only `compliant: true` when committer, approver and deployer are pairwise distinct.

## See also

- [GitLab CI Integration](gitlab-ci.md) · [Azure DevOps Integration](azure-devops.md)
- [Best Practices](best-practices.md) — conditional evidence, allow-lists and rotation
- [CLI Reference](cli-reference.md)
