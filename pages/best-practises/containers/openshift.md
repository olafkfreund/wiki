# OpenShift

OpenShift is an enterprise Kubernetes platform that adds developer productivity, security, and automation features on top of upstream Kubernetes. Managed OpenShift services are available on Azure (ARO), AWS (ROSA), and can be deployed on-premises or in hybrid cloud environments.

---

## Real-Life Workload Examples
- **E-commerce:** Scalable web frontends, payment APIs, and background workers for online retailers.
- **Financial Services:** Secure, compliant microservices for banking, trading, and analytics.
- **Healthcare:** HIPAA-compliant patient data platforms, FHIR APIs, and secure portals.
- **CI/CD Runners:** Host Jenkins, Tekton, or GitHub Actions runners for scalable builds.
- **AI/ML Pipelines:** Deploy JupyterHub, Kubeflow, or custom ML workflows.

---

## Best Practices for OpenShift Development & Operations
- **Use Infrastructure as Code:** Provision clusters and workloads with Terraform, Ansible, or OpenShift GitOps (ArgoCD) for repeatability.
- **Leverage OpenShift Templates & Operators:** Use Operators for databases, monitoring, and security; use templates for reusable app patterns.
- **Namespace Isolation:** Organize workloads by project (namespace) for security and resource management.
- **Resource Requests & Limits:** Always set CPU/memory requests and limits to avoid noisy neighbor issues and OOMKills.
- **Secure by Default:** Use OpenShift's built-in security features (SCCs, network policies, integrated OAuth, image scanning).
- **Automate Deployments:** Use OpenShift Pipelines (Tekton), GitHub Actions, or Azure Pipelines for automated, auditable deployments.
- **Monitor & Alert:** Integrate Prometheus, Grafana, and OpenShift Monitoring for metrics and alerting.
- **RBAC & Quotas:** Use Role-Based Access Control and resource quotas to enforce least privilege and prevent resource exhaustion.
- **Regular Upgrades:** Keep OpenShift and Operators up to date for security and new features.

---

## Step-by-Step: Deploying an App on OpenShift (ARO/ROSA/On-Prem)
1. **Login to OpenShift:**
   ```sh
   oc login --token=<token> --server=<api-url>
   ```
2. **Create a new project (namespace):**
   ```sh
   oc new-project my-app
   ```
3. **Deploy an app from source or image:**
   ```sh
   oc new-app nodejs~https://github.com/sclorg/nodejs-ex.git
   # or from image
   oc new-app quay.io/openshift-examples/httpd-example
   ```
4. **Expose the app with a route:**
   ```sh
   oc expose svc/httpd-example
   oc get route
   ```
5. **Monitor and troubleshoot:**
   ```sh
   oc get pods
   oc logs <pod-name>
   oc describe pod <pod-name>
   ```
6. **Automate with GitOps:**
   - Use OpenShift GitOps (ArgoCD) to sync manifests from Git repositories.

---

## Common Pitfalls
- Not setting resource requests/limits (leads to instability)
- Hardcoding secrets in manifests (use OpenShift Secrets or external secret managers)
- Ignoring pod health checks (causes undetected failures)
- Manual changes outside of GitOps or IaC (causes drift)
- Not monitoring cluster health and resource usage
- Overlooking OpenShift-specific security controls (SCCs, image policies)

---

## References
- [OpenShift Official Docs](https://docs.openshift.com/container-platform/latest/)
- [Azure Red Hat OpenShift (ARO)](https://learn.microsoft.com/en-us/azure/openshift/)
- [AWS ROSA](https://docs.aws.amazon.com/rosa/latest/userguide/what-is.html)
- [OpenShift GitOps](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [OpenShift Security Best Practices](https://docs.openshift.com/container-platform/latest/security/)
