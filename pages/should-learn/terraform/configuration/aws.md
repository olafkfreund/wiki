# AWS

### [Authentication and Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) <a href="#authentication-and-configuration" id="authentication-and-configuration"></a>

Configuration for the AWS Provider can be derived from several sources, which are applied in the following order:

1. Parameters in the provider configuration
2. Environment variables
3. Shared credentials files
4. Shared configuration files
5. Container credentials
6. Instance profile credentials and region

This order matches the precedence used by the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-precedence) and the [AWS SDKs](https://aws.amazon.com/tools/).

The AWS Provider supports assuming an IAM role, either in the provider configuration block parameter `assume_role` or in [a named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html).

The AWS Provider supports assuming an IAM role using [web identity federation and OpenID Connect (OIDC)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc). This can be configured either using environment variables or in a named profile.

When using a named profile, the AWS Provider also supports [sourcing credentials from an external process](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html).

#### [Provider Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration) <a href="#provider-configuration" id="provider-configuration"></a>

Warning:

Hard-coded credentials are not recommended in any Terraform configuration and risks secret leakage should this file ever be committed to a public version control system.

Credentials can be provided by adding an `access_key`, `secret_key`, and optionally `token`, to the `aws` provider block.

Usage:

```terraform
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```plaintext

Other settings related to authorization can be configured, such as:

* [`profile`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#profile)
* [`shared_config_files`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared\_config\_files)
* [`shared_credentials_files`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared\_credentials\_files)

#### [Environment Variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) <a href="#environment-variables" id="environment-variables"></a>

Credentials can be provided by using the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN` environment variables. The region can be set using the `AWS_REGION` or `AWS_DEFAULT_REGION` environment variables.

For example:

```terraform
provider "aws" {}
```plaintext

```sh
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_REGION="us-west-2"
$ terraform plan
```plaintext

Other environment variables related to authorization are:

* [`AWS_PROFILE`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#AWS\_PROFILE)
* [`AWS_CONFIG_FILE`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#AWS\_CONFIG\_FILE)
* [`AWS_SHARED_CREDENTIALS_FILE`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#AWS\_SHARED\_CREDENTIALS\_FILE)

#### [Shared Configuration and Credentials Files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-configuration-and-credentials-files) <a href="#shared-configuration-and-credentials-files" id="shared-configuration-and-credentials-files"></a>

The AWS Provider can source credentials and other settings from the [shared configuration and credentials files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html). By default, these files are located at `$HOME/.aws/config` and `$HOME/.aws/credentials` on Linux and macOS, and `"%USERPROFILE%\.aws\config"` and `"%USERPROFILE%\.aws\credentials"` on Windows.

If no named profile is specified, the `default` profile is used. Use the `profile` parameter or `AWS_PROFILE` environment variable to specify a named profile.

The locations of the shared configuration and credentials files can be configured using either the parameters `shared_config_files` and `shared_credentials_files` or the environment variables `AWS_CONFIG_FILE` and `AWS_SHARED_CREDENTIALS_FILE`.

For example:

```terraform
provider "aws" {
  shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile                  = "customprofile"
}
```plaintext

#### [Container Credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#container-credentials) <a href="#container-credentials" id="container-credentials"></a>

If you're running Terraform on CodeBuild or ECS and have configured an [IAM Task Role](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html), Terraform can use the container's Task Role. This support is based on the underlying `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` and `AWS_CONTAINER_CREDENTIALS_FULL_URI` environment variables being automatically set by those services or manually for advanced usage.

If you're running Terraform on EKS and have configured [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), Terraform can use the pod's role. This support is based on the underlying `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE` environment variables being automatically set by Kubernetes or manually for advanced usage.

#### [Instance profile credentials and region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#instance-profile-credentials-and-region) <a href="#instance-profile-credentials-and-region" id="instance-profile-credentials-and-region"></a>

When the AWS Provider is running on an EC2 instance with an IAM Instance Profile set, the provider can source credentials from the [EC2 Instance Metadata Service](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html#instance-metadata-security-credentials). Both IMDS v1 and IMDS v2 are supported.

A custom endpoint for the metadata service can be provided using the `ec2_metadata_service_endpoint` parameter or the `AWS_EC2_METADATA_SERVICE_ENDPOINT` environment variable.

#### [Assuming an IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assuming-an-iam-role) <a href="#assuming-an-iam-role" id="assuming-an-iam-role"></a>

If provided with a role ARN, the AWS Provider will attempt to assume this role using the supplied credentials.

Usage:

```terraform
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/ROLE_NAME"
    session_name = "SESSION_NAME"
    external_id  = "EXTERNAL_ID"
  }
}
```plaintext

> **Hands-on:** Try the [Use AssumeRole to Provision AWS Resources Across Accounts](https://learn.hashicorp.com/tutorials/terraform/aws-assumerole) tutorial.

#### [Assuming an IAM Role Using A Web Identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assuming-an-iam-role-using-a-web-identity) <a href="#assuming-an-iam-role-using-a-web-identity" id="assuming-an-iam-role-using-a-web-identity"></a>

If provided with a role ARN and a token from a web identity provider, the AWS Provider will attempt to assume this role using the supplied credentials.

Usage:

```terraform
provider "aws" {
  assume_role_with_web_identity {
    role_arn                = "arn:aws:iam::123456789012:role/ROLE_NAME"
    session_name            = "SESSION_NAME"
    web_identity_token_file = "/Users/tf_user/secrets/web-identity-token"
  }
}
```plaintext

#### [Using an External Credentials Process](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#using-an-external-credentials-process) <a href="#using-an-external-credentials-process" id="using-an-external-credentials-process"></a>

To use an [external process to source credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html), the process must be configured in a named profile, including the `default` profile. The profile is configured in a shared configuration file.

For example:

```terraform
provider "aws" {
  profile = "customprofile"
}
```plaintext

```plaintext
[profile customprofile]
credential_process = custom-process --username jdoe
```plaintext
