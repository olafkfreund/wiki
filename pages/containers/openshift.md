# OpenShift (2025)

OpenShift is an enterprise Kubernetes platform by Red Hat, available as a managed service on Azure (ARO), AWS (ROSA), and for on-premises or hybrid cloud. It extends Kubernetes with developer tools, security, and automation for modern cloud-native workloads.

## 2025 Best Practices

- **Use GitOps for Deployment:** Adopt ArgoCD or OpenShift GitOps for declarative, version-controlled deployments.
- **Leverage Operator Framework:** Use certified Operators for lifecycle management of databases, monitoring, and more.
- **Enable Role-Based Access Control (RBAC):** Define granular permissions for users and service accounts.
- **Automate Security Scans:** Integrate image scanning (Quay, Clair, Trivy) into CI/CD pipelines.
- **Network Policies:** Enforce strict network segmentation using OpenShift SDN or OVN-Kubernetes.
- **Monitor with Prometheus & Grafana:** Use built-in monitoring for cluster health and custom app metrics.
- **Use Service Mesh (Istio/Red Hat OpenShift Service Mesh):** For advanced traffic management, security, and observability.
- **Multi-Cluster Management:** Use OpenShift Advanced Cluster Manager (ACM) for hybrid/multi-cloud fleets.

## Real-Life Usage Example: Deploying a Secure App

**1. Create a new project:**
```bash
oc new-project prod-app
```

**2. Apply a deployment and service:**
```yaml
# app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: quay.io/org/web:2025
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
        securityContext:
          runAsNonRoot: true
          allowPrivilegeEscalation: false
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```
```bash
oc apply -f app-deployment.yaml
```

**3. Expose with a secure route:**
```bash
oc expose service web --port=80 --name=web-route
```

**4. Enforce network policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Installing OpenShift CLI (oc)

### Linux (Ubuntu, Fedora, RHEL, Arch)
```bash
# Download latest CLI
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

# Extract and move to /usr/local/bin
sudo tar -xvf openshift-client-linux.tar.gz -C /usr/local/bin oc kubectl
sudo chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

# Verify
oc version
```

### NixOS
Add to your `configuration.nix`:
```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ openshift oc kubectl ];
}
```
Then run:
```bash
sudo nixos-rebuild switch
```

### Windows Subsystem for Linux (WSL)
Follow the Linux steps above inside your WSL terminal. For persistent PATH, add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH=$PATH:/usr/local/bin
```

## Real-Life CLI Usage

- **Login to a cluster:**
  ```bash
  oc login https://api.example.openshift.com:6443 --token=sha256~...
  ```
- **List projects/namespaces:**
  ```bash
  oc get projects
  ```
- **Deploy from source (S2I):**
  ```bash
  oc new-app python:3.11~https://github.com/org/repo.git --name=myapp
  ```
- **View logs:**
  ```bash
  oc logs deployment/web
  ```
- **Scale deployment:**
  ```bash
  oc scale deployment/web --replicas=5
  ```
- **Open the web console:**
  ```bash
  oc whoami --show-console
  ```

## Pros and Cons of OpenShift

| Pros | Cons |
|------|------|
| Enterprise security & compliance | Higher cost than vanilla Kubernetes |
| Built-in CI/CD, monitoring, S2I  | Steeper learning curve |
| OperatorHub & automation         | Some vendor lock-in |
| Multi-cloud & hybrid support     | Resource overhead |
| Advanced RBAC & OAuth            | |
| Managed options (ARO, ROSA)      | |

## OpenShift vs. Other Providers (2025)

| Feature                | OpenShift (ARO/ROSA) | AWS EKS | Azure AKS | GCP GKE | VMware Tanzu |
|------------------------|----------------------|---------|-----------|---------|--------------|
| Managed Option         | Yes                  | Yes     | Yes       | Yes     | Yes          |
| GitOps Built-in        | Yes (ArgoCD)         | No      | No        | No      | Yes          |
| Operator Framework     | Yes                  | No      | No        | No      | Yes          |
| S2I/Dev Tools          | Yes                  | No      | No        | No      | No           |
| Security/Compliance    | Advanced             | Good    | Good      | Good    | Good         |
| Multi-Cluster Mgmt     | Yes (ACM)            | Partial | Partial   | Partial | Yes          |
| Hybrid/On-prem         | Yes                  | No      | No        | No      | Yes          |
| Cost                   | $$$                  | $$      | $         | $       | $$$          |
| Ecosystem              | Large                | Largest | Large     | Large   | Medium       |

**Summary:**
- OpenShift is best for regulated, hybrid, or multi-cloud environments needing advanced automation and security.
- EKS/AKS/GKE are simpler, cheaper, and integrate tightly with their respective clouds.
- VMware Tanzu is strong for on-premises and vSphere shops.

## References
- [OpenShift Docs](https://docs.openshift.com/container-platform/latest/)
- [ARO (Azure Red Hat OpenShift)](https://learn.microsoft.com/en-us/azure/openshift/)
- [ROSA (Red Hat OpenShift Service on AWS)](https://docs.aws.amazon.com/rosa/latest/userguide/)
- [OpenShift CLI](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
- [OperatorHub](https://operatorhub.io/)
