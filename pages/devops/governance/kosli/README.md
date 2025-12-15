---
description: Kosli automated DevOps change tracking and compliance platform for audit-ready deployment evidence and continuous compliance
keywords: kosli, change tracking, compliance, audit, devops, deployment evidence, software provenance, sbom
---

# Kosli - DevOps Change Tracking & Compliance

## Overview

Kosli is an automated change tracking and compliance platform that functions as a "flight data recorder" for your DevOps pipelines. It provides forensic-level tracking of what's deployed in production, how it got there, and whether it complies with your policies—all without manual documentation or approval gates that slow down deployments.

##

 What is Kosli?

Kosli connects real events from commit to production, ensuring you always know:
- **What's running**: Exact versions in each environment with cryptographic verification
- **How it got there**: Complete evidence chain (tests, scans, reviews, approvals)
- **If it's compliant**: Real-time policy verification without manual gates

Think of Kosli as a **black box recorder for software delivery**—it captures everything that happens to your code from the first commit to production deployment, creating an immutable audit trail that proves compliance automatically.

## Why Kosli?

### The DevOps Compliance Challenge

Modern DevOps teams face a fundamental conflict:

**Fast Deployment** ↔ **Compliance Requirements**

Traditional approach:
- Manual approval gates
- Documentation in spreadsheets/tickets
- Audit preparation takes weeks
- Slows deployments from hours to days

**Kosli's Solution**: Automated evidence collection that enables fast deployments with continuous compliance.

### Core Capabilities

#### 1. Automated Evidence Collection

Kosli automatically records evidence from your CI/CD pipelines:

```
┌──────────┐     ┌────────────┐     ┌─────────────┐     ┌────────────┐
│  Commit  │────→│ CI Pipeline │────→│ Kosli Trail │────→│ Production │
└──────────┘     └────────────┘     └─────────────┘     └────────────┘
                       │                    │
                       │             Record Evidence:
                       │             • Commit SHA
                       │             • Code reviews
                       │             • Test results
                       │             • Security scans
                       │             • Approvals
                       │             • SBOM
                       │
                       ▼
              Automatic Collection
              (No Manual Work)
```

#### 2. Deployment Tracking

Track what's running in each environment with cryptographic fingerprints:

- **Snapshot environments**: Kubernetes, Docker, ECS, Lambda
- **Verify deployments**: Ensure what you tested is what you deployed
- **Detect drift**: Alert on unexpected or undocumented changes
- **Historical tracking**: Query "what was running on date X?"

#### 3. Continuous Compliance

Replace manual approval gates with automated policy verification:

- **Define policies**: "All code must be reviewed, tested, and scanned"
- **Real-time verification**: Check compliance before deployment
- **No manual gates**: Teams deploy freely when compliant
- **Audit trails**: Comprehensive evidence for auditors

#### 4. Drift Detection

Get alerted when unauthorized changes occur:

- **Unexpected deployments**: Something deployed without going through CI/CD
- **Configuration drift**: Running workload doesn't match declared state
- **Missing evidence**: Deployment without required tests or scans
- **Version mismatch**: Production running different version than expected

## How Kosli Works

### 1. Report Artifacts

As you build software, report artifacts to Kosli:

```bash
# Report Docker image artifact
kosli report artifact myapp:v2.1.0 \
  --artifact-type docker \
  --flow microservices \
  --commit $GIT_COMMIT
```

Kosli creates a cryptographic fingerprint of the artifact, ensuring what you test is what you deploy.

### 2. Report Evidence

Report evidence that required processes occurred:

```bash
# Report test results
kosli report evidence test junit \
  --flow microservices \
  --name myapp:v2.1.0 \
  --results-file test-results.xml

# Report security scan
kosli report evidence generic \
  --flow microservices \
  --name myapp:v2.1.0 \
  --evidence-type security-scan \
  --attachments trivy-scan.json
```

Evidence is attached to the artifact fingerprint, creating an immutable trail.

### 3. Report Deployments

When you deploy, report to Kosli:

```bash
# Report deployment to production
kosli report deployment production \
  --flow microservices \
  --name myapp:v2.1.0 \
  --environment production
```

Kosli tracks when and where each artifact was deployed.

### 4. Snapshot Environments

Periodically snapshot what's actually running:

```bash
# Snapshot Kubernetes environment
kosli snapshot k8s production \
  --namespace production

# Kosli compares actual state vs. expected
# Alerts on any discrepancies
```

## Key Features

### Cryptographic Verification

Kosli uses cryptographic fingerprints (SHA256) to ensure:
- The artifact you tested is the artifact you deployed
- No tampering between build and deployment
- Exact version tracking across environments

### Immutable Audit Trails

All events recorded in Kosli are immutable:
- Cannot be edited or deleted
- Timestamped and signed
- Complete chain of evidence from commit to production
- Audit-ready compliance reports

### Policy as Code

Define deployment policies in code:

```yaml
# kosli-policy.yml
rules:
  - name: code-review-required
    type: pull-request
    required: true

  - name: tests-must-pass
    type: junit-test
    required: true
    min-success-rate: 100%

  - name: no-critical-vulnerabilities
    type: security-scan
    required: true
    max-severity: high
```

### Integration with Everything

Kosli integrates with your existing tools:

**CI/CD Platforms**:
- GitHub Actions
- GitLab CI
- Azure DevOps
- Jenkins
- CircleCI
- Bitbucket Pipelines

**Container Platforms**:
- Kubernetes
- Docker
- Amazon ECS
- AWS Lambda

**Tooling**:
- Slack (notifications)
- ServiceNow (change management)
- Jira (issue tracking)
- PagerDuty (incident management)

## Use Cases

### Use Case 1: SOC 2 Compliance for SaaS

**Scenario**: Fast-growing SaaS company needs SOC 2 certification

**Challenge**:
- Deploying 30-50 times per day
- No existing compliance documentation
- Auditors need proof of controls
- Can't slow down deployments

**Solution**:
```
1. Integrate Kosli into CI/CD pipelines
2. Automatically collect evidence (tests, scans, reviews)
3. Snapshot production daily
4. Generate compliance reports for auditors
```

**Results**:
- Passed SOC 2 audit on first attempt
- Zero manual documentation effort
- Maintained deployment velocity
- Comprehensive audit trails

### Use Case 2: Regulatory Compliance (Financial Services)

**Scenario**: Bank deploying to production 20+ times per day

**Challenge**:
- SOX compliance requires change documentation
- Manual change tickets create bottlenecks
- Auditors need proof of testing and approval
- Must detect unauthorized changes

**Solution**:
```
1. Kosli tracks all deployments automatically
2. Integrates with ServiceNow for change correlation
3. Provides evidence of testing, scanning, approval
4. Alerts on unexpected production changes
```

**Results**:
- Reduced deployment time by 60%
- 100% change documentation compliance
- Real-time drift detection
- Auditors access compliance reports on-demand

### Use Case 3: Multi-Team Platform

**Scenario**: 50+ development teams deploying to shared Kubernetes clusters

**Challenge**:
- Need to know what each team deployed and when
- Troubleshoot: "What changed before the incident?"
- Ensure security scans run for all deployments
- Detect rogue deployments

**Solution**:
```
1. All teams report deployments to Kosli
2. Kosli snapshots clusters every 15 minutes
3. Platform team gets alerts for non-compliant deployments
4. Incident postmortems reference Kosli timeline
```

**Results**:
- Complete visibility into all deployments
- Reduced MTTR by 40% (faster root cause analysis)
- Enforced security scanning across all teams
- Prevented 12+ unauthorized deployments

## Kosli vs. Traditional Approaches

| Aspect | Traditional | Kosli |
|--------|-------------|-------|
| **Evidence Collection** | Manual documentation | Automatic from CI/CD |
| **Approval Gates** | Manual approval delays | Continuous compliance |
| **Audit Preparation** | Weeks of work | On-demand reports |
| **Change Tracking** | ServiceNow tickets | Automatic deployment tracking |
| **Drift Detection** | Periodic manual checks | Real-time automated alerts |
| **Compliance Verification** | Pre-deployment gates | Continuous verification |
| **Deployment Speed** | Hours-to-days | Minutes (no gates) |
| **Developer Experience** | Frustrating delays | Transparent automation |

## Kosli Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipelines                           │
│                                                              │
│  ┌────────┐   ┌────────┐   ┌────────┐   ┌──────────┐      │
│  │ Build  │──→│ Test   │──→│  Scan  │──→│  Deploy  │      │
│  └───┬────┘   └───┬────┘   └───┬────┘   └────┬─────┘      │
│      │            │            │             │             │
│      │ Report     │ Report     │ Report      │ Report      │
│      │ Artifact   │ Evidence   │ Evidence    │ Deployment  │
│      │            │            │             │             │
└──────┼────────────┼────────────┼─────────────┼─────────────┘
       │            │            │             │
       ▼            ▼            ▼             ▼
┌──────────────────────────────────────────────────────────────┐
│                    Kosli Platform (SaaS)                      │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Artifact Registry                                       │ │
│  │  • Cryptographic fingerprints                           │ │
│  │  • Version tracking                                     │ │
│  │  • SBOM storage                                         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Evidence Store                                          │ │
│  │  • Test results                                          │ │
│  │  • Security scans                                        │ │
│  │  • Code reviews                                          │ │
│  │  • Approvals                                            │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Deployment Tracker                                      │ │
│  │  • Environment snapshots                                 │ │
│  │  • Deployment history                                    │ │
│  │  • Drift detection                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Compliance Engine                                       │ │
│  │  • Policy evaluation                                     │ │
│  │  • Audit trail generation                                │ │
│  │  • Compliance reports                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────┬───────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │    Runtime            │
                    │   Environments        │
                    │                       │
                    │  • Kubernetes         │
                    │  • Docker             │
                    │  • ECS                │
                    │  • Lambda             │
                    └───────────────────────┘
```

## Getting Started

Ready to implement automated change tracking and compliance?

1. [Getting Started Guide](getting-started.md) - Install Kosli CLI and configure your first flow
2. [GitHub Actions Integration](github-actions.md) - Integrate Kosli with GitHub Actions
3. [GitLab CI Integration](gitlab-ci.md) - Integrate Kosli with GitLab CI/CD
4. [Azure DevOps Integration](azure-devops.md) - Integrate Kosli with Azure Pipelines
5. [CLI Reference](cli-reference.md) - Complete Kosli CLI command reference
6. [Best Practices](best-practices.md) - Proven patterns for Kosli implementation

## Pricing and Plans

Kosli is a commercial SaaS platform with:
- **Free Trial**: 30 days, full features
- **Starter**: For small teams and startups
- **Professional**: For growing companies
- **Enterprise**: For large organizations with advanced requirements

Visit [kosli.com](https://www.kosli.com/) for current pricing.

## Additional Resources

- [Kosli Official Documentation](https://docs.kosli.com/)
- [Kosli CLI GitHub Repository](https://github.com/kosli-dev/cli)
- [Kosli Blog](https://www.kosli.com/blog/)
- [DevOps Governance Overview](../README.md)

## Next Steps

Choose your CI/CD platform to get started:
- [GitHub Actions →](github-actions.md)
- [GitLab CI →](gitlab-ci.md)
- [Azure DevOps →](azure-devops.md)

Or learn about [Kosli CLI commands →](cli-reference.md)
