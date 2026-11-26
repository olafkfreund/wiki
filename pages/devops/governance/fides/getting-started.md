---
description: Install the Fides CLI, authenticate with a service-account key, and record your first build trail with artifacts and attestations
keywords: fides, getting started, installation, service account, trail, artifact, attestation, quickstart
---

# Getting Started with Fides

This page takes you from nothing to a complete, verifiable evidence trail for one build.

## Prerequisites

- A running Fides server (Go binary + PostgreSQL). See the [Helm chart and setup docs](https://github.com/olafkfreund/fides) for deployment.
- Network access to that server from wherever you run the CLI.
- An API token — ideally a **service-account key**, not a personal one.

## 1. Install the CLI

The server hosts its own installer:

```bash
curl -sSfL https://fides.example.com/cli/install.sh | sh
fides help
```

## 2. Authenticate

The CLI reads exactly **three** environment variables. Everything else in Fides configures the *server*, not the CLI:

```bash
export FIDES_SERVER_URL="https://fides.example.com"   # default: http://localhost:8080
export FIDES_API_TOKEN="fides_<prefix>_<secret>"      # a service-account key (preferred)
export FIDES_ENCRYPTION_KEY="<passphrase>"            # optional: AES-256-GCM payload encryption
```

Verify connectivity before doing anything real:

```bash
fides flow list
```

If that returns without error, you are wired up correctly.

### Create a service-account key

Personal tokens in CI are a bad habit — they carry a human's permissions and die when that human leaves. Issue a scoped key instead:

```bash
fides service-account create --name ci-runner --role Writer
fides service-account issue-key --account <sa_id> --label ci --expires-hours 720
```

The key is printed **once**, in the form `fides_<prefix>_<secret>`. Store it in your CI secret store immediately.

Roles are `Admin`, `Auditor`, `Writer` and `Viewer`. CI needs `Writer`. Rotation is issue-new → switch CI → revoke-old:

```bash
fides service-account revoke-key --account <sa_id> --key <key_id>
```

## 3. Record your first trail

The trail identifier is a value **you choose** — the Git SHA is the convention — and you pass it consistently to every subsequent command. IDs are **not** captured from `fides` stdout.

```bash
FLOW_ID="<flow-uuid>"
ORG_ID="<org-uuid>"
TRAIL="$(git rev-parse HEAD)"

fides trail start \
  --flow "$FLOW_ID" \
  --trail "$TRAIL" \
  --repository "https://github.com/acme/app" \
  --commit "$TRAIL" \
  --branch "main" \
  --message "$(git log -1 --pretty=%s)"
```

## 4. Register the artifact

Artifacts are identified by **SHA256 digest** — lowercase hex, no `sha256:` prefix. Either supply the digest or let Fides compute it from a file:

```bash
docker build -t app:$TRAIL .
DIGEST=$(docker inspect --format='{{index .Id}}' app:$TRAIL)

fides artifact report \
  --org "$ORG_ID" --trail "$TRAIL" \
  --sha256 "$DIGEST" --name app --type docker

# ...or hash a file directly:
fides artifact report --org "$ORG_ID" --trail "$TRAIL" --file ./dist/app.tar.gz --name app --type binary
```

## 5. Attach evidence

Fides ships parsers for the common report formats. Each one normalizes the raw report into a compliant/non-compliant attestation and attaches the original file:

```bash
fides attest junit --trail "$TRAIL" --file reports/junit.xml  --artifact-sha "$DIGEST"
fides attest trivy --trail "$TRAIL" --file reports/trivy.json --artifact-sha "$DIGEST"
fides attest snyk  --trail "$TRAIL" --file reports/snyk.json  --artifact-sha "$DIGEST"
fides attest sbom  --artifact-sha "$DIGEST" --file sbom.json
```

`attest sbom` auto-detects CycloneDX vs SPDX and persists every component (name, version, purl, licenses) linked to the artifact — which is what makes `fides search components --purl <purl>` able to answer "which of my artifacts contain this component?".

For anything without a built-in parser, use the generic form:

```bash
fides attest --trail "$TRAIL" --name pen-test --type security-review \
  --payload results.json --artifact-sha "$DIGEST" --encrypt
```

## 6. Gate the deploy

Gate commands signal via **exit code**, never stdout. Pick the strictest that applies:

```bash
fides assert       --sha256 "$DIGEST" --policy production-release-rules   # exit 1 on violation
fides policy check --env "$ENV_ID" --trail "$TRAIL"                       # exit 2 if unsatisfied
fides change-gate  --trail "$TRAIL"                                       # exit 2 on HOLD
```

`change-gate` will hold until a human signs off — see [Best Practices](best-practices.md#segregation-of-duties) for the four-eyes model.

## 7. Snapshot the runtime and verify

After deploying, record what is actually running and confirm the evidence chain is intact:

```bash
fides snapshot k8s --env "$ENV_ID" --namespace prod
fides verify-chain --trail "$TRAIL"     # exit 2 if the chain is broken or tampered with
```

## 8. Adopt a framework

Importing a catalog is idempotent, so it is safe to run repeatedly:

```bash
fides control import --framework SOC2
fides control enforce --all-controls --all-environments
fides control coverage
fides report --framework SOC2
```

Available catalogs: `SOC2`, `ISO27001`, `NIST-800-53`, `PCI-DSS`, `DORA`, `PSD2`, `SOX` and `SLSA`.

## 9. Hand something to the auditor

```bash
fides audit --trail "$TRAIL" --output trail-audit.zip
```

A self-contained ZIP: the trail, its artifacts, every attestation, the chain verdict and the report. Publishing this as a build artifact means the auditor never has to ask you for anything.

## Next steps

- Wire it into CI: [GitHub Actions](github-actions.md) · [GitLab CI](gitlab-ci.md) · [Azure DevOps](azure-devops.md)
- [CLI Reference](cli-reference.md) — the complete command surface
- [Best Practices](best-practices.md) — including the traps worth knowing about early
