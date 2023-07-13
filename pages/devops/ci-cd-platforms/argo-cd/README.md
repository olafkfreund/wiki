# Argo CD

### What Is Argo CD?[¶](https://argo-cd.readthedocs.io/en/stable/#what-is-argo-cd) <a href="#what-is-argo-cd" id="what-is-argo-cd"></a>

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

![Argo CD UI](https://argo-cd.readthedocs.io/en/stable/assets/argocd-ui.gif)

### Why Argo CD?[¶](https://argo-cd.readthedocs.io/en/stable/#why-argo-cd) <a href="#why-argo-cd" id="why-argo-cd"></a>

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

{% embed url="https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/" %}

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data. Password}" | base64 -d
```

