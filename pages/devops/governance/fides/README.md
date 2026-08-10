---
description: Fides self-hosted compliance, provenance and evidence-tracking system for audit-ready software delivery across SOC 2, ISO 27001, NIST 800-53, PCI-DSS, DORA, PSD2, SOX and SLSA
keywords: fides, compliance, provenance, attestation, evidence, audit, sbom, slsa, cosign, change gate, segregation of duties, servicenow
---

# Fides — Trust, Provenance & Evidence Tracking

## Overview

Fides (named after the Roman goddess of trust and oaths) is a **self-hosted, multi-cloud compliance tracking system**. It records and evaluates every state change in the software delivery lifecycle in real time, acting as an audit-ready single source of truth for frameworks such as SOC 2, ISO 27001, NIST 800-53, PCI-DSS, DORA, PSD2, SOX and SLSA.

Where a traditional compliance programme reconstructs the story after the fact — screenshots, spreadsheets, a week of someone's life before an audit — Fides captures it as the pipeline runs, and can prove the record has not been altered since.

## The mental model

Everything in Fides hangs off a small set of nouns. Learn these six and the rest of the tool follows:

| Noun | What it is |
| --- | --- |
| **Flow** | A logical delivery stream — roughly one service or repository. Has a UUID. |
| **Trail** | One build or run of a Flow — roughly one Git SHA or build number. |
| **Artifact** | A built deliverable identified by its **SHA256** digest, attached to a trail. |
| **Attestation** | A piece of evidence about a trail or artifact — test results, scans, SBOM, a change record. Chained per-trail into a tamper-evident hash chain. |
| **Environment** | A runtime (docker / k8s / ecs / lambda) you **snapshot**. A **logical environment** aggregates several. |
| **Control / Framework** | A compliance control (e.g. `SOC2-CC7.1`) requiring specific evidence types. **Enforcing** a control creates the environment policy that raises **coverage**. |

The canonical pipeline is always the same shape:

```
trail start → build → artifact report → attest (tests/scans/SBOM)
    → GATE (assert / policy check / change-gate) → deploy → snapshot → verify-chain / audit
```

## Why Fides?

### The problem

Regulated delivery teams hit the same wall. Evidence lives in five to ten different tools and nobody owns the whole story. Audit prep becomes archaeology. The change board treats a one-character fix and a schema migration identically because nothing makes the difference in risk visible. And the moment a workload moves cloud, a compliance story wired to one provider's primitives breaks.

### The approach

Fides is deliberately **self-hosted and evidence-first**:

- **Provenance by digest, not by name.** Artifacts are traced by cryptographic SHA256 from git commit to running runtime — cosign/Sigstore signatures, SLSA in-toto provenance and SBOMs are verified along the way.
- **Tamper-evident by construction.** Attestations are chained per trail; `fides verify-chain` fails loudly if the record has been altered.
- **Advisory, not authoritative.** The change gate emits a verdict and a 0–100 risk score and writes it onto the matching ServiceNow change request. *Fides advises; ServiceNow decides.*
- **Air-gap friendly.** The LLM audit gateway runs against Ollama or llama.cpp as happily as Gemini, so natural-language compliance checks work with no egress.

## Core capabilities

### Supply-chain provenance

Trace artifacts by SHA256 digest from commit to running runtime. Ingest platform-native GitHub/GitLab SLSA attestations, verify cosign/Sigstore signatures (keyless OIDC or a supplied public key), and ingest CycloneDX or SPDX SBOMs — normalized per component so you can answer "which artifacts contain component X?" with `fides search components --purl <purl>`.

### Evidence vault

Immutable storage for external scan output — SBOMs, CVE reports, logs — on local disk or S3/GCS/Azure Blob. Optional **S3 Object Lock (WORM)** retention makes stored evidence immutable for a fixed window.

### Regulated control frameworks

One-command adoption of the SOC 2, ISO 27001, NIST 800-53, PCI-DSS, DORA, PSD2, SOX and SLSA catalogs, with per-framework auditor-ready reports and coverage tracked across environments. A **continuous control-test timeline** shows evidence over time rather than at a single point.

### Change gate & risk scoring

An evidence-backed approve/hold verdict with a 0–100 risk score for any change, driven by which controls pass, fail, or lack evidence — and written back onto the matching ServiceNow change request as a work note plus a risk field.

### Segregation of duties

First-class approval evidence distinguishing human sign-off from machine automation. Four-eyes requires two distinct human approvers, and the change gate will not recommend approval without a human review. Each gate or approval call records a `segregation-of-duties` attestation proving committer ≠ approver ≠ deployer — required by PCI-DSS 4.0 and SOX ITGC.

### Drift & shadow-change detection

Snapshot running containers, Kubernetes pods, ECS tasks or Lambda functions, then diff against the previous snapshot to surface unauthorised deployments and configuration drift.

### Tenant isolation & regulated records

Defense-in-depth Postgres **row-level security** — the app runs as a least-privilege role, so a tenant only ever sees its own data. FDA **21 CFR Part 11** support covers time-stamped system log tables, electronic records and ECDSA signature validation.

## Fides vs Kosli

Both tools solve the same shape of problem — automated evidence collection across the delivery lifecycle — and this knowledge base documents both. The practical differences:

| | Kosli | Fides |
| --- | --- | --- |
| **Model** | SaaS (hosted) | Self-hosted, single binary + Postgres |
| **Best for** | Teams wanting a managed service | Regulated or air-gapped estates that cannot egress delivery data |
| **Frameworks** | Evidence + policy primitives | Shipped control catalogs for 8 frameworks, with coverage and per-framework reports |
| **AI** | — | Built-in LLM audit gateway (Ollama / llama.cpp / Gemini) |
| **ITSM** | Integrations | Deep ServiceNow two-way: change gate write-back, CMDB anchoring, Now Assist grounding, and consuming ServiceNow's own MCP server |

If you are choosing between them, the deciding question is usually **can delivery metadata leave your network?** If yes, either works. If no, Fides is the one that runs entirely inside your perimeter.

## Where Fides is used

Fides is the evidence ledger shipped inside [SARC](../../../showcase/synechron-arc.md), the multi-cloud compliance pipeline — which is why the SARC portal has a Fides section covering environments, trails, attestations, SBOM and controls.

## In this section

- [Getting Started](getting-started.md) — install, authenticate, and record your first trail
- [GitHub Actions Integration](github-actions.md) — a complete build-attest-gate workflow
- [GitLab CI Integration](gitlab-ci.md) — the same pipeline in GitLab stages
- [Azure DevOps Integration](azure-devops.md) — the same pipeline in ADO YAML
- [CLI Reference](cli-reference.md) — every command and flag
- [Best Practices](best-practices.md) — what to do, and the traps to avoid

## Further reading

- [Fides source and documentation](https://github.com/olafkfreund/fides)
- [Kosli](../kosli/README.md) — the SaaS alternative documented in this section
- [ServiceNow](../servicenow/README.md) — the ITSM side of the change gate
