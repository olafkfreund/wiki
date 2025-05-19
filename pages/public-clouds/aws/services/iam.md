# AWS IAM (Identity and Access Management)

## Overview
AWS IAM lets you manage access to AWS services and resources securely. IAM enables you to create and manage AWS users and groups, and use permissions to allow and deny their access to AWS resources.

## Real-life Use Cases
- **Cloud Architect:** Design least-privilege access policies for multi-account environments.
- **DevOps Engineer:** Automate user and role provisioning for CI/CD pipelines.

## Terraform Example
```hcl
resource "aws_iam_user" "ci_user" {
  name = "ci-cd-user"
}

resource "aws_iam_policy" "readonly" {
  name   = "readonly-policy"
  policy = data.aws_iam_policy_document.readonly.json
}

resource "aws_iam_user_policy_attachment" "attach" {
  user       = aws_iam_user.ci_user.name
  policy_arn = aws_iam_policy.readonly.arn
}
```

## AWS CLI Example
```sh
aws iam create-user --user-name ci-cd-user
aws iam attach-user-policy --user-name ci-cd-user --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```

## Best Practices
- Use groups to assign permissions to users.
- Enable MFA for privileged users.
- Regularly audit IAM policies.

## Common Pitfalls
- Overly permissive policies (e.g., `*:*` actions).
- Not rotating access keys.

> **Joke:** Why did the IAM user get locked out? Because he forgot his policy statement!
