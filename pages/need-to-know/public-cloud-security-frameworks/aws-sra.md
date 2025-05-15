# AWS Security Reference Architecture (SRA)

The AWS Security Reference Architecture (SRA) provides a practical blueprint for building secure, compliant, and resilient cloud environments. It aligns with the AWS Cloud Adoption Framework (CAF), AWS Well-Architected Framework, and the AWS Shared Responsibility Model.

---

## 1. Foundations & Frameworks
- **AWS CAF:** Organize security guidance into perspectives (business, people, governance, platform, security, operations).
- **Well-Architected Framework:** Follow the six pillars, especially the [Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html).
- **Shared Responsibility Model:** AWS secures the cloud infrastructure; you secure your workloads, data, and configurations. ([Learn more](https://aws.amazon.com/compliance/shared-responsibility-model/))

---

## 2. Security Capabilities: Actionable Steps

### Security Governance
- Define security policies and roles in code (e.g., Terraform IAM policies).
- Example:
  ```hcl
  resource "aws_iam_policy" "readonly" {
    name   = "readonly-policy"
    policy = data.aws_iam_policy_document.readonly.json
  }
  ```
- Use AWS Organizations for account structure and SCPs (Service Control Policies).

### Security Assurance
- Enable AWS Config to track resource changes:
  ```sh
  aws configservice put-configuration-recorder --configuration-recorder name=default,roleARN=<role-arn>
  aws configservice start-configuration-recorder --configuration-recorder-name default
  ```
- Use AWS Security Hub for continuous compliance checks.

### Identity and Access Management
- Enforce least privilege with IAM roles and policies.
- Use SSO and MFA for all users.
- Example: Require MFA for console access.

### Threat Detection
- Enable GuardDuty in all regions:
  ```sh
  aws guardduty create-detector --enable
  ```
- Aggregate findings in Security Hub.

### Vulnerability Management
- Use AWS Inspector for EC2 and container image scanning.
- Integrate with CI/CD (e.g., scan ECR images on push).

### Infrastructure Protection
- Use Security Groups, NACLs, and VPC flow logs.
- Automate network segmentation with IaC.

### Data Protection
- Encrypt data at rest (KMS, S3 default encryption) and in transit (TLS).
- Example: Enable S3 bucket encryption by default.
  ```hcl
  resource "aws_s3_bucket" "secure" {
    bucket = "my-secure-bucket"
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
  ```

### Application Security
- Integrate static code analysis (CodeGuru, SonarQube) in CI/CD.
- Use WAF and Shield for web app protection.

### Incident Response
- Automate incident response with Lambda and CloudWatch Events.
- Example: Auto-isolate compromised EC2 instance.
  ```hcl
  # Use Lambda triggered by GuardDuty finding to quarantine instance
  ```
- Run regular incident response simulations (tabletop, chaos engineering).

---

## 3. Security Design Principles: Best Practices
- **Strong Identity Foundation:** Use IAM roles, avoid long-lived credentials, enable SSO and MFA.
- **Enable Traceability:** Centralize logging (CloudTrail, CloudWatch Logs, S3), enable real-time alerts.
- **Apply Security at All Layers:** Use defense-in-depth (network, compute, app, data).
- **Automate Security:** Use Terraform/CloudFormation for all security controls, automate patching and compliance.
- **Protect Data:** Encrypt everything, classify data, restrict access.
- **Keep People Away from Data:** Use automation, limit direct access, use session recording.
- **Prepare for Security Events:** Document runbooks, automate response, conduct regular drills.

---

## 4. Real-Life Example: Secure Multi-Account AWS Landing Zone
1. Use AWS Control Tower or Terraform to create a multi-account structure (prod, dev, audit).
2. Apply SCPs to restrict actions (e.g., deny S3 public access).
3. Enable GuardDuty, Security Hub, and Config in all accounts.
4. Centralize CloudTrail logs to a secure S3 bucket.
5. Use IAM roles for cross-account access and automation.
6. Integrate security checks in CI/CD (Terraform validate, Checkov, Trivy).

---

## 5. Common Pitfalls
- Not enabling security services in all regions/accounts
- Overly permissive IAM policies
- Manual changes outside of IaC
- Lack of centralized logging and monitoring
- Not testing incident response plans

---

## 6. References
- [AWS Security Reference Architecture](https://docs.aws.amazon.com/security-reference-architecture/latest/sra-aws/welcome.html)
- [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [AWS Shared Responsibility Model](https://aws.amazon.com/compliance/shared-responsibility-model/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
- [AWS GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)
- [AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/)
- [AWS Inspector](https://docs.aws.amazon.com/inspector/latest/user/)
- [AWS Control Tower](https://docs.aws.amazon.com/controltower/latest/userguide/)

---

> For step-by-step implementation, see the [AWS SRA GitHub repository](https://github.com/aws-samples/aws-security-reference-architecture-examples) and official AWS documentation.
