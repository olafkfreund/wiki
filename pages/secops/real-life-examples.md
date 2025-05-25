# Real Life SecOps Examples Across Public Clouds

## Azure SecOps Examples

1. Azure Security Center: Azure Security Center is a cloud-native security management tool that provides visibility into the security state of Azure resources. It provides security recommendations, vulnerability assessments, and threat protection for Azure resources. Here's an example of using PowerShell to enable Azure Security Center:

```powershell
Set-AzSecurityCenterSubscription -SubscriptionId <Subscription ID> -ResourceGroup <Resource Group Name> -Enabled $true
```

2. Azure Active Directory: Azure Active Directory (Azure AD) is a cloud-based identity and access management tool that provides authentication and authorization for Azure resources. It allows organizations to manage user identities, control access to Azure resources, and enforce security policies. Here's an example of using the Azure AD PowerShell module to create a new user:

```powershell
New-AzureADUser -AccountEnabled $true -DisplayName "John Doe" -UserPrincipalName "john.doe@contoso.com" -Password "P@ssw0rd"
```

3. Azure Key Vault: Azure Key Vault is a cloud-based service that provides key management and cryptographic operations for Azure resources. It allows organizations to securely store and manage cryptographic keys, certificates, and secrets. Here's an example of using PowerShell to create a new key vault:

```powershell
New-AzKeyVault -VaultName <Vault Name> -ResourceGroupName <Resource Group Name> -Location <Location>
```

4. Azure Policy: Azure Policy is a cloud-based service that provides governance and compliance for Azure resources. It allows organizations to enforce compliance with internal policies and external regulations. Here's an example of using Azure Policy to enforce a policy that requires multi-factor authentication for users:

```json
New-AzPolicyDefinition -Name "Require MFA for Users" -Description "Requires multi-factor authentication for all users" -Policy '{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Authorization/policyAssignments"
      },
      {
        "field": "Microsoft.Authorization/policyAssignments/enforcementMode",
        "equals": "Default"
      }
    ]
  },
  "then": {
    "effect": "deny",
    "details": {
      "type": "Microsoft.MultiFactorAuthentication/userstates",
      "exists": "false"
    }
  }
}'
```

---

## AWS SecOps Examples

1. **Enable GuardDuty (Threat Detection) via AWS CLI**

```bash
aws guardduty create-detector --enable --region us-east-1
```

2. **Enforce IAM Policy for Least Privilege**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::example-bucket"]
    }
  ]
}
```

Apply with AWS CLI:

```bash
aws iam put-user-policy --user-name dev-user --policy-name LeastPrivilegeS3 --policy-document file://least-privilege-s3.json
```

3. **Store and Retrieve Secrets with AWS Secrets Manager**

```bash
# Store a secret
echo -n 'SuperSecretValue' | aws secretsmanager create-secret --name MySecret --secret-string file:///dev/stdin
# Retrieve a secret
aws secretsmanager get-secret-value --secret-id MySecret --query SecretString --output text
```

---

## GCP SecOps Examples

1. **Enable Security Command Center (SCC) via gcloud**

```bash
gcloud scc settings update --organization=ORG_ID --enable
```

2. **Set IAM Policy to Enforce Least Privilege**

```bash
gcloud projects add-iam-policy-binding my-project \
  --member='user:dev@example.com' \
  --role='roles/storage.objectViewer'
```

3. **Store and Access Secrets with Secret Manager**

```bash
# Store a secret
echo -n 'SuperSecretValue' | gcloud secrets create my-secret --data-file=-
# Access a secret
gcloud secrets versions access latest --secret=my-secret
```

---

## Best Practices for Linux, WSL, and NixOS

- Use official CLIs (awscli, azure-cli, gcloud) from your package manager or via Nix:

  ```nix
  environment.systemPackages = with pkgs; [ awscli azure-cli google-cloud-sdk ];
  ```

- Always use environment variables or profiles for credentials—never hard-code secrets.
- Use jq for parsing CLI output:

  ```bash
  aws sts get-caller-identity | jq .
  gcloud projects list --format=json | jq .
  ```

- For WSL, ensure credentials are accessible in your Linux home directory.
- Use automation (scripts, CI/CD) to enforce security policies and compliance.

---

## Security Joke

> Why did the security engineer cross the road?
>
> To patch the chicken on the other side before hackers could get to it!

---

By leveraging these tools and practices across Azure, AWS, and GCP, you can ensure robust security and compliance for your cloud resources—no matter your operating system.
