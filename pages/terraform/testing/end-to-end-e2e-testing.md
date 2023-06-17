# End-to-End (E2E) Testing

End-to-end testing involves testing your infrastructure configuration in a production-like environment to ensure that it works as expected in a real-world scenario. This can be done using tools like **Terratest** or manual testing in a staging environment.

Continuing with the Azure storage account example, let’s look at how we can use Terratest to implement end-to-end testing.

1. Create a Terraform [configuration file](https://spacelift.io/blog/terraform-files) that defines an Azure Storage account and container:

_main.tf_

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "test-resource-group"
  location = "uksouth"
}

resource "azurerm_storage_account" "test" {
  name                     = "teststorageaccount"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  tags = {
    environment = "test"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
```

2. Create a Terratest test file to deploy the Terraform configuration and validate the created Azure Storage account exists, along with testing that the container has the correct name and access type.

_storage\_test.go_

```hcl
package test

import (
 "context"
 "fmt"
 "os"
 "testing"

 "github.com/Azure/azure-sdk-for-go/profiles/latest/storage/mgmt/storage"
 "github.com/gruntwork-io/terratest/modules/azure"
 "github.com/gruntwork-io/terratest/modules/terraform"
 "github.com/stretchr/testify/assert"
)

func TestAzureStorageAccountAndContainer(t *testing.T) {
 t.Parallel()

 // Define the Terraform options with the desired variables
 terraformOptions := &terraform.Options{
  // The path to the Terraform code to be tested.
  TerraformDir: "../",

  // Variables to pass to our Terraform code using -var options
  Vars: map[string]interface{}{
   "environment": "test",
  },
 }

 // Deploy the Terraform code
 defer terraform.Destroy(t, terraformOptions)
 terraform.InitAndApply(t, terraformOptions)

 // Retrieve the Azure Storage account and container information using the Azure SDK
 storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
 storageAccountGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
 containerName := terraform.Output(t, terraformOptions, "container_name")

 // Authenticate using the environment variables or Azure CLI credentials
 azClient, err := azure.NewClientFromEnvironmentWithResource("https://storage.azure.com/")
 if err != nil {
  t.Fatal(err)
 }

 // Get the container properties
 container, err := azClient.GetBlobContainer(context.Background(), storageAccountGroupName, storageAccountName, containerName)
 if err != nil {
  t.Fatal(err)
 }

 // Check that the container was created with the expected configuration
 assert.Equal(t, "testcontainer", *container.Name)
 assert.Equal(t, "private", string(container.Properties.PublicAccess))

 fmt.Printf("Container %s was created successfully\n", containerName)
}
```

3. Run the test by navigating to the directory where the go file is saved and run the following command.

```hcl
go test -v
```
