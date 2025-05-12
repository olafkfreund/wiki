---
description: Guide to programmatically authenticating with AWS using the AWS CLI and SDK
---

# AWS Authentication Methods

## Overview

Programmatic access to AWS requires secure authentication. This guide covers various methods to authenticate with AWS services using command-line tools (AWS CLI) and SDKs, following security best practices as of 2025.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) installed (current version as of May 2025: 2.17.x)
- Basic understanding of AWS IAM concepts
- Terminal or command-line interface

## Authentication Methods

### 1. AWS CLI Configuration with Access Keys

This is the most basic method, but should be used carefully and mainly for development environments.

#### Setup Process

1. **Create Access Keys in AWS Console**:
   - Log in to the AWS Management Console
   - Navigate to IAM → Users → Security credentials
   - Create access key (ideally for a specific purpose)

2. **Configure AWS CLI**:

```bash
aws configure
```

You'll be prompted to enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., us-west-2)
- Default output format (json, yaml, text, table)

This creates configuration files in `~/.aws/credentials` and `~/.aws/config`.

#### For Specific Profiles

For managing multiple AWS accounts or roles:

```bash
aws configure --profile project1
```

Then use the profile with any command:

```bash
aws s3 ls --profile project1
```

### 2. Environment Variables

More secure for CI/CD pipelines or temporary sessions:

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-west-2
```

Then run AWS CLI commands normally without specifying credentials.

### 3. AWS IAM Roles (Recommended for EC2 & Production)

For EC2 instances, Lambda functions, or other AWS services:

1. Create an IAM role with appropriate permissions
2. Attach the role to your EC2 instance or service
3. The AWS CLI will automatically use the instance profile credentials

No manual configuration is needed with this approach, making it the most secure option for resources running within AWS.

### 4. AWS Single Sign-On (AWS SSO)

For enterprise environments with centralized identity management:

1. **Configure AWS SSO** in your organization
2. **Configure the AWS CLI for SSO**:

```bash
aws configure sso
```

3. **Authenticate via the browser**:

```bash
aws sso login --profile sso-profile
```

### 5. Web Identity Federation with Amazon Cognito

For mobile or web applications:

```bash
aws configure set region us-west-2
aws configure set web_identity_token_file /path/to/token/file
aws configure set role_arn arn:aws:iam::123456789012:role/role-name
```

### 6. Using MFA with AWS CLI

For enhanced security with Multi-Factor Authentication:

1. **Create a temporary session**:

```bash
aws sts get-session-token --serial-number arn:aws:iam::123456789012:mfa/user --token-code 123456
```

2. **Use the temporary credentials**:

```bash
export AWS_ACCESS_KEY_ID=returned_access_key
export AWS_SECRET_ACCESS_KEY=returned_secret_key
export AWS_SESSION_TOKEN=returned_session_token
```

## Assuming Roles

Assuming roles is powerful for cross-account access or privilege escalation:

```bash
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/example-role --role-session-name example-session
```

Store the returned credentials as environment variables or in AWS CLI profile.

## Best Practices for AWS Authentication

1. **Use IAM Roles** whenever possible instead of access keys
2. **Implement the principle of least privilege** for all credentials
3. **Rotate access keys** regularly (ideally every 90 days)
4. **Never hardcode credentials** in application code
5. **Use MFA** for all IAM users with console access
6. **Audit authentication methods** with AWS CloudTrail
7. **Use temporary credentials** instead of long-term access keys
8. **Implement identity federation** for enterprise environments

## Troubleshooting Authentication Issues

- **Check credential precedence**: AWS CLI follows a specific order to find credentials
- **Verify IAM permissions**: Ensure the user/role has appropriate permissions
- **Check region configuration**: Some services are region-specific
- **Validate MFA token** if using MFA-protected API access
- **Examine AWS CLI version**: Some authentication methods require newer versions

## References

- [Official AWS CLI Authentication Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS CLI Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)