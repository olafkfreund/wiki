# Security Best Practices for Azure

Securing your Azure environment is critical for protecting applications, data, and infrastructure. Below are actionable, modern best practices for DevOps Engineers and Cloud Architects, with real-life examples and automation snippets.

## 1. Centralized Security Management

- **Use Microsoft Defender for Cloud** for unified security posture management and threat protection.
- **Example:**

```sh
az security pricing create --name VirtualMachines --tier 'Standard'
```

## 2. Enforce Multi-Factor Authentication (MFA)

- **Enable MFA for all users, especially privileged accounts.**
- **Example:**

```sh
az ad user update --id user@contoso.com --force-change-password-next-login true
# Enforce MFA via Conditional Access Policy in Azure Portal
```

## 3. Least-Privilege Access with RBAC

- **Assign only the permissions required for each user/service.**
- **Example:**

```sh
az role assignment create --assignee <user-or-group-id> --role "Reader" --scope /subscriptions/<sub-id>/resourceGroups/<rg>
```

- **Best Practice:** Use custom roles for fine-grained access.

## 4. Network Security

- **Use Network Security Groups (NSGs) and Azure Firewall to restrict traffic.**
- **Example (Terraform):**

```hcl
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

## 5. Secure Secrets and Keys

- **Store all secrets, certificates, and keys in Azure Key Vault.**
- **Example:**

```sh
az keyvault secret set --vault-name my-keyvault --name "DbPassword" --value "SuperSecret123"
```

## 6. Patch and Update Regularly

- **Enable automatic OS and application updates for VMs and PaaS services.**
- **Example:**

```sh
az vm update --name myvm --resource-group myrg --set osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform
```

## 7. Backup and Disaster Recovery

- **Use Azure Backup and geo-redundant storage for critical data.**
- **Example:**

```sh
az backup vault create --resource-group myrg --name mybackupvault --location westeurope
```

## 8. Identity Protection and Conditional Access

- **Enable Azure AD Identity Protection and set up risk-based conditional access policies.**
- **Example:**
- Configure via Azure Portal or with [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/resources/identityprotection-root?view=graph-rest-1.0)

## 9. Monitor, Audit, and Alert

- **Enable Azure Monitor, Log Analytics, and Security Center alerts.**
- **Example:**

```sh
az monitor diagnostic-settings create --resource-id <resource-id> --workspace <log-analytics-id> --logs '[{"category": "AllLogs", "enabled": true}]'
```

## 10. Automate Security with Policy

- **Use Azure Policy to enforce security standards (e.g., require tags, restrict locations, enforce encryption).**
- **Example:**

```sh
az policy assignment create --policy "/providers/Microsoft.Authorization/policyDefinitions/audit-vm-managed-disks-encryption" --scope /subscriptions/<sub-id>
```

## Common Pitfalls

- Over-permissioned accounts and service principals
- Storing secrets in code or pipelines
- Not enabling logging and alerting
- Manual patching and configuration

## References

- [Azure Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices)
- [Microsoft Defender for Cloud Docs](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Azure Policy Samples](https://learn.microsoft.com/en-us/azure/governance/policy/samples/)

> **Joke:** Why did the Azure admin enable MFA? Because one factor just wasn’t secure enough!
