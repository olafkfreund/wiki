---
description: Configuring network policies
---

# Network Policies

Network policies are configured via the `NetworkPolicy` resource. You can define ingress and/or egress policies. Here is a sample network policy that specifies both ingress and egress:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: awesome-project
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
    - Egress
  ingress:  
    - from:
        - namespaceSelector:
            matchLabels:
              project: awesome-project
        - podSelector:
            matchLabels:
              role: frontend
      ports:
       - protocol: TCP
         port: 6379
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/24
      ports:
        - protocol: TCP
          port: 7777     
CopyExplain
```

\
