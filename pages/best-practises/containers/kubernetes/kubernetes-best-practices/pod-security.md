# Kubernetes Pod Security (2024+)

## Pod Security Standards

Kubernetes Pod Security Standards define three policies:

- Privileged: Unrestricted policy
- Baseline: Minimally restrictive policy
- Restricted: Highly restrictive policy for security-critical applications

### Pod Security Admission Controller

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
```

### Modern Security Context Examples

1. Restricted Policy Compliant Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: my-secure-app:latest
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
      runAsUser: 1000
      runAsGroup: 3000
      readOnlyRootFilesystem: true
      seccompProfile:
        type: RuntimeDefault
```

2. RuntimeClass Integration:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc

---
apiVersion: v1
kind: Pod
metadata:
  name: gvisor-pod
spec:
  runtimeClassName: gvisor
  containers:
  - name: app
    image: my-app:latest
```

### OPA/Gatekeeper Policy Examples

1. Require Non-Root Users:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequireNonRootUser
metadata:
  name: require-non-root
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

2. Enforce Security Context:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: securitycontext
spec:
  crd:
    spec:
      names:
        kind: SecurityContext
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package securitycontext
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.readOnlyRootFilesystem
          msg := "Root filesystem must be read-only"
        }
```

### Network Policy Examples

Modern zero-trust network policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific-traffic
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          purpose: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Best Practices for 2024+

1. **Pod Security Standards Adoption**
   - Enable Pod Security Admission controller
   - Use "restricted" policy by default
   - Implement exceptions only when necessary

2. **Runtime Security**
   - Use gVisor or kata-containers for isolation
   - Enable SeccompProfile
   - Implement Falco for runtime monitoring

3. **Supply Chain Security**
   - Sign container images
   - Use cosign for verification
   - Implement admission controllers

4. **Zero Trust Implementation**
   - Default deny network policies
   - Explicit allow rules only
   - Regular audit logging

5. **Resource Constraints**
   - Set CPU/Memory limits
   - Configure OOM score
   - Use resource quotas
