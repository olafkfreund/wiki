# Functions

### Function 1 <a href="#50e2" id="50e2"></a>

**Function**: `coalesce()`\
Description: The _coalesce()_ function returns the first non-null argument from a list of arguments.

Use case: When dealing with optional or conditional values, _coalesce()_ helps provide a default value when the desired value is not available.

```hcl
locals {
 fallback_value = "default"
 optional_value = null
 result = coalesce(local.optional_value, local.fallback_value)
}
```plaintext

> In my infrastructure, I had a scenario where I needed to handle optional input variables. Let’s say one of the input variables, **optional\_value**, could be null or have a specific value. However, I wanted to ensure that I always have a valid value to work with.

This approach allowed me to provide a default value and ensure the presence of a valid value for further processing within my Terraform configuration. The _coalesce()_ function played a crucial role in handling optional values effectively.

### Function 2 <a href="#ef10" id="ef10"></a>

**Function**: `join()`\
Description: The _join()_ function joins multiple strings into a single string using a specified separator.

Use case: Combining strings with separators is commonly used when constructing file paths, generating configuration strings, or creating command-line arguments.

```hcl
resource "azurerm_storage_account" "example" {
  count = 3
  name                     = join("-", [ azurerm_resource_group.example.location, "sa", count.index + 1, var.environment])
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    ip_rules       = ["23.45.1.0/30"]
  }
}
```plaintext

> I needed to create multiple instances of a particular resource, each with a unique name that included static values and variable inputs. By using the \`join()\` function, I combined the static strings _“web”, “app”,_ and the index value of the current instance (incremented by 1) with a hyphen separator. Additionally, I included the value of the _“environment”_ variable to differentiate instances based on the environment.

### Function 3 <a href="#f5fb" id="f5fb"></a>

**Function**: `lookup()`\
Description: The _lookup()_ function looks up a value in a map based on a given key.

Use case: Looking up values in a map is helpful when you need to retrieve specific configuration values based on keys.

```plaintext
locals {
 environment_vars = {
   "dev" = "development"
   "prod" = "production"
 }

 current_environment = "prod"
 environment_type = lookup(local.environment_vars, local.current_environment, "unknown")
}
```plaintext

> I used it to retrieve the environment type based on the current environment. By using the _lookup()_ function, I searched for the value associated with the _current\_environment_ key in the _environment\_vars_ map. If the key was found, the corresponding value was assigned to _environment\_type_. If the key was not found, I provided a default value of “_**unknown**_”.

### Function 4 <a href="#71be" id="71be"></a>

**Function**: `format()`\
Description: The _format()_ function is used to format a string based on a given format specifier.

Use case: Formatting strings is useful when you need to generate dynamic resource names or construct complex output strings.

```hcl
resource "azurerm_linux_web_app" "webapp" {
  count = 2
  name                  = format("webapp-linux-%02d", count.index + 1)
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
  }
}
```plaintext

> We have so many functions which we can use to achieve similar things I used this _format()_ function to create multiple S3 buckets with sequentially numbered names. By using the _format()_ function, I constructed the bucket name by combining the static string “my-bucket-” with the index value. This is similar to what we did with join() function.

### Function 5 <a href="#cd86" id="cd86"></a>

**Function**: `element()` _\[element(list, index)]_\
Description: The _element()_ function retrieves the element at a specific index from a list.

Use case: Accessing a specific element in a list is useful when you want to select a particular resource or parameter from a list based on its index.

```hcl
locals {
 regions = ["uksouth", "ukwest" ]
 primary_region = element(local.regions, 1)
}
```plaintext

> Here we used _element()_ to designate a specific region as the primary region for my deployment. By using the _element()_ function with an index value of 1, I retrieved the element at index 1 from the _regions_ list, assigning it to _primary\_region_.



Created by [https://medium.com/@inkinsight](https://medium.com/@inkinsight)
