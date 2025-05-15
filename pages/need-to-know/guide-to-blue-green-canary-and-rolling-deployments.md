# Guide to Blue-Green, Canary, and Rolling Deployments

This guide provides actionable steps, real-life examples, and best practices for implementing blue-green, canary, and rolling deployments in cloud-native environments (AWS, Azure, GCP) using Kubernetes, Terraform, and CI/CD tools.

---

## Blue-Green Deployment

Blue-green deployment maintains two identical production environments (blue and green). Traffic is switched to the new version only after validation, enabling zero-downtime releases and easy rollbacks.

**How to Implement (Kubernetes Example):**
1. Deploy the new version as a separate deployment/service (e.g., `myapp-green`).
2. Test the green environment (QA, smoke tests).
3. Switch traffic by updating the service selector:
   ```sh
   kubectl patch service myapp-service -p '{"spec": {"selector": {"app": "myapp-green"}}}'
   ```
4. Monitor for issues. Roll back by switching the selector back to blue if needed.

**Terraform Example (AWS ALB):**
- Use two target groups (blue/green) and switch the ALB listener rule to point to the new target group.

**Best Practices:**
- Automate traffic switch in CI/CD (GitHub Actions, Azure Pipelines).
- Keep environments in sync using IaC (Terraform, Bicep).
- Monitor after cutover for quick rollback.

**Common Pitfalls:**
- Configuration drift between environments.
- Not testing green environment thoroughly before switch.

---

## Canary Deployment

Canary deployment gradually routes a small percentage of traffic to the new version, increasing as confidence grows.

**How to Implement (Kubernetes Ingress NGINX Example):**
1. Deploy the new version alongside the stable version.
2. Use ingress annotations to split traffic:
   ```yaml
   nginx.ingress.kubernetes.io/canary: "true"
   nginx.ingress.kubernetes.io/canary-weight: "10"
   ```
3. Gradually increase the canary weight (10% → 25% → 50% → 100%).
4. Monitor metrics and logs for errors or regressions.

**GitHub Actions Example:**
- Use workflow steps to update canary weights and run automated tests after each increment.

**Best Practices:**
- Automate canary progression and rollback based on health checks.
- Use feature flags for user-level canaries.
- Monitor user experience and error rates closely.

**Common Pitfalls:**
- Not monitoring canary traffic separately.
- Skipping incremental rollout steps.

---

## Rolling Deployment

Rolling deployment updates pods or servers incrementally, ensuring some instances always serve traffic.

**How to Implement (Kubernetes Example):**
- Use a rolling update strategy in your deployment manifest:
  ```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  ```
- Apply the new deployment:
  ```sh
  kubectl apply -f deployment.yaml
  ```
- Kubernetes will update pods one at a time, maintaining availability.

**Terraform Example (VMSS on Azure):**
- Use `rolling_upgrade_policy` for Azure Virtual Machine Scale Sets.

**Best Practices:**
- Set appropriate `maxUnavailable` and `maxSurge` values for your SLA.
- Monitor deployment progress and health.

**Common Pitfalls:**
- Setting `maxUnavailable` too high, causing downtime.
- Not monitoring for failed updates.

---

## Summary Table

| Strategy      | Downtime | Rollback | Complexity | Use Case                        |
|---------------|----------|----------|------------|---------------------------------|
| Blue-Green    | Minimal  | Easy     | High       | Major releases, zero-downtime   |
| Canary        | Minimal  | Easy     | Medium     | Risk mitigation, feature rollout|
| Rolling       | Low      | Medium   | Low        | Routine updates, large clusters |

---

## References
- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)
- [NGINX Ingress Canary](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)
- [Terraform Blue-Green Example](https://learn.hashicorp.com/tutorials/terraform/blue-green-deployments)
- [Azure Rolling Upgrade](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-rolling-upgrade)
- [AWS Blue/Green Deployments](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-steps.html)
