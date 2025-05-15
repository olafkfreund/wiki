# Kubernetes Security and Compliance

Securing Kubernetes at enterprise scale requires a comprehensive approach spanning infrastructure, workloads, data, and access controls. This guide outlines security best practices and compliance strategies for production Kubernetes environments.

---

## Defense-in-Depth Security Model

Enterprise Kubernetes security follows a layered approach:

```
┌─────────────────────────────────────────────────────┐
│ Cluster Infrastructure Security                     │
├─────────────────────────────────────────────────────┤
│ Kubernetes Control Plane Security                   │
├─────────────────────────────────────────────────────┤
│ Network Security & Segmentation                     │
├─────────────────────────────────────────────────────┤
│ Workload Security (Pods & Containers)               │
├─────────────────────────────────────────────────────┤
│ Data Security & Secrets Management                  │
├─────────────────────────────────────────────────────┤
│ Authentication & Authorization (IAM)                │
├─────────────────────────────────────────────────────┤
│ Audit Logging & Monitoring                          │
├─────────────────────────────────────────────────────┤
│ Compliance & Governance                             │
└─────────────────────────────────────────────────────┘
```

---

## Cluster Infrastructure Hardening

### Private Cluster Architecture

Implement security best practices at the infrastructure level:

```
┌─────────────────────────────────────────────────────────┐
│                     Private VPC/VNET                    │
│                                                         │
│  ┌─────────────────┐                                    │
│  │ Bastion Host/   │                                    │
│  │ VPN Gateway     │                                    │
│  └────────┬────────┘                                    │
│           │                                             │
│  ┌────────▼─────────────────────────────────────┐       │
│  │           Private Kubernetes Cluster         │       │
│  │                                              │       │
│  │   ┌──────────────┐      ┌──────────────┐     │       │
│  │   │ Control Plane│      │ Worker Nodes │     │       │
│  │   └──────────────┘      └──────────────┘     │       │
│  └──────────────────────────────────────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Cloud-Specific Recommendations

**AWS EKS**:

- Enable envelope encryption of EKS secrets using AWS KMS
- Use Security Groups to restrict traffic between nodes
- Implement private endpoint access for the EKS API
- Use EC2 instances with IMDSv2 for node groups

**Azure AKS**:

- Deploy AKS with Azure Private Link
- Implement Azure Service Endpoints for service connections
- Use Azure Policy for AKS security controls
- Enable Azure Defender for Kubernetes

**Google GKE**:

- Deploy private GKE clusters
- Use VPC Service Controls to restrict API access
- Enable Shielded GKE Nodes
- Implement Binary Authorization

---

## Kubernetes-Native Security Controls

### Pod Security Standards

Enforce pod security using the built-in Pod Security Standards:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Policy Enforcement with OPA Gatekeeper

Deploy policy guardrails with OPA Gatekeeper:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-team-label
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["team", "environment", "application"]
```

### Image Scanning and Admission Control

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: trivy-operator-policies
  namespace: trivy-system
data:
  policy.yaml: |
    package trivy
    
    deny[msg] {
      input.vulnerabilities[_].Severity == "CRITICAL"
      msg := "Critical vulnerabilities are not allowed"
    }
    
    deny[msg] {
      input.securityIssues[_].Severity == "HIGH"
      msg := "Images with high security issues are not allowed"
    }
```

---

## Network Security

### Core Network Security Components

```
┌──────────────────────────────────────────┐
│              Egress Firewall             │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│              Ingress Controller          │
│              with WAF/DDoS               │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│              Service Mesh                │
│         (East-West Traffic Control)      │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│           Network Policies               │
│           (Pod-level Firewalls)          │
└──────────────────────────────────────────┘
```

### Network Policy Implementation

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          purpose: database
      podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

### Service Mesh Security (Istio Example)

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-specific-methods
  namespace: production
spec:
  selector:
    matchLabels:
      app: backend
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/frontend-service-account"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/v1/*"]
```

---

## Secret Management

### External Secret Management Integration

```yaml
# Using External Secrets Operator with AWS Secrets Manager
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: production
spec:
  refreshInterval: "15m"
  secretStoreRef:
    name: aws-secretsmanager
    kind: ClusterSecretStore
  target:
    name: database-credentials
  data:
  - secretKey: username
    remoteRef:
      key: production/database
      property: username
  - secretKey: password
    remoteRef:
      key: production/database
      property: password
```

### Sealed Secrets for GitOps

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: api-key
  namespace: production
spec:
  encryptedData:
    api-key: AgBy8hCNjjSa...truncated...P8kQ9H3mAyxF3A
```

---

## Authentication & Authorization

### RBAC Implementation Best Practices

**Principle of Least Privilege**:

```yaml
# Team-specific role with limited permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: team-a
  name: team-a-developer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# Bind role to team group from identity provider
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-a-developers
  namespace: team-a
subjects:
- kind: Group
  name: "ad:team-a-developers"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: team-a-developer
  apiGroup: rbac.authorization.k8s.io
```

### SSO Integration with OIDC

```yaml
# Using OIDC with Azure AD for AKS
apiVersion: v1
kind: ConfigMap
metadata:
  name: azure-ad-oidc-config
  namespace: kube-system
data:
  oidc-client-id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  oidc-issuer-url: "https://sts.windows.net/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/"
  oidc-username-claim: "email"
  oidc-groups-claim: "groups"
```

---

## Audit Logging & Monitoring

### Enhanced Audit Policy

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log all requests at the Metadata level
- level: Metadata
  # Long-running requests like watches that aren't recorded at RequestReceived
  omitStages:
    - "RequestReceived"
# Log pod changes at RequestResponse level
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods"]
# Log auth at RequestResponse level
- level: RequestResponse
  resources:
  - group: "authentication.k8s.io"
    resources: ["*"]
# Log all other resources at the Metadata level
- level: Metadata
  # Long-running requests like watches that aren't recorded at RequestReceived
  omitStages:
    - "RequestReceived"
```

### Security-Focused Monitoring

```yaml
# Falco security monitoring
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: security
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      containers:
      - name: falco
        image: falcosecurity/falco:latest
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-socket
        - mountPath: /host/var/run/docker.sock
          name: docker-socket
        - mountPath: /host/dev
          name: dev-fs
        - mountPath: /host/proc
          name: proc-fs
          readOnly: true
        - mountPath: /host/boot
          name: boot-fs
          readOnly: true
        - mountPath: /host/lib/modules
          name: lib-modules
          readOnly: true
        - mountPath: /host/usr
          name: usr-fs
          readOnly: true
        - mountPath: /etc/falco
          name: falco-config
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: dev-fs
        hostPath:
          path: /dev
      - name: proc-fs
        hostPath:
          path: /proc
      - name: boot-fs
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr-fs
        hostPath:
          path: /usr
      - name: falco-config
        configMap:
          name: falco-config
```

---

## Compliance Automation

### Continuous Compliance Validation

```yaml
# Kyverno policy for PCI-DSS compliance
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pci-dss-restricted
spec:
  validationFailureAction: Enforce
  rules:
  - name: host-path-volumes-restricted
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Host path volumes are not allowed for PCI-DSS compliance"
      pattern:
        spec:
          =(volumes):
            - =(hostPath): "null"
  - name: require-pod-probes
    match:
      resources:
        kinds:
        - Deployment
    validate:
      message: "Liveness and readiness probes are required"
      pattern:
        spec:
          template:
            spec:
              containers:
              - livenessProbe:
                  =(httpGet):
                    path: "*"
                    port: "*"
                readinessProbe:
                  =(httpGet):
                    path: "*"
                    port: "*"
```

### Compliance Scanning and Reporting

```yaml
# Trivy Operator configuration for vulnerability reporting
apiVersion: aquasecurity.github.io/v1alpha1
kind: VulnerabilityReport
metadata:
  name: app-vulnerability-report
  namespace: compliance
spec:
  target:
    resource:
      apiVersion: apps/v1
      kind: Deployment
      name: web-application
      namespace: production
  scanner:
    name: Trivy
    parameters:
      - name: "ignoreUnfixed"
        value: "true"
      - name: "severity"
        value: "CRITICAL,HIGH"
  schedule: "0 */6 * * *" # Every 6 hours
```

---

## Disaster Recovery & Security Incident Response

### Security Incident Response Plan

1. **Detection**: Monitor security alerts from:
   - Kubernetes audit logs
   - Container runtime security tools (Falco)
   - Cloud provider security services

2. **Containment**:

   ```sh
   # Isolate compromised namespace
   kubectl label namespace compromised security=isolated
   kubectl apply -f isolate-network-policy.yaml
   
   # Force restart suspicious pods
   kubectl delete pod suspicious-pod-xyz -n compromised
   
   # Temporarily disable compromised service account
   kubectl patch serviceaccount -n compromised compromised-sa \
     -p '{"metadata":{"annotations":{"security.alpha.kubernetes.io/disabled":"true"}}}'
   ```

3. **Eradication & Recovery**:

   ```sh
   # Rotate credentials
   kubectl create secret generic app-credentials --from-literal=password=$(openssl rand -base64 32) -n compromised --dry-run=client -o yaml | kubectl apply -f -
   
   # Apply updated security policies
   kubectl apply -f updated-pod-security-policies.yaml
   
   # Restore from known good state
   kubectl apply -f https://gitops-repo/known-good-state.yaml
   ```

4. **Post-Incident Analysis**:
   - Forensic analysis of compromised containers
   - Audit log review
   - Root cause identification and remediation

---

## Cloud-Specific Compliance Controls

### AWS EKS Compliance

| Requirement | Implementation |
|-------------|---------------|
| Access Logging | AWS CloudTrail + EKS audit logs to CloudWatch |
| Data Encryption | EBS encryption with KMS for PVs |
| Network Segmentation | Security Groups, NACLs, and K8s NetworkPolicies |
| Vulnerability Management | Amazon Inspector + ECR image scanning |
| Compliance Reporting | AWS Config Rules + AWS Security Hub |

### Azure AKS Compliance

| Requirement | Implementation |
|-------------|---------------|
| Access Logging | Azure Monitor + AKS diagnostic settings |
| Data Encryption | Azure Disk Encryption + Azure Key Vault |
| Network Segmentation | NSGs, Azure Firewall, and K8s NetworkPolicies |
| Vulnerability Management | Microsoft Defender for Containers |
| Compliance Reporting | Azure Policy for AKS + Azure Security Center |

### GCP GKE Compliance

| Requirement | Implementation |
|-------------|---------------|
| Access Logging | Cloud Audit Logs + GKE audit logging |
| Data Encryption | Application-layer encryption with Cloud KMS |
| Network Segmentation | VPC Firewalls and K8s NetworkPolicies |
| Vulnerability Management | GKE container threat detection + Binary Authorization |
| Compliance Reporting | Security Command Center + Compliance Reports |

---

## References

- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Application Container Security Guide](https://nvlpubs.nist.gov/nistpubs/specialpublications/nist.sp.800-190.pdf)
- [Kubernetes Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)
- [NSA Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)
- [CNCF Cloud Native Security Whitepaper](https://github.com/cncf/tag-security/blob/main/security-whitepaper/CNCF_cloud-native-security-whitepaper-Nov2020.pdf)
