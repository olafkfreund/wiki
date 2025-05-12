# Backend Best-Practise

## Terraform Backend <a href="#6128" id="6128"></a>

Every Terraform configuration can specify a backend, which defines where and how operations are performed, and where state snapshots are stored.

When working on a team or managing a large infrastructure, it is advisable to use a remote backend. Remote backends enable seamless collaboration within the team and provide version control capabilities. They allow multiple people to work on the same infrastructure efficiently.

Terraform uses a backend to determine how state is loaded and how an operation such as `apply` is executed. The state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

### **Local Backends** <a href="#98e9" id="98e9"></a>

This is the default backend and it stores state on the local filesystem, locks that state with system APIs, and performs operations locally. f you don’t specify a backend in your Terraform configuration, Terraform will use the local backend.

The local backend stores state on the local filesystem, locks that state using system APIs, and performs operations locally.

```hcl
terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }
}
```plaintext

In this example, the `path` argument tells Terraform where to store the state file. The path is relative to the root module directory. If the path is not specified, Terraform will use the default location, which is `terraform.tfstate` in the root module directory.

### Remote Backends <a href="#cb88" id="cb88"></a>

These store the state and may be used to run operations in a remote environment. Remote backends allow multiple collaborators and automated systems to use Terraform together in a more coordinated way, which is useful for production infrastructures. Some of these backends, like the S3 backend, support state locking for concurrent runs.

For example:

```hcl
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```plaintext

## Key Points of Using Backends <a href="#82a8" id="82a8"></a>

There are a few key points to remember when working with backend configurations:

1. When the backend configuration changes, it is crucial to run `terraform init`. This ensures that Terraform pulls down the necessary configuration for the new backend. Failure to run `terraform init` may result in using the previous backend configuration.
2. Terraform provides an option to migrate your state when the backend changes. Although convenient, it is always recommended to manually back up your state to ensure data safety. Make a copy of the `terraform.tfstate` file and store it in a separate location until the migration is complete.

## Backends Examples <a href="#7ecb" id="7ecb"></a>

Remote backends like AWS S3 and Azure Blob Storage are popular choices as they allow for state locking and work well in team environments. Below are examples of how to configure both.

### AWS S3 <a href="#b7cc" id="b7cc"></a>

```hcl
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-west-2"
    # Optional, allows state locking & consistency checking
    dynamodb_table = "mytable"
  }
}
```plaintext

In this example, Terraform uses an S3 bucket in the `us-west-2` region to store the state file. The `mybucket` and `path/to/my/key` values should be replaced with your actual bucket name and key. The `dynamodb_table` option is used for state locking and consistency checking, which prevents others from running Terraform at the same time.

### Azure <a href="#4a5a" id="4a5a"></a>

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```plaintext

In this example, Terraform uses an Azure Storage Account Blob Container to store the state file. Replace `"StorageAccount-ResourceGroup"`, `"abcd1234"`, `"tfstate"`, and `"prod.terraform.tfstate"` with your actual resource group name, storage account name, storage container name, and key respectively.

## Best Practices <a href="#7b66" id="7b66"></a>

* **Use Remote State**: Remote state allows you to share the state of your infrastructure between all members of your team. This is necessary for collaboration and is more secure because only the changes are pulled and pushed, which means that sensitive parts of your state never have to be on a disk.
* **Enable State Locking**: State locking helps to prevent any concurrent runs of Terraform that could lead to corruption of the state file or conflicts in the infrastructure changes. Many remote backends like AWS S3 (when used with DynamoDB), Azure Blob Storage, Google Cloud Storage, etc., support state locking.
* **Secure Your Backend**: The state file can contain sensitive information, so it’s essential to secure it. Use encryption at rest if it’s supported by the backend. Also, control access to the backend using appropriate IAM roles and policies.
* **Keep Different Environments Separate**: You should have different state files for different environments like production, staging, development, etc. This can be achieved using workspaces or separate backend configurations.
* **Use Versioning**: If your backend supports versioning (like AWS S3), enable it. It allows you to roll back to a previous version of the state file if something goes wrong.
* **Backup Your State File**: Even though your state is stored remotely and possibly versioned, it’s still a good idea to occasionally backup your state file, especially before making significant changes.
* **Limit Access**: The state file can include sensitive data, depending on your infrastructure. You should limit access to the state file to only those who absolutely need it.

## Conclusion <a href="#fd0e" id="fd0e"></a>

<figure><img src="https://miro.medium.com/v2/resize:fit:594/1*yrYF54oH_kgN-a2Qd7IOqg.png" alt="" height="342" width="594"><figcaption></figcaption></figure>
