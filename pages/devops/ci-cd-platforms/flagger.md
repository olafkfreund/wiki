# Flagger: Progressive Delivery for Kubernetes (2025)

[Flagger](https://github.com/fluxcd/flagger) is a cloud-native progressive delivery tool that automates the release process for applications running on Kubernetes. It significantly reduces the risk of introducing new software versions in production by implementing sophisticated traffic management, automated rollback mechanisms, and comprehensive observability.

## Key Features (2025)

- **Advanced Deployment Strategies**: Canary releases, A/B testing, Blue/Green deployments, and traffic mirroring
- **Multi-Provider Support**: Works with service meshes (Istio, Linkerd, Consul Connect, Open Service Mesh) and ingress controllers (NGINX, Traefik, Gateway API, Contour, Ambassador, Gloo)
- **Comprehensive Observability**: Integration with Prometheus, Grafana, Datadog, New Relic, CloudWatch, and custom metrics
- **Enhanced Security**: Built-in security scanning, policy enforcement, and compliance validation
- **GitOps Ready**: Native integration with Flux v2, ArgoCD, and other GitOps tools
- **Multi-Cloud**: Support for AWS EKS, Azure AKS, Google GKE, and on-premises clusters

![Flagger overview diagram](https://fluxcd.io/img/diagrams/flagger-overview.png)

## Modern Architecture Benefits

### 2025 Enhancements

1. **Gateway API Support**: Native support for Kubernetes Gateway API standard
2. **Enhanced Security**: Integration with OPA Gatekeeper, Falco, and policy engines
3. **Cost Optimization**: Traffic-based cost analysis and optimization recommendations
4. **ML-Powered Analysis**: Machine learning-based anomaly detection for canary analysis
5. **Multi-Cluster Deployments**: Support for progressive delivery across multiple clusters

### Integration Ecosystem

Flagger seamlessly integrates with modern cloud-native tools:

- **CI/CD Platforms**: Tekton, GitHub Actions, Azure Pipelines, GitLab CI/CD
- **GitOps Tools**: Flux v2, ArgoCD, Rancher Fleet
- **Service Meshes**: Istio 1.20+, Linkerd 2.14+, Consul Connect 1.17+
- **Monitoring**: Prometheus, Grafana, Jaeger, OpenTelemetry
- **Security**: OPA Gatekeeper, Falco, Twistlock, Aqua Security

## Gateway API Integration (2025)

Flagger v1.37+ provides native support for Kubernetes Gateway API, offering a more standardized approach to traffic management.

### Gateway API Setup

Install Gateway API CRDs and configure Istio for Gateway API:

```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Configure Istio for Gateway API (if using Istio)
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      env:
        EXTERNAL_ISTIOD: false
        PILOT_ENABLE_GATEWAY_API: true
        PILOT_ENABLE_GATEWAY_API_STATUS: true
        PILOT_ENABLE_GATEWAY_API_DEPLOYMENT_CONTROLLER: true
EOF
```

### Gateway API Canary Configuration

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: podinfo-gateway
  namespace: test
spec:
  provider: gatewayapi:v1.0.0
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: podinfo
  service:
    port: 80
    targetPort: 9898
    gatewayRefs:
    - name: gateway
      namespace: istio-system
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
    webhooks:
    - name: security-gate
      type: pre-rollout
      url: http://security-scanner.default/
      timeout: 30s
      metadata:
        type: bash
        cmd: "security-scan --image=$(params.image) --severity=HIGH,CRITICAL"
```

## Istio Service Mesh Integration (2025)

### Enhanced Istio Setup

Install Istio with modern security and observability features:

```bash
# Download Istio 1.20+
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
cd istio-1.20.0
export PATH=$PWD/bin:$PATH

# Install Istio with security features
istioctl install --set values.pilot.env.EXTERNAL_ISTIOD=false \
  --set values.global.meshID=mesh1 \
  --set values.global.network=network1 \
  --set values.global.meshConfig.defaultConfig.proxyStatsMatcher.inclusionRegexps=".*outlier_detection.*" \
  --set values.telemetry.v2.prometheus.configOverride.metric_relabeling_configs[0].source_labels[0]="__name__" \
  --set values.telemetry.v2.prometheus.configOverride.metric_relabeling_configs[0].regex=".*_bucket" \
  --set values.telemetry.v2.prometheus.configOverride.metric_relabeling_configs[0].target_label="le" \
  --set values.telemetry.v2.prometheus.configOverride.metric_relabeling_configs[0].replacement="$1"

# Enable sidecar injection
kubectl label namespace test istio-injection=enabled

# Install Flagger for Istio
helm upgrade -i flagger flagger/flagger \
  --namespace istio-system \
  --set meshProvider=istio \
  --set metricsServer=http://prometheus:9090 \
  --set slack.url=$SLACK_URL \
  --set slack.channel=alerts
```

### Advanced Istio Canary with Security

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: podinfo-istio
  namespace: test
spec:
  provider: istio
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: podinfo
  service:
    port: 80
    targetPort: 9898
    gateways:
    - public-gateway.istio-system.svc.cluster.local
    hosts:
    - app.example.com
    trafficPolicy:
      tls:
        mode: ISTIO_MUTUAL
    retries:
      attempts: 3
      perTryTimeout: 1s
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    # Enhanced metrics for Istio
    metrics:
    - name: request-success-rate
      templateRef:
        name: success-rate
        namespace: istio-system
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      templateRef:
        name: latency
        namespace: istio-system
      thresholdRange:
        max: 500
      interval: 1m
    - name: error-rate
      templateRef:
        name: error-rate
        namespace: istio-system
      thresholdRange:
        max: 1
      interval: 1m
    webhooks:
    - name: security-scan
      type: pre-rollout
      url: http://security-scanner.security-system/
      timeout: 30s
      metadata:
        type: bash
        cmd: "trivy image --severity HIGH,CRITICAL $(params.image)"
    - name: load-test
      type: rollout
      url: http://flagger-loadtester.test/
      timeout: 5s
      metadata:
        type: cmd
        cmd: "hey -z 1m -q 10 -c 2 -H 'Host: app.example.com' http://istio-ingressgateway.istio-system"
```

## Security and Compliance (2025)

### OPA Gatekeeper Integration

Configure policy enforcement for canary deployments:

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: canarydeploymentsecurity
spec:
  crd:
    spec:
      names:
        kind: CanaryDeploymentSecurity
      validation:
        properties:
          requiredSecurityContext:
            type: object
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package canarydeploymentsecurity
        
        violation[{"msg": msg}] {
          input.review.object.kind == "Canary"
          not input.review.object.spec.analysis.webhooks[_].name == "security-scan"
          msg := "Canary deployments must include security scanning webhook"
        }
        
        violation[{"msg": msg}] {
          input.review.object.kind == "Canary"
          input.review.object.spec.analysis.threshold > 10
          msg := "Canary failure threshold must not exceed 10"
        }
---
apiVersion: config.gatekeeper.sh/v1alpha1
kind: CanaryDeploymentSecurity
metadata:
  name: canary-security-requirements
spec:
  match:
    - apiGroups: ["flagger.app"]
      kinds: ["Canary"]
```

### Falco Integration for Runtime Security

Create a Falco rule for monitoring canary deployments:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-canary-rules
  namespace: falco-system
data:
  canary_rules.yaml: |
    - rule: Suspicious Canary Network Activity
      desc: Detect unusual network activity during canary deployment
      condition: >
        k8s_audit and ka.verb in (create, update, patch) and
        ka.target.resource=canaries and
        outbound and not fd.sport in (80, 443, 9090, 8080)
      output: >
        Suspicious network activity during canary deployment
        (user=%ka.user.name verb=%ka.verb resource=%ka.target.resource 
         canary=%ka.target.name namespace=%ka.target.namespace
         connection=%fd.rip:%fd.rport)
      priority: WARNING
      tags: [network, k8s, canary]
    
    - rule: Canary Pod Security Violation
      desc: Detect security violations in canary pods
      condition: >
        spawned_process and container and
        k8s.pod.label[app] contains "canary" and
        (proc.name in (curl, wget, nc) or
         proc.cmdline contains "chmod +x")
      output: >
        Security violation in canary pod
        (user=%user.name command=%proc.cmdline pod=%k8s.pod.name
         namespace=%k8s.ns.name image=%container.image.repository)
      priority: HIGH
      tags: [process, k8s, canary, security]
```

## Multi-Cluster Progressive Delivery

### Cross-Cluster Canary Configuration

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: podinfo-multi-cluster
  namespace: test
spec:
  provider: istio
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: podinfo
  service:
    port: 80
    targetPort: 9898
    gateways:
    - mesh
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    # Multi-cluster metrics
    metrics:
    - name: cross-cluster-success-rate
      templateRef:
        name: multi-cluster-success-rate
        namespace: istio-system
      thresholdRange:
        min: 99
      interval: 1m
    sessionAffinity:
      cookieName: flagger-canary
      maxAge: 3600
    webhooks:
    - name: cluster-validation
      type: pre-rollout
      url: http://cluster-validator.fleet-system/validate
      timeout: 30s
      metadata:
        clusters: ["production-us", "production-eu"]
        regions: ["us-west-2", "eu-west-1"]
```

## Observability and Monitoring (2025)

### Enhanced Grafana Dashboards

Import Flagger dashboards with modern visualizations:

```bash
# Import Flagger dashboards
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: flagger-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  flagger-canary.json: |
    {
      "dashboard": {
        "title": "Flagger Canary Analysis (2025)",
        "panels": [
          {
            "title": "Canary Success Rate",
            "type": "stat",
            "targets": [
              {
                "expr": "histogram_quantile(0.99, sum(rate(flagger_canary_duration_seconds_bucket[5m])) by (le))",
                "legendFormat": "P99 Duration"
              }
            ]
          },
          {
            "title": "Active Canaries",
            "type": "table",
            "targets": [
              {
                "expr": "flagger_canary_total",
                "legendFormat": "{{name}}.{{namespace}}"
              }
            ]
          }
        ]
      }
    }
EOF
```

### OpenTelemetry Integration

Configure distributed tracing for canary deployments:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
  namespace: istio-system
data:
  config.yaml: |
    receivers:
      jaeger:
        protocols:
          grpc:
            endpoint: 0.0.0.0:14250
          thrift_http:
            endpoint: 0.0.0.0:14268
      prometheus:
        config:
          scrape_configs:
          - job_name: 'flagger'
            static_configs:
            - targets: ['flagger.istio-system:8080']
            metrics_path: /metrics
            scrape_interval: 15s
    
    processors:
      batch:
        timeout: 1s
        send_batch_size: 1024
      resource:
        attributes:
        - key: service.name
          value: flagger-canary
          action: upsert
    
    exporters:
      jaeger:
        endpoint: jaeger-collector.monitoring:14250
        tls:
          insecure: true
      prometheus:
        endpoint: "0.0.0.0:8889"
        namespace: flagger
        const_labels:
          component: canary
    
    service:
      pipelines:
        traces:
          receivers: [jaeger]
          processors: [batch, resource]
          exporters: [jaeger]
        metrics:
          receivers: [prometheus]
          processors: [batch]
          exporters: [prometheus]
```

## Production Best Practices (2025)

### Resource Management

Configure appropriate resource limits and requests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flagger
  namespace: istio-system
spec:
  template:
    spec:
      containers:
      - name: flagger
        resources:
          limits:
            cpu: 1000m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 64Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 10001
          capabilities:
            drop:
            - ALL
```

### High Availability Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flagger
  namespace: istio-system
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: flagger
              topologyKey: kubernetes.io/hostname
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: flagger
```

### Backup and Disaster Recovery

Implement backup strategies for Flagger configurations:

```bash
#!/bin/bash
# Flagger backup script

BACKUP_DIR="/backup/flagger/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup Canary resources
kubectl get canaries -A -o yaml > "$BACKUP_DIR/canaries.yaml"

# Backup MetricTemplates
kubectl get metrictemplates -A -o yaml > "$BACKUP_DIR/metrictemplates.yaml"

# Backup AlertProviders
kubectl get alertproviders -A -o yaml > "$BACKUP_DIR/alertproviders.yaml"

# Backup Flagger configuration
kubectl get configmap flagger-config -n istio-system -o yaml > "$BACKUP_DIR/flagger-config.yaml"

echo "Backup completed: $BACKUP_DIR"
```

For an in-depth look at the analysis process read the [usage docs](https://fluxcd.io/flagger/usage/how-it-works/).
