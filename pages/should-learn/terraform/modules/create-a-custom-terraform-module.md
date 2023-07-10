# Create a Custom Terraform Module

## Background <a href="#9704" id="9704"></a>

Custom Terraform Modules provide several benefits to infrastructure automation and management.

They are reusable code blocks that abstract infrastructure configuration into modular and easily repeatable pieces.

## ome benefits of using custom Terraform modules <a href="#f980" id="f980"></a>

### **Simpler Codebase** <a href="#424e" id="424e"></a>

With a custom Terraform module, you can abstract complex infrastructure logic into a smaller and more manageable codebase. This makes it easier to write and maintain Terraform code, reduces the risk of errors, and increases the overall reliability of your infrastructure.

### Easier Collaboration <a href="#f0e3" id="f0e3"></a>

Terraform modules make it easier to collaborate on infrastructure projects. Instead of having to share large and complex Terraform files, collaborators can simply share smaller and more manageable modules. This makes it easier to maintain and update the infrastructure over time.

### Reusability <a href="#251d" id="251d"></a>

Custom Terraform modules are reusable, which means that you can reuse them across multiple infrastructure projects. This saves time and effort, as you don’t need to write new code each time you want to set up similar infrastructure.

### Consistency <a href="#9fd5" id="9fd5"></a>

Custom Terraform modules ensure that your infrastructure is consistent and follows best practices. By using a module, you can enforce standards and guidelines across your infrastructure, ensuring that your infrastructure is scalable, secure, and efficient.

### Easy Testing <a href="#b0b3" id="b0b3"></a>

Custom Terraform modules are easier to test than complex Terraform files. By breaking down infrastructure into smaller modules, you can test each module in isolation, making it easier to detect and fix issues before they become critical.

## You should consider creating custom Terraform modules if: <a href="#b30b" id="b30b"></a>

### You’re building complex infrastructure <a href="#0cb6" id="0cb6"></a>

Custom Terraform modules are especially useful for complex infrastructure projects that involve many resources and configurations.

### You’re working on multiple infrastructure projects <a href="#22f8" id="22f8"></a>

If you’re working on multiple infrastructure projects, creating custom Terraform modules can save time and effort by allowing you to reuse code across projects.

### You want to enforce standards and best practices <a href="#9632" id="9632"></a>

Custom Terraform modules can help you enforce standards and best practices across your infrastructure, ensuring consistency and reliability.

### You want to simplify your Terraform codebase <a href="#beae" id="beae"></a>

Custom Terraform modules can help you break down complex infrastructure into smaller and more manageable pieces, making it easier to write and maintain Terraform code.

## Let’s create a Custom Terraform Module! <a href="#468b" id="468b"></a>

### Step 1: Create a Directory for Your Module <a href="#6f64" id="6f64"></a>

The first step is to create a directory for your module. You can do this in your terminal using the `mkdir` command, followed by the name of your module directory.

```sh
mkdir my-terraform-module
```

### Step 2: Define the Module Inputs and Outputs <a href="#23cf" id="23cf"></a>

The next step is to define the inputs and outputs for your module. Inputs are variables that the user of the module can set to configure it, while outputs are values that the module returns to the user.

Create a new file named `variables.tf` within the `my-terraform-module` directory, and define the input variables for your module using the `variable` block.

Here’s an example:

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

Next, create another file named `outputs.tf` within the `my-terraform-module` directory, and define the output values for your module using the `output` block. Here's an example:

```hcl
output "instance_id" {
  value = aws_instance.my_instance.id
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
```

### Step 3: Define the Resources <a href="#30ad" id="30ad"></a>

The next step is to define the resources that your module creates. Resources are the actual infrastructure components that Terraform manages.

Create a new file named `main.tf` within the `my-terraform-module` directory, and define the resources for your module. Here's an example:

```hcl
resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  tags = {
    Name = "my-instance"
  }
}
```

### Step 4: Add Provider Configuration <a href="#7dfd" id="7dfd"></a>

If your module uses resources from a specific cloud provider, you’ll need to configure the provider. Create a new file named `providers.tf` within the `my-terraform-module` directory, and add the provider configuration. Here's an example:

```hcl
provider "aws" {
  region = var.aws_region
}
```

### Step 5: Create a README <a href="#2b06" id="2b06"></a>

Create a `README.md` file in your module directory that explains how to use your module. This should include information about the input variables, output values, and any other configuration that the user needs to provide.

Here’s an example README:

```hcl
# Terraform Module: My Module

This module creates a sample EC2 instance in AWS.

## Usage


module "my_module" {
  source = "github.com/arwahab/my-terraform-module"

  aws_region     = "us-east-1"
  instance_type  = "t2.micro"
}

output "instance_id" {
  value = module.my_module.instance_id
}

output "instance_public_ip" {
  value = module.my_module.instance_public_ip
}
```
