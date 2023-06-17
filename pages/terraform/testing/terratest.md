# Terratest

In the Terratest example below, a function is created to test the creation of an Azure storage account in a resource group, and a container in the storage account, then verifies that the storage account and container exist. The resources are then cleaned up after the test is complete.

```hcl
package test

import (
 "context"
 "fmt"
 "testing"
 "time"

 "github.com/Azure/azure-sdk-for-go/storage"
 "github.com/gruntwork-io/terratest/modules/azure"
 "github.com/gruntwork-io/terratest/modules/random"
 "github.com/gruntwork-io/terratest/modules/testing"
)

func TestAzureStorageAccount(t *testing.T) {
 t.Parallel()

 // Set the Azure subscription ID and resource group where the Storage Account will be created
 uniqueID := random.UniqueId()
 subscriptionID := "YOUR_AZURE_SUBSCRIPTION_ID"
 resourceGroupName := fmt.Sprintf("test-rg-%s", uniqueID)

 // Create the resource group
 azure.CreateResourceGroup(t, resourceGroupName, "uksouth")

 // Set the Storage Account name and create the account
 accountName := fmt.Sprintf("teststorage%s", uniqueID)
 accountType := storage.StandardZRS
 location := "uksouth"
 account := azure.CreateStorageAccount(t, subscriptionID, resourceGroupName, accountName, accountType, location)

 // Create a container in the Storage Account
 ctx := context.Background()
 client, err := storage.NewBasicClient(accountName, azure.GenerateAccountKey(t, accountName))
 if err != nil {
  t.Fatalf("Failed to create Storage Account client: %v", err)
 }
 service := client.GetBlobService()
 containerName := fmt.Sprintf("testcontainer%s", uniqueID)
 if _, err := service.CreateContainer(ctx, containerName, nil); err != nil {
  t.Fatalf("Failed to create container: %v", err)
 }

 // Check if the container exists
 testing.WaitForTerraform(ctx, terraformOptions, nil)

 // Cleanup resources
 defer azure.DeleteResourceGroup(t, resourceGroupName)
}
```

### Unit Testing

Unit testing involves testing individual modules or resources in isolation to ensure that they work as expected. This can again be done using tools like **Terratest** or using Terraform’s built-in testing functionality.
