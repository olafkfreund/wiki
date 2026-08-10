---
description: Fides best practices — service-account hygiene, gate selection, segregation of duties, conditional evidence, WORM retention and production hardening
keywords: fides, best practices, segregation of duties, four eyes, service account rotation, worm retention, rls, policy, allowlist, air-gapped
---

# Fides Best Practices

Patterns that hold up in a real regulated estate, and the traps worth knowing about before you hit them.

## Identity and secrets

### Use service-account keys, never personal tokens

A personal token carries a human's permissions and dies when that human leaves — usually at 2am, in the middle of a release. Issue a scoped **Writer** key per pipeline instead:

```bash
fides service-account create --name ci-payments --role Writer
fides service-account issue-key --account <sa_id> --label ci --expires-hours 720
```

Roles are `Admin`, `Auditor`, `Writer`, `Viewer`. CI only ever needs `Writer`. Give auditors `Auditor`, not `Admin`.

### Rotate by overlap, not by outage

Keys are printed once. The safe rotation order is **issue new → switch CI → revoke old**:

```bash
fides service-account issue-key  --account <sa_id> --label ci-2026q3 --expires-hours 2160
# update the CI secret, let one pipeline run green, then:
fides service-account revoke-key --account <sa_id> --key <old_key_id>
```

Setting `--expires-hours` at issue time means a forgotten key expires on its own rather than living forever.

### Never inline secrets in integration config

Every integration takes `--secret-path`, which is a *reference* — an env-var name or a Secrets Manager id — resolved server-side by `SECRETS_PROVIDER`:

```bash
# good
fides servicenow config --instance-url https://acme.service-now.com \
  --auth-type oauth2 --client-id fides --secret-path acme/prod/servicenow-oauth

# bad — the secret is now in your shell history, your CI log, and probably a ticket
```

## Choosing the right gate

Fides gives you four gates. Use the strictest one that genuinely applies, and understand what each actually checks:

| Gate | Checks | Use when |
| --- | --- | --- |
| `fides assert` | The artifact against named policy rules | You want a single artifact-level pass/fail |
| `fides policy check` | Whether required evidence types exist for an environment | Different environments demand different evidence |
| `fides allowlist check` | Whether this exact digest is approved for this environment | A release board approves specific builds |
| `fides change-gate` | Control coverage + evidence + human approval → verdict and 0–100 risk | You need a defensible, scored decision |

**Always rely on the exit code.** Every gate signals non-zero on failure; parsing stdout is fragile and will eventually let a bad build through.

```bash
# good — the step fails, the pipeline stops
fides change-gate --trail "$TRAIL"

# bad — a format change silently breaks the gate
fides change-gate --trail "$TRAIL" | grep -q APPROVE || exit 1
```

## Segregation of duties

The change gate **will not** recommend approval without a human sign-off, and four-eyes requires two *distinct* humans.

```bash
fides approve --trail "$TRAIL" --role approver --reason "Release board 2026-08-04"
fides approve --trail "$TRAIL" --role deployer --reason "Deployed by platform on-call"
```

Every `change-gate` or `approve` call re-records a `segregation-of-duties` attestation. It is only `compliant: true` when **committer, approver and deployer are pairwise distinct** — which is exactly what PCI-DSS 4.0 and SOX ITGC ask you to prove.

Two practical consequences:

- **Set `--committer` on `trail start`.** Without it, Fides has no committer identity to compare against, and the SoD check cannot be satisfied.
- **Model approval as a manual CI step**, not an automated one. A pipeline that approves itself has defeated the control while appearing to satisfy it.

## Evidence design

### Prefer the format parsers

`fides attest junit|snyk|trivy|slsa|sbom` normalize the report into `{format, compliant, summary{counts}, findings}` and attach the original. That normalized shape is jq-evaluable, so a policy rule stays readable:

```
.summary.failed == 0
```

Reach for generic `fides attest --payload` only when nothing else fits.

### Make evidence conditional rather than universal

Requiring a ServiceNow change record on every build is how teams learn to route around the tool. Tag the flow and require it only where it matters:

```bash
# tag the flow as high-risk
curl -X POST "$FIDES_SERVER_URL/api/v1/flows/$FLOW/tags" \
  -H "Authorization: Bearer $FIDES_API_TOKEN" \
  -d '{"tags":{"risk":"high"}}'

# require the change record only for high-risk flows
fides policy add --env "$ENV" --name high-risk \
  --require servicenow-change --if-tag risk --if-value high
```

### Always attach an SBOM

`fides attest sbom` persists every component with its purl, which is what makes this possible during the next Log4Shell:

```bash
fides search components --purl "pkg:maven/org.apache.logging.log4j/log4j-core@2.14.1"
```

Without per-component rows, that question takes a week of manual work. With them, it takes a second.

## Framework adoption

Import and enforce are both **idempotent**, so run them from configuration management rather than by hand:

```bash
fides control import  --framework SOC2
fides control import  --framework ISO27001
fides control enforce --all-controls --all-environments
fides control coverage
```

`control enforce --all-controls --all-environments` is the fastest way to raise coverage across an estate, but do it deliberately — it creates an environment policy per control, which means builds start failing the moment evidence is missing. Run `fides control coverage` **first** to see what you would be turning on.

Use `fides control timeline --days 90` for continuous control-test evidence. Auditors increasingly want to see that a control held *over a period*, not that it passed on the day you ran the report.

## Runtime and drift

Snapshot after every deploy, then diff:

```bash
fides snapshot k8s --env "$ENV" --namespace prod
fides env diff --env "$ENV"
```

`env diff` defaults to comparing the two most recent snapshots. Anything appearing there that did not come from a pipeline is a shadow change — which is usually the single most valuable finding the tool produces in its first month.

## Production hardening

Configure these on the **server**, not the CLI:

```bash
export FIDES_RLS_ENABLED=true                      # Postgres row-level security per tenant
export SECRETS_PROVIDER=aws AWS_REGION=eu-west-2
export STORAGE_DRIVER=s3 AWS_S3_BUCKET=acme-fides-evidence
export FIDES_OBJECT_LOCK_MODE=COMPLIANCE           # WORM; bucket must have Object Lock enabled
export FIDES_EVIDENCE_RETENTION_DAYS=2555          # ~7 years
export FIDES_EVENTS_ENABLED=true
export FIDES_PUBLIC_URL=https://fides.acme.com
```

Two warnings worth internalising:

- **`FIDES_OBJECT_LOCK_MODE=COMPLIANCE` cannot be undone.** Not by you, not by your root account, not by AWS support. Objects are immutable until the retention window expires. Use `GOVERNANCE` unless you specifically need the stronger guarantee.
- **`FIDES_RLS_ENABLED=true` requires the app to run as the least-privilege `fides_app` role.** Turning it on without that role configured will fail closed, which is the correct behaviour but a surprising one at 5pm on a Friday.

## Air-gapped operation

Fides is designed to work with no egress. The LLM audit gateway takes local providers:

```bash
export AI_PROVIDER=ollama
export AI_OLLAMA_ENDPOINT=http://localhost:11434
export AI_MODEL=llama3
```

This powers `fides policy generate`, the portal's policy linter and scored AI audit reports — all without a single packet leaving the network.

## Auditor experience

Publish the audit package from every pipeline run:

```bash
fides audit --trail "$TRAIL" --output trail-audit.zip
```

A self-contained ZIP containing the trail, artifacts, attestations, chain verdict and report. The goal is that an auditor never has to file a request with your team — and, just as importantly, that nobody on your team spends a week assembling a binder.

Give auditors an `Auditor` service account rather than a shared login, so their access is scoped and their queries are attributable.

## Anti-patterns

| Don't | Do |
| --- | --- |
| Parse gate stdout | Rely on the exit code |
| Capture IDs from `fides` output | Choose `TRAIL_ID` yourself (the Git SHA) and pass it everywhere |
| Use a personal token in CI | Issue a Writer service-account key |
| Inline secrets in integration config | Use `--secret-path` references |
| Approve automatically in the pipeline | Make approval a manual, attributable step |
| Enforce every control on day one | Run `control coverage` first, then enforce in waves |
| Prefix digests with `sha256:` | Lowercase hex only |

## See also

- [Getting Started](getting-started.md) · [CLI Reference](cli-reference.md)
- [GitHub Actions](github-actions.md) · [GitLab CI](gitlab-ci.md) · [Azure DevOps](azure-devops.md)
