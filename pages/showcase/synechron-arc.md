---
description: >-
  Synechron ARC (SARC) — a multi-cloud compliance pipeline platform that ships
  the same software the same way on AWS, Azure, GCP, and a developer laptop,
  with ServiceNow change management, Kosli cryptographic attestations, and a
  unified DevSecOps control plane.
keywords: >-
  ServiceNow, Kosli, GitLab, GitHub Actions, Azure DevOps, multi-cloud, EKS,
  AKS, GKE, k3d, compliance, DORA, SBOM, ArgoCD, Tekton, OpenShift, ROSA,
  AI governance, DevSecOps, platform engineering
---

# Synechron ARC — Multi-Cloud Compliance Pipeline

> **The compliance pipeline platform that runs the same way on AWS, Azure, GCP, and a laptop.**

Synechron ARC (internally **SARC**) is a customer demo and reference platform that wires **ServiceNow + Kosli + GitLab / GitHub / Azure DevOps** into a single, auditable delivery pipeline — deployable to **AWS EKS, Azure AKS, GCP GKE, or local k3d** from one repository with a single `TARGET_CLOUD` environment variable. OpenShift (ROSA HCP) is a fifth, read-only observable target inside the portal.

The deployable workload is the CNCF [podtato-head](https://github.com/cncf/podtato-head) microservice mesh; the value is the compliance pipeline around it — and the **ARC-portal**, a Next.js DevSecOps control plane that stitches every signal (CI status, scans, change requests, SBOMs, Kosli attestations, CMDB CIs, costs, AI guardrails) into one screen.

## At a glance

|                  |                                                                                              |
| ---------------- | -------------------------------------------------------------------------------------------- |
| **Role**         | Lead engineer, architect, full-stack                                                         |
| **Status**       | Active customer demo platform; mirrored across GitLab / GitHub / Azure DevOps                |
| **Clouds**       | AWS (EKS 1.31), Azure (AKS 1.31), GCP (GKE 1.31), local k3d, OpenShift (ROSA HCP, read-only) |
| **CI**           | GitLab (source of truth), GitHub Actions (full parity), Azure Pipelines (in progress)        |
| **Portal stack** | Next.js 15, TypeScript, Prisma, Postgres, Redis, multi-provider LLM                          |
| **Compliance**   | SOC 2, SOX, PCI DSS, ISO 27001, DORA Regulation, NIST 800-53                                 |
| **License**      | Apache-2.0                                                                                   |

## The problem ARC solves

Regulated organisations hit the same four problems with software delivery:

{% hint style="warning" %}

- **Evidence is scattered** across SonarQube, Snyk, Wiz, GitGuardian, ServiceNow, and three CI systems. An auditor asks one question and someone spends a week in spreadsheets.
- **Approvals are a bottleneck.** A typo fix and a schema migration get the same 48-hour CAB review. Engineers route around the system; auditors lose the trail.
- **CMDB is always stale.** By month-end it bears no resemblance to reality.
- **Cloud lock-in is forced early** because compliance tooling is built around one cloud's primitives. Evaluating a second cloud means rebuilding the pipeline.

{% endhint %}

ARC answers all four with a single pipeline that produces the same evidence on every cloud, and a single portal that surfaces that evidence — plus the controls that satisfy each framework — for every role in the delivery chain.

## Architecture at a glance

```text
                +-----------------------------------------+
                |              Developer push             |
                +-------------------+---------------------+
                                    |
                                    v
            +-----------------------+--------------------------+
            |   GitLab CI  (source of truth)                   |
            |   ----------                                     |
            |   validate  ->  build  ->  scan  ->  attest      |
            |                                       |          |
            |                                       v          |
            |                                  +---------+     |
            |                                  |  Kosli  |     |
            |                                  +----+----+     |
            |                                       |          |
            |                  +----------+         |          |
            |   ServiceNow CR  | risk eval|<--------+          |
            |   <------------+ +----------+                    |
            +----------+--------+--+--------------------+------+
                       |           |                    |
                       |           |  mirror jobs       |
                       |           v                    |
                       |   +-----------+   +---------------------+
                       |   | GitHub    |   | Azure DevOps        |
                       |   | Actions   |   | Pipelines           |
                       |   +-----------+   +---------------------+
                       |
                       v
          +-------------------------------------+
          |  helm upgrade --values              |
          |  apps/<chart>/values-${CLOUD}.yaml  |
          +--+----------+----------+----------+-+
             |          |          |          |
             v          v          v          v
          +------+   +------+   +------+   +------+
          | EKS  |   | AKS  |   | GKE  |   | k3d  |
          +--+---+   +--+---+   +--+---+   +--+---+
             |          |          |          |
             +----------+----+-----+----------+
                            |
                            v
                   +-----------------+
                   |   ARC-portal    |
                   | (every signal)  |
                   +-----------------+
```

Every box on the path emits a **Kosli attestation**, every promotion creates a **ServiceNow change request**, and the **ARC-portal** subscribes to all of it and renders the unified picture.

## The one knob — `TARGET_CLOUD`

A single environment variable drives every cloud-specific decision:

```bash
export TARGET_CLOUD=aws       # or azure | gcp | k3d
```

| Consumer                                                         | What it selects                                                                                                         |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `terraform -chdir=infra/${TARGET_CLOUD}`                         | Which cluster + identity stack runs                                                                                     |
| `configure-kubectl` CI step                                      | Which cloud CLI authenticates kubectl                                                                                   |
| `helm upgrade --values apps/<chart>/values-${TARGET_CLOUD}.yaml` | Which cloud-specific overlay applies — ingress class, TLS issuer, external-secrets backend, managed-identity annotation |
| Kosli environment name                                           | `${TARGET_CLOUD}-arc-${env}` — 12 environments across 4 clouds, all feeding one flow `arc-pipeline`                     |

What stays identical across clouds: `ingress-nginx`, `cert-manager`, `external-secrets`, the same Helm charts, the same `just` recipes, the same `kubectl` commands during a demo. What diverges, by necessity: identity federation (IRSA / Workload Identity / WI Federation), secret-store backend, managed Postgres + Redis, network primitives.

## The ARC-portal — DevSecOps control plane

One web application, every role: developers, security, compliance, change managers, and management all open the same URL. Below is a tour of the surfaces that matter most.

### Dashboard — release-health command centre

![ARC dashboard](../../assets/images/showcase/synechron-arc/00-dashboard.png)

Per-environment status, DORA mini, pending change requests, deploy impacts, vulnerability burndown sparkline, SBOM coverage, and a change-window banner that turns red during freezes. One screen.

### Environments and DORA metrics

{% tabs %}
{% tab title="Environments" %}
![Environments](../../assets/images/showcase/synechron-arc/01-environments.png)

Every environment (`dev` / `qa` / `prod`) on every cloud with deployed services, current versions, and compliance status. Version drift between environments is visible at a glance.
{% endtab %}
{% tab title="DORA metrics" %}
![DORA metrics](../../assets/images/showcase/synechron-arc/02-metrics-dora.png)

Deployment Frequency, Lead Time for Changes, Change Failure Rate, MTTR — calculated from pipeline data with trends over time.
{% endtab %}
{% endtabs %}

### Pipelines, change requests, and change windows

{% tabs %}
{% tab title="Pipelines" %}
![Pipelines](../../assets/images/showcase/synechron-arc/10-pipelines.png)

Every pipeline run across every connected CI/CD system (GitLab, GitHub Actions, Azure Pipelines) in one list with status, trigger, scans, and deep-link back to source.
{% endtab %}
{% tab title="Change requests" %}
![Change requests](../../assets/images/showcase/synechron-arc/11-change-requests.png)

ServiceNow change requests created automatically by the pipeline, with risk score, approval status, and outcome. Risk-based routing: about 80% of releases need no manual approval.
{% endtab %}
{% tab title="Change windows" %}
![Change windows](../../assets/images/showcase/synechron-arc/12-change-windows.png)

Freeze, restricted, or maintenance windows — one-time or recurring. Pipelines that try to deploy during a freeze are stopped before they touch the cluster.
{% endtab %}
{% tab title="Problems" %}
![Problems](../../assets/images/showcase/synechron-arc/13-problems.png)

ServiceNow Problem records correlated with affected services and CIs, with one-click "Solve with Agent" dispatch.
{% endtab %}
{% tab title="Issue sync" %}
![Issue sync](../../assets/images/showcase/synechron-arc/14-issue-sync.png)

Three-way issue broker — GitLab Issues, GitHub Issues, and ADO Work Items kept in sync, with canonical-source tracking and state/label/comment replication.
{% endtab %}
{% endtabs %}

### Service catalogue, graph, and teams

{% tabs %}
{% tab title="Catalogue" %}
![Services catalogue](../../assets/images/showcase/synechron-arc/20-services-catalog.png)

Every service indexed with owner, lifecycle, environment coverage, dependencies, and last-deployed metadata.
{% endtab %}
{% tab title="Graph" %}
![Service graph](../../assets/images/showcase/synechron-arc/21-services-graph.png)

23 seeded services laid out as a force-directed graph — ARC internal infra (portal, MCP server, postgres, redis, argocd), the podtato microservice mesh, and 9 external integrations.
{% endtab %}
{% tab title="Teams" %}
![Teams](../../assets/images/showcase/synechron-arc/22-teams.png)

Team-to-service ownership with on-call rotation, escalation policy, and contact channels.
{% endtab %}
{% endtabs %}

### SBOMs, vulnerabilities, and security scans

{% tabs %}
{% tab title="SBOM" %}
![SBOM](../../assets/images/showcase/synechron-arc/30-sbom.png)

Complete component inventory per deployed service, CycloneDX + SPDX, SHA-256 verified, one-click download.
{% endtab %}
{% tab title="Vulnerabilities" %}
![Vulnerabilities](../../assets/images/showcase/synechron-arc/31-vulnerabilities.png)

7-column tracked view with SLA folded into one cell (Critical 15d / High 30d / Medium 60d / Low 90d), priority KPI tiles, URL-persisted filters, and a row drawer with CVE/NVD/OSV advisory links, SBOM component, Kosli attestation, AskAi popover, agent-fix dispatch, and impacted compliance controls.
{% endtab %}
{% tab title="Burndown" %}
![Vulnerability burndown](../../assets/images/showcase/synechron-arc/32-vuln-burndown.png)

Severity-stacked burndown chart with SLA-breach overlay.
{% endtab %}
{% tab title="Scans" %}
![Security scans](../../assets/images/showcase/synechron-arc/33-security-scans.png)

SAST, dependency, container, secret, IaC, and DAST findings aggregated from GitLab, GitHub Advanced Security, SonarQube, Snyk, Wiz, and GitGuardian. Six providers, one dashboard.
{% endtab %}
{% endtabs %}

### Compliance, risk, control mapping, policies, Kosli, evidence export

{% tabs %}
{% tab title="Compliance" %}
![Compliance](../../assets/images/showcase/synechron-arc/40-compliance.png)

Real-time view against SOX, PCI DSS, DORA Regulation, ISO 27001, NIST 800-53 — controls present, controls satisfied, gaps remaining.
{% endtab %}
{% tab title="Risk" %}
![Risk](../../assets/images/showcase/synechron-arc/41-risk.png)

Per-deployment risk score 0–100 from the attestation graph; drives auto-approval thresholds (QA ≤ 5, prod ≤ 2).
{% endtab %}
{% tab title="Control mapping" %}
![Control mapping](../../assets/images/showcase/synechron-arc/42-control-mapping.png)

3-tile KPI strip, consolidated evidence table with single Links and Gap columns, 8-group cross-link sidebar, and 7/30/60/90-day window picker.
{% endtab %}
{% tab title="Policies" %}
![Policies](../../assets/images/showcase/synechron-arc/43-policies.png)

Kosli + OPA policies with enforcement scope, last-evaluation result, and version history.
{% endtab %}
{% tab title="Kosli" %}
![Kosli](../../assets/images/showcase/synechron-arc/44-kosli.png)

Live view of the `arc-pipeline` flow across 12 cloud × env environments — artifact attestations, deployment receipts, policy verdicts.
{% endtab %}
{% tab title="Evidence export" %}
![Evidence export](../../assets/images/showcase/synechron-arc/45-evidence-export.png)

One-button SOC 2 evidence package with date-range + framework selector. Packages every attestation, SBOM, audit log entry, Kosli trail, CR, and policy result into a canonical-JSON envelope, per-tenant rate-limited.
{% endtab %}
{% endtabs %}

### CMDB and releases

{% tabs %}
{% tab title="CMDB" %}
![CMDB](../../assets/images/showcase/synechron-arc/50-cmdb.png)

Every Configuration Item from ServiceNow (including OpenShift CIs) with operational state, version, environment, and deep-link to the full record. **Every successful deploy updates the corresponding CI via the ServiceNow IRE API** — the CMDB stays current without anyone touching it.
{% endtab %}
{% tab title="Releases" %}
![Releases](../../assets/images/showcase/synechron-arc/51-releases.png)

Release timeline with diff, attestation chain, deployment outcome, and rollback button.
{% endtab %}
{% endtabs %}

### Multi-cluster operations — Clusters, ArgoCD, Tekton, Costs

{% tabs %}
{% tab title="Clusters" %}
![Clusters](../../assets/images/showcase/synechron-arc/60-clusters.png)

Live status across all configured clusters — node health, control-plane reachability, addon versions, kubeconfig context.
{% endtab %}
{% tab title="ArgoCD" %}
![ArgoCD](../../assets/images/showcase/synechron-arc/61-argocd.png)

Multi-cluster GitOps with live SSE sync status, PreSync (Kosli assert + ServiceNow CR) and PostSync (Kosli report + DAST QA) hooks.
{% endtab %}
{% tab title="Timeline" %}
![Timeline](../../assets/images/showcase/synechron-arc/62-timeline.png)

Chronological cross-cluster activity feed.
{% endtab %}
{% tab title="Performance" %}
![Performance](../../assets/images/showcase/synechron-arc/63-performance.png)

Per-service latency, error-rate, and resource-pressure tiles.
{% endtab %}
{% tab title="Tekton" %}
![Tekton](../../assets/images/showcase/synechron-arc/64-tekton.png)

Multi-cluster PipelineRuns dashboard with live SSE status and step-log streaming across up to 5 cluster targets, configured per-tenant.
{% endtab %}
{% tab title="Costs" %}
![Costs](../../assets/images/showcase/synechron-arc/65-costs.png)

Per-service cost and chargeback from AWS Cost Explorer, Azure Cost Management, GCP Cloud Billing, and Kubecost — with cost ↔ vulnerability correlation.
{% endtab %}
{% endtabs %}

### Governance — Audit log, Users, Notifications

{% tabs %}
{% tab title="Audit log" %}
![Audit log](../../assets/images/showcase/synechron-arc/70-audit-log.png)

Every action — deployment, approval, rejection, rollback, settings change, risk acceptance — recorded with actor, timestamp, and a **SHA-256 hash chained to the previous entry**. JSON evidence package + printable HTML report exports.
{% endtab %}
{% tab title="Users" %}
![Users](../../assets/images/showcase/synechron-arc/71-users.png)

Three-role RBAC (Viewer / Approver / Admin) with magic-link invites, MFA, and disable-preserves-trail semantics.
{% endtab %}
{% tab title="Notifications" %}
![Notifications](../../assets/images/showcase/synechron-arc/72-notifications.png)

Slack, Teams, email, and webhook fan-out with per-rule severity threshold and channel routing.
{% endtab %}
{% endtabs %}

### Settings — wire your stack

{% tabs %}
{% tab title="Overview" %}
![Settings grid](../../assets/images/showcase/synechron-arc/73-settings-grid.png)

Every integration in one grid. Credentials encrypted at rest with AES-256-GCM; the portal never stores plain-text secrets.
{% endtab %}
{% tab title="AI providers" %}
![AI settings](../../assets/images/showcase/synechron-arc/74-settings-ai.png)

Multi-provider LLM configuration — Anthropic, Azure OpenAI, Bedrock, Vertex, on-prem — for AskAi popovers, natural-language search, and agent recipes. MCP server configuration lives here too.
{% endtab %}
{% tab title="Agent dispatch" %}
![Agent dispatch](../../assets/images/showcase/synechron-arc/75-settings-agent-dispatch.png)

Agent recipe bindings: `vuln-suggest-fix`, `problem-investigate-fix`, `right-sizing-apply` dispatched to GitLab, GitHub, or Azure DevOps from in-row buttons on vulnerabilities, problems, and change requests.
{% endtab %}
{% tab title="Tekton" %}
![Tekton settings](../../assets/images/showcase/synechron-arc/76-settings-tekton.png)

Per-tenant Tekton cluster targets — kubeconfig context, namespace scope, RBAC, live-SSE endpoints.
{% endtab %}
{% tab title="Help" %}
![Help docs](../../assets/images/showcase/synechron-arc/77-help-docs.png)

In-portal documentation filtered by role — compliance officers see plain-language framework explanations, admins see integration setup guides, engineers see dashboard usage.
{% endtab %}
{% endtabs %}

## AI Governance — SR 11-7 / OCC 2021-39 ready

A portal-wide dashboard at `/ai/governance` covering:

- **Kill-switch** for any registered model
- **Model registry** with version, provider, evaluation status
- **Eval results** with regression detection
- **Risk register** mapped to **NIST AI 600-1** and **ISO 42001** controls
- **Guardrails** — Llama Guard 3 input/output filtering and **Microsoft Presidio** PII redaction
- **Cross-encoder reranker** for retrieval quality

The same evidence-export mechanism that produces SOC 2 packs produces AI governance packs.

## Compliance flow — one delivery cycle

End-to-end, an ARC delivery from issue to production:

1. **Issue filed** — GitLab Issue / GitHub Issue / ADO Work Item; ID flows through commit messages to the ServiceNow CR.
2. **Branch from main** — protected branch, signed commits, required CI status.
3. **Pre-commit hooks** — yamllint, shellcheck, tfsec, checkov, gitleaks. The same checks the CI runs.
4. **Push triggers validate** — terraform validate matrix × 3 clouds, helm lint + template matrix × 2 charts × 3 clouds.
5. **Build + scan** — container image built, SAST + dependency + container + IaC + secret scans run, **Kosli artifact attestation** emitted with digest + scan results.
6. **Deploy to dev** — Helm install into `arc-dev` on the chosen `TARGET_CLOUD`. Portal lights up with the new artefact.
7. **Open MR/PR** — full evidence on the review surface: scans, SBOM, Kosli chain. CODEOWNERS gates merge; Kosli policy gate confirms attestations are present.
8. **Merge** — kicks off the parallel mirror jobs (GitLab → GitHub + ADO) and the QA promotion path.
9. **Promote to QA** — `scripts/ci/promote.sh` generates release notes, computes Kosli risk score, creates ServiceNow CR with 13 custom fields, attaches SBOM + SARIF, **auto-approves if risk ≤ 5**, otherwise routes to a human.
10. **Verify in QA** — ArgoCD PostSync triggers a ZAP DAST scan; findings flow back to the portal.
11. **Promote to prod** — **always manual approval** in ServiceNow, even for risk-zero. CR enriched with production evidence bundle (bulk attestation upload, control-mapping snapshot, SBOM hash chain).
12. **Verify in prod** — Kosli environment receipts, **CMDB CI auto-updated via the IRE API**, DORA lead-time clock recorded.

End-to-end: one issue, one branch, one merge, three environments, six attestations, two change requests (auto-approved QA, human-approved prod), a refreshed CMDB record, and a cryptographic chain of evidence an auditor can verify in seconds.

## Multi-cloud implementation

The same Helm charts and the same pipeline produce four genuinely different cloud deployments. What's identical and what diverges:

| Target          | Cluster           | Ingress             | TLS                       | Secrets                              | Prod Postgres         | Prod Redis       | TF state        |
| --------------- | ----------------- | ------------------- | ------------------------- | ------------------------------------ | --------------------- | ---------------- | --------------- |
| **AWS**         | EKS 1.31          | ingress-nginx (NLB) | cert-manager + LE         | Secrets Manager via **IRSA**         | RDS PostgreSQL 16.4   | ElastiCache      | S3 + DynamoDB   |
| **Azure**       | AKS 1.31          | ingress-nginx       | cert-manager + LE         | Key Vault via **Workload Identity**  | Flexible Server 16.4  | Azure Cache      | Azure Storage   |
| **GCP**         | GKE 1.31 regional | ingress-nginx       | cert-manager + LE         | Secret Manager via **WI Federation** | Cloud SQL POSTGRES_16 | Memorystore      | GCS (versioned) |
| **k3d (local)** | k3d single-node   | ingress-nginx       | self-signed ClusterIssuer | plain `Secret` from `.envrc`         | bitnami subchart      | bitnami subchart | local TF state  |

Postgres major+minor is **pinned across all four targets** so a migration generated against the dev subchart applies cleanly against every managed service.

A deploy layers three Helm values files: `values.yaml` + `values-${TARGET_CLOUD}.yaml` + `envs/${env}/values.yaml`. Simple precedence — env overrides cloud overrides common.

## CI mirror topology

GitLab is the source of truth. GitHub and Azure DevOps are read-only replicas refreshed after every successful pipeline on `main`:

```text
        gitlab.com/compliance-calitii/sarc       (source of truth)
            |
            |  mirror stage (parallel jobs, --force-with-lease)
            v
   +--------+---------+
   |                  |
   v                  v
github.com/        dev.azure.com/
Freundcloud/SARC   olaffreund0455/SARC/_git/SARC
```

| Platform            | Role            | Key facts                                                                                                                                                            |
| ------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **GitLab**          | Source of truth | Canonical pipeline templates in `.gitlab/ci/templates/`; mirror jobs `--force-with-lease`, `allow_failure: true` so a mirror blip never blocks an upstream pipeline. |
| **GitHub Actions**  | Full parity     | 17 dispatchable orchestrator workflows + 20 reusable modules. **OIDC auth to all three clouds — no long-lived credentials.**                                         |
| **Azure Pipelines** | In progress     | Mirror live; pipeline parity follows.                                                                                                                                |

The same `scripts/ci/*.sh` shell modules are called by all three platforms — domain logic stays out of the platform-specific YAML.

## Integrations catalogue

| System                                                                 | Purpose                                                                                                                     |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **ServiceNow**                                                         | Change Requests with 13 custom fields, Problems, CMDB sync (including OpenShift), `pa_dashboards`, multi-env approval gates |
| **Kosli**                                                              | Artifact + deployment attestations, policy enforcement, flow `arc-pipeline`, 12 envs across 4 clouds                        |
| **GitLab (source of truth)**                                           | Primary CI, Issues, MR flow                                                                                                 |
| **GitHub Actions**                                                     | Full pipeline parity, OIDC to all clouds                                                                                    |
| **Azure DevOps**                                                       | Parity in progress                                                                                                          |
| **OpenShift (ROSA HCP)**                                               | Read-only CMDB + Builds + Routes + ImageStreams + ClusterOperators                                                          |
| **Tekton**                                                             | Multi-cluster PipelineRuns dashboard + live SSE + step-log streaming                                                        |
| **ArgoCD**                                                             | Multi-cluster GitOps with PreSync (Kosli assert + ServiceNow CR) and PostSync (Kosli report + DAST QA) hooks                |
| **Wiz / Snyk / SonarQube / GitGuardian / Trivy**                       | CVE + scan intake for portal risk dashboards                                                                                |
| **AWS Cost Explorer / Azure Cost Mgmt / GCP Cloud Billing / Kubecost** | Per-service cost + chargeback + cost-vuln correlation                                                                       |
| **Anthropic / Azure OpenAI / Bedrock / Vertex / on-prem**              | LLM provider for AskAi and natural-language search                                                                          |
| **AI Governance**                                                      | Kill-switch, model registry, eval results, NIST AI 600-1 + ISO 42001 risk register, Llama Guard 3 + Presidio guardrails     |
| **Agent recipes**                                                      | `vuln-suggest-fix` / `problem-investigate-fix` / `right-sizing-apply` dispatched to GitLab / GitHub / Azure DevOps          |
| **Microsoft 365 / Google Workspace**                                   | Change-window calendar sync                                                                                                 |
| **MCP server**                                                         | HTTP transport, per-tenant Portal Tokens, 12 read tools + 3 prompts                                                         |

## Tech stack

| Layer                    | Tooling                                                                                              |
| ------------------------ | ---------------------------------------------------------------------------------------------------- |
| **Portal**               | Next.js 15 (App Router), TypeScript, Prisma, NextAuth, Tailwind, shadcn/ui                           |
| **Data**                 | Postgres 16.4 (cloud-managed in prod, bitnami subchart in dev/k3d), Redis                            |
| **Infrastructure**       | Terraform + OpenTofu, Helm, Kustomize, ArgoCD, Tekton, ingress-nginx, cert-manager, external-secrets |
| **CI**                   | GitLab CI templates, GitHub Actions reusable workflows, Azure Pipelines                              |
| **Attestation + policy** | Kosli, OPA, cosign, Trivy, syft, grype                                                               |
| **Compliance**           | ServiceNow CR + Problems + CMDB (IRE API), SOC 2 evidence export                                     |
| **AI**                   | Multi-provider LLM, MCP server, Llama Guard 3, Microsoft Presidio, cross-encoder reranker            |
| **Dev environment**      | Nix flake (`nix develop` or `direnv allow`), `just` recipes, k3d, pre-commit hooks                   |

## Try it locally

```bash
git clone https://gitlab.com/compliance-calitii/sarc.git
cd sarc
cp .envrc.example .envrc
# edit .envrc: fill in tokens for any integrations you want to demo
direnv allow                          # loads tools + tokens

just demo-up-k3d                      # cluster + ingress + cert-manager
                                      # + podtato-head + karc-portal
                                      # ~10 min on first run

just podtato-url dev                  # http://podtato.karc.localtest.me:8080
just portal-url   dev                 # http://portal.karc.localtest.me:8080

just k3d-down                         # tear down when done
```

Requires Nix (with flakes enabled), [direnv](https://direnv.net/), and Docker.

## What this project is not

- **Not a microservices demo.** The microservices (podtato-head) are there as a realistic deployment target. The value is the compliance pipeline around them.
- **Not production-ready as a business app.** podtato-head is a CNCF cloud-native delivery reference app; the portal is an internal dashboard. Neither is intended to ship to end users.
- **Not single-cloud.** AWS was the predecessor (KARC) default. In ARC, no cloud is privileged — all four are first-class, and the pipeline produces the same evidence shape on every one.

## Links

- **Source (source of truth):** [gitlab.com/compliance-calitii/sarc](https://gitlab.com/compliance-calitii/sarc)
- **GitHub mirror:** [github.com/Freundcloud/SARC](https://github.com/Freundcloud/SARC)
- **License:** Apache-2.0

---

_Synechron ARC — the compliance pipeline platform that runs the same way on AWS, Azure, GCP, and a laptop._
