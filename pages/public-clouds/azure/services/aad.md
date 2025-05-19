# Azure Active Directory (AAD)

## Overview
Azure AD is Microsoft’s cloud-based identity and access management service. It enables secure access to resources and supports SSO, MFA, and conditional access.

## Real-life Use Cases
- **Cloud Architect:** Design secure, multi-tenant authentication for SaaS apps.
- **DevOps Engineer:** Automate user and group provisioning for CI/CD pipelines.

## Terraform Example
```hcl
resource "azuread_group" "devops" {
  display_name = "DevOps Team"
}
```

## Bicep Example
```bicep
resource aadGroup 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, 'DevOps Team')
  properties: {
    roleDefinitionId: 'role-guid'
    principalId: 'user-guid'
  }
}
```

## Azure CLI Example
```sh
az ad group create --display-name "DevOps Team" --mail-nickname devops
```

## Best Practices
- Use conditional access policies.
- Enable MFA for all users.

## Common Pitfalls
- Over-permissioned service principals.
- Not monitoring sign-in logs.

> **Joke:** Why did the Azure AD user get locked out? Too many conditional relationships!
