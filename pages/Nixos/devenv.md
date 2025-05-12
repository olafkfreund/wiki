# Using devenv with Nix: Dev Environments Made Easy

devenv is a tool for creating reproducible, declarative development environments using Nix. It is ideal for teams and projects that want consistent tooling, easy onboarding, and secure secret management.

## Why use devenv?
- **Reproducibility**: Every developer gets the same environment, on any OS (Linux, macOS, WSL).
- **Isolation**: No more global tool pollution—everything is project-scoped.
- **Automation**: Integrates with CI/CD for consistent builds and tests.
- **Secrets Management**: Supports [agenix](https://github.com/ryantm/agenix) for encrypted secrets in Git.
- **Easy Onboarding**: `devenv up` and you’re ready to code.

## Example: Terraform + AWS + agenix

### 1. Project Structure
```
my-aws-project/
├── devenv.nix
├── secrets/
│   └── aws-creds.age
├── .envrc (optional)
└── main.tf
```

### 2. Example `devenv.nix`
```nix
{ pkgs, ... }:
{
  # Packages for your dev shell
  packages = [ pkgs.terraform pkgs.awscli2 pkgs.agenix ];

  # agenix secrets
  secrets."AWS_CREDS" = {
    file = ./secrets/aws-creds.age;
    # Optionally, set environment variable
    env = "AWS_SHARED_CREDENTIALS_FILE";
  };

  # Environment variables
  env.AWS_PROFILE = "default";

  # Pre-commit hooks, CI, etc. can be added here
}
```

### 3. Example `main.tf`
```hcl
provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = var.shared_credentials_file
}

variable "shared_credentials_file" {
  default = env("AWS_SHARED_CREDENTIALS_FILE")
}

resource "aws_s3_bucket" "example" {
  bucket = "my-devenv-bucket"
  acl    = "private"
}
```

### 4. Using agenix for secrets
- Encrypt your AWS credentials:
  ```bash
  agenix -e secrets/aws-creds.age
  ```
- Only users with the right SSH keys can decrypt.

### 5. Usage
```bash
nix develop # or devenv up
# Secrets are decrypted and available as env vars
terraform init
terraform apply
```

## References
- [devenv.sh](https://devenv.sh/)
- [agenix](https://github.com/ryantm/agenix)
- [NixOS Wiki: devenv](https://nixos.wiki/wiki/Devenv)

With devenv and Nix, you get reproducible, secure, and portable dev environments for any stack.
