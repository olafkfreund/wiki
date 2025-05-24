# AWS Landing Zone: Real-World Guide for DevOps Engineers

An **AWS Landing Zone** is a secure, scalable, multi-account AWS environment based on best practices. It provides a foundation for cloud adoption, enabling organizations to deploy workloads with governance, security, and compliance from day one.

---

## What is an AWS Landing Zone?

- A pre-configured AWS environment with multiple accounts (e.g., security, logging, shared services, workloads)
- Implements guardrails using Service Control Policies (SCPs), AWS Organizations, IAM, and centralized logging
- Automates account creation, baseline networking (VPCs), and security controls

**References:**
- [AWS Landing Zone Solution](https://aws.amazon.com/solutions/implementations/aws-landing-zone/)
- [AWS Control Tower](https://docs.aws.amazon.com/controltower/latest/userguide/)

---

## Real-Life Use Cases

- **Enterprise Cloud Adoption:** Standardize environments for multiple business units
- **Regulated Industries:** Enforce compliance (e.g., PCI, HIPAA) with automated guardrails
- **Startups/Scale-ups:** Rapidly scale with secure, repeatable account structures

---

## Configuration Options

- **Account Structure:** Define core accounts (security, log archive, shared services, workload)
- **Networking:** Centralized VPCs, shared subnets, Transit Gateway, VPC peering
- **Security:** SCPs, IAM roles, AWS Config, CloudTrail, GuardDuty, Security Hub
- **Automation:** Use AWS Control Tower, custom Terraform, or CloudFormation

---

## Example: AWS Landing Zone with Terraform

Below is a simplified example using Terraform to create an AWS Organization, core accounts, and baseline guardrails.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "security" {
  name      = "Security"
  email     = "security@example.com"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_account" "log_archive" {
  name      = "LogArchive"
  email     = "logs@example.com"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy" "deny_s3_public" {
  name        = "DenyS3PublicAccess"
  description = "Deny S3 public access"
  content     = file("policies/deny_s3_public.json")
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  policy_id = aws_organizations_policy.deny_s3_public.id
  target_id = aws_organizations_organization.main.roots[0].id
}
```

**Tip:** Store your SCP JSON in a `policies/deny_s3_public.json` file for modularity.

---

## Example: Terraform Test with terraform-compliance

You can use [terraform-compliance](https://terraform-compliance.com/) to test your Terraform code for security and compliance. Example test to ensure S3 public access is denied:

```gherkin
Feature: Deny S3 Public Access
  Scenario: Ensure S3 buckets do not allow public access
    Given I have aws_s3_bucket defined
    Then it must contain public_access_block
    And its block_public_acls must be true
    And its block_public_policy must be true
```

---

## Notes for Linux, WSL, and NixOS Users

- **Linux:** Use the latest Terraform binary and AWS CLI. Install via your package manager or [official releases](https://developer.hashicorp.com/terraform/downloads).
- **WSL:** Ensure your AWS credentials are accessible in your WSL home directory. Use `wsl --mount` for shared filesystems if needed.
- **NixOS:** Use [nixpkgs](https://search.nixos.org/packages) for reproducible installs:
  ```nix
  environment.systemPackages = with pkgs; [ terraform awscli ];
  ```
- Always use environment variables or [AWS profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for credentials—never hard-code secrets.

---

## Landing Zone Joke

> Why did the DevOps engineer refuse to deploy in an unprepared AWS account?
>
> Because there was no landing zone—he didn’t want to crash the cloud party!

---

For more advanced patterns, see [AWS Control Tower](https://docs.aws.amazon.com/controltower/latest/userguide/) and the [AWS Landing Zone Accelerator](https://github.com/awslabs/landing-zone-accelerator-on-aws).
