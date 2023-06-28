# Argo CD

{% embed url="https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/" %}

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data. Password}" | base64 -d
```

