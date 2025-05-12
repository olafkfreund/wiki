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

## Using agenix for Secrets Management

[agenix](https://github.com/ryantm/agenix) is a Nix-native tool for managing encrypted secrets using age. It allows you to store secrets in your Git repository, encrypted for specific users or hosts, and decrypt them only when needed in your Nix or devenv environment.

### 1. Install agenix
- Add to your environment (Nix shell, devenv, or devbox):
  ```nix
  # In devenv.nix or shell.nix
  packages = [ pkgs.agenix ];
  ```
- Or install globally:
  ```bash
  nix profile install github:ryantm/agenix
  ```

### 2. Generate age key pairs
- For each user or host that should decrypt secrets:
  ```bash
  age-keygen -o ~/.age/key.txt
  # Public key is shown in output or with:
  cat ~/.age/key.txt | grep public
  ```
- Add the public key(s) to your project, e.g. in `secrets/age.pub`.

### 3. Create `age.secrets` file
- List all public keys that should have access:
  ```
  # secrets/age.secrets
  AGE-SECRET-KEY-1... # user1
  AGE-SECRET-KEY-2... # user2
  ...
  ```

### 4. Encrypt a secret
- Encrypt a file for the listed recipients:
  ```bash
  agenix -e secrets/aws-creds.age
  # This will prompt for the secret value and encrypt it for the recipients in age.secrets
  ```
- The resulting `.age` file can be committed to Git.

### 5. Reference secrets in devenv
- In your `devenv.nix`:
  ```nix
  secrets."AWS_CREDS" = {
    file = ./secrets/aws-creds.age;
    env = "AWS_SHARED_CREDENTIALS_FILE";
  };
  ```
- When you run `nix develop` or `devenv up`, agenix will decrypt the secret and set the environment variable.

### 6. Usage in your workflow
- Only users with the corresponding private key can decrypt the secret.
- To rotate or add users, update `age.secrets` and re-encrypt.

---

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
- [agenix GitHub](https://github.com/ryantm/agenix)
- [age encryption tool](https://age-encryption.org/)

With devenv and Nix, you get reproducible, secure, and portable dev environments for any stack.
