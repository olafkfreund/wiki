# Docker Image Security

## Enterprise Docker Image Security Policy

**Container Image Lifecycle Management & Security Framework**

**Version 1.0**\
&#xNAN;_&#x4F;ctober 2025_

***

### Table of Contents

1. Executive Summary
2. Governance and Ownership Model
3. Base Image Creation and Management
4. Container Registry Management
5. Security Scanning and Vulnerability Management
6. License Compliance and Open Source Management
7. Image Lifecycle Management
8. Best Practices and Technical Standards
9. Implementation Guidance
10. Assessment and Continuous Improvement
11. Appendices

***

### 1. Executive Summary

Container security represents a critical component of modern infrastructure protection. Unlike traditional virtual machines, containers share the host kernel, making isolation boundaries more permeable and security concerns more nuanced. A compromised container image can serve as a persistent attack vector, embedded with malicious code that propagates across development, staging, and production environments.

This policy establishes enterprise-wide standards for container image security, addressing the full lifecycle from base image selection through runtime deployment. The policy recognizes that container security is not a point-in-time assessment but rather a continuous process requiring automated tooling, clear ownership, and regular updates.

#### Purpose and Scope

This policy applies to all container images used within the organization, regardless of deployment target (Kubernetes, Docker Swarm, ECS, Cloud Run, etc.). It covers:

* Base operating system images maintained centrally
* Language runtime images (Python, Node.js, Java, Go, etc.)
* Application-specific images built by development teams
* Third-party images imported from external registries
* Utility and tooling images used in CI/CD pipelines

The policy does not cover virtual machine images, serverless function packages (Lambda, Cloud Functions), or legacy application deployment methods.

#### Key Objectives

**Reduce Attack Surface**: Minimize the number of packages, libraries, and services included in container images. Each additional component represents a potential vulnerability. Our baseline Ubuntu image contains 88 packages versus 280 in the standard ubuntu:latest image.

**Establish Clear Accountability**: Define unambiguous ownership for each layer of the container image stack. When CVE-2024-12345 is discovered in OpenSSL, there should be no question about who is responsible for patching base images versus application dependencies.

**Enable Rapid Response**: Security vulnerabilities can be announced at any time. Our infrastructure must support building, testing, and deploying patched images within hours, not days or weeks.

**Maintain Compliance**: Track all software components, licenses, and versions to meet regulatory requirements (SOC 2, ISO 27001, GDPR) and avoid legal exposure from license violations.

**Support Developer Velocity**: Security should not become a bottleneck. Automated scanning, clear base images, and self-service tools enable developers to build securely without waiting for security team approvals.

***

### 2. Governance and Ownership Model

#### 2.1 Organizational Structure

The traditional "throw it over the wall" model fails for container security. Development teams cannot rely solely on a central security team, and security teams cannot review every application deployment. Instead, we implement a shared responsibility model with clear boundaries.

**2.1.1 Platform Engineering Team**

**Primary Responsibilities:**

**Base Image Curation and Maintenance**\
Platform Engineering owns the "golden images" that serve as the foundation for all application containers. This includes:

* Selecting upstream base images from trusted sources
* Applying security hardening configurations
* Removing unnecessary packages and services
* Installing common tooling and certificates
* Configuring non-root users and proper file permissions
* Maintaining multiple versions to support different application needs

Example base image inventory:

```
registry.company.com/base/ubuntu:22.04-20250115
registry.company.com/base/alpine:3.19-20250115
registry.company.com/base/distroless-static:20250115
registry.company.com/base/python:3.11-slim-20250115
registry.company.com/base/node:20-alpine-20250115
registry.company.com/base/openjdk:21-jre-20250115
```

**Security Baseline Definition**\
Platform Engineering defines what "secure by default" means for the organization. This includes technical controls like:

* Mandatory non-root execution (UID >= 10000)
* Read-only root filesystem where feasible
* Dropped capabilities (NET\_RAW, SYS\_ADMIN, etc.)
* No setuid/setgid binaries
* Minimal installed packages (documented exceptions only)
* Security-focused default configurations

**Vulnerability Response for Base Layers**\
When vulnerabilities affect base OS packages or language runtimes, Platform Engineering owns the response:

1. Assess impact and exploitability
2. Build patched base images
3. Test for breaking changes
4. Publish updated images with clear release notes
5. Notify consuming teams
6. Track adoption and follow up on stragglers

**Registry Operations**\
Platform Engineering manages the container registry infrastructure:

* High availability configuration
* Backup and disaster recovery
* Access control and authentication
* Image replication across regions
* Storage optimization and garbage collection
* Audit logging and compliance reporting

**2.1.2 Application Development Teams**

**Primary Responsibilities:**

**Application Layer Security**\
Development teams own everything they add on top of base images:

* Application source code and binaries
* Application dependencies (npm packages, pip packages, Maven artifacts, Go modules)
* Application configuration files
* Secrets management (though secrets should never be in images)
* Custom scripts and utilities
* Application-specific system configurations

**Dependency Management**\
Teams must actively maintain their dependency trees:

```dockerfile
# ❌ BAD - Unpinned versions create reproducibility issues
FROM registry.company.com/base/python:3.11-slim-20250115
COPY requirements.txt .
RUN pip install -r requirements.txt

# requirements.txt
flask
requests
sqlalchemy
```

```dockerfile
# ✅ GOOD - Pinned versions with hash verification
FROM registry.company.com/base/python:3.11-slim-20250115@sha256:abc123...
COPY requirements.txt .
RUN pip install --require-hashes -r requirements.txt

# requirements.txt
flask==3.0.0 \
    --hash=sha256:abc123...
requests==2.31.0 \
    --hash=sha256:def456...
sqlalchemy==2.0.23 \
    --hash=sha256:ghi789...
```

**Vulnerability Remediation**\
When scans identify vulnerabilities in application dependencies:

1. Assess whether the vulnerability affects the application (not all CVEs are exploitable in every context)
2. Update the vulnerable dependency to a patched version
3. Test the application thoroughly (breaking changes may have been introduced)
4. Rebuild and redeploy the image
5. Document the remediation in the ticket system

**Image Rebuilds**\
When Platform Engineering releases updated base images, development teams must:

1. Update the FROM line in Dockerfiles
2. Rebuild application images
3. Run integration tests
4. Deploy updated images through standard deployment pipelines

This typically happens monthly for routine updates and within days for critical security patches.

**2.1.3 Security Team**

**Primary Responsibilities:**

**Policy Definition and Enforcement**\
The Security team defines the security requirements that Platform Engineering and Development teams must implement. This includes:

* Vulnerability severity thresholds (no critical CVEs in production)
* Allowed base image sources (Docker Hub verified publishers, Red Hat, etc.)
* Prohibited packages and configurations (telnet, FTP, debug symbols in production)
* Scanning frequency and tool requirements
* Exception process and approval workflow

**Security Assessment and Validation**\
The Security team validates that policies are effective:

* Penetration testing of container images and runtime environments
* Security architecture reviews of container platforms
* Audit of base image hardening configurations
* Review of scanning tool configurations and coverage
* Analysis of vulnerability trends and response times

**Threat Intelligence Integration**\
Security maintains awareness of the threat landscape:

* Monitoring security mailing lists and CVE databases
* Analyzing proof-of-concept exploits for applicability
* Coordinating disclosure of internally-discovered vulnerabilities
* Providing context on vulnerability severity and exploitability

**Incident Response**\
When security incidents involve containers:

* Leading forensic analysis of compromised containers
* Coordinating response across Platform Engineering and Development teams
* Identifying root causes and recommending preventive measures
* Documenting incidents for lessons learned

#### 2.2 Shared Responsibility Model

Container images are composed of layers, each with different ownership and security obligations.

**Layer-by-Layer Breakdown**

**Base OS Layer (Platform Engineering Responsibility)**

This layer includes the operating system packages and core utilities. For an Ubuntu-based image, this includes:

* libc6, libssl3, libcrypto, and other core libraries
* bash, sh, coreutils
* Package managers (apt, dpkg)
* System configuration files in /etc

When a vulnerability like CVE-2024-XXXXX affects libssl3, Platform Engineering must:

1. Monitor for the updated package from Ubuntu
2. Build a new base image with the patched package
3. Test that existing applications remain functional
4. Release the updated base image
5. Notify teams to rebuild

**Runtime Layer (Platform Engineering Responsibility)**

Language runtimes and frameworks maintained by Platform Engineering:

* Python interpreter and standard library
* Node.js runtime and built-in modules
* OpenJDK JVM and class libraries
* Go runtime
* System-level dependencies these runtimes need

Example: When a vulnerability is discovered in the Node.js HTTP parser, Platform Engineering updates the Node.js base images across all maintained versions (Node 18, 20, 22) and publishes new images.

**Application Dependencies (Development Team Responsibility)**

Third-party libraries and packages installed by application teams:

* npm packages (express, lodash, axios)
* Python packages (django, flask, requests)
* Java dependencies (spring-boot, hibernate, jackson)
* Go modules (gin, gorm)

Example: When CVE-2024-YYYYY is discovered in the `lodash` npm package, the development team must:

1. Update package.json to specify a patched version
2. Run `npm audit` to verify the fix
3. Test the application with the updated dependency
4. Rebuild and redeploy the image

**Application Code (Development Team Responsibility)**

Custom code written by the organization:

* Application logic and business rules
* API endpoints and handlers
* Database queries and data access
* Authentication and authorization code
* Configuration management

Security concerns include:

* Injection vulnerabilities (SQL, command, XSS)
* Broken authentication and session management
* Sensitive data exposure
* Security misconfigurations
* Insecure deserialization

**Boundary Cases and Escalation**

Some security issues span multiple layers and require coordination:

**Example 1: Upstream Package Delayed**\
A critical vulnerability is discovered in Python 3.11.7, but the patch won't be released by the Python maintainers for several days. Platform Engineering must decide:

* Wait for the official patch (safest but slower)
* Backport the patch manually (faster but requires expertise)
* Switch to an alternative Python distribution (complex migration)

This decision requires input from Security (risk assessment) and Development teams (impact assessment).

**Example 2: Vulnerability in Shared Dependency**\
OpenSSL is used by both the base OS and application dependencies. A vulnerability is discovered that affects specific usage patterns. Platform Engineering patches the OS-level OpenSSL, but some applications have bundled OpenSSL statically. Coordination is needed to identify and remediate all instances.

**Example 3: Zero-Day Exploitation**\
An actively exploited zero-day vulnerability is discovered in a widely-used package. Security team must:

1. Immediately assess blast radius (which images and deployments affected)
2. Coordinate emergency patching or mitigation
3. Potentially take affected services offline temporarily
4. Fast-track patches through testing and deployment

***

### 3. Base Image Creation and Management

#### 3.1 Base Image Selection Criteria

Selecting the right base image is the most important security decision in the container image lifecycle. A poor choice creates technical debt that compounds over time.

**3.1.1 Approved Base Image Sources**

**Official Docker Hub Images (Verified Publishers)**

Docker Hub's verified publisher program provides some assurance of image authenticity and maintenance. However, not all official images meet enterprise security standards.

Approved:

* `ubuntu:22.04` - Widely used, well-documented, extensive package ecosystem
* `alpine:3.19` - Minimal attack surface, small size, but uses musl libc (compatibility concerns)
* `python:3.11-slim` - Official Python builds with minimal OS layers
* `node:20-alpine` - Official Node.js on Alpine base
* `postgres:16-alpine` - Official PostgreSQL builds

Prohibited:

* `ubuntu:latest` - Unpredictable, changes without warning, breaks reproducibility
* `debian:unstable` - Unstable by definition, not suitable for production
* Any image without a verified publisher badge

**Red Hat Universal Base Images (UBI)**

Red Hat provides UBI images that are freely redistributable and receive enterprise-grade security support:

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.3

# UBI-minimal includes microdnf package manager but minimal packages
# Ideal for applications that need a few extra system packages
RUN microdnf install -y shadow-utils && microdnf clean all

# Create non-root user
RUN useradd -r -u 1001 -g root appuser
USER 1001
```

Benefits:

* Predictable release cycle aligned with RHEL
* Security errata published promptly
* Compliance with enterprise Linux standards
* Support available through Red Hat

Drawbacks:

* Larger image size than Alpine
* Fewer packages available than Debian/Ubuntu
* Requires Red Hat-compatible tooling

**Google Distroless Images**

Distroless images contain only the application and runtime dependencies, removing package managers, shells, and system utilities:

```dockerfile
# Multi-stage build required for distroless
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o myapp

# Distroless has no shell, package manager, or utilities
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/myapp /myapp
ENTRYPOINT ["/myapp"]
```

Benefits:

* Minimal attack surface (no shell for attackers to use)
* Smallest possible image size
* Reduced vulnerability count
* Forces proper multi-stage builds

Drawbacks:

* Debugging requires external tools (ephemeral containers, kubectl debug)
* Cannot install packages in running containers
* Limited to statically-linked binaries or specific language runtimes
* Steeper learning curve for developers

**Chainguard Images**

Chainguard provides hardened, minimal images with strong supply chain security:

```dockerfile
FROM cgr.dev/chainguard/python:latest-dev AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM cgr.dev/chainguard/python:latest
COPY --from=builder /root/.local /home/nonroot/.local
COPY app.py /app/
WORKDIR /app
ENV PATH=/home/nonroot/.local/bin:$PATH
CMD ["python", "app.py"]
```

Benefits:

* Updated daily with latest patches
* Minimal CVE count
* SBOM provided for every image
* Signed with Sigstore for verification

Drawbacks:

* Requires account for private registry access
* Less community documentation than official images
* Breaking changes possible with frequent updates

**3.1.2 Selection Evaluation Criteria**

**Security Posture Assessment**

Before approving a base image, Platform Engineering must evaluate:

1. **Current Vulnerability Count**: Use multiple scanners to establish baseline

```bash
# Scan with Trivy
trivy image --severity HIGH,CRITICAL ubuntu:22.04

# Scan with Grype for comparison
grype ubuntu:22.04 -o json | jq '.matches | length'

# Check for known malware
trivy image --scanners vuln,secret,misconfig ubuntu:22.04
```

2. **Update Frequency**: Review the image's update history

```bash
# Check Docker Hub API for update history
curl -s "https://hub.docker.com/v2/repositories/library/ubuntu/tags/22.04" | \
  jq '.last_updated'

# Look for regular updates (at least monthly)
# Gaps of 3+ months indicate poor maintenance
```

3. **Security Response Time**: Research how quickly security issues are addressed

* Review CVE databases for past vulnerabilities
* Check mailing lists for security announcements
* Examine GitHub issues for security-related bugs
* Validate that security fixes are backported to older versions

4. **Provenance and Supply Chain**: Verify image authenticity

```bash
# Verify image signatures (Docker Content Trust)
export DOCKER_CONTENT_TRUST=1
docker pull ubuntu:22.04

# Verify Sigstore signatures for Chainguard images
cosign verify cgr.dev/chainguard/python:latest \
  --certificate-identity-regexp='.*' \
  --certificate-oidc-issuer-regexp='.*'

# Download and inspect SBOM
cosign download sbom cgr.dev/chainguard/python:latest | jq
```

**Maintenance Commitment Analysis**

Evaluate the long-term viability of the base image:

1. **Support Lifecycle**: Understand the support timeline

* Ubuntu LTS: 5 years standard support, 10 years with ESM
* Debian: \~5 years per major release
* Alpine: \~2 years per minor release
* RHEL/UBI: 10 years full support

2. **Vendor Commitment**: Assess the organization behind the image

* Is there a commercial entity providing support?
* Is the project community-driven (risk of maintainer burnout)?
* Are security updates contractually guaranteed?

3. **Deprecation Policy**: Understand end-of-life procedures

```yaml
# Example deprecation policy from base image documentation
versions:
  "22.04":
    status: active
    support_until: "2027-04"
    eol_date: "2032-04"
  "20.04":
    status: maintenance
    support_until: "2025-04"
    eol_date: "2030-04"
  "18.04":
    status: deprecated
    support_until: "2023-04"
    eol_date: "2028-04"
```

**Size and Efficiency Evaluation**

Image size affects:

* Storage costs in registries
* Network transfer time during deployment
* Pod startup time in Kubernetes
* Cache efficiency in CI/CD pipelines

Compare alternatives:

```bash
# Get image sizes
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep python

# Results:
python:3.11               1.02GB  # Full Debian-based image
python:3.11-slim          197MB   # Slim variant without dev tools
python:3.11-alpine        57.4MB  # Alpine-based (musl libc)
cgr.dev/chainguard/python 42.1MB  # Chainguard minimal
```

Analyze layer composition:

```bash
# Dive into image layers
dive python:3.11-slim

# Use docker history to see layer sizes
docker history python:3.11-slim --human --no-trunc
```

**License Compliance Review**

Ensure all components use acceptable licenses:

```bash
# Generate SBOM and extract licenses
syft python:3.11-slim -o json | \
  jq -r '.artifacts[].licenses[] | .value' | \
  sort -u

# Common licenses in base images:
# - GPL-2.0 (Linux kernel, some utilities)
# - LGPL-2.1 (glibc)
# - MIT (many utilities)
# - Apache-2.0 (various components)
# - BSD-3-Clause (various components)
```

Flag problematic licenses:

* AGPL (requires source disclosure for network services)
* GPL-3.0 with certain interpretations (patent retaliation clauses)
* Proprietary licenses requiring explicit approval
* Commons Clause and similar source-available licenses

#### 3.2 Image Hardening Standards

**3.2.1 Non-Root User Configuration**

Containers should never run as root (UID 0). This limits the impact of container escapes and follows the principle of least privilege.

**Implementation Pattern:**

```dockerfile
FROM ubuntu:22.04

# Install packages as root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user with specific UID
# Use UID >= 10000 to avoid conflicts with host users
RUN groupadd -r appgroup -g 10001 && \
    useradd -r -u 10001 -g appgroup -d /app -s /sbin/nologin \
    -c "Application user" appuser

# Create app directory with appropriate permissions
RUN mkdir -p /app && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser
WORKDIR /app

# Subsequent commands run as appuser
COPY --chown=appuser:appgroup requirements.txt .
RUN pip3 install --user -r requirements.txt

COPY --chown=appuser:appgroup . .

CMD ["python3", "app.py"]
```

**Validation:**

```bash
# Check that container runs as non-root
docker run --rm myapp id
# Output: uid=10001(appuser) gid=10001(appgroup) groups=10001(appgroup)

# Verify in Kubernetes
kubectl run test --image=myapp --rm -it -- id

# Enforce non-root in Kubernetes Pod Security
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    fsGroup: 10001
  containers:
  - name: app
    image: myapp
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
          - ALL
```

**3.2.2 Minimal Package Set**

Every package in an image is a potential vulnerability. Remove everything not strictly required.

**Analysis Technique:**

```dockerfile
# Start with a full image
FROM ubuntu:22.04 AS full

# Install typical development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    python3 \
    python3-pip

# Analyze what's actually needed
FROM ubuntu:22.04 AS minimal

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Compare sizes
# full: 850MB
# minimal: 180MB
```

**Package Audit Process:**

```bash
# List all installed packages
dpkg -l | grep ^ii

# For each package, assess necessity:
# 1. Does the application import/use it directly?
# 2. Is it a transitive dependency of required packages?
# 3. Is it a build-time only dependency?

# Remove build dependencies after use
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc-dev && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc libc-dev && \
    rm -rf /var/lib/apt/lists/*
```

**Prohibited Packages:**

Never include in production images:

* Shells beyond `/bin/sh` (bash, zsh, fish)
* Text editors (vim, nano, emacs)
* Network utilities (telnet, ftp, netcat)
* Debuggers (gdb, strace, ltrace)
* Compilers (gcc, clang unless required at runtime)
* Version control (git, svn)
* Package manager databases (can be removed post-install)

Example hardened Dockerfile:

```dockerfile
FROM ubuntu:22.04 AS builder

# Build stage can include development tools
RUN apt-get update && \
    apt-get install -y build-essential python3-pip

COPY requirements.txt .
RUN pip3 install --prefix=/install --no-cache-dir -r requirements.txt

FROM ubuntu:22.04

# Runtime stage has minimal packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    # Remove unnecessary packages
    apt-get purge -y --auto-remove && \
    # Remove setuid/setgid binaries (security risk)
    find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY --from=builder /install /usr/local

RUN groupadd -r appuser -g 10001 && \
    useradd -r -u 10001 -g appuser appuser

USER appuser
WORKDIR /app
COPY --chown=appuser:appuser app.py .

CMD ["python3", "app.py"]
```

**3.2.3 Read-Only Root Filesystem**

Making the root filesystem read-only prevents attackers from modifying system files or installing persistence mechanisms.

**Implementation:**

```dockerfile
FROM alpine:3.19

# Install packages during build (when filesystem is writable)
RUN apk add --no-cache python3 py3-pip

# Create necessary writable directories
RUN mkdir -p /app/tmp /app/cache && \
    adduser -D -u 10001 appuser && \
    chown -R appuser:appuser /app

USER appuser
WORKDIR /app

# Application needs writable directories for:
# - Temporary files
# - Cache
# - Logs (or write to stdout/stderr)

COPY --chown=appuser:appuser . .

CMD ["python3", "app.py"]
```

**Kubernetes Deployment:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        fsGroup: 10001
      containers:
      - name: app
        image: myapp
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop:
              - ALL
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
```

**Testing:**

```bash
# Verify read-only filesystem
docker run --rm --read-only myapp sh -c "touch /test"
# Should fail: touch: cannot touch '/test': Read-only file system

# Verify writable volumes work
docker run --rm --read-only -v /tmp:/tmp myapp sh -c "touch /tmp/test && ls /tmp/test"
# Should succeed
```

**3.2.4 Capability Dropping**

Linux capabilities allow fine-grained control over privileges. Drop all capabilities and add back only what's needed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp
    securityContext:
      capabilities:
        # Drop all capabilities
        drop:
          - ALL
        # Add back only required capabilities
        add:
          - NET_BIND_SERVICE  # Only if binding to port < 1024
```

Common capabilities to always drop:

* `CAP_SYS_ADMIN` - Mount filesystems, load kernel modules
* `CAP_NET_RAW` - Create raw sockets (ping, traceroute)
* `CAP_SYS_PTRACE` - Debug processes
* `CAP_SYS_MODULE` - Load kernel modules
* `CAP_DAC_OVERRIDE` - Bypass file permissions
* `CAP_CHOWN` - Change file ownership
* `CAP_SETUID`/`CAP_SETGID` - Change process UID/GID

**Verification:**

```bash
# Check capabilities of running container
docker run --rm --cap-drop=ALL myapp sh -c "capsh --print"

# Test that capabilities are properly restricted
docker run --rm --cap-drop=ALL myapp ping google.com
# Should fail: ping: socket: Operation not permitted
```

**3.2.5 Security Metadata and Labels**

Embed security-relevant metadata in images for automated policy enforcement and audit:

```dockerfile
FROM ubuntu:22.04

LABEL maintainer="platform-team@company.com" \
      org.opencontainers.image.vendor="Company Inc" \
      org.opencontainers.image.title="Python Base Image" \
      org.opencontainers.image.description="Hardened Python 3.11 base image" \
      org.opencontainers.image.version="3.11.7-20250115" \
      org.opencontainers.image.created="2025-01-15T10:30:00Z" \
      org.opencontainers.image.source="https://github.com/company/base-images" \
      org.opencontainers.image.documentation="https://docs.company.com/base-images/python" \
      security.scan-date="2025-01-15" \
      security.scan-tool="trivy" \
      security.scan-version="0.48.0" \
      security.vulnerability-count.critical="0" \
      security.vulnerability-count.high="0" \
      security.vulnerability-count.medium="2" \
      security.approved="true" \
      security.approval-date="2025-01-15" \
      security.approver="security-team@company.com"

# ... rest of Dockerfile
```

Query labels programmatically:

```bash
# Check if image is approved
docker inspect myimage | jq -r '.[0].Config.Labels["security.approved"]'

# Enforce in admission controller
if [[ $(docker inspect $IMAGE | jq -r '.[0].Config.Labels["security.approved"]') != "true" ]]; then
  echo "Image not approved for production"
  exit 1
fi
```

#### 3.3 Image Build Process

**3.3.1 Reproducible Builds**

Builds must be reproducible: given the same inputs, produce bit-for-bit identical outputs. This enables verification and prevents supply chain attacks.

**Techniques for Reproducibility:**

```dockerfile
# Pin everything
FROM ubuntu:22.04@sha256:ac58ff7fe7fba2a0d9193c6a5d3c1f0aef871b3f5c9b5c2e0e8d7f8a0b1c2d3e

# Pin package versions
RUN apt-get update && \
    apt-get install -y \
        python3=3.10.6-1~22.04 \
        python3-pip=22.0.2+dfsg-1ubuntu0.4 && \
    rm -rf /var/lib/apt/lists/*

# Pin Python packages with hashes
COPY requirements.txt .
RUN pip install --require-hashes --no-deps -r requirements.txt

# Set fixed timestamps
ENV SOURCE_DATE_EPOCH=1704067200
```

**Verification:**

```bash
# Build image twice
docker build -t test:build1 .
docker build -t test:build2 .

# Compare digests
docker inspect test:build1 | jq -r '.[0].Id'
docker inspect test:build2 | jq -r '.[0].Id'
# Should be identical
```

**3.3.2 Multi-Stage Builds**

Use multi-stage builds to separate build dependencies from runtime dependencies:

```dockerfile
# Stage 1: Build
FROM golang:1.21 AS builder

WORKDIR /src

# Copy go mod files first (better caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a \
    -ldflags '-s -w -extldflags "-static"' \
    -o /app/server .

# Stage 2: Runtime
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /app/server /server

ENTRYPOINT ["/server"]
```

Benefits:

* Build stage can include compilers, dev tools (500MB+)
* Runtime stage contains only the binary (5-10MB)
* Smaller attack surface (no build tools in production)
* Faster deployment (smaller images to transfer)

**Advanced Multi-Stage Pattern:**

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Runtime
FROM node:20-alpine AS runtime
WORKDIR /app

# Copy production dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
# Copy built application from builder stage
COPY --from=builder /app/dist ./dist
COPY package.json ./

RUN adduser -D -u 10001 nodeuser && \
    chown -R nodeuser:nodeuser /app

USER nodeuser

CMD ["node", "dist/server.js"]
```

**3.3.3 Build Caching Strategy**

Optimize Docker layer caching to speed up builds:

```dockerfile
# ❌ Poor caching - any code change invalidates all layers
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["node", "dist/server.js"]

# ✅ Good caching - dependencies cached separately
FROM node:20-alpine
WORKDIR /app

# Dependencies rarely change - cache this layer
COPY package*.json ./
RUN npm ci

# Code changes don't invalidate dependency layer
COPY . .
RUN npm run build

CMD ["node", "dist/server.js"]
```

**BuildKit Advanced Caching:**

```dockerfile
# syntax=docker/dockerfile:1.4

FROM python:3.11-slim

WORKDIR /app

# Use BuildKit cache mounts
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip

# Cache dependency downloads
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

Build with BuildKit:

```bash
DOCKER_BUILDKIT=1 docker build -t myapp .
```

**3.3.4 SBOM Generation During Build**

Generate Software Bill of Materials as part of the build process:

```dockerfile
FROM python:3.11-slim AS base

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Generate SBOM in separate stage
FROM base AS sbom-generator
RUN pip install cyclonedx-bom
RUN cyclonedx-py requirements.txt -o /sbom.json

# Final stage
FROM base
COPY --from=sbom-generator /sbom.json /app/sbom.json

CMD ["python", "app.py"]
```

Or generate during CI/CD:

```bash
#!/bin/bash
# build-and-scan.sh

# Build image
docker build -t myapp:$VERSION .

# Generate SBOM
syft myapp:$VERSION -o spdx-json=/tmp/sbom.spdx.json

# Upload SBOM to registry as attachment
cosign attach sbom --sbom /tmp/sbom.spdx.json myapp:$VERSION

# Sign the image
cosign sign myapp:$VERSION

# Scan for vulnerabilities
grype myapp:$VERSION
```

***

### 4. Container Registry Management

#### 4.1 Registry Architecture

A production-grade container registry requires more than just image storage. It needs security controls, high availability, and integration with scanning tools.

**4.1.1 Registry Selection Criteria**

**Harbor (Recommended for On-Premise)**

Harbor is an open-source registry with enterprise features:

```yaml
# harbor.yml configuration
hostname: registry.company.com

https:
  port: 443
  certificate: /data/cert/server.crt
  private_key: /data/cert/server.key

# External PostgreSQL for HA
database:
  type: external
  external:
    host: postgres.company.com
    port: 5432
    db_name: registry
    username: harbor
    password: ${DB_PASSWORD}
    sslmode: require

# External Redis for caching and job queue
redis:
  type: external
  external:
    addr: redis.company.com:6379
    password: ${REDIS_PASSWORD}
    db_index: 0

# Integrated vulnerability scanning
trivy:
  github_token: ${GITHUB_TOKEN}
  skip_update: false

# Replication for DR
replication:
  - name: dr-datacenter
    url: https://registry-dr.company.com
    insecure: false
    credential:
      type: basic
      username: admin
      password: ${REPLICATION_PASSWORD}
```

Features we leverage:

* Role-based access control with LDAP/OIDC integration
* Integrated Trivy scanning
* Content signing with Notary
* Image replication for disaster recovery
* Webhook notifications for CI/CD integration
* Retention policies for storage management
* Audit logging of all operations

**AWS ECR (Recommended for AWS Deployments)**

For AWS-native deployments, ECR provides tight integration:

```bash
# Enable scanning on push
aws ecr put-image-scanning-configuration \
    --repository-name myapp \
    --image-scanning-configuration scanOnPush=true

# Enable encryption
aws ecr put-encryption-configuration \
    --repository-name myapp \
    --encryption-type KMS \
    --kms-key arn:aws:kms:us-east-1:123456789:key/abc-123

# Set lifecycle policy to clean old images
aws ecr put-lifecycle-policy \
    --repository-name myapp \
    --lifecycle-policy-text file://policy.json
```

Lifecycle policy example:

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 production images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod"],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Expire untagged images after 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

**4.1.2 Registry Organization and Naming**

**Repository Structure:**

```
registry.company.com/
├── base/
│   ├── ubuntu:22.04-20250115
│   ├── alpine:3.19-20250115
│   ├── python:3.11-slim-20250115
│   └── node:20-alpine-20250115
├── apps/
│   ├── api-gateway:1.2.3
│   ├── user-service:2.0.1
│   ├── payment-processor:1.8.5
│   └── notification-worker:3.1.0
├── tools/
│   ├── ci-builder:latest
│   ├── security-scanner:1.0.0
│   └── deployment-helper:2.1.0
└── sandbox/
    ├── experimental-ai:alpha
    └── prototype-feature:dev
```

**Naming Conventions:**

```
registry.company.com/[namespace]/[image-name]:[tag]

namespace: base, apps, tools, sandbox
image-name: lowercase-with-hyphens
tag: version or environment-version

Examples:
registry.company.com/base/python:3.11-20250115
registry.company.com/apps/user-service:2.0.1
registry.company.com/apps/user-service:staging-2.0.1-rc3
registry.company.com/tools/ci-builder:1.0.0
```

**Tag Strategy:**

```bash
# Production images use semantic version
docker tag myapp:latest registry.company.com/apps/myapp:1.2.3
docker tag myapp:latest registry.company.com/apps/myapp:1.2
docker tag myapp:latest registry.company.com/apps/myapp:1

# Pre-production images include environment
docker tag myapp:latest registry.company.com/apps/myapp:staging-1.2.3
docker tag myapp:latest registry.company.com/apps/myapp:dev-1.2.3-rc1

# Always tag with git commit SHA for traceability
docker tag myapp:latest registry.company.com/apps/myapp:sha-a1b2c3d

# Critical: Always reference by digest in production
docker pull registry.company.com/apps/myapp@sha256:abc123...
```

#### 4.2 Access Control and Authentication

**4.2.1 RBAC Configuration**

**Harbor Project-Level Permissions:**

```yaml
# Project: base-images
members:
  - username: platform-team
    role: project-admin
  - username: security-team
    role: developer  # Can push/pull, cannot delete
  - ldap-group: all-developers
    role: guest  # Pull only

# Project: applications
members:
  - ldap-group: team-payments
    role: developer  # Can push their own apps
    allowed_repos:
      - payment-.*  # Regex matching
  - ldap-group: team-users
    role: developer
    allowed_repos:
      - user-.*

# Production registry (pull-only for deployments)
members:
  - service-account: kubernetes-production
    role: guest
  - service-account: ci-cd-pipeline
    role: developer  # Push to non-prod only
```

**Kubernetes Service Account:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: image-puller
  namespace: production
---
apiVersion: v1
kind: Secret
metadata:
  name: registry-credentials
  namespace: production
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-credentials>
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  serviceAccountName: image-puller
  imagePullSecrets:
  - name: registry-credentials
  containers:
  - name: app
    image: registry.company.com/apps/myapp:1.2.3
```

**4.2.2 Automated Credential Rotation**

```bash
#!/bin/bash
# rotate-registry-credentials.sh

# Generate new credentials
NEW_PASSWORD=$(openssl rand -base64 32)

# Update in Harbor
harbor-cli user update robot-account-prod \
  --password "$NEW_PASSWORD"

# Update in all Kubernetes clusters
for CLUSTER in prod-us-east prod-eu-west prod-asia; do
  kubectl --context=$CLUSTER \
    create secret docker-registry registry-credentials \
    --docker-server=registry.company.com \
    --docker-username=robot-account-prod \
    --docker-password="$NEW_PASSWORD" \
    --dry-run=client -o yaml | \
    kubectl --context=$CLUSTER apply -f -
done

# Update in CI/CD
# ... update credentials in Jenkins/GitLab/GitHub Actions
```

#### 4.3 Image Promotion Workflow

**4.3.1 Automated Quality Gates**

```yaml
# .gitlab-ci.yml
stages:
  - build
  - scan
  - test
  - promote-staging
  - promote-production

variables:
  IMAGE_NAME: registry.company.com/apps/myapp
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA

build:
  stage: build
  script:
    - docker build -t $IMAGE_NAME:dev-$IMAGE_TAG .
    - docker push $IMAGE_NAME:dev-$IMAGE_TAG
    # Generate SBOM
    - syft $IMAGE_NAME:dev-$IMAGE_TAG -o spdx-json=sbom.json
    - cosign attach sbom --sbom sbom.json $IMAGE_NAME:dev-$IMAGE_TAG
    # Sign image
    - cosign sign $IMAGE_NAME:dev-$IMAGE_TAG
  artifacts:
    paths:
      - sbom.json

security-scan:
  stage: scan
  script:
    # Vulnerability scan
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE_NAME:dev-$IMAGE_TAG
    # License scan
    - syft $IMAGE_NAME:dev-$IMAGE_TAG -o json | \
      jq -r '.artifacts[].licenses[] | select(.value | contains("GPL"))' | \
      grep -q . && echo "GPL license found" && exit 1 || true
    # Secret scan
    - trivy image --scanners secret $IMAGE_NAME:dev-$IMAGE_TAG
    # Malware scan (if applicable)
    - trivy image --scanners vuln,secret,misconfig $IMAGE_NAME:dev-$IMAGE_TAG

integration-tests:
  stage: test
  script:
    - docker run -d --name test-container $IMAGE_NAME:dev-$IMAGE_TAG
    - ./run-integration-tests.sh
    - docker logs test-container
    - docker stop test-container

promote-to-staging:
  stage: promote-staging
  when: manual
  script:
    # Re-tag for staging
    - crane tag $IMAGE_NAME:dev-$IMAGE_TAG staging-$IMAGE_TAG
    # Deploy to staging environment
    - kubectl --context=staging set image deployment/myapp \
        app=$IMAGE_NAME:staging-$IMAGE_TAG

staging-smoke-tests:
  stage: promote-staging
  needs: [promote-to-staging]
  script:
    - ./smoke-tests.sh https://staging.company.com

promote-to-production:
  stage: promote-production
  when: manual
  only:
    - main
  script:
    # Verify image hasn't changed since staging
    - crane digest $IMAGE_NAME:staging-$IMAGE_TAG
    # Re-tag for production with semantic version
    - crane tag $IMAGE_NAME:staging-$IMAGE_TAG $VERSION
    - crane tag $IMAGE_NAME:staging-$IMAGE_TAG prod-$VERSION
    # Create immutable reference
    - echo "Production digest: $(crane digest $IMAGE_NAME:$VERSION)"
```

**4.3.2 Policy Enforcement with OPA**

```rego
# policy/image-policy.rego

package kubernetes.admission

# Deny images without valid signatures
deny[msg] {
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  not is_signed(container.image)
  msg := sprintf("Image %v is not signed", [container.image])
}

# Deny images from unapproved registries
deny[msg] {
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  not starts_with(container.image, "registry.company.com/")
  msg := sprintf("Image %v is not from approved registry", [container.image])
}

# Deny images with known high/critical CVEs
deny[msg] {
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  vulnerabilities := get_vulnerabilities(container.image)
  count([v | v := vulnerabilities[_]; v.severity == "HIGH"]) > 0
  msg := sprintf("Image %v has HIGH severity vulnerabilities", [container.image])
}

# Deny latest tag in production namespace
deny[msg] {
  input.request.namespace == "production"
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  endswith(container.image, ":latest")
  msg := "Cannot use :latest tag in production"
}

# Helper functions
is_signed(image) {
  # Query Cosign verification service
  response := http.send({
    "method": "GET",
    "url": sprintf("http://cosign-verifier/verify?image=%v", [image]),
    "headers": {"Content-Type": "application/json"}
  })
  response.status_code == 200
}

get_vulnerabilities(image) {
  # Query vulnerability database
  response := http.send({
    "method": "GET",
    "url": sprintf("http://vuln-db/scan?image=%v", [image]),
    "headers": {"Content-Type": "application/json"}
  })
  response.body.vulnerabilities
}
```

***

### 5. Security Scanning and Vulnerability Management

#### 5.1 Scanning Tools and Integration

**5.1.1 Trivy Deep Dive**

Trivy is our primary scanner due to its speed, accuracy, and broad coverage.

**Installation and Configuration:**

```bash
# Install Trivy
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.tar.gz
tar zxvf trivy_Linux-64bit.tar.gz
sudo mv trivy /usr/local/bin/

# Configure Trivy cache
mkdir -p ~/.cache/trivy
export TRIVY_CACHE_DIR=~/.cache/trivy

# Update vulnerability database
trivy image --download-db-only
```

**Basic Scanning:**

```bash
# Scan image for vulnerabilities
trivy image python:3.11-slim

# Filter by severity
trivy image --severity HIGH,CRITICAL python:3.11-slim

# Output as JSON for automation
trivy image --format json --output results.json python:3.11-slim

# Scan for specific vulnerability types
trivy image --vuln-type os python:3.11-slim  # OS packages only
trivy image --vuln-type library python:3.11-slim  # Language libraries only

# Scan for secrets accidentally committed
trivy image --scanners secret nginx:latest

# Scan for misconfigurations
trivy image --scanners misconfig my-app:latest
```

**Advanced Usage:**

```bash
# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed python:3.11-slim

# Custom ignorefile for accepted risks
# .trivyignore
CVE-2024-12345  # Low risk, fix ETA Q2 2025, exception approved
CVE-2024-67890  # False positive, not exploitable in our context

trivy image --ignorefile .trivyignore my-app:latest

# Scan with custom timeout
trivy image --timeout 10m large-image:latest

# Scan specific layers only
trivy image --image-layers my-app:latest

# Compare vulnerability counts between images
trivy image --format json python:3.10 > py310.json
trivy image --format json python:3.11 > py311.json
jq -r '.Results[].Vulnerabilities | length' py310.json
jq -r '.Results[].Vulnerabilities | length' py311.json
```

**CI/CD Integration:**

```yaml
# GitHub Actions
name: Container Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Build image
      run: docker build -t ${{ github.repository }}:${{ github.sha }} .

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ github.repository }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH'

    - name: Upload Trivy results to GitHub Security
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

    - name: Fail build on critical vulnerabilities
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ github.repository }}:${{ github.sha }}
        exit-code: '1'
        severity: 'CRITICAL'
```

**5.1.2 Grype for Validation**

Grype provides a second opinion on vulnerabilities using different data sources:

```bash
# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Scan image
grype myapp:latest

# Output formats
grype myapp:latest -o json > grype-results.json
grype myapp:latest -o table  # Human-readable
grype myapp:latest -o cyclonedx  # SBOM with vulnerabilities

# Compare with Trivy results
trivy image --format json myapp:latest | jq '.Results[].Vulnerabilities | length'
grype myapp:latest -o json | jq '.matches | length'

# Explain differences
grype myapp:latest -o json | jq -r '.matches[].vulnerability.id' | sort > grype-cves.txt
trivy image --format json myapp:latest | jq -r '.Results[].Vulnerabilities[].VulnerabilityID' | sort > trivy-cves.txt
comm -3 grype-cves.txt trivy-cves.txt  # Show differences
```

**Why Use Multiple Scanners:**

Different scanners have different vulnerability databases and detection heuristics:

* Trivy uses its own database aggregated from NVD, Red Hat, Debian, Alpine, etc.
* Grype uses Anchore's feed service with additional vulnerability data
* Snyk has proprietary vulnerability data from security research
* Clair uses data directly from distro security teams

A vulnerability might appear in one scanner days before others, or might be a false positive in one but not another.

**5.1.3 Snyk for Developer Integration**

Snyk provides IDE integration and developer-friendly workflows:

```bash
# Install Snyk CLI
npm install -g snyk

# Authenticate
snyk auth

# Scan container image
snyk container test myapp:latest

# Get remediation advice
snyk container test myapp:latest --json | jq '.remediation'

# Monitor image for new vulnerabilities
snyk container monitor myapp:latest --project-name=myapp

# Scan Dockerfile for best practices
snyk iac test Dockerfile

# Test with custom severity threshold
snyk container test myapp:latest --severity-threshold=high
```

**IDE Integration:**

```json
// VSCode settings.json
{
  "snyk.cliPath": "/usr/local/bin/snyk",
  "snyk.severity": "high",
  "snyk.scannerConfigurations": {
    "container": {
      "enabled": true,
      "baseImageRemediation": true
    }
  }
}
```

**Pre-commit Hook:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Scan Dockerfile if changed
if git diff --cached --name-only | grep -q Dockerfile; then
  echo "Scanning Dockerfile..."
  snyk iac test Dockerfile --severity-threshold=high || exit 1
fi

# Scan application dependencies
echo "Scanning dependencies..."
snyk test --severity-threshold=high || exit 1
```

#### 5.2 Scanning Frequency and Triggers

**5.2.1 Build-Time Scanning**

Every image must be scanned before pushing to the registry:

```bash
#!/bin/bash
# build-and-scan.sh

set -e

IMAGE_NAME=$1
IMAGE_TAG=$2
REGISTRY="registry.company.com"

echo "Building image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

echo "Scanning for vulnerabilities..."
trivy image --exit-code 1 --severity CRITICAL $IMAGE_NAME:$IMAGE_TAG

echo "Scanning for secrets..."
trivy image --exit-code 1 --scanners secret $IMAGE_NAME:$IMAGE_TAG

echo "Scanning for misconfigurations..."
trivy image --exit-code 1 --scanners misconfig $IMAGE_NAME:$IMAGE_TAG

echo "Checking licenses..."
syft $IMAGE_NAME:$IMAGE_TAG -o json | \
  jq -r '.artifacts[].licenses[] | select(.value | contains("GPL"))' | \
  grep -q . && echo "ERROR: GPL license found" && exit 1 || true

echo "All scans passed. Pushing to registry..."
docker tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$IMAGE_NAME:$IMAGE_TAG
docker push $REGISTRY/$IMAGE_NAME:$IMAGE_TAG

echo "Generating and attaching SBOM..."
syft $REGISTRY/$IMAGE_NAME:$IMAGE_TAG -o spdx-json=/tmp/sbom.json
cosign attach sbom --sbom /tmp/sbom.json $REGISTRY/$IMAGE_NAME:$IMAGE_TAG

echo "Signing image..."
cosign sign $REGISTRY/$IMAGE_NAME:$IMAGE_TAG

echo "Done!"
```

**5.2.2 Registry Continuous Scanning**

Harbor automatically scans images on schedule:

```yaml
# Harbor scanner configuration
scanners:
  - name: trivy
    url: http://trivy-adapter:8080
    auth: none
    skip_cert_verify: false

# Project-level scanning
projects:
  - name: base-images
    auto_scan: true
    severity: high
    scan_on_push: true
    prevent_vulnerable_images: true

  - name: applications
    auto_scan: true
    severity: critical
    scan_on_push: true
    prevent_vulnerable_images: false  # Warning only
```

Scheduled rescanning finds newly-discovered vulnerabilities:

```bash
#!/bin/bash
# rescan-all-images.sh

# Get all repositories
REPOS=$(curl -s -u admin:$HARBOR_PASSWORD \
  "https://registry.company.com/api/v2.0/projects/base-images/repositories" | \
  jq -r '.[].name')

for REPO in $REPOS; do
  # Get all tags
  TAGS=$(curl -s -u admin:$HARBOR_PASSWORD \
    "https://registry.company.com/api/v2.0/projects/base-images/repositories/$REPO/artifacts" | \
    jq -r '.[].tags[].name')
  
  for TAG in $TAGS; do
    echo "Scanning $REPO:$TAG"
    curl -X POST -u admin:$HARBOR_PASSWORD \
      "https://registry.company.com/api/v2.0/projects/base-images/repositories/$REPO/artifacts/$TAG/scan"
  done
done
```

**5.2.3 Runtime Scanning**

Scan running containers to detect runtime modifications or configuration drift:

```bash
# Scan running containers with Trivy
for CONTAINER in $(docker ps --format "{{.Names}}"); do
  echo "Scanning $CONTAINER..."
  docker inspect $CONTAINER --format='{{.Image}}' | xargs trivy image
done

# Kubernetes runtime scanning
kubectl get pods -A -o json | \
  jq -r '.items[] | .spec.containers[] | .image' | \
  sort -u | \
  while read IMAGE; do
    echo "Scanning $IMAGE..."
    trivy image --severity HIGH,CRITICAL $IMAGE
  done
```

**Falco Runtime Detection:**

```yaml
# falco-rules.yaml
- rule: Container Drift Detection
  desc: Detect binary execution from container that wasn't in the image
  condition: >
    spawned_process and
    container and
    not container.image.repository in (known_repositories) and
    proc.pname != "runc" and
    proc.name != "sh"
  output: >
    Binary executed that wasn't in the original image
    (user=%user.name container=%container.name image=%container.image.repository
    command=%proc.cmdline)
  priority: WARNING
```

#### 5.3 Vulnerability Severity Classification

**5.3.1 CVSS Scoring Context**

Not all high CVSS scores mean immediate risk. Context matters:

```python
# vulnerability-risk-assessment.py

def calculate_actual_risk(cve_id, cvss_score, context):
    """
    Adjust CVSS score based on organizational context
    """
    risk_score = cvss_score
    
    # Reduce risk if vulnerable component not exposed
    if context['network_exposure'] == 'internal':
        risk_score *= 0.7
    
    # Reduce risk if exploit complexity is high
    if context['exploit_complexity'] == 'high':
        risk_score *= 0.8
    
    # Increase risk if exploit code is public
    if context['exploit_available']:
        risk_score *= 1.3
    
    # Increase risk if actively exploited
    if context['actively_exploited']:
        risk_score *= 1.5
    
    # Reduce risk if compensating controls exist
    if context['compensating_controls']:
        risk_score *= 0.6
    
    return min(risk_score, 10.0)  # Cap at 10.0

# Example usage
cve_context = {
    'cve_id': 'CVE-2024-12345',
    'cvss_score': 9.8,
    'network_exposure': 'internal',  # Not exposed to internet
    'exploit_complexity': 'high',
    'exploit_available': False,
    'actively_exploited': False,
    'compensating_controls': True,  # WAF, network segmentation
}

actual_risk = calculate_actual_risk(
    cve_context['cve_id'],
    cve_context['cvss_score'],
    cve_context
)

print(f"CVSS Score: {cve_context['cvss_score']}")
print(f"Actual Risk Score: {actual_risk:.1f}")
# Output: CVSS Score: 9.8, Actual Risk Score: 5.1
```

**5.3.2 Exploitability Assessment**

Not all CVEs are exploitable in your specific context:

```bash
# Check if vulnerable function is actually used
# Example: CVE in unused OpenSSL function

# 1. Identify the vulnerable function
echo "CVE-2024-12345 affects SSL_connect() function"

# 2. Check if application uses this function
strings /app/binary | grep SSL_connect

# 3. If found, check if it's reachable
objdump -d /app/binary | grep -A 10 SSL_connect

# 4. Analyze network connectivity
# If the container has no network access, network-based CVEs are not exploitable

# 5. Check defense in depth measures
kubectl get networkpolicy -n production
kubectl get podsecuritypolicy
```

**Automated Exploitability Checks:**

```python
# check-exploitability.py

import json
import subprocess

def is_exploitable(cve, image):
    """
    Check if CVE is exploitable in this specific image
    """
    reasons = []
    
    # Check if vulnerable package is installed
    scan = json.loads(subprocess.check_output([
        'trivy', 'image', '--format', 'json', image
    ]))
    
    vuln_found = False
    for result in scan.get('Results', []):
        for vuln in result.get('Vulnerabilities', []):
            if vuln['VulnerabilityID'] == cve:
                vuln_found = True
                vuln_data = vuln
                break
    
    if not vuln_found:
        return False, ["CVE not present in image"]
    
    # Check if vulnerable library is actually used
    # This requires static analysis or runtime monitoring
    
    # Check if network-based CVE has network access
    if 'network' in vuln_data.get('Description', '').lower():
        # Check Kubernetes network policies
        result = subprocess.run([
            'kubectl', 'get', 'networkpolicy',
            '-n', 'production',
            '-o', 'json'
        ], capture_output=True)
        
        if result.returncode == 0:
            policies = json.loads(result.stdout)
            if policies['items']:
                reasons.append("Network policies restrict exposure")
    
    # Check if requires specific conditions
    if 'requires authentication' in vuln_data.get('Description', '').lower():
        reasons.append("Requires authentication (defense in depth)")
    
    # If we have reasons it's not exploitable
    exploitable = len(reasons) == 0
    
    return exploitable, reasons

# Example
cve = "CVE-2024-12345"
image = "registry.company.com/apps/myapp:1.2.3"

exploitable, reasons = is_exploitable(cve, image)
if exploitable:
    print(f"{cve} IS EXPLOITABLE in {image}")
else:
    print(f"{cve} NOT exploitable in {image}")
    for reason in reasons:
        print(f"  - {reason}")
```

#### 5.4 Vulnerability Response Process

**5.4.1 Automated Notification System**

```python
# vulnerability-notifier.py

import json
import subprocess
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def scan_and_notify(image, team_email, slack_webhook):
    """
    Scan image and notify team of any high/critical vulnerabilities
    """
    # Scan image
    result = subprocess.run([
        'trivy', 'image',
        '--severity', 'HIGH,CRITICAL',
        '--format', 'json',
        image
    ], capture_output=True)
    
    scan_data = json.loads(result.stdout)
    
    # Extract vulnerabilities
    all_vulns = []
    for result in scan_data.get('Results', []):
        vulns = result.get('Vulnerabilities', [])
        if vulns:
            all_vulns.extend(vulns)
    
    if not all_vulns:
        return  # No vulnerabilities to report
    
    # Group by severity
    critical = [v for v in all_vulns if v['Severity'] == 'CRITICAL']
    high = [v for v in all_vulns if v['Severity'] == 'HIGH']
    
    # Create notification
    message = f"""
Security Scan Results for {image}

Critical Vulnerabilities: {len(critical)}
High Vulnerabilities: {len(high)}

Critical Issues:
"""
    
    for vuln in critical[:5]:  # Top 5
        message += f"""
  - {vuln['VulnerabilityID']}: {vuln['Title']}
    Package: {vuln['PkgName']} {vuln['InstalledVersion']}
    Fixed in: {vuln.get('FixedVersion', 'Not available')}
    CVSS Score: {vuln.get('CVSS', {}).get('nvd', {}).get('V3Score', 'N/A')}
"""
    
    message += f"\nFull report: https://registry.company.com/harbor/projects/apps/repositories/{image}/scan"
    
    # Send email
    send_email(team_email, f"Security Alert: {image}", message)
    
    # Send Slack notification
    send_slack(slack_webhook, message)
    
    # Create Jira ticket for critical vulnerabilities
    if critical:
        create_jira_ticket(image, critical)

def send_email(to, subject, body):
    msg = MIMEMultipart()
    msg['From'] = 'security@company.com'
    msg['To'] = to
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    with smtplib.SMTP('smtp.company.com', 587) as server:
        server.starttls()
        server.send_message(msg)

def send_slack(webhook, message):
    import requests
    requests.post(webhook, json={'text': message})

def create_jira_ticket(image, vulnerabilities):
    # Implementation depends on your Jira setup
    pass

# Run for all production images
images = [
    'registry.company.com/apps/api-gateway:1.2.3',
    'registry.company.com/apps/user-service:2.0.1',
    # ... more images
]

for image in images:
    scan_and_notify(
        image,
        'team-backend@company.com',
        'https://hooks.slack.com/services/...'
    )
```

**5.4.2 Remediation Workflow**

```yaml
# .github/workflows/vulnerability-remediation.yml

name: Automated Vulnerability Remediation

on:
  schedule:
    - cron: '0 2 * * *'  # Run daily at 2 AM
  workflow_dispatch:  # Manual trigger

jobs:
  check-base-images:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Check for base image updates
      id: check-updates
      run: |
        # Check if newer base image available
        CURRENT=$(grep "^FROM" Dockerfile | awk '{print $2}')
        LATEST=$(crane ls registry.company.com/base/python | grep -E "3\.11-[0-9]+" | sort -V | tail -1)
        
        if [ "$CURRENT" != "registry.company.com/base/python:$LATEST" ]; then
          echo "update_available=true" >> $GITHUB_OUTPUT
          echo "current=$CURRENT" >> $GITHUB_OUTPUT
          echo "latest=registry.company.com/base/python:$LATEST" >> $GITHUB_OUTPUT
        fi

    - name: Update Dockerfile
      if: steps.check-updates.outputs.update_available == 'true'
      run: |
        sed -i "s|${{ steps.check-updates.outputs.current }}|${{ steps.check-updates.outputs.latest }}|" Dockerfile

    - name: Build and test
      if: steps.check-updates.outputs.update_available == 'true'
      run: |
        docker build -t test-image .
        docker run test-image python -c "import app; print('OK')"

    - name: Create Pull Request
      if: steps.check-updates.outputs.update_available == 'true'
      uses: peter-evans/create-pull-request@v5
      with:
        title: 'chore: update base image to fix vulnerabilities'
        body: |
          Automated base image update
          
          Current: ${{ steps.check-updates.outputs.current }}
          Latest: ${{ steps.check-updates.outputs.latest }}
          
          This update includes security fixes. Please review and merge.
        branch: auto-update-base-image
```

***

### 6. License Compliance and Open Source Management

#### 6.1 License Scanning Implementation

**6.1.1 SBOM Generation**

```bash
# Generate SBOM with Syft
syft myapp:latest -o spdx-json=sbom.spdx.json

# Generate SBOM with CycloneDX format
syft myapp:latest -o cyclonedx-json=sbom.cdx.json

# Include file metadata
syft myapp:latest -o spdx-json=sbom.json --scope all-layers
```

**SBOM Structure:**

```json
{
  "spdxVersion": "SPDX-2.3",
  "dataLicense": "CC0-1.0",
  "SPDXID": "SPDXRef-DOCUMENT",
  "name": "myapp-1.2.3",
  "packages": [
    {
      "SPDXID": "SPDXRef-Package-python3",
      "name": "python3",
      "versionInfo": "3.11.7",
      "filesAnalyzed": false,
      "licenseConcluded": "PSF-2.0",
      "licenseDeclared": "PSF-2.0",
      "copyrightText": "Copyright (c) 2001-2023 Python Software Foundation",
      "externalRefs": [
        {
          "referenceCategory": "PACKAGE-MANAGER",
          "referenceType": "purl",
          "referenceLocator": "pkg:deb/ubuntu/python3@3.11.7"
        }
      ]
    }
  ]
}
```

**6.1.2 License Policy Enforcement**

```python
# check-licenses.py

import json
import sys

# Define license policy
APPROVED_LICENSES = [
    'MIT', 'Apache-2.0', 'BSD-2-Clause', 'BSD-3-Clause',
    'ISC', 'PSF-2.0', 'CC0-1.0', 'Unlicense'
]

REVIEW_REQUIRED = [
    'LGPL-2.1', 'LGPL-3.0', 'MPL-2.0', 'EPL-2.0'
]

PROHIBITED = [
    'GPL-2.0', 'GPL-3.0', 'AGPL-3.0', 'Commons Clause'
]

def check_sbom_licenses(sbom_path):
    with open(sbom_path) as f:
        sbom = json.load(f)
    
    violations = []
    warnings = []
    
    for package in sbom.get('packages', []):
        pkg_name = package.get('name')
        license = package.get('licenseConcluded', 'UNKNOWN')
        
        # Handle multiple licenses (OR logic)
        licenses = [l.strip() for l in license.split(' OR ')]
        
        for lic in licenses:
            if lic in PROHIBITED:
                violations.append(f"{pkg_name}: {lic} (PROHIBITED)")
            elif lic in REVIEW_REQUIRED:
                warnings.append(f"{pkg_name}: {lic} (REQUIRES REVIEW)")
            elif lic not in APPROVED_LICENSES and lic != 'UNKNOWN':
                warnings.append(f"{pkg_name}: {lic} (NOT IN APPROVED LIST)")
    
    # Report results
    if violations:
        print("LICENSE VIOLATIONS FOUND:")
        for v in violations:
            print(f"  ❌ {v}")
        return False
    
    if warnings:
        print("LICENSE WARNINGS:")
        for w in warnings:
            print(f"  ⚠️  {w}")
    
    print(f"\n✅ License check passed ({len(warnings)} warnings)")
    return True

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: check-licenses.py <sbom.json>")
        sys.exit(1)
    
    success = check_sbom_licenses(sys.argv[1])
    sys.exit(0 if success else 1)
```

**Integration in CI/CD:**

```yaml
- name: License Check
  run: |
    syft $IMAGE_NAME -o spdx-json=sbom.json
    python3 check-licenses.py sbom.json
```

#### 6.2 License Compliance Database

Track all licenses across the organization:

```sql
-- schema.sql

CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    tag VARCHAR(100) NOT NULL,
    digest VARCHAR(71) NOT NULL,
    build_date TIMESTAMP NOT NULL,
    UNIQUE(name, tag)
);

CREATE TABLE packages (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(100) NOT NULL,
    license VARCHAR(100),
    UNIQUE(name, version)
);

CREATE TABLE image_packages (
    image_id INTEGER REFERENCES images(id),
    package_id INTEGER REFERENCES packages(id),
    PRIMARY KEY (image_id, package_id)
);

CREATE TABLE license_approvals (
    license VARCHAR(100) PRIMARY KEY,
    status VARCHAR(20) CHECK (status IN ('approved', 'review', 'prohibited')),
    notes TEXT,
    approved_by VARCHAR(255),
    approved_date TIMESTAMP
);

-- Query: Images with prohibited licenses
SELECT DISTINCT i.name, i.tag, p.name as package, p.license
FROM images i
JOIN image_packages ip ON i.id = ip.image_id
JOIN packages p ON ip.package_id = p.id
JOIN license_approvals la ON p.license = la.license
WHERE la.status = 'prohibited';
```

#### 6.3 SBOM Management

**6.3.1 Storing and Retrieving SBOMs**

```bash
# Attach SBOM to image in registry
cosign attach sbom --sbom sbom.json registry.company.com/apps/myapp:1.2.3

# Retrieve SBOM later
cosign download sbom registry.company.com/apps/myapp:1.2.3

# Verify SBOM signature
cosign verify-attestation \
  --type https://spdx.dev/Document \
  --certificate-identity-regexp '.*' \
  --certificate-oidc-issuer-regexp '.*' \
  registry.company.com/apps/myapp:1.2.3
```

**6.3.2 SBOM Comparison for Updates**

```python
# compare-sboms.py

import json

def load_sbom(path):
    with open(path) as f:
        return json.load(f)

def extract_packages(sbom):
    packages = {}
    for pkg in sbom.get('packages', []):
        name = pkg.get('name')
        version = pkg.get('versionInfo')
        license = pkg.get('licenseConcluded')
        packages[name] = {'version': version, 'license': license}
    return packages

def compare_sboms(old_sbom_path, new_sbom_path):
    old_packages = extract_packages(load_sbom(old_sbom_path))
    new_packages = extract_packages(load_sbom(new_sbom_path))
    
    added = set(new_packages.keys()) - set(old_packages.keys())
    removed = set(old_packages.keys()) - set(new_packages.keys())
    updated = []
    
    for pkg in set(old_packages.keys()) & set(new_packages.keys()):
        if old_packages[pkg]['version'] != new_packages[pkg]['version']:
            updated.append({
                'name': pkg,
                'old_version': old_packages[pkg]['version'],
                'new_version': new_packages[pkg]['version'],
                'license': new_packages[pkg]['license']
            })
    
    print("SBOM Comparison Report")
    print("=" * 50)
    
    if added:
        print(f"\n📦 Added Packages ({len(added)}):")
        for pkg in sorted(added):
            print(f"  + {pkg} {new_packages[pkg]['version']} ({new_packages[pkg]['license']})")
    
    if removed:
        print(f"\n🗑️  Removed Packages ({len(removed)}):")
        for pkg in sorted(removed):
            print(f"  - {pkg} {old_packages[pkg]['version']}")
    
    if updated:
        print(f"\n⬆️  Updated Packages ({len(updated)}):")
        for pkg in sorted(updated, key=lambda x: x['name']):
            print(f"  {pkg['name']}: {pkg['old_version']} → {pkg['new_version']}")

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print("Usage: compare-sboms.py <old-sbom.json> <new-sbom.json>")
        sys.exit(1)
    
    compare_sboms(sys.argv[1], sys.argv[2])
```

***

### 7. Image Lifecycle Management

#### 7.1 Semantic Versioning Implementation

**7.1.1 Version Tagging Strategy**

```bash
#!/bin/bash
# tag-and-push.sh

set -e

IMAGE_NAME=$1
GIT_SHA=$(git rev-parse --short HEAD)
VERSION=$2  # e.g., 1.2.3

REGISTRY="registry.company.com"
FULL_IMAGE="$REGISTRY/$IMAGE_NAME"

# Build image
docker build -t $IMAGE_NAME:$VERSION .

# Get digest for immutable reference
DIGEST=$(docker inspect $IMAGE_NAME:$VERSION --format='{{index .RepoDigests 0}}' | cut -d'@' -f2)

# Tag with multiple versions
docker tag $IMAGE_NAME:$VERSION $FULL_IMAGE:$VERSION
docker tag $IMAGE_NAME:$VERSION $FULL_IMAGE:$(echo $VERSION | cut -d. -f1,2)  # 1.2
docker tag $IMAGE_NAME:$VERSION $FULL_IMAGE:$(echo $VERSION | cut -d. -f1)     # 1
docker tag $IMAGE_NAME:$VERSION $FULL_IMAGE:sha-$GIT_SHA
docker tag $IMAGE_NAME:$VERSION $FULL_IMAGE:latest

# Push all tags
docker push $FULL_IMAGE:$VERSION
docker push $FULL_IMAGE:$(echo $VERSION | cut -d. -f1,2)
docker push $FULL_IMAGE:$(echo $VERSION | cut -d. -f1)
docker push $FULL_IMAGE:sha-$GIT_SHA
docker push $FULL_IMAGE:latest

# Print deployment reference
echo "✅ Image pushed successfully"
echo "📦 Immutable reference for production:"
echo "   $FULL_IMAGE@$DIGEST"
```

**7.1.2 Automated Version Bumping**

```python
# bump-version.py

import re
import sys

def read_version(dockerfile_path):
    with open(dockerfile_path) as f:
        content = f.read()
    
    match = re.search(r'LABEL version="([^"]+)"', content)
    if match:
        return match.group(1)
    return None

def bump_version(version, bump_type='patch'):
    major, minor, patch = map(int, version.split('.'))
    
    if bump_type == 'major':
        return f"{major + 1}.0.0"
    elif bump_type == 'minor':
        return f"{major}.{minor + 1}.0"
    else:  # patch
        return f"{major}.{minor}.{patch + 1}"

def update_dockerfile(dockerfile_path, new_version):
    with open(dockerfile_path) as f:
        content = f.read()
    
    # Update version label
    content = re.sub(
        r'LABEL version="[^"]+"',
        f'LABEL version="{new_version}"',
        content
    )
    
    with open(dockerfile_path, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: bump-version.py [major|minor|patch]")
        sys.exit(1)
    
    bump_type = sys.argv[1]
    dockerfile = 'Dockerfile'
    
    current = read_version(dockerfile)
    if not current:
        print("Error: No version label found in Dockerfile")
        sys.exit(1)
    
    new_version = bump_version(current, bump_type)
    update_dockerfile(dockerfile, new_version)
    
    print(f"Version bumped: {current} → {new_version}")
```

#### 7.2 Automated Update System

**7.2.1 Dependency Update Automation**

```yaml
# .github/dependabot.yml

version: 2
updates:
  # Docker base images
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 5
    reviewers:
      - "platform-team"
    labels:
      - "dependencies"
      - "docker"
    commit-message:
      prefix: "chore"
      include: "scope"

  # Python dependencies
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    reviewers:
      - "backend-team"
```

**7.2.2 Base Image Update Notification**

```python
# notify-base-image-updates.py

import requests
import json
from datetime import datetime, timedelta

REGISTRY_API = "https://registry.company.com/api/v2.0"
SLACK_WEBHOOK = "https://hooks.slack.com/services/..."

def get_recent_base_images(days=7):
    """Get base images updated in the last N days"""
    cutoff = datetime.now() - timedelta(days=days)
    
    response = requests.get(
        f"{REGISTRY_API}/projects/base/repositories",
        headers={"accept": "application/json"}
    )
    
    repos = response.json()
    recent_updates = []
    
    for repo in repos:
        repo_name = repo['name']
        
        # Get artifacts (tags)
        artifacts_response = requests.get(
            f"{REGISTRY_API}/projects/base/repositories/{repo_name}/artifacts"
        )
        
        for artifact in artifacts_response.json():
            push_time = datetime.fromisoformat(artifact['push_time'].replace('Z', '+00:00'))
            
            if push_time > cutoff:
                recent_updates.append({
                    'image': f"registry.company.com/base/{repo_name}",
                    'tag': artifact['tags'][0]['name'] if artifact['tags'] else 'untagged',
                    'digest': artifact['digest'],
                    'push_time': push_time.isoformat(),
                    'vulnerabilities': artifact.get('scan_overview', {})
                })
    
    return recent_updates

def notify_teams(updates):
    """Send Slack notification to development teams"""
    if not updates:
        return
    
    message = {
        "text": "🆕 Base Image Updates Available",
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": "Base Image Updates"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*{len(updates)} base images* have been updated in the last 7 days. Please update your applications."
                }
            }
        ]
    }
    
    for update in updates:
        vuln_summary = update['vulnerabilities'].get('summary', {})
        critical = vuln_summary.get('critical', 0)
        high = vuln_summary.get('high', 0)
        
        message["blocks"].append({
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"*{update['image']}:{update['tag']}*\n"
                        f"Pushed: {update['push_time'][:10]}\n"
                        f"Vulnerabilities: {critical} critical, {high} high"
            }
        })
    
    message["blocks"].append({
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "Update your Dockerfiles and rebuild applications to incorporate these security fixes."
        }
    })
    
    requests.post(SLACK_WEBHOOK, json=message)

if __name__ == '__main__':
    updates = get_recent_base_images(days=7)
    notify_teams(updates)
    print(f"Notified about {len(updates)} base image updates")
```

#### 7.3 Image Deprecation Process

**7.3.1 Deprecation Metadata**

```dockerfile
# Deprecated image
FROM ubuntu:20.04

LABEL deprecated="true" \
      deprecation_date="2025-01-01" \
      eol_date="2025-04-01" \
      replacement="ubuntu:22.04" \
      migration_guide="https://docs.company.com/migration/ubuntu-22.04"

# ... rest of Dockerfile
```

**7.3.2 Automated Deprecation Detection**

```python
# detect-deprecated-images.py

import docker
import requests
from datetime import datetime

def check_deprecated_images():
    """Check all running containers for deprecated base images"""
    client = docker.from_env()
    
    deprecated_containers = []
    
    for container in client.containers.list():
        image = container.image
        attrs = image.attrs
        labels = attrs.get('Config', {}).get('Labels', {})
        
        if labels.get('deprecated') == 'true':
            eol_date = labels.get('eol_date')
            replacement = labels.get('replacement')
            
            deprecated_containers.append({
                'container': container.name,
                'image': image.tags[0] if image.tags else image.id,
                'eol_date': eol_date,
                'replacement': replacement,
                'migration_guide': labels.get('migration_guide')
            })
    
    if deprecated_containers:
        print("⚠️  DEPRECATED IMAGES DETECTED")
        print("=" * 60)
        
        for item in deprecated_containers:
            print(f"\nContainer: {item['container']}")
            print(f"Image: {item['image']}")
            print(f"EOL Date: {item['eol_date']}")
            print(f"Replacement: {item['replacement']}")
            print(f"Migration Guide: {item['migration_guide']}")
        
        # Create Jira tickets
        for item in deprecated_containers:
            create_migration_ticket(item)

def create_migration_ticket(deprecated_info):
    """Create Jira ticket for image migration"""
    # Implementation specific to your Jira setup
    pass

if __name__ == '__main__':
    check_deprecated_images()
```

***

### 8. Best Practices and Technical Standards

#### 8.1 Advanced Dockerfile Patterns

**8.1.1 Distroless Migration**

```dockerfile
# Building for distroless requires static binaries or specific language runtimes

# Example: Go application
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]

# Example: Python application
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM gcr.io/distroless/python3-debian12:nonroot
COPY --from=builder /root/.local /home/nonroot/.local
COPY app.py /app/
WORKDIR /app
ENV PYTHONPATH=/home/nonroot/.local/lib/python3.11/site-packages
ENV PATH=/home/nonroot/.local/bin:$PATH
USER nonroot:nonroot
CMD ["python3", "app.py"]
```

**8.1.2 Argument and Secret Handling**

```dockerfile
# ❌ NEVER do this - secrets in build args are visible in history
ARG DATABASE_PASSWORD=supersecret
RUN echo "PASSWORD=$DATABASE_PASSWORD" > /app/config

# ✅ Use BuildKit secrets
# docker build --secret id=dbpass,src=./secrets/dbpass.txt .
FROM python:3.11-slim

RUN --mount=type=secret,id=dbpass \
    cat /run/secrets/dbpass | some-command

# ✅ Use multi-stage builds to avoid secret leakage
FROM python:3.11-slim AS builder
ARG PRIVATE_REPO_TOKEN
RUN --mount=type=secret,id=token \
    pip install --extra-index-url https://$(cat /run/secrets/token)@repo.company.com/simple package

FROM python:3.11-slim
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
# Token not in final image
```

**8.1.3 Effective Layer Caching**

```dockerfile
# ❌ Poor caching - every code change rebuilds everything
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build

# ✅ Better caching - dependencies cached separately
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package.json ./
CMD ["node", "dist/index.js"]

# ✅ Even better with BuildKit cache mounts
FROM node:20-alpine AS builder
WORKDIR /app

# Cache npm packages
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci

COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

#### 8.2 Runtime Security Configurations

**8.2.1 Pod Security Standards**

```yaml
# Restricted Pod Security Standard (highest security)
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  labels:
    app: myapp
spec:
  securityContext:
    # Run as non-root
    runAsNonRoot: true
    runAsUser: 10001
    fsGroup: 10001
    # Secure system calls
    seccompProfile:
      type: RuntimeDefault
    # Drop all capabilities
  containers:
  - name: app
    image: registry.company.com/apps/myapp:1.2.3
    securityContext:
      # Prevent privilege escalation
      allowPrivilegeEscalation: false
      # Read-only root filesystem
      readOnlyRootFilesystem: true
      # Drop all capabilities
      capabilities:
        drop:
          - ALL
      # Run as specific user
      runAsNonRoot: true
      runAsUser: 10001
    # Resource limits
    resources:
      limits:
        memory: "512Mi"
        cpu: "1000m"
      requests:
        memory: "256Mi"
        cpu: "500m"
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /app/cache
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

**8.2.2 NetworkPolicy Implementation**

```yaml
# Default deny all traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow ingress from ingress controller only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: myapp
      tier: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
---
# Allow egress to database only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-database-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: myapp
      tier: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

***

### 9. Implementation Guidance

#### 9.1 Infrastructure Setup

**9.1.1 Harbor Installation with High Availability**

```yaml
# harbor-values.yaml for Helm

# External database for HA
database:
  type: external
  external:
    host: "postgres-ha.database.svc.cluster.local"
    port: "5432"
    username: "harbor"
    password: "changeme"
    coreDatabase: "registry"
    sslmode: "require"

# External Redis for HA
redis:
  type: external
  external:
    addr: "redis-ha.database.svc.cluster.local:6379"
    sentinelMasterSet: "mymaster"
    password: "changeme"

# S3 storage for images
persistence:
  imageChartStorage:
    type: s3
    s3:
      region: us-east-1
      bucket: company-harbor-images
      accesskey: AKIAIOSFODNN7EXAMPLE
      secretkey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
      regionendpoint: https://s3.us-east-1.amazonaws.com

# Trivy for vulnerability scanning
trivy:
  enabled: true
  gitHubToken: "ghp_..."
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 2Gi

# Ingress configuration
expose:
  type: ingress
  ingress:
    hosts:
      core: registry.company.com
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: harbor-tls

# Notary for image signing
notary:
  enabled: true

# Replicate to DR site
replication:
  enabled: true
```

Install Harbor:

```bash
# Add Harbor Helm repository
helm repo add harbor https://helm.goharbor.io
helm repo update

# Create namespace
kubectl create namespace harbor

# Install Harbor
helm install harbor harbor/harbor \
  --namespace harbor \
  --values harbor-values.yaml \
  --version 1.13.0

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod \
  --all \
  --namespace harbor \
  --timeout=600s
```

**9.1.2 Scanning Infrastructure Setup**

```bash
# Install Trivy operator for Kubernetes
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/main/deploy/static/trivy-operator.yaml

# Configure Trivy operator
kubectl create configmap trivy-operator-config \
  --from-literal=trivy.severity=HIGH,CRITICAL \
  --from-literal=trivy.timeout=10m \
  --namespace trivy-system

# Verify installation
kubectl get pods -n trivy-system

# Install Grype for secondary validation
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
  sh -s -- -b /usr/local/bin

# Set up scanning cron job
kubectl create -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scan-all-images
  namespace: security
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scanner
            image: aquasec/trivy:latest
            command:
            - /bin/sh
            - -c
            - |
              # Get all images in use
              kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u > /tmp/images.txt
              
              # Scan each image
              while read image; do
                echo "Scanning \$image..."
                trivy image --severity HIGH,CRITICAL "\$image"
              done < /tmp/images.txt
          restartPolicy: OnFailure
          serviceAccountName: scanner
EOF

# Create service account with permissions
kubectl create serviceaccount scanner -n security
kubectl create clusterrolebinding scanner-view \
  --clusterrole=view \
  --serviceaccount=security:scanner
```

#### 9.2 Base Image Build Pipeline

```yaml
# .github/workflows/base-image-build.yml

name: Build Base Image

on:
  push:
    paths:
      - 'base-images/**'
  schedule:
    - cron: '0 0 * * 0'  # Weekly rebuild
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        image: [ubuntu-22.04, alpine-3.19, python-3.11, node-20]
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to Harbor
      uses: docker/login-action@v2
      with:
        registry: registry.company.com
        username: ${{ secrets.HARBOR_USERNAME }}
        password: ${{ secrets.HARBOR_PASSWORD }}

    - name: Generate version tag
      id: version
      run: |
        echo "tag=$(date +%Y%m%d)" >> $GITHUB_OUTPUT

    - name: Build image
      uses: docker/build-push-action@v4
      with:
        context: ./base-images/${{ matrix.image }}
        push: false
        tags: |
          registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }}
          registry.company.com/base/${{ matrix.image }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max
        load: true

    - name: Scan with Trivy
      run: |
        trivy image \
          --severity HIGH,CRITICAL \
          --exit-code 1 \
          registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }}

    - name: Scan with Grype
      run: |
        grype registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }} \
          --fail-on high

    - name: Generate SBOM
      run: |
        syft registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }} \
          -o spdx-json=sbom.spdx.json

    - name: Check licenses
      run: |
        python3 scripts/check-licenses.py sbom.spdx.json

    - name: Push image
      uses: docker/build-push-action@v4
      with:
        context: ./base-images/${{ matrix.image }}
        push: true
        tags: |
          registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }}
          registry.company.com/base/${{ matrix.image }}:latest
        cache-from: type=gha

    - name: Install Cosign
      uses: sigstore/cosign-installer@v3

    - name: Sign image
      run: |
        cosign sign --yes \
          registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }}

    - name: Attach SBOM
      run: |
        cosign attach sbom --sbom sbom.spdx.json \
          registry.company.com/base/${{ matrix.image }}:${{ steps.version.outputs.tag }}

    - name: Notify teams
      run: |
        python3 scripts/notify-base-image-update.py \
          --image ${{ matrix.image }} \
          --version ${{ steps.version.outputs.tag }}
```

#### 9.3 Admission Control

```yaml
# kyverno-policy.yaml

apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: verify-signature
    match:
      any:
      - resources:
          kinds:
          - Pod
    verifyImages:
    - imageReferences:
      - "registry.company.com/*"
      attestors:
      - count: 1
        entries:
        - keyless:
            subject: "https://github.com/company/*"
            issuer: "https://token.actions.githubusercontent.com"
            rekor:
              url: https://rekor.sigstore.dev
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: enforce
  rules:
  - name: require-image-tag
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Using 'latest' tag is not allowed in production"
      pattern:
        spec:
          containers:
          - image: "!*:latest"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-approved-registry
spec:
  validationFailureAction: enforce
  rules:
  - name: check-registry
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Images must come from registry.company.com"
      pattern:
        spec:
          containers:
          - image: "registry.company.com/*"
```

***

### 10. Assessment and Continuous Improvement

#### 10.1 Security Metrics Dashboard

```python
# metrics-collector.py

import json
import subprocess
from datetime import datetime
from influxdb import InfluxDBClient

class MetricsCollector:
    def __init__(self):
        self.influx = InfluxDBClient(
            host='influxdb.company.com',
            port=8086,
            database='container_security'
        )
    
    def collect_vulnerability_metrics(self):
        """Collect vulnerability counts across all images"""
        # Get all production images
        result = subprocess.run([
            'kubectl', 'get', 'pods',
            '-A', '-o', 'json'
        ], capture_output=True)
        
        pods = json.loads(result.stdout)
        images = set()
        
        for pod in pods['items']:
            for container in pod['spec']['containers']:
                images.add(container['image'])
        
        # Scan and collect metrics
        for image in images:
            scan_result = subprocess.run([
                'trivy', 'image',
                '--format', 'json',
                '--quiet',
                image
            ], capture_output=True)
            
            data = json.loads(scan_result.stdout)
            
            # Count vulnerabilities by severity
            critical = high = medium = low = 0
            for result in data.get('Results', []):
                for vuln in result.get('Vulnerabilities', []):
                    severity = vuln['Severity']
                    if severity == 'CRITICAL':
                        critical += 1
                    elif severity == 'HIGH':
                        high += 1
                    elif severity == 'MEDIUM':
                        medium += 1
                    elif severity == 'LOW':
                        low += 1
            
            # Write to InfluxDB
            self.influx.write_points([{
                'measurement': 'image_vulnerabilities',
                'tags': {
                    'image': image
                },
                'fields': {
                    'critical': critical,
                    'high': high,
                    'medium': medium,
                    'low': low,
                    'total': critical + high + medium + low
                },
                'time': datetime.utcnow().isoformat()
            }])
    
    def collect_compliance_metrics(self):
        """Collect policy compliance metrics"""
        # Check image signatures
        signed = unsigned = 0
        
        result = subprocess.run([
            'kubectl', 'get', 'pods',
            '-A', '-o', 'json'
        ], capture_output=True)
        
        pods = json.loads(result.stdout)
        
        for pod in pods['items']:
            for container in pod['spec']['containers']:
                image = container['image']
                
                # Check signature
                verify = subprocess.run([
                    'cosign', 'verify',
                    '--certificate-identity-regexp', '.*',
                    '--certificate-oidc-issuer-regexp', '.*',
                    image
                ], capture_output=True)
                
                if verify.returncode == 0:
                    signed += 1
                else:
                    unsigned += 1
        
        self.influx.write_points([{
            'measurement': 'image_compliance',
            'fields': {
                'signed': signed,
                'unsigned': unsigned,
                'compliance_rate': (signed / (signed + unsigned)) * 100
            },
            'time': datetime.utcnow().isoformat()
        }])
    
    def collect_adoption_metrics(self):
        """Track base image adoption"""
        result = subprocess.run([
            'kubectl', 'get', 'pods',
            '-A', '-o', 'json'
        ], capture_output=True)
        
        pods = json.loads(result.stdout)
        
        approved_base = unapproved = 0
        
        for pod in pods['items']:
            for container in pod['spec']['containers']:
                image = container['image']
                
                if image.startswith('registry.company.com/base/'):
                    approved_base += 1
                elif image.startswith('registry.company.com/apps/'):
                    # Check if uses approved base
                    # This requires querying image metadata
                    approved_base += 1
                else:
                    unapproved += 1
        
        self.influx.write_points([{
            'measurement': 'base_image_adoption',
            'fields': {
                'approved': approved_base,
                'unapproved': unapproved,
                'adoption_rate': (approved_base / (approved_base + unapproved)) * 100
            },
            'time': datetime.utcnow().isoformat()
        }])

if __name__ == '__main__':
    collector = MetricsCollector()
    collector.collect_vulnerability_metrics()
    collector.collect_compliance_metrics()
    collector.collect_adoption_metrics()
```

#### 10.2 Continuous Improvement Feedback Loop

```python
# analyze-incidents.py

import json
from collections import defaultdict
from datetime import datetime, timedelta

def analyze_security_incidents():
    """Analyze security incidents to identify improvement opportunities"""
    # Load incidents from last quarter
    incidents = load_incidents_from_jira(days=90)
    
    # Categorize incidents
    root_causes = defaultdict(int)
    affected_images = defaultdict(int)
    response_times = []
    
    for incident in incidents:
        # Extract data
        root_cause = incident['root_cause']
        image = incident['affected_image']
        reported = datetime.fromisoformat(incident['reported_at'])
        resolved = datetime.fromisoformat(incident['resolved_at'])
        
        root_causes[root_cause] += 1
        affected_images[image] += 1
        response_times.append((resolved - reported).total_seconds() / 3600)
    
    # Generate report
    print("Security Incident Analysis")
    print("=" * 60)
    print(f"\nTotal Incidents: {len(incidents)}")
    print(f"Average Response Time: {sum(response_times)/len(response_times):.1f} hours")
    
    print("\nRoot Causes:")
    for cause, count in sorted(root_causes.items(), key=lambda x: x[1], reverse=True):
        print(f"  {cause}: {count}")
    
    print("\nMost Affected Images:")
    for image, count in sorted(affected_images.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {image}: {count} incidents")
    
    # Recommendations
    print("\nRecommendations:")
    
    if root_causes['outdated_dependencies'] > len(incidents) * 0.3:
        print("  - Implement automated dependency updates")
        print("  - Increase dependency scanning frequency")
    
    if root_causes['missing_patches'] > len(incidents) * 0.2:
        print("  - Improve base image update notification system")
        print("  - Enforce maximum age for base images")
    
    if sum(response_times) / len(response_times) > 48:
        print("  - Review incident response procedures")
        print("  - Improve automation in patching pipeline")

def load_incidents_from_jira(days=90):
    """Load security incidents from Jira"""
    # Implementation specific to your Jira setup
    # This is a placeholder
    return []

if __name__ == '__main__':
    analyze_security_incidents()
```

***

### 11. Appendices

#### 11.1 Appendix A: Dockerfile Template Library

**A.1 Python Application**

```dockerfile
# syntax=docker/dockerfile:1.4

# Build stage
FROM registry.company.com/base/python:3.11-slim-20250115 AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM registry.company.com/base/python:3.11-slim-20250115

WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Create non-root user
RUN groupadd -r appuser -g 10001 && \
    useradd -r -u 10001 -g appuser -d /app appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Set Python path
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**A.2 Node.js Application**

```dockerfile
# syntax=docker/dockerfile:1.4

FROM registry.company.com/base/node:20-alpine-20250115 AS deps

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

FROM registry.company.com/base/node:20-alpine-20250115 AS builder

WORKDIR /app

# Install all dependencies (including dev)
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Build application
COPY . .
RUN npm run build

FROM registry.company.com/base/node:20-alpine-20250115

WORKDIR /app

# Create non-root user
RUN adduser -D -u 10001 nodeuser && \
    chown -R nodeuser:nodeuser /app

USER nodeuser

# Copy production dependencies
COPY --from=deps --chown=nodeuser:nodeuser /app/node_modules ./node_modules

# Copy built application
COPY --from=builder --chown=nodeuser:nodeuser /app/dist ./dist
COPY --chown=nodeuser:nodeuser package.json ./

ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

**A.3 Go Application**

```dockerfile
# syntax=docker/dockerfile:1.4

FROM golang:1.21-alpine AS builder

WORKDIR /src

# Install ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Cache dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Build application
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o /app/server .

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/server /server

USER nonroot:nonroot

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/server", "healthcheck"]

EXPOSE 8080

ENTRYPOINT ["/server"]
```

#### 11.2 Appendix B: CI/CD Integration Examples

**B.1 GitLab CI**

```yaml
# .gitlab-ci.yml

variables:
  IMAGE_NAME: $CI_REGISTRY_IMAGE
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA
  TRIVY_VERSION: latest

stages:
  - build
  - scan
  - test
  - deploy

build:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $IMAGE_NAME:$IMAGE_TAG .
    - docker push $IMAGE_NAME:$IMAGE_TAG
  only:
    - branches

vulnerability-scan:
  stage: scan
  image: aquasec/trivy:$TRIVY_VERSION
  script:
    - trivy image --exit-code 0 --severity LOW,MEDIUM $IMAGE_NAME:$IMAGE_TAG
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE_NAME:$IMAGE_TAG
  allow_failure: false

secret-scan:
  stage: scan
  image: aquasec/trivy:$TRIVY_VERSION
  script:
    - trivy image --scanners secret --exit-code 1 $IMAGE_NAME:$IMAGE_TAG

license-check:
  stage: scan
  image: anchore/syft:latest
  script:
    - syft $IMAGE_NAME:$IMAGE_TAG -o json | jq -r '.artifacts[].licenses[] | select(.value | contains("GPL"))' | grep -q . && exit 1 || exit 0

integration-tests:
  stage: test
  image: docker:24-dind
  services:
    - docker:24-dind
  script:
    - docker run -d --name test $IMAGE_NAME:$IMAGE_TAG
    - sleep 10
    - docker exec test /app/run-tests.sh
  after_script:
    - docker logs test
    - docker rm -f test

deploy-staging:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context staging
    - kubectl set image deployment/myapp app=$IMAGE_NAME:$IMAGE_TAG
    - kubectl rollout status deployment/myapp
  only:
    - main

deploy-production:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context production
    - kubectl set image deployment/myapp app=$IMAGE_NAME:$IMAGE_TAG
    - kubectl rollout status deployment/myapp
  when: manual
  only:
    - main
```

**B.2 GitHub Actions**

See earlier example in section 9.2

**B.3 Jenkins Pipeline**

```groovy
// Jenkinsfile

pipeline {
    agent any
    
    environment {
        REGISTRY = 'registry.company.com'
        IMAGE_NAME = 'apps/myapp'
        IMAGE_TAG = "${GIT_COMMIT.take(7)}"
        FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build(FULL_IMAGE)
                }
            }
        }
        
        stage('Security Scans') {
            parallel {
                stage('Trivy Scan') {
                    steps {
                        sh """
                            trivy image \
                                --severity HIGH,CRITICAL \
                                --exit-code 1 \
                                ${FULL_IMAGE}
                        """
                    }
                }
                
                stage('License Check') {
                    steps {
                        sh """
                            syft ${FULL_IMAGE} -o json > sbom.json
                            python3 scripts/check-licenses.py sbom.json
                        """
                    }
                }
                
                stage('Secret Scan') {
                    steps {
                        sh """
                            trivy image \
                                --scanners secret \
                                --exit-code 1 \
                                ${FULL_IMAGE}
                        """
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'harbor-credentials') {
                        docker.image(FULL_IMAGE).push()
                        docker.image(FULL_IMAGE).push('latest')
                    }
                }
            }
        }
        
        stage('Sign Image') {
            steps {
                withCredentials([file(credentialsId: 'cosign-key', variable: 'COSIGN_KEY')]) {
                    sh """
                        cosign sign --key ${COSIGN_KEY} ${FULL_IMAGE}
                    """
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                sh """
                    kubectl --context=staging \
                        set image deployment/myapp \
                        app=${FULL_IMAGE}
                    
                    kubectl --context=staging \
                        rollout status deployment/myapp
                """
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
            }
            steps {
                sh """
                    kubectl --context=production \
                        set image deployment/myapp \
                        app=${FULL_IMAGE}
                    
                    kubectl --context=production \
                        rollout status deployment/myapp
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            slackSend(
                color: 'danger',
                message: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
        success {
            slackSend(
                color: 'good',
                message: "Build succeeded: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

***

### 10. Developer Guidelines: Anti-Patterns and Best Practices

#### 10.1 Introduction: Using Base Images Correctly

Base images are designed to provide a secure, consistent foundation for applications. However, developers can inadvertently undermine this foundation through common anti-patterns. This section provides clear guidance on what NOT to do, and how to properly use base images to maintain security and operational consistency.

**The Golden Rule**: Treat base images as immutable building blocks. Add your application on top, but never modify the base layer security configurations.

#### 10.2 Critical Anti-Patterns to Avoid

**10.2.1 Anti-Pattern: Running as Root in Application Layer**

**❌ WRONG: Switching back to root after base image sets non-root user**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# Base image sets USER to appuser (uid 10001)
# Developer switches back to root - WRONG!
USER root

RUN apt-get update && apt-get install -y some-package

COPY app.py /app/
CMD ["python", "app.py"]
```

**Why this is dangerous:**

* Completely negates the security hardening in the base image
* Container runs with root privileges, allowing attackers full system access
* Violates security policies and will fail compliance scans
* Defeats the purpose of using a hardened base image

**✅ CORRECT: Stay as non-root user, install dependencies properly**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# Base image already sets USER to appuser (uid 10001)
# Stay as that user!

WORKDIR /app

# If you need to install system packages, do it in a multi-stage build
# or request the package be added to the base image

# Copy application files (they'll be owned by appuser)
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser app.py .

# Already running as appuser - no need to switch
CMD ["python", "app.py"]
```

**If you absolutely need system packages:**

```dockerfile
# Option 1: Multi-stage build (PREFERRED)
FROM registry.company.com/base/ubuntu:22.04-20250115 AS builder
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    # ... compile your application
    rm -rf /var/lib/apt/lists/*

FROM registry.company.com/base/python:3.11-slim-20250115
COPY --from=builder --chown=appuser:appuser /app/built-binary /app/
CMD ["/app/built-binary"]

# Option 2: Request the package in base image (for common needs)
# Create ticket: "Please add imagemagick to Python base image"
# Platform team evaluates if it's a common need
```

**10.2.2 Anti-Pattern: Installing Unnecessary System Packages**

**❌ WRONG: Installing everything "just in case"**

```dockerfile
FROM registry.company.com/base/node:20-alpine-20250115

USER root
RUN apk add --no-cache \
    vim \
    curl \
    wget \
    bash \
    git \
    openssh \
    sudo \
    build-base \
    python3 \
    py3-pip \
    && npm install -g nodemon
USER node

COPY package*.json ./
RUN npm install

COPY . .
CMD ["npm", "start"]
```

**Why this is wrong:**

* Adds 100+ MB to image size unnecessarily
* Introduces dozens of potential vulnerabilities
* vim, bash, openssh are debug tools that shouldn't be in production
* sudo in a container makes no sense
* build-base not needed at runtime

**Security impact:**

* Each package is a potential CVE entry point
* Attackers have more tools available if they compromise the container
* Larger attack surface to maintain and patch

**✅ CORRECT: Minimal runtime dependencies only**

```dockerfile
FROM registry.company.com/base/node:20-alpine-20250115 AS builder

# Build stage can have dev dependencies
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage - minimal
FROM registry.company.com/base/node:20-alpine-20250115

WORKDIR /app

# Only production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built artifacts
COPY --from=builder /app/dist ./dist

# Already running as non-root from base image
CMD ["node", "dist/server.js"]
```

**Result:**

* Image size: 450MB → 180MB
* Zero unnecessary packages
* No debug tools for attackers to abuse
* Faster deployments and startup

**10.2.3 Anti-Pattern: Modifying Base Image Security Configurations**

**❌ WRONG: Changing file permissions, adding capabilities, modifying system configs**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

USER root

# Modifying security configurations - WRONG!
RUN chmod 777 /tmp && \
    chmod 777 /app && \
    chmod +s /usr/bin/python3 && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Re-enabling security features that base image disabled - WRONG!
RUN apk add --no-cache sudo

USER appuser

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Why this is dangerous:**

* chmod 777 allows any user to write anywhere (security nightmare)
* chmod +s (setuid) allows privilege escalation attacks
* Adding sudo defeats non-root user security
* Violates least privilege principle

**What happens:**

* Security scans will flag these violations
* Kubernetes Pod Security Standards will reject the pod
* Creates security incidents waiting to happen

**✅ CORRECT: Work within the security model**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# Base image already configured securely
# Don't modify security settings!

WORKDIR /app

# Use proper ownership for files
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser . .

# If your app needs to write files, use designated directories
# Base image provides /tmp and /app with correct permissions
RUN mkdir -p /app/data && chown appuser:appuser /app/data

# Already running as appuser - secure by default
CMD ["python3", "app.py"]
```

**If your application truly needs to write outside /app:**

```yaml
# Use Kubernetes volumes instead of modifying image
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: registry.company.com/apps/myapp:1.0.0
    volumeMounts:
    - name: data
      mountPath: /data
    - name: cache
      mountPath: /cache
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: myapp-data
  - name: cache
    emptyDir: {}
```

**10.2.4 Anti-Pattern: Embedding Secrets in Images**

**❌ WRONG: Secrets in Dockerfile or build arguments**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# NEVER DO THIS - secrets in image!
ENV DATABASE_PASSWORD=super_secret_password
ENV API_KEY=sk-abc123def456

# Also wrong - build args are visible in image history
ARG PRIVATE_REPO_TOKEN=ghp_secrettoken123
RUN pip install --extra-index-url https://${PRIVATE_REPO_TOKEN}@repo.company.com/simple private-package

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Why this is catastrophic:**

* Secrets are baked into image layers permanently
* Anyone with registry access can extract secrets
* `docker history` shows all build arguments
* Image layers are cached and may be widely distributed
* Secrets can't be rotated without rebuilding image

**Real attack scenario:**

```bash
# Attacker pulls your image
docker pull registry.company.com/apps/myapp:1.0.0

# Extracts environment variables from image config
docker inspect myapp:1.0.0 | grep -A 20 Env

# Sees your secrets!
# "DATABASE_PASSWORD=super_secret_password"

# Extracts build args from history
docker history --no-trunc myapp:1.0.0 | grep PRIVATE_REPO_TOKEN
```

**✅ CORRECT: Use proper secret management**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# No secrets in the image!
COPY requirements.txt .

# For private packages, use BuildKit secrets (not stored in image)
RUN --mount=type=secret,id=pip_token \
    pip install \
      --extra-index-url https://$(cat /run/secrets/pip_token)@repo.company.com/simple \
      -r requirements.txt

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Build command:**

```bash
# Secret is only available during build, not stored in image
docker buildx build \
  --secret id=pip_token,src=./secrets/token.txt \
  -t myapp:1.0.0 .
```

**Runtime secrets - use environment variables or secret stores:**

```yaml
# Kubernetes - mount secrets as environment variables
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: app
        image: registry.company.com/apps/myapp:1.0.0
        env:
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-credentials
              key: api-key
```

**Or use a secret manager:**

```python
# app.py - fetch secrets at runtime
import os
import boto3

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

# Get secrets at application startup
db_password = get_secret('prod/database/password')
api_key = get_secret('prod/api/key')
```

**10.2.5 Anti-Pattern: Using 'latest' or Unpinned Versions**

**❌ WRONG: Unpredictable base image versions**

```dockerfile
# WRONG - 'latest' tag can change without warning
FROM registry.company.com/base/python:latest

# Also wrong - minor version can introduce breaking changes
FROM registry.company.com/base/python:3.11

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Why this is problematic:**

* 'latest' tag can point to different images tomorrow
* Builds are not reproducible
* Can't roll back to previous version reliably
* Team members may build different images from same Dockerfile
* Production and development may run different code

**Real scenario:**

```
Monday: FROM python:3.11 → pulls python:3.11.7
Wednesday: Platform team releases python:3.11.8 with security patches
Thursday: Developer rebuilds → gets python:3.11.8 → app breaks
Friday: Production still running python:3.11.7 → inconsistency
```

**✅ CORRECT: Pin exact versions with digests**

```dockerfile
# Use specific date-tagged version from base images team
FROM registry.company.com/base/python:3.11-slim-20250115

# Even better - use digest for immutability
FROM registry.company.com/base/python:3.11-slim-20250115@sha256:abc123def456...

# Pin all dependencies too
COPY requirements.txt .
RUN pip install --require-hashes -r requirements.txt

COPY app.py /app/
CMD ["python3", "app.py"]
```

**requirements.txt with hashes:**

```
# requirements.txt
flask==3.0.0 \
    --hash=sha256:abc123def456...
requests==2.31.0 \
    --hash=sha256:def456abc789...
sqlalchemy==2.0.23 \
    --hash=sha256:ghi789jkl012...
```

**Generate hashes automatically:**

```bash
# Generate requirements with hashes
pip-compile --generate-hashes requirements.in > requirements.txt
```

**When to update base images:**

```dockerfile
# Update quarterly or when critical CVEs are patched
# OLD: FROM registry.company.com/base/python:3.11-slim-20250115
# NEW: FROM registry.company.com/base/python:3.11-slim-20250415

# Document why you're updating in commit message:
# "Update base image to 20250415 for OpenSSL CVE-2024-12345 patch"
```

**10.2.6 Anti-Pattern: Bloated Application Images**

**❌ WRONG: Copying entire project directory**

```dockerfile
FROM registry.company.com/base/node:20-alpine-20250115

WORKDIR /app

# WRONG - copies everything including junk
COPY . .

RUN npm install

CMD ["npm", "start"]
```

**What gets copied (unintentionally):**

* .git/ directory (10+ MB, contains entire history)
* node\_modules/ from developer's machine
* .env files with local secrets
* test/ directory with test fixtures
* docs/ directory
* .vscode/, .idea/ IDE configurations
* \*.log files
* build artifacts from local builds

**Result:**

* Image size: 800 MB instead of 200 MB
* Potential secret leakage
* Inconsistent builds (using local node\_modules)
* Longer build and deployment times

**✅ CORRECT: Use .dockerignore and selective COPY**

```
# .dockerignore
.git
.gitignore
.vscode
.idea
*.md
Dockerfile*
docker-compose*.yml
.env
.env.*
*.log
node_modules
coverage
dist
build
.pytest_cache
__pycache__
*.pyc
test
tests
docs
examples
```

```dockerfile
FROM registry.company.com/base/node:20-alpine-20250115 AS builder

WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./
RUN npm ci

# Copy only source code
COPY src/ ./src/
COPY tsconfig.json ./

RUN npm run build

# Production stage - minimal
FROM registry.company.com/base/node:20-alpine-20250115

WORKDIR /app

# Only production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy only built artifacts
COPY --from=builder /app/dist ./dist

CMD ["node", "dist/server.js"]
```

**Result:**

* Image size: 800 MB → 185 MB
* No secrets or unnecessary files
* Reproducible builds
* Faster deployments

**10.2.7 Anti-Pattern: Ignoring Base Image Updates**

**❌ WRONG: Never updating base images**

```dockerfile
# Dockerfile hasn't been updated in 18 months
FROM registry.company.com/base/python:3.10-slim-20230615

# Python 3.10 is now EOL
# Base image has 47 known CVEs
# OpenSSL vulnerable to 3 critical exploits

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Why this is dangerous:**

* Accumulating security vulnerabilities
* Missing performance improvements
* Using deprecated/unsupported software
* Compliance violations
* Technical debt grows exponentially

**What happens:**

* Security team flags your image with critical CVEs
* You're forced to do emergency update during incident
* Update is now complex (18 months of changes)
* Application breaks due to multiple breaking changes
* Weekend spent firefighting instead of gradual updates

**✅ CORRECT: Regular base image updates**

```dockerfile
# Keep base images up to date
FROM registry.company.com/base/python:3.11-slim-20250115

# Update monthly or when platform team notifies
# Critical CVEs: update within 7 days
# Routine updates: update within 30 days

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py /app/
CMD ["python3", "app.py"]
```

**Establish update cadence:**

```yaml
# .github/workflows/base-image-update.yml
name: Check Base Image Updates

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  check-updates:
    runs-on: ubuntu-latest
    steps:
    - name: Check for newer base image
      run: |
        CURRENT=$(grep "^FROM" Dockerfile | awk '{print $2}')
        echo "Current: $CURRENT"
        
        # Get latest version from registry
        LATEST=$(crane ls registry.company.com/base/python | \
                 grep "3.11-slim" | \
                 sort -V | \
                 tail -1)
        echo "Latest: registry.company.com/base/python:$LATEST"
        
        if [ "$CURRENT" != "registry.company.com/base/python:$LATEST" ]; then
          echo "Update available!"
          # Create PR with updated Dockerfile
        fi
```

**Response to platform team notifications:**

```
Subject: [CRITICAL] Base Image Update Required - CVE-2024-12345

The Python 3.11 base image has been updated to patch CVE-2024-12345 
(OpenSSL vulnerability, CVSS 9.8).

Action Required:
1. Update FROM line: python:3.11-slim-20250415
2. Test your application
3. Deploy within 7 days (by 2025-04-22)

Updated image: registry.company.com/base/python:3.11-slim-20250415
Changelog: https://docs.company.com/base-images/python/changelog

Platform Engineering Team
```

**Developer response:**

```bash
# 1. Update Dockerfile
sed -i 's/python:3.11-slim-20250115/python:3.11-slim-20250415/' Dockerfile

# 2. Rebuild and test
docker build -t myapp:test .
docker run --rm myapp:test python -c "import ssl; print(ssl.OPENSSL_VERSION)"

# 3. Run integration tests
./run-tests.sh

# 4. Commit and deploy
git add Dockerfile
git commit -m "Update base image for CVE-2024-12345 (OpenSSL patch)"
git push
```

#### 10.3 Best Practices for Using Base Images

**10.3.1 Multi-Stage Builds for Clean Production Images**

**The pattern:**

```dockerfile
# Stage 1: Build environment (can be large)
FROM registry.company.com/base/python:3.11-slim-20250115 AS builder

# Install build dependencies (these won't be in final image)
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libc6-dev \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

USER appuser
WORKDIR /app

# Build wheels for dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt

# Stage 2: Runtime (minimal and secure)
FROM registry.company.com/base/python:3.11-slim-20250115

WORKDIR /app

# Copy only the built wheels (no build tools)
COPY --from=builder /app/wheels /wheels
COPY requirements.txt .
RUN pip install --user --no-cache-dir --find-links=/wheels -r requirements.txt && \
    rm -rf /wheels

# Copy application
COPY --chown=appuser:appuser app/ ./app/

# Already running as non-root user from base image
CMD ["python", "-m", "app.main"]
```

**Benefits:**

* Build stage: 850 MB (with gcc, build tools)
* Runtime stage: 180 MB (only runtime dependencies)
* No build tools for attackers to abuse
* Faster deployments and pod startup

**10.3.2 Proper Dependency Management**

**Pin everything:**

```dockerfile
FROM registry.company.com/base/node:20-alpine-20250115@sha256:abc123...

WORKDIR /app

# package.json with exact versions
# {
#   "dependencies": {
#     "express": "4.18.2",      // NOT "^4.18.2"
#     "pg": "8.11.3",            // NOT "~8.11.0"
#     "lodash": "4.17.21"        // NOT "latest"
#   }
# }

COPY package*.json ./

# Use 'ci' not 'install' for reproducible builds
RUN npm ci

COPY . .

CMD ["node", "server.js"]
```

**Lock files are mandatory:**

* package-lock.json for npm
* yarn.lock for Yarn
* poetry.lock for Poetry
* Cargo.lock for Rust
* go.mod and go.sum for Go

**Always commit lock files to git!**

**10.3.3 Efficient Layer Caching**

**Order matters:**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

WORKDIR /app

# ❌ WRONG ORDER - invalidates cache on every code change
# COPY . .
# RUN pip install -r requirements.txt

# ✅ CORRECT ORDER - dependencies cached separately
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Code changes don't invalidate dependency layer
COPY app/ ./app/

CMD ["python", "-m", "app.main"]
```

**Cache invalidation example:**

```
Change one line in app.py:
  ❌ Wrong order: Reinstalls ALL dependencies (5 minutes)
  ✅ Right order: Uses cached dependencies (5 seconds)
```

**10.3.4 Health Checks and Observability**

**Add proper health checks:**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

WORKDIR /app

COPY requirements.txt .
RUN pip install --user -r requirements.txt

COPY app/ ./app/

# Define health check (helps Kubernetes know if app is healthy)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health').raise_for_status()" || exit 1

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Implement health endpoint in application:**

```python
# app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    """Health check endpoint for container orchestration"""
    # Check database connection
    # Check external service connectivity
    # Return 200 if healthy, 503 if not
    return {"status": "healthy"}

@app.get("/ready")
async def readiness_check():
    """Readiness check - is app ready to receive traffic?"""
    # Check if initialization complete
    # Check if dependencies are available
    return {"status": "ready"}
```

**10.3.5 Proper Logging Configuration**

**Log to stdout/stderr, not files:**

```python
# ❌ WRONG - logging to files in container
import logging

logging.basicConfig(
    filename='/var/log/app.log',  # Don't do this!
    level=logging.INFO
)
```

**Problems:**

* Log files grow indefinitely, filling up container disk
* Can't view logs with `kubectl logs` or `docker logs`
* Logs lost when container restarts
* Need to mount volumes just for logs

```python
# ✅ CORRECT - log to stdout
import logging
import sys

logging.basicConfig(
    stream=sys.stdout,  # Log to stdout
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)
logger.info("Application started")
```

**Structured logging (even better):**

```python
import structlog

# Structured logs are easier to parse and analyze
logger = structlog.get_logger()

logger.info(
    "user_login",
    user_id=user.id,
    ip_address=request.remote_addr,
    success=True
)
```

#### 10.4 Testing Your Images

**10.4.1 Local Testing Before Push**

**Always test locally first:**

```bash
#!/bin/bash
# test-image.sh

set -e

IMAGE_NAME="myapp"
IMAGE_TAG="test-$(git rev-parse --short HEAD)"

echo "Building image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Testing image security..."
# Check if running as root
RUNNING_USER=$(docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} id -u)
if [ "$RUNNING_USER" = "0" ]; then
    echo "❌ ERROR: Image running as root!"
    exit 1
fi
echo "✅ Running as non-root user (uid: $RUNNING_USER)"

# Scan for vulnerabilities
echo "Scanning for vulnerabilities..."
trivy image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_NAME}:${IMAGE_TAG}

# Check image size
echo "Checking image size..."
SIZE=$(docker images ${IMAGE_NAME}:${IMAGE_TAG} --format "{{.Size}}")
echo "Image size: $SIZE"

# Test application functionality
echo "Testing application..."
docker run -d --name test-${IMAGE_TAG} -p 8000:8000 ${IMAGE_NAME}:${IMAGE_TAG}
sleep 5

# Health check
curl -f http://localhost:8000/health || {
    echo "❌ Health check failed!"
    docker logs test-${IMAGE_TAG}
    docker rm -f test-${IMAGE_TAG}
    exit 1
}
echo "✅ Health check passed"

# Cleanup
docker rm -f test-${IMAGE_TAG}

echo "✅ All tests passed! Safe to push."
```

**10.4.2 Verify Base Image Compliance**

**Check that you're using approved base image:**

```bash
#!/bin/bash
# check-base-image.sh

DOCKERFILE="Dockerfile"

# Extract FROM line
BASE_IMAGE=$(grep "^FROM" $DOCKERFILE | head -1 | awk '{print $2}')

echo "Checking base image: $BASE_IMAGE"

# Verify it's from approved registry
if [[ ! "$BASE_IMAGE" =~ ^registry\.company\.com/base/ ]]; then
    echo "❌ ERROR: Not using approved base image!"
    echo "Base image must be from: registry.company.com/base/"
    echo "Current: $BASE_IMAGE"
    exit 1
fi

# Verify it's not using 'latest' tag
if [[ "$BASE_IMAGE" =~ :latest ]]; then
    echo "❌ ERROR: Using 'latest' tag is prohibited!"
    echo "Use specific version tag like: python:3.11-slim-20250115"
    exit 1
fi

# Verify image is signed
echo "Verifying image signature..."
cosign verify \
    --certificate-identity-regexp '.*' \
    --certificate-oidc-issuer-regexp '.*' \
    $BASE_IMAGE || {
    echo "❌ ERROR: Base image signature verification failed!"
    exit 1
}

echo "✅ Base image compliance check passed"
```

#### 10.5 Common Developer Questions

**Q: "The base image doesn't have the package I need. What do I do?"**

**Option 1: Check if it's really needed at runtime**

```dockerfile
# ❌ Don't do this if you only need it at build time
FROM registry.company.com/base/python:3.11-slim-20250115
USER root
RUN apt-get update && apt-get install -y gcc
USER appuser
```

```dockerfile
# ✅ Use multi-stage build instead
FROM registry.company.com/base/python:3.11-slim-20250115 AS builder
USER root
RUN apt-get update && apt-get install -y gcc
# ... build your app
USER appuser

FROM registry.company.com/base/python:3.11-slim-20250115
# Copy built artifacts only
```

**Option 2: Request it be added to base image**

Create a ticket with platform team:

```
Title: Add imagemagick to Python base image

Justification:
- Used by 5 teams for image processing
- Required at runtime for thumbnail generation
- Security: imagemagick 7.1.1 (latest stable)
- Size impact: ~12 MB

Alternative considered:
- Multi-stage build (not feasible - need runtime processing)
- External service (adds latency and complexity)
```

**Option 3: Use a specialized base image**

If it's unique to your team:

```dockerfile
# Create your own application base FROM approved base
FROM registry.company.com/base/python:3.11-slim-20250115 AS custom-base

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends imagemagick && \
    rm -rf /var/lib/apt/lists/*
USER appuser

# Now use this as YOUR base for multiple apps
FROM custom-base
COPY app.py .
```

**Q: "My application needs to write files. How do I do that with read-only filesystem?"**

**Use designated writable locations:**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

WORKDIR /app

# Create writable directories
RUN mkdir -p /app/uploads /app/cache && \
    chown appuser:appuser /app/uploads /app/cache

COPY app.py .

# App can write to /app/uploads and /app/cache
CMD ["python", "app.py"]
```

```python
# app.py
UPLOAD_DIR = "/app/uploads"  # Writable
CACHE_DIR = "/app/cache"     # Writable

# Don't try to write to /usr, /etc, /var, etc.
```

**Or use Kubernetes volumes:**

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        volumeMounts:
        - name: uploads
          mountPath: /app/uploads
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: uploads
        persistentVolumeClaim:
          claimName: uploads-pvc
      - name: tmp
        emptyDir: {}
```

**Q: "Can I use a different base image for local development vs production?"**

**No. Use the same base image everywhere.**

```dockerfile
# ❌ WRONG - different images for different environments
# FROM python:3.11-slim-bookworm  # Local dev
FROM registry.company.com/base/python:3.11-slim-20250115  # Production
```

**Why:**

* "Works on my machine" problems
* Different vulnerabilities in dev vs prod
* Inconsistent behavior
* Defeats purpose of containers

**✅ CORRECT - Same image everywhere:**

```dockerfile
FROM registry.company.com/base/python:3.11-slim-20250115

# Use environment variables for env-specific config
ENV FLASK_ENV=${FLASK_ENV:-production}

COPY app.py .

CMD ["python", "app.py"]
```

```bash
# Local dev - same image, different config
docker run -e FLASK_ENV=development myapp

# Production - same image
docker run -e FLASK_ENV=production myapp
```

#### 10.6 Pre-Commit Checklist

Before committing Dockerfile changes, verify:

```markdown
## Dockerfile Pre-Commit Checklist

- [ ] Using approved base image from registry.company.com/base/
- [ ] Base image tag is specific date version (not 'latest')
- [ ] Not switching to root user after base image sets non-root
- [ ] No secrets embedded in image (no ENV, no ARG with secrets)
- [ ] Using .dockerignore to exclude unnecessary files
- [ ] Multi-stage build if build dependencies needed
- [ ] All dependencies pinned to specific versions
- [ ] Minimal layer count (combine RUN commands)
- [ ] Proper COPY order for layer caching
- [ ] HEALTHCHECK defined
- [ ] Logging to stdout/stderr (not files)
- [ ] Tested locally with test-image.sh
- [ ] Scanned with Trivy (no HIGH or CRITICAL)
- [ ] Image size reasonable (<500MB for most apps)
- [ ] Documented any custom changes in commit message
```

#### 10.7 Getting Help

**When you're stuck:**

1. **Check Documentation**: https://docs.company.com/base-images/
2. **Slack Channel**: #base-images-support
3. **Office Hours**: Every Tuesday 2-3pm
4. **Create Ticket**: For feature requests or bugs
5. **Emergency**: Page platform-engineering (P1 issues only)

**What to include when asking for help:**

```
Subject: [Help] Python base image - need PostgreSQL client

Environment: Development
Base Image: registry.company.com/base/python:3.11-slim-20250115
Issue: Need to install postgresql-client for database backups

What I tried:
- Multi-stage build (doesn't work - need at runtime)
- pip install psycopg2 (works but need pg_dump binary)

Question: Should I request postgresql-client be added to Python base image?
Or is there a better approach?

Dockerfile snippet:
[paste relevant Dockerfile section]

Error output:
[paste error if applicable]
```

***

### 11. The Container Base Images Team: Structure and Operations

#### 11.1 The Case for Centralization

Organizations that successfully scale container adoption almost universally adopt a centralized approach to base image management. This isn't merely an operational convenience—it's a strategic necessity driven by several factors that become more critical as container usage grows.

**11.1.1 The Cost of Decentralization**

When individual development teams maintain their own base images, organizations face compounding problems:

**Knowledge Fragmentation**\
Security expertise gets diluted across teams. A critical CVE affecting OpenSSL requires coordination across dozens of teams, each maintaining their own fork of Ubuntu or Alpine. Response time measured in weeks instead of hours.

**Redundant Effort**\
Ten teams building Node.js images means ten teams researching the same security hardening, ten teams implementing non-root users, ten teams fighting the same dockerfile caching issues. Multiply this across Python, Java, Go, and other runtimes.

**Inconsistent Security Posture**\
Team A's images drop all capabilities and use distroless. Team B's images run as root with a full Ubuntu install. Both are "approved" because there's no central standard. Incident responders waste hours understanding each team's custom security model.

**Scale Problems**\
With 100 development teams each maintaining 3 images, that's 300 images to track, scan, and update. When a critical vulnerability drops, coordinating remediation across 100 teams is organizational chaos.

**Compliance Nightmares**\
Auditors ask "How many of your container images have critical vulnerabilities?" The answer: "We don't know—each team manages their own." SOC 2, ISO 27001, and PCI-DSS audits become exponentially more complex.

**11.1.2 The Benefits of Centralization**

Industry leaders like Netflix, Google, and Spotify have demonstrated that centralizing base image management delivers measurable benefits:

Netflix uses centralized base images created by their Aminator tool, enabling them to launch three million containers per week with consistent security and operational standards across all workloads.

**Single Source of Truth**\
One team maintains the "golden images" that serve as the foundation for all applications. When CVE-2024-12345 hits, one team patches it once, and all consuming teams rebuild. Response time: hours, not weeks.

**Expert Focus**\
A dedicated team develops deep expertise in container security, operating system hardening, supply chain security, and vulnerability management. This expertise is difficult to maintain when spread across application teams focused on business logic.

**Consistent Security**\
All images follow the same hardening standards: non-root users, minimal packages, dropped capabilities, signed SBOMs. Security tooling knows what to expect. Incident response is streamlined because all images follow known patterns.

**Economies of Scale**\
One team maintaining 20 well-crafted base images serves 100 application teams building 500+ application images. The cost of the base images team is amortized across the entire engineering organization.

**Faster Developer Onboarding**\
New developers don't need to learn dockerfile best practices, security hardening, or vulnerability management. They start FROM an approved base and focus on application code.

**Audit Simplicity**\
"How many critical vulnerabilities in base images?" Answer: "Zero—we have automated scanning with blocking gates." "How do you track software licenses?" Answer: "Every base image has a signed SBOM in our registry."

#### 11.2 Team Structure and Composition

The Container Base Images team (often called Platform Engineering, Developer Experience, or Golden Images team) typically sits at the intersection of infrastructure, security, and developer productivity. The exact structure varies based on organization size, but follows common patterns.

**11.2.1 Core Team Roles**

**Platform Engineering Lead (Technical Lead)**

This role owns the strategic direction and technical decisions for the base images program.

Responsibilities:

* Define base image strategy and roadmap
* Establish security and operational standards
* Make technology choices (which base OS, scanning tools, registry platform)
* Resolve conflicts between security requirements and developer needs
* Represent base images in architecture reviews and security forums
* Own relationships with security, compliance, and development leadership

Technical profile:

* Deep expertise in containers, Linux, and cloud platforms
* Strong security background (CVE analysis, threat modeling)
* Experience with large-scale infrastructure (1000+ hosts)
* Understanding of software development workflows and pain points
* Ability to design systems for 100+ consuming teams

Typical background: Senior infrastructure engineer, former SRE/DevOps lead, or security engineer with platform experience.

**Container Platform Engineers (2-4 engineers)**

These are the hands-on builders who create, maintain, and improve base images.

Responsibilities:

* Build and maintain base images for different runtimes (Python, Node.js, Java, Go)
* Implement security hardening (minimal packages, non-root, capabilities)
* Automate image builds with CI/CD pipelines
* Integrate scanning tools (Trivy, Grype, Syft)
* Generate and sign SBOMs
* Manage the container registry infrastructure
* Respond to security vulnerabilities in base images
* Write documentation and runbooks
* Provide technical support to development teams

Technical profile:

* Strong Linux system administration skills
* Proficiency with Docker, Kubernetes, and container runtimes
* Scripting and automation (Python, Bash, Go)
* CI/CD expertise (GitHub Actions, GitLab CI, Jenkins)
* Security tooling experience (vulnerability scanners, SBOM generators)

Typical background: DevOps engineers, infrastructure engineers, or developers with strong ops experience.

**Security Engineer (Dedicated or Shared, 0.5-1 FTE)**

This role ensures base images meet security standards and responds to vulnerabilities.

Responsibilities:

* Define security requirements for base images
* Review and approve security hardening configurations
* Triage vulnerability scan results
* Assess exploitability and business impact of CVEs
* Coordinate security incident response for container issues
* Conduct security audits of base images
* Stay current on container security threats and best practices
* Provide security training to platform engineers

Technical profile:

* Container security expertise (image scanning, runtime security, admission control)
* Vulnerability management experience
* Understanding of attack vectors and exploit techniques
* Familiarity with compliance frameworks (SOC 2, ISO 27001, PCI-DSS)
* Ability to communicate risk to both technical and non-technical audiences

Typical background: Application security engineer, infrastructure security engineer, or security architect.

**Developer Experience Engineer (Optional, 0.5-1 FTE)**

This role focuses on making base images easy to use and understand for development teams.

Responsibilities:

* Create comprehensive documentation and tutorials
* Develop example applications demonstrating base image usage
* Provide office hours and Slack support
* Gather feedback from development teams
* Create metrics dashboards showing base image adoption
* Run training sessions and workshops
* Advocate for developer needs in base image design
* Build CLI tools and plugins to simplify common workflows

Technical profile:

* Strong technical writing and communication skills
* Understanding of developer workflows and pain points
* Ability to translate technical concepts for different audiences
* Basic to intermediate container knowledge
* User research and feedback analysis skills

Typical background: Developer advocate, technical writer, or developer with strong communication skills.

**11.2.2 Extended Team and Stakeholders**

The base images team doesn't work in isolation. Success requires close collaboration with multiple groups:

**Security Team Partnership**

The security team provides:

* Security requirements and standards
* Threat intelligence and vulnerability context
* Security audits and penetration testing
* Incident response coordination
* Compliance requirements interpretation

Integration points:

* Weekly sync on new vulnerabilities and remediation status
* Monthly security reviews of base images
* Quarterly security audits and penetration tests
* Joint incident response for container security issues
* Security team has read access to base image repositories
* Security team receives automated notifications of failed security scans

**Application Development Teams (The Customers)**

Development teams consume base images and provide feedback:

* Use base images as FROM in their Dockerfiles
* Report bugs and request new features
* Provide feedback on documentation and usability
* Participate in beta testing of new base image versions
* Attend office hours and training sessions

Communication channels:

* Dedicated Slack channel (#base-images-support)
* Monthly office hours (Q\&A session)
* Quarterly all-hands presentation on roadmap and updates
* Email distribution list for critical announcements
* Self-service documentation portal

**Compliance and Legal Teams**

These teams ensure base images meet regulatory and legal requirements:

* Review license compliance for all included packages
* Validate SBOM generation and accuracy
* Ensure audit trail for all base image changes
* Approve exception requests for non-standard licenses
* Participate in external audits (SOC 2, ISO 27001)

Integration points:

* Automated SBOM delivery for all base images
* Quarterly compliance review meetings
* Annual audit preparation and support
* License approval workflow integration

**Cloud Infrastructure Team**

The infrastructure team provides the foundation:

* Container registry infrastructure (Harbor, ECR, ACR)
* CI/CD platform (Jenkins, GitLab, GitHub Actions)
* Monitoring and observability platform
* Backup and disaster recovery
* Network connectivity and access control

Shared responsibilities:

* Registry capacity planning and scaling
* Performance optimization
* Incident response for registry outages
* Cost optimization for storage and bandwidth

**11.2.3 Team Scaling Model**

Team size scales based on organization size and container adoption:

**Small Organization (< 50 developers)**

* 1 Platform Engineering Lead (50% time)
* 1-2 Platform Engineers
* Security Engineer (shared resource, 25% time)
* Supports: 5-10 base images, 50-100 application images

**Medium Organization (50-500 developers)**

* 1 Platform Engineering Lead (full time)
* 2-3 Platform Engineers
* 1 Security Engineer (dedicated, shared with AppSec)
* 1 Developer Experience Engineer (50% time)
* Supports: 15-25 base images, 200-500 application images

**Large Organization (500+ developers)**

* 1 Platform Engineering Lead
* 4-6 Platform Engineers (may specialize by runtime or OS)
* 1-2 Security Engineers (dedicated)
* 1 Developer Experience Engineer
* 1 Site Reliability Engineer (focused on registry operations)
* Supports: 30+ base images, 1000+ application images

Netflix's Titus platform team, which manages container infrastructure for the entire company, enables over 10,000 long-running service containers and launches three million containers per week, demonstrating how a focused platform team can support massive scale.

#### 11.3 Responsibilities and Accountability

Clear ownership prevents gaps and duplication. The base images team owns specific layers of the container stack.

**11.3.1 What the Base Images Team Owns**

**Base Operating System Images**

Complete responsibility for OS-level base images:

* Ubuntu 22.04, Alpine 3.19, Red Hat UBI 9
* OS package selection and minimization
* Security hardening (sysctl, file permissions, user configuration)
* OS vulnerability patching and updates
* OS-level compliance (CIS benchmarks, DISA STIGs)

Example: When CVE-2024-XXXX affects glibc in Ubuntu 22.04, the base images team:

1. Assesses impact (which base images affected, exploitability)
2. Builds patched base images
3. Tests for breaking changes
4. Publishes updated images
5. Notifies all consuming teams
6. Tracks adoption and follows up

**Language Runtime Images**

Complete responsibility for language runtime base images:

* Python 3.11, Node.js 20, OpenJDK 21, Go 1.21, .NET 8
* Runtime installation and configuration
* Runtime security hardening
* Runtime vulnerability patching
* Best practice examples and documentation

Example: When a vulnerability affects the Node.js HTTP parser, the base images team:

1. Updates Node.js runtime in all supported versions (Node 18, 20, 22)
2. Rebuilds and tests base images
3. Updates documentation with migration notes
4. Publishes updated images with detailed changelogs
5. Notifies teams via Slack and email

**Image Build Infrastructure**

Complete responsibility for the build and publishing pipeline:

* CI/CD pipelines for automated builds
* Build environment security and compliance
* Image signing infrastructure (Cosign, Notary)
* SBOM generation automation
* Image promotion workflows
* Build reproducibility

**Registry Infrastructure and Governance**

Complete responsibility for the container registry:

* Registry infrastructure (Harbor, ECR, ACR deployment)
* High availability and disaster recovery
* Access control and authentication
* Image replication across regions
* Storage optimization and garbage collection
* Registry monitoring and alerting
* Backup and restore procedures

**Security Scanning and Vulnerability Management**

Complete responsibility for base layer vulnerability management:

* Vulnerability scanning infrastructure (Trivy, Grype, Clair)
* Scan result analysis and triage
* Base layer vulnerability remediation
* Security advisory publication
* Vulnerability metrics and reporting

**Documentation and Developer Support**

Complete responsibility for enabling teams to use base images:

* Comprehensive usage documentation
* Best practices guides
* Migration guides for version updates
* Troubleshooting guides
* Example applications and templates
* Office hours and support channels
* Training materials and workshops

**11.3.2 What the Base Images Team Does NOT Own**

Clear boundaries prevent scope creep and confusion.

**Application Code and Business Logic**

Application teams own:

* All application source code
* Application-specific logic and features
* Application configuration
* Application testing and quality assurance

The base images team provides the platform; application teams build on it.

**Application Dependencies**

Application teams own:

* Python packages installed via pip (requirements.txt)
* Node.js packages installed via npm (package.json)
* Java dependencies from Maven/Gradle
* Go modules
* Any other application-level dependencies

When a vulnerability exists in Flask, Django, Express, or Spring Boot, the application team must update those dependencies. The base images team may provide guidance, but does not own the remediation.

**Application-Specific System Packages**

Application teams own packages they add for application needs:

* Database clients (postgresql-client, mysql-client)
* Media processing libraries (ffmpeg, imagemagick)
* Specialized utilities (wkhtmltopdf, pandoc)

The base images team provides minimal base images; application teams add what they specifically need.

**Runtime Configuration**

Application teams own:

* Environment variables and configuration files
* Application-specific security policies
* Resource limits and requests
* Health check endpoints
* Logging and monitoring configuration

The base images team provides sensible defaults; application teams customize for their needs.

**Kubernetes Manifests and Deployment**

Application teams own:

* Deployment YAML files
* Service definitions
* Ingress configurations
* ConfigMaps and Secrets
* Network policies
* Pod security contexts

The base images team may provide best practice examples, but does not own production deployments.

**11.3.3 Shared Responsibilities**

Some areas require coordination between teams.

**Image Rebuilds After Base Updates**

Shared responsibility model:

* Base Images Team: Publishes updated base images with detailed release notes
* Application Teams: Rebuilds their images using updated base within SLA
* Both: Coordinate testing and rollout to minimize disruption

SLA example:

* Critical vulnerabilities: Application teams must rebuild within 7 days
* High vulnerabilities: Application teams must rebuild within 30 days
* Routine updates: Application teams should rebuild monthly

**Incident Response**

Shared responsibility based on incident type:

* Container runtime vulnerabilities (runC, containerd): Base Images Team leads
* Base OS vulnerabilities: Base Images Team leads
* Application vulnerabilities: Application Team leads
* Configuration issues: Application Team leads, Base Images Team advises
* Registry outages: Infrastructure Team leads, Base Images Team supports

**Security Audits and Compliance**

Shared responsibility:

* Base Images Team: Provides evidence for base image security controls
* Application Teams: Provides evidence for application-level controls
* Security Team: Conducts audits and validates controls
* Compliance Team: Interprets requirements and coordinates audits

#### 11.4 Cross-Team Collaboration Models

Effective collaboration is what makes centralized base images work. Different organizations adopt different models.

**11.4.1 Platform-as-a-Product Model**

Platform engineering teams treat the platform as a product rather than a project, providing clear guidance to other teams on how to interact via collaboration or self-service interfaces.

In this model, base images are a product with customers (development teams).

**Product Management Approach**

The base images team acts as a product team:

* Maintains a public roadmap of planned features and improvements
* Collects feature requests through structured process
* Prioritizes work based on customer impact
* Conducts user research and feedback sessions
* Measures success through adoption metrics and satisfaction scores

Example roadmap:

```
Q1 2025:
- Add Rust base image (high demand from 5 teams)
- Implement automated base image rebuilds (reduce maintenance burden)
- Add multi-arch support (ARM64 for cost savings)

Q2 2025:
- Migrate to distroless for production images (reduce CVE count by 60%)
- Add Air Gap support for secure environments
- Improve documentation with interactive tutorials
```

**Self-Service First**

Developers should be able to use base images without tickets or approvals:

* Comprehensive documentation answers 90% of questions
* Example applications demonstrate common patterns
* Automated tools (CLI, IDE plugins) simplify workflows
* Clear error messages guide developers to solutions

When developers need help:

1. Check documentation and examples (self-service)
2. Ask in Slack channel (peer support)
3. Attend office hours (group support)
4. Create a ticket (last resort)

**Feedback Loops**

Regular mechanisms for gathering feedback:

* Quarterly surveys measuring satisfaction and pain points
* Monthly office hours for Q\&A and feedback
* Dedicated Slack channel monitored by team
* Embedded engineer rotations (team member temporarily joins app team)
* Retrospectives after major incidents or changes

**SLAs and Commitments**

The base images team makes explicit commitments:

* Critical vulnerability patches: Published within 24 hours
* High vulnerability patches: Published within 7 days
* Feature requests: Initial response within 3 business days
* Support questions: Response within 1 business day
* Registry uptime: 99.9% availability

**11.4.2 Embedded Engineer Model**

Some organizations embed platform engineers temporarily with application teams.

**How It Works**

A platform engineer spends 2-4 weeks embedded with an application team:

* Sits with the team (physically or virtually)
* Participates in standups and planning
* Helps migrate applications to approved base images
* Identifies pain points and improvement opportunities
* Provides training and knowledge transfer
* Brings learnings back to platform team

Benefits:

* Deep understanding of real developer workflows
* Trust building between platform and application teams
* Accelerated adoption of base images
* Identification of documentation gaps
* Real-world testing of platform features

Example rotation schedule:

* Week 1-2: Embedded with Team A (payments team)
* Week 3-4: Embedded with Team B (recommendations team)
* Week 5-6: Back on platform team, incorporating learnings
* Repeat with different teams quarterly

**11.4.3 Guild or Center of Excellence Model**

Team Topologies emphasizes collaboration and community models where platform teams establish communities of practice to share knowledge and standards across the organization.

A Container Guild brings together representatives from multiple teams.

**Guild Structure**

* Meets monthly or quarterly
* Members: Representatives from base images team + app teams
* Rotating chair from application teams
* Open to all interested engineers

**Guild Responsibilities**

* Review and approve base image roadmap
* Share knowledge and best practices across teams
* Identify common pain points and solutions
* Evangelize base images within their teams
* Provide feedback on proposals before implementation
* Help prioritize feature requests

**Example Guild Activities**

* Lightning talks: Teams share how they use base images
* Working groups: Tackle specific problems (multi-arch, air-gapped deployments)
* RFC reviews: Comment on proposed changes to base images
* Show and tell: Demonstrations of new features
* Post-mortem reviews: Learn from incidents together

#### 11.5 Collaboration with Security Team

The relationship with the security team is critical. Done wrong, it creates friction and slow-downs. Done right, it enables speed with confidence.

**11.5.1 Security Partnership Model**

**Security as Enabler, Not Gatekeeper**

Modern security teams enable safe velocity rather than blocking releases:

* Provide automated tools (scanners, policies) rather than manual reviews
* Define clear requirements rather than case-by-case approvals
* Offer self-service compliance checks rather than ticket queues
* Build guard rails rather than gates

Traditional (Slow):

```
Developer: "Can I use this base image?"
Security: "Submit a ticket. We'll review in 2 weeks."
Developer: "But I need to ship this feature..."
Security: "Sorry, security can't be rushed."
```

Modern (Fast):

```
Developer: Builds from approved base image
Pipeline: Automatically scans for vulnerabilities
Pipeline: Blocks deployment if critical CVEs found
Developer: Sees clear error message with remediation steps
Developer: Updates dependency, rebuild passes, ships feature
Security: Reviews metrics dashboard showing 99% compliant deployments
```

**Joint Ownership of Security Standards**

Base Images Team and Security Team collaborate to define standards:

* Base Images Team proposes technical implementation
* Security Team defines security requirements
* Both teams iterate until requirements can be met practically
* Security Team audits, Base Images Team implements
* Both teams share accountability for security outcomes

Example collaboration on "non-root requirement":

```
Security Team: "All containers must run as non-root (UID >= 1000)"
Base Images Team: "We can do this. Concerns: some apps expect root. 
                  Proposal: Use UID 10001, provide migration guide."
Security Team: "Agreed. Can you add detection for processes running as root?"
Base Images Team: "Yes. We'll add runtime monitoring with Falco."
Both Teams: Document standard, implement detection, train teams
```

**11.5.2 Integration Points**

**Weekly Vulnerability Triage**

Regular sync between Base Images Team and Security Team:

* Review new CVEs affecting base images
* Assess exploitability and business impact
* Prioritize remediation work
* Coordinate communication to application teams

Meeting structure (30 minutes):

1. Review critical CVEs from past week (10 min)
2. Update status on in-progress remediations (5 min)
3. Discuss upcoming security changes (10 min)
4. Review metrics: CVE count, MTTR, compliance rate (5 min)

**Quarterly Security Audits**

Security Team conducts comprehensive audits:

* Review all base images for compliance with security standards
* Penetration testing of container runtime environment
* Audit of build pipeline security
* Review of access controls and authentication
* Validate SBOM accuracy and completeness

Output: Audit report with findings and recommendations Follow-up: Base Images Team addresses findings with defined timeline

**Joint Incident Response**

When container security incidents occur:

* Security Team leads investigation and coordination
* Base Images Team provides technical expertise on containers
* Both teams participate in incident response calls
* Base Images Team implements technical remediation
* Security Team coordinates communication with stakeholders
* Both teams participate in post-incident review

**Shared Metrics Dashboard**

Real-time dashboard visible to both teams:

* Number of base images and application images
* CVE count by severity across all images
* Mean time to remediation for vulnerabilities
* Percentage of images in compliance
* Number of images with signed SBOMs
* Registry availability and performance

Both teams use same metrics for decision-making and prioritization.

**11.5.3 Security Team's Role in Base Images**

**What Security Team Provides**

Security Requirements Definition:

* "No critical or high CVEs in production"
* "All images must run as non-root"
* "All images must have signed SBOM"
* "Images must follow CIS benchmarks"

Threat Intelligence:

* Context on new vulnerabilities (exploitability, active exploitation)
* Information on attack techniques targeting containers
* Updates on regulatory requirements affecting containers

Security Tooling Expertise:

* Recommendations on scanning tools
* Configuration of security policies
* Integration with SIEM and SOAR platforms

Audit and Compliance:

* Interpretation of compliance requirements
* Evidence collection for audits
* Attestation of security controls

**What Security Team Does NOT Own**

Technical Implementation:

* Security defines "run as non-root"
* Base Images Team implements it in Dockerfiles

Day-to-Day Operations:

* Security defines scanning requirements
* Base Images Team operates scanners and triages results

Developer Support:

* Security defines security training content
* Base Images Team delivers training and provides ongoing support

#### 11.6 Governance and Decision Making

Clear governance prevents conflicts and ensures alignment.

**11.6.1 Decision Authority**

**Base Images Team Has Authority Over:**

* Which base operating systems to support (Ubuntu vs Alpine vs RHEL)
* Which language runtimes and versions to provide
* Technical implementation details (specific hardening techniques)
* Build pipeline and tooling choices
* Release schedule and versioning scheme
* Registry infrastructure decisions

**Security Team Has Authority Over:**

* Security requirements and standards
* Acceptable vulnerability thresholds
* Exception approvals for security policy violations
* Incident response procedures
* Compliance interpretation

**Joint Decision Making Required For:**

* Adding new base image types that deviate from standards
* Changes to security scanning thresholds
* Major architectural changes affecting security
* Exception processes and approval workflows

**Application Teams Have Authority Over:**

* Which approved base image to use for their application
* When to rebuild images after base updates (within SLA)
* Application-specific configuration and dependencies

**11.6.2 RFC (Request for Comments) Process**

For significant changes, teams use an RFC process:

```markdown
# RFC-042: Add Rust Base Image

## Author
Jane Chen (Platform Engineering Team)

## Status
Proposed → Under Review → Accepted → Implemented

## Summary
Add official Rust base image to support growing number of Rust applications.

## Motivation
5 teams have requested Rust support. Currently using unofficial Rust images
from Docker Hub with unknown security posture.

## Proposal
Create minimal Rust base images for versions 1.75, 1.76, 1.77
Base: Debian 12 slim
Includes: rustc, cargo, common build tools
Security: Non-root user (uid 10001), minimal packages

## Security Considerations
- Rust itself has good security track record
- Small attack surface compared to C/C++
- Will follow same hardening standards as other base images
- Rust packages managed via Cargo (application team responsibility)

## Alternatives Considered
1. Wait for official Rust distroless images (ETA: unknown)
2. Use Alpine-based Rust (smaller but musl compatibility issues)
3. Let teams continue using Docker Hub images (security risk)

## Open Questions
- Support both stable and nightly Rust channels?
- Include cross-compilation support?

## Implementation Plan
Week 1-2: Create Dockerfile and test builds
Week 3: Security review and hardening
Week 4: Documentation and examples
Week 5: Beta release to requesting teams
Week 6: GA release after beta feedback

## Feedback
[Space for reviewers to provide feedback]

Security Team: Approved. Ensure SBOMs include Rust toolchain.
Dev Team A: Excited for this! Can we get nightly channel too?
Dev Team B: Please include cross-compilation for ARM.
```

The RFC is reviewed by:

* Security Team (security implications)
* Relevant application teams (usability)
* Infrastructure team (registry capacity)
* Platform engineering leadership (strategic fit)

Approval requires: Security sign-off + majority support from stakeholders

**11.6.3 Exception Process**

Sometimes teams need exceptions from standard policies.

**When Exceptions Are Needed**

* Legacy application cannot run on approved base images
* Regulatory requirement demands specific OS version not yet supported
* Performance requirement necessitates specific optimization
* Time-bound workaround while permanent solution is developed

**Exception Request Process**

```yaml
exception_request:
  id: EXC-2025-042
  requester: Team Payments
  date_submitted: 2025-10-15
  
  request:
    policy_violated: "All production images must use approved base images"
    requested_exception: "Use Ubuntu 18.04 base image (deprecated)"
    justification: |
      Legacy payment processing application requires Python 2.7
      which is not available in our Ubuntu 22.04 base image.
      Migration to Python 3.11 estimated at 6 months.
  
  risk_assessment:
    vulnerability_count:
      critical: 0
      high: 3
      medium: 12
    compensating_controls:
      - Network segmentation (no internet access)
      - Additional monitoring with Falco
      - Weekly vulnerability scans
      - Dedicated firewall rules
    residual_risk: MEDIUM
  
  approval:
    security_team: APPROVED (with conditions)
    platform_team: APPROVED
    approver: CISO
    expiration_date: 2026-04-15  # 6 months for migration
    
  conditions:
    - Quarterly risk review
    - Migration to Python 3.11 must begin within 3 months
    - Exception expires regardless of migration status
    - Team must respond to high CVEs within 48 hours
```

#### 11.7 Prerequisites for Centralization

Successfully centralizing base image management requires organizational prerequisites.

**11.7.1 Executive Sponsorship**

Centralization will disrupt existing workflows. Executive support is essential.

**What Leadership Must Provide**

Mandate and Authority:

* Clear statement that all teams will use centralized base images
* Authority for base images team to set standards
* Backing when teams push back on changes
* Budget for team headcount and tooling

Example executive communication:

```
From: CTO
To: All Engineering
Subject: Standardizing on Centralized Base Images

Starting Q1 2025, all container deployments must use base images 
provided by the Platform Engineering team. This initiative improves 
our security posture, reduces redundant work, and enables faster 
response to vulnerabilities.

The Platform Engineering team will provide comprehensive support 
during this transition. Teams have 6 months to migrate existing 
applications.

This is not optional. Security and operational efficiency require 
standardization. I'm personally committed to making this successful.
```

**What Leadership Must NOT Do**

* Undermine the base images team when teams complain
* Allow individual teams to opt out without valid reason
* Cut budget or headcount before the program is mature
* Set unrealistic timelines without consulting the team

**11.7.2 Organizational Readiness**

Cultural Readiness:

* Teams must accept that not every team needs custom base images
* Willingness to adopt shared standards over team-specific preferences
* Trust in platform team to make good technical decisions
* Commitment to collaboration over silos

Technical Readiness:

* Container registry infrastructure in place
* CI/CD pipelines capable of building images
* Monitoring and logging infrastructure
* Vulnerability scanning tools available
* Basic container knowledge across engineering organization

Process Readiness:

* Defined software development lifecycle
* Incident response procedures
* Change management process
* Security review process

**11.7.3 Initial Investment**

Starting a base images program requires upfront investment in tooling, infrastructure, and team resources.

**Tooling and Infrastructure**

Container Registry:

* Harbor, JFrog Artifactory, or cloud provider registry
* High availability setup
* Backup and disaster recovery configuration
* Geographic replication for distributed teams

Security Scanning:

* Trivy, Grype, Snyk, or commercial alternatives
* Integration with CI/CD and registry
* Continuous scanning infrastructure
* Vulnerability database maintenance

CI/CD Platform:

* GitHub Actions, GitLab CI, Jenkins, or alternatives
* Build capacity for image builds
* Pipeline templates and automation
* Integration with registry and scanning tools

Monitoring and Observability:

* Prometheus, Grafana, ELK stack, or alternatives
* Metrics collection for base images
* Alerting infrastructure
* Dashboards for adoption and health metrics

SBOM and Signing Infrastructure:

* Syft or CycloneDX for SBOM generation
* Cosign or Notary for image signing
* Key management infrastructure
* Verification systems

**Team Headcount**

Year 1 (Foundation):

* 1 Platform Engineering Lead (full time)
* 2 Platform Engineers (full time)
* 1 Security Engineer (50% time, shared)
* Total: 3.5 FTE

Year 2 (Scaling):

* Add 1-2 Platform Engineers
* Add Developer Experience Engineer (50% time)
* Increase Security Engineer to 75% time
* Total: 5-6 FTE

**Implementation Timeline**

* Month 1-2: Hire team, setup infrastructure
* Month 3-4: Create first base images, establish processes
* Month 5-6: Pilot with 2-3 friendly application teams
* Month 7-9: Iterate based on feedback, expand to more teams
* Month 10-12: General availability, mandate for new applications
* Year 2: Migrate existing applications, achieve critical mass

#### 11.8 Success Metrics

Track these metrics to measure program success.

**11.8.1 Security Metrics**

**Primary Security KPIs**

| Metric                        | Target     | Current  | Trend            |
| ----------------------------- | ---------- | -------- | ---------------- |
| Critical CVEs in base images  | 0          | 0        | ✅ Stable         |
| High CVEs in base images      | < 5        | 3        | ⬇️ Improving     |
| Mean time to patch (Critical) | < 24 hours | 18 hours | ✅ Meeting target |
| Mean time to patch (High)     | < 7 days   | 5 days   | ✅ Meeting target |
| % images with signed SBOM     | 100%       | 98%      | ⬆️ Improving     |
| % production images compliant | > 95%      | 92%      | ⬆️ Improving     |

**Secondary Security Metrics**

* Number of security exceptions granted
* Average age of security exceptions
* Security audit findings (trend over time)
* Security incidents related to containers
* Time from vulnerability disclosure to patch availability

**11.8.2 Adoption Metrics**

| Metric                                  | Target | Current |
| --------------------------------------- | ------ | ------- |
| % teams using approved base images      | 100%   | 87%     |
| % production images from approved bases | 100%   | 94%     |
| Number of application images built      | -      | 487     |
| Number of active base images            | -      | 18      |
| Average rebuild frequency (days)        | < 30   | 22      |

**11.8.3 Operational Metrics**

| Metric                           | Target   | Current     |
| -------------------------------- | -------- | ----------- |
| Registry uptime                  | 99.9%    | 99.95%      |
| Average build time (base images) | < 10 min | 7 min       |
| Average image size               | < 200 MB | 156 MB      |
| Storage costs per image          | -        | $0.12/month |
| Pull success rate                | > 99.5%  | 99.8%       |

**11.8.4 Developer Experience Metrics**

| Metric                         | Target   | Current  |
| ------------------------------ | -------- | -------- |
| Developer satisfaction score   | > 4/5    | 4.2/5    |
| Documentation helpfulness      | > 4/5    | 3.8/5    |
| Support ticket resolution time | < 2 days | 1.5 days |
| Office hours attendance        | -        | 12 avg   |
| Time to onboard new team       | < 1 week | 4 days   |

#### 11.9 Common Pitfalls and How to Avoid Them

Learn from organizations that struggled with centralization.

**11.9.1 The "Ivory Tower" Problem**

The "Set and Forget" mistake involves failing to update images regularly, leaving vulnerabilities unaddressed, and creating larger risk when maintenance eventually occurs. This leads to developer frustration and shadow IT workarounds.

**The Mistake**

Base images team becomes disconnected from real developer needs:

* Makes decisions without consulting development teams
* Prioritizes security over usability without compromise
* Ignores feedback from application teams
* Operates in a silo with minimal communication

**The Result**

* Developers work around base images (shadow IT)
* Low adoption and resistance to mandates
* Friction between platform and application teams
* Base images team viewed as blocker, not enabler

**How to Avoid**

* Embed platform engineers with application teams regularly
* Hold monthly office hours for Q\&A and feedback
* Include application team representatives in RFC reviews
* Measure and track developer satisfaction
* Make pragmatic trade-offs between security and usability
* Celebrate teams that successfully migrate to base images

**11.9.2 The "Boiling the Ocean" Problem**

**The Mistake**

Trying to create perfect base images for every possible use case:

* 50 different base image variants
* Support for every language version ever released
* Every possible configuration option exposed
* Attempting to satisfy every feature request

**The Result**

* Overwhelming maintenance burden
* Slow iteration and feature delivery
* Analysis paralysis on decisions
* Team burnout

**How to Avoid**

* Start with 3-5 most common base images (Ubuntu, Python, Node.js)
* Support only N and N-1 versions of language runtimes
* Focus on 80% use case, make exceptions for the 20%
* Say "no" to feature requests that benefit only one team
* Regular deprecation of unused base images
* Clear criteria for adding new base images

**11.9.3 The "Perfect Security" Problem**

**The Mistake**

Demanding perfect security at the expense of everything else:

* Zero vulnerabilities required (including low/medium)
* Blocking all deployments for minor security findings
* No exception process, even for valid edge cases
* Months-long security reviews for new base images

**The Result**

* Developers circumvent security controls
* Business velocity grinds to halt
* Security team viewed as blocker
* Constant escalations to leadership

**How to Avoid**

* Risk-based approach: prioritize critical and high CVEs
* Clear SLAs: critical within 24h, high within 7 days
* Exception process with defined criteria
* Measure security improvements, not perfection
* Automated controls instead of manual reviews
* Security team as consultants, not gatekeepers

**11.9.4 The "Big Bang Migration" Problem**

**The Mistake**

Mandating all teams migrate immediately:

* 6-month hard deadline for 100 teams
* No grandfathering for legacy applications
* Insufficient support for teams during migration
* Underestimating complexity of migrations

**The Result**

* Overwhelmed support channels
* Missed deadlines and leadership frustration
* Poor quality migrations done under pressure
* Developer resentment

**How to Avoid**

* Phased rollout: pilot → friendly teams → general availability → mandate
* Mandate for new applications, gradual migration for existing
* Dedicated migration support (embedded engineers)
* Document common migration patterns
* Celebrate successful migrations
* Realistic timelines (12-18 months for large organizations)

#### 11.10 Case Study: Implementing a Base Images Team

Fictional but realistic example based on common patterns.

**Organization Profile**

* Size: 300 developers across 40 application teams
* Platform: AWS with Kubernetes (EKS)
* Current state: Teams maintain their own Dockerfiles, mix of Ubuntu/Alpine/random bases
* Pain points: 47 critical CVEs across production images, inconsistent security, slow vulnerability response

**Phase 1: Foundation (Months 1-3)**

**Team Formation**

* Hired Platform Engineering Lead (Sarah) from previous SRE role
* Assigned two DevOps engineers (Mike and Priya) to platform team
* Security engineer (Tom) allocated 50% time from AppSec team

**Infrastructure Setup**

* Deployed Harbor on EKS for container registry
* Integrated Trivy for vulnerability scanning
* Set up GitHub Actions for automated image builds
* Configured Slack channel #base-images-support

**Initial Base Images**

Created 5 base images:

1. Ubuntu 22.04 (minimal)
2. Python 3.11 (slim)
3. Node.js 20 (alpine)
4. OpenJDK 21 (slim)
5. Go 1.21 (alpine)

Each with:

* Non-root user (UID 10001)
* Minimal package set
* Security hardening
* Signed SBOM
* Comprehensive documentation

**Phase 2: Pilot (Months 4-6)**

**Selected Pilot Teams**

* Team A: New greenfield application (easy win)
* Team B: Mature Node.js service (real-world test)
* Team C: Python data pipeline (batch workload)

**Pilot Results**

Team A:

* Migrated in 2 days
* Faster builds due to pre-cached layers
* Positive feedback on documentation

Team B:

* Found bug in Node.js base image (missing SSL certificates)
* Fixed in 1 day, updated docs
* 40% reduction in image size (450MB → 270MB)

Team C:

* Required custom Python packages
* Created tutorial for adding packages to base image
* Successful migration after minor tweaks

**Learnings**

* Documentation needed more examples
* Support response time critical during migration
* Teams need migration guide tailored to their stack

**Phase 3: Expansion (Months 7-12)**

**Expanded Base Image Catalog**

Added 8 more base images based on demand:

* .NET 8
* Ruby 3.2
* PHP 8.3
* Rust 1.75
* Nginx (static file serving)
* Plus distroless variants for production

**Scaled Support**

* Added Developer Experience Engineer (Lisa, 50% time)
* Created 15 example applications showing migration patterns
* Started monthly office hours (avg 15 attendees)
* Embedded engineer program (2-week rotations)

**Adoption Progress**

* 25 teams migrated (62% of teams)
* 156 application images using approved bases
* Zero critical CVEs in base images
* 98% of teams satisfied with base images

**Phase 4: Mandate and Scale (Year 2)**

**Executive Mandate**

CTO announcement:

* All new applications must use approved base images (effective immediately)
* Existing applications: 12-month migration timeline
* Exceptions require CISO approval

**Full Team**

* Platform Engineering Lead (Sarah)
* 3 Platform Engineers (Mike, Priya, Jun)
* Security Engineer (Tom, 75% time)
* Developer Experience Engineer (Lisa, full time)

**Results After 18 Months**

Security Improvements:

* Critical CVEs in production: 47 → 0
* High CVEs in production: 123 → 8
* Mean time to patch critical: 14 days → 18 hours
* All images have signed SBOMs

Operational Improvements:

* Average image size: 320MB → 180MB
* Average build time: 15 min → 8 min
* Registry storage efficiency improved significantly

Adoption:

* 39 of 40 teams using approved base images (98%)
* 1 legacy team with approved exception
* 487 application images on approved bases
* Zero security exceptions in past 6 months

Developer Experience:

* Satisfaction score: 4.2/5
* 92% would recommend to other teams
* 89% say base images make them more productive

Impact:

* Security incident reduction: 80% fewer container-related incidents
* Engineering time saved: Significant reduction in redundant work
* Faster time to production for new apps: 2-3 days faster

The program demonstrated clear value through improved security posture, operational efficiency, and developer productivity.

***

### 12. References and Further Reading

#### 12.1 Industry Standards and Frameworks

**NIST (National Institute of Standards and Technology)**

* NIST Special Publication 800-190: Application Container Security Guide
  * https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf
  * Comprehensive guidance on container security threats and countermeasures
* NIST Special Publication 800-53: Security and Privacy Controls
  * https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
  * Defines baseline configurations and security controls for information systems

**CIS (Center for Internet Security)**

* CIS Docker Benchmark
  * https://www.cisecurity.org/benchmark/docker
  * Security configuration guidelines for Docker containers
* CIS Kubernetes Benchmark
  * https://www.cisecurity.org/benchmark/kubernetes
  * Hardening standards for Kubernetes deployments

**OWASP (Open Web Application Security Project)**

* OWASP Docker Security Cheat Sheet
  * https://cheatsheetseries.owasp.org/cheatsheets/Docker\_Security\_Cheat\_Sheet.html
  * Practical security guidance for Docker containers
* OWASP Kubernetes Security Cheat Sheet
  * https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html
  * Security best practices for Kubernetes

**CNCF (Cloud Native Computing Foundation)**

* Software Supply Chain Best Practices
  * https://github.com/cncf/tag-security/blob/main/supply-chain-security/supply-chain-security-paper/CNCF\_SSCP\_v1.pdf
  * Comprehensive guide to securing the software supply chain

#### 12.2 Container Security Tools Documentation

**Vulnerability Scanning**

* Trivy Documentation
  * https://aquasecurity.github.io/trivy/
  * Official documentation for Trivy vulnerability scanner
* Grype Documentation
  * https://github.com/anchore/grype
  * Anchore Grype vulnerability scanner documentation
* Snyk Container Documentation
  * https://docs.snyk.io/products/snyk-container
  * Snyk's container security scanning platform
* Clair Documentation
  * https://quay.github.io/clair/
  * Static analysis of vulnerabilities in containers

**SBOM Generation**

* Syft Documentation
  * https://github.com/anchore/syft
  * SBOM generation tool from Anchore
* CycloneDX Specification
  * https://cyclonedx.org/
  * SBOM standard format specification
* SPDX Specification
  * https://spdx.dev/
  * Software Package Data Exchange standard

**Image Signing and Verification**

* Cosign Documentation
  * https://docs.sigstore.dev/cosign/overview/
  * Container image signing and verification
* Notary Project
  * https://notaryproject.dev/
  * Content signing and verification framework
* Sigstore Documentation
  * https://www.sigstore.dev/
  * Improving software supply chain security

#### 12.3 Container Registries

**Harbor**

* Harbor Documentation
  * https://goharbor.io/docs/
  * Open source container registry with security scanning
* Harbor GitHub Repository
  * https://github.com/goharbor/harbor
  * Source code and issue tracking

**Cloud Provider Registries**

* AWS Elastic Container Registry (ECR)
  * https://docs.aws.amazon.com/ecr/
  * Amazon's container registry service
* Azure Container Registry (ACR)
  * https://docs.microsoft.com/en-us/azure/container-registry/
  * Microsoft Azure container registry
* Google Artifact Registry
  * https://cloud.google.com/artifact-registry/docs
  * Google Cloud's artifact management service

**JFrog Artifactory**

* Artifactory Documentation
  * https://www.jfrog.com/confluence/display/JFROG/JFrog+Artifactory
  * Universal artifact repository manager

#### 12.4 Base Image Sources

**Official Docker Images**

* Docker Hub Official Images
  * https://hub.docker.com/search?q=\&type=image\&image\_filter=official
  * Curated set of Docker repositories

**Vendor-Specific Base Images**

* Red Hat Universal Base Images (UBI)
  * https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image
  * Free redistributable container base images
* Google Distroless Images
  * https://github.com/GoogleContainerTools/distroless
  * Minimal container images from Google
* Chainguard Images
  * https://www.chainguard.dev/chainguard-images
  * Hardened, minimal container images with daily updates
  * https://www.chainguard.dev/unchained/why-golden-images-still-matter-and-how-to-secure-them-with-chainguard
  * White paper on modern golden image strategies
* Canonical Ubuntu Images
  * https://hub.docker.com/\_/ubuntu
  * Official Ubuntu container images
* Amazon Linux Container Images
  * https://gallery.ecr.aws/amazonlinux/amazonlinux
  * Amazon's Linux distribution for containers

#### 12.5 Industry Case Studies and Best Practices

**Netflix**

* Netflix Open Source
  * https://netflix.github.io/
  * Netflix's open source projects and container platform
* Titus: Netflix Container Management Platform
  * https://netflix.github.io/titus/
  * Documentation for Netflix's container orchestration system
* "The Evolution of Container Usage at Netflix"
  * https://netflixtechblog.com/the-evolution-of-container-usage-at-netflix-3abfc096781b
  * Netflix Technology Blog article on container adoption
* "Titus: Introducing Containers to the Netflix Cloud"
  * https://queue.acm.org/detail.cfm?id=3158370
  * ACM Queue article detailing Netflix's container journey

**Docker and Platform Engineering**

* "Building Stronger, Happier Engineering Teams with Team Topologies"
  * https://www.docker.com/blog/building-stronger-happier-engineering-teams-with-team-topologies/
  * Docker's approach to organizing engineering teams
* Docker Engineering Careers
  * https://www.docker.com/careers/engineering/
  * Insights into Docker's engineering team structure

**Google Cloud**

* "Base Images Overview"
  * https://cloud.google.com/software-supply-chain-security/docs/base-images
  * Google's approach to base container images

**HashiCorp**

* "Creating a Multi-Cloud Golden Image Pipeline"
  * https://www.hashicorp.com/en/blog/multicloud-golden-image-pipeline-terraform-cloud-hcp-packer
  * Enterprise approach to golden image management

**Red Hat**

* "What is a Golden Image?"
  * https://www.redhat.com/en/topics/linux/what-is-a-golden-image
  * Comprehensive explanation of golden image concepts
* "Automate VM Golden Image Management with OpenShift"
  * https://developers.redhat.com/articles/2025/06/03/automate-vm-golden-image-management-openshift
  * Technical implementation of golden image automation

#### 12.6 Platform Engineering Resources

**Team Topologies**

* Team Topologies Website
  * https://teamtopologies.com/
  * Framework for organizing business and technology teams
* "Team Topologies" by Matthew Skelton and Manuel Pais
  * Book: https://teamtopologies.com/book
  * Foundational resource for platform team structure

**Platform Engineering Team Structure**

* "How to Build a Platform Engineering Team" (Spacelift)
  * https://spacelift.io/blog/how-to-build-a-platform-engineering-team
  * Guide to building and structuring platform teams
* "Platform Engineering Team Structure" (Puppet)
  * https://www.puppet.com/blog/platform-engineering-teams
  * DevOps skills and roles for platform engineering
* "What is a Platform Engineering Team?" (Harness)
  * https://www.harness.io/harness-devops-academy/what-is-a-platform-engineering-team
  * Overview of platform engineering team responsibilities
* "Platform Engineering Roles and Responsibilities" (Loft Labs)
  * https://www.vcluster.com/blog/platform-engineering-roles-and-responsibilities-building-scalable-reliable-and-secure-platform
  * Detailed breakdown of platform engineering roles
* "What Does a Platform Engineer Do?" (Spacelift)
  * https://spacelift.io/blog/what-is-a-platform-engineer
  * Role definition and responsibilities
* "The Platform Engineer Role Explained" (Splunk)
  * https://www.splunk.com/en\_us/blog/learn/platform-engineer-role-responsibilities.html
  * Comprehensive guide to platform engineering

#### 12.7 Golden Images and Base Image Management

**Concepts and Best Practices**

* "What is Golden Image?" (NinjaOne)
  * https://www.ninjaone.com/it-hub/remote-access/what-is-golden-image/
  * Detailed explanation with NIST references
* "A Guide to Golden Images" (SmartDeploy)
  * https://www.smartdeploy.com/blog/guide-to-golden-images/
  * Best practices for creating and managing golden images
* "What are Golden Images?" (Parallels)
  * https://www.parallels.com/glossary/golden-images/
  * Definition and use cases
* "What is Golden Image?" (TechTarget)
  * https://www.techtarget.com/searchitoperations/definition/golden-image
  * Technical definition and explanation

**Implementation Guides**

* "DevOps Approach to Build Golden Images in AWS"
  * https://medium.com/@sudhir\_thakur/devops-approach-to-build-golden-images-in-aws-part-1-d44588a46d6
  * Practical implementation guide for AWS environments
* "Create an Azure Virtual Desktop Golden Image"
  * https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-golden-image
  * Microsoft's approach to golden images in Azure

#### 12.8 Container Security Research and Analysis

**Vulnerability Management**

* Common Vulnerabilities and Exposures (CVE)
  * https://cve.mitre.org/
  * Official CVE database
* National Vulnerability Database (NVD)
  * https://nvd.nist.gov/
  * U.S. government repository of vulnerability data

**Security Scanning Best Practices**

* "Why Golden Images Still Matter" (Chainguard)
  * https://www.chainguard.dev/unchained/why-golden-images-still-matter-and-how-to-secure-them-with-chainguard
  * Modern approach to golden image security and management

#### 12.9 Kubernetes and Container Orchestration

**Kubernetes Documentation**

* Kubernetes Security Best Practices
  * https://kubernetes.io/docs/concepts/security/
  * Official Kubernetes security documentation
* Pod Security Standards
  * https://kubernetes.io/docs/concepts/security/pod-security-standards/
  * Kubernetes pod security policies

**Policy Enforcement**

* Kyverno Documentation
  * https://kyverno.io/docs/
  * Kubernetes-native policy management
* Open Policy Agent (OPA)
  * https://www.openpolicyagent.org/docs/latest/
  * Policy-based control for cloud native environments
* Gatekeeper Documentation
  * https://open-policy-agent.github.io/gatekeeper/website/docs/
  * OPA constraint framework for Kubernetes

#### 12.10 CI/CD and Automation

**GitHub Actions**

* GitHub Actions Documentation
  * https://docs.github.com/en/actions
  * CI/CD automation with GitHub
* Aqua Security Trivy Action
  * https://github.com/aquasecurity/trivy-action
  * GitHub Action for Trivy scanning

**GitLab CI**

* GitLab CI/CD Documentation
  * https://docs.gitlab.com/ee/ci/
  * Continuous integration and delivery with GitLab

**Jenkins**

* Jenkins Documentation
  * https://www.jenkins.io/doc/
  * Open source automation server

**BuildKit**

* BuildKit Documentation
  * https://github.com/moby/buildkit
  * Concurrent, cache-efficient, and Dockerfile-agnostic builder

#### 12.11 Books and Publications

**Container Security**

* "Container Security" by Liz Rice
  * O'Reilly Media, 2020
  * Comprehensive guide to container security fundamentals
* "Kubernetes Security and Observability" by Brendan Creane and Amit Gupta
  * O'Reilly Media, 2021
  * Security practices for Kubernetes environments

**Platform Engineering**

* "Team Topologies" by Matthew Skelton and Manuel Pais
  * IT Revolution Press, 2019
  * Organizing business and technology teams for fast flow
* "Building Secure and Reliable Systems" by Google
  * O'Reilly Media, 2020
  * Best practices for designing, implementing, and maintaining systems

**DevOps and Infrastructure**

* "The Phoenix Project" by Gene Kim, Kevin Behr, and George Spafford
  * IT Revolution Press, 2013
  * Novel about IT, DevOps, and helping your business win
* "The DevOps Handbook" by Gene Kim, Jez Humble, Patrick Debois, and John Willis
  * IT Revolution Press, 2016
  * How to create world-class agility, reliability, and security

#### 12.12 Community and Forums

**Container Community**

* CNCF Slack
  * https://slack.cncf.io/
  * Cloud Native Computing Foundation community discussions
* Docker Community Forums
  * https://forums.docker.com/
  * Official Docker community support
* Kubernetes Slack
  * https://kubernetes.slack.com/
  * Kubernetes community discussions

**Security Communities**

* Cloud Native Security Slack
  * Part of CNCF Slack workspace
  * Dedicated security discussions
* r/kubernetes (Reddit)
  * https://www.reddit.com/r/kubernetes/
  * Community discussions and support
* r/docker (Reddit)
  * https://www.reddit.com/r/docker/
  * Docker community discussions

#### 12.13 Training and Certification

**Container Security Training**

* Kubernetes Security Specialist (CKS)
  * https://training.linuxfoundation.org/certification/certified-kubernetes-security-specialist/
  * Official Kubernetes security certification
* Docker Certified Associate
  * https://training.mirantis.com/certification/dca-certification-exam/
  * Docker platform certification

**Cloud Provider Certifications**

* AWS Certified DevOps Engineer
  * https://aws.amazon.com/certification/certified-devops-engineer-professional/
  * AWS DevOps practices and container services
* Google Professional Cloud DevOps Engineer
  * https://cloud.google.com/certification/cloud-devops-engineer
  * Google Cloud DevOps and container expertise
* Microsoft Certified: Azure Solutions Architect Expert
  * https://docs.microsoft.com/en-us/certifications/azure-solutions-architect/
  * Azure infrastructure and container services

#### 12.14 Compliance and Regulatory Resources

**Compliance Frameworks**

* SOC 2 Compliance
  * https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/aicpasoc2report.html
  * Service Organization Control 2 reporting
* ISO 27001
  * https://www.iso.org/isoiec-27001-information-security.html
  * Information security management standard
* PCI DSS
  * https://www.pcisecuritystandards.org/
  * Payment Card Industry Data Security Standard

**GDPR Resources**

* GDPR Official Text
  * https://gdpr-info.eu/
  * General Data Protection Regulation documentation

#### 12.15 Additional Technical Resources

**Multi-Platform Builds**

* Docker Multi-Platform Images
  * https://docs.docker.com/build/building/multi-platform/
  * Building images for multiple architectures

**Image Optimization**

* Docker Best Practices
  * https://docs.docker.com/develop/dev-best-practices/
  * Official Docker development best practices
* Dockerfile Best Practices
  * https://docs.docker.com/develop/develop-images/dockerfile\_best-practices/
  * Writing efficient and secure Dockerfiles

**Container Runtimes**

* containerd Documentation
  * https://containerd.io/docs/
  * Industry-standard container runtime
* CRI-O Documentation
  * https://cri-o.io/
  * Lightweight container runtime for Kubernetes

***

### 13. Document Control

#### Version History

| Version | Date         | Author                    | Changes                                                                                 |
| ------- | ------------ | ------------------------- | --------------------------------------------------------------------------------------- |
| 1.0     | October 2025 | Platform Engineering Team | Initial comprehensive policy release with technical details and implementation guidance |

#### Review and Approval

| Role                               | Name | Signature / Date |
| ---------------------------------- | ---- | ---------------- |
| Platform Engineering Lead          |      |                  |
| Security Team Lead                 |      |                  |
| Chief Information Security Officer |      |                  |

#### Review Schedule

This policy will be reviewed and updated:

* **Quarterly Review:** Technical standards and tool recommendations
* **Annual Review:** Complete policy review including governance and processes
* **Event-Driven Review:** When significant security incidents occur or new threats emerge

**Next Scheduled Review:** January 2026

***

_This document represents the current state of container security best practices and will evolve as technologies and threats change._
