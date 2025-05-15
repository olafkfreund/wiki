# Terraform: Deploying Docker Compose on Azure App Service

This guide demonstrates how to use Terraform to provision an Azure Linux App Service that runs multiple Docker containers using a Docker Compose file. It includes best practices, step-by-step instructions, and common pitfalls for real-life DevOps workflows.

---

## Best Practices
- Store your Docker Compose file (`docker-compose.yml`) in version control and keep secrets out of the file (use environment variables or Azure Key Vault).
- Pin image versions (avoid `latest`) for reproducibility.
- Use Terraform variables for resource names, locations, and sensitive data.
- Enable monitoring and logging for your App Service.
- Use CI/CD pipelines (GitHub Actions, Azure Pipelines) to automate deployments.

---

## Step-by-Step: Deploy Multi-Container App with Terraform

1. **Write your Docker Compose file:**
   ```yaml
   version: '3.3'
   services:
     db:
       image: mysql:5.7
       volumes:
         - db_data:/var/lib/mysql
       restart: always
       environment:
         MYSQL_ROOT_PASSWORD: somewordpress
         MYSQL_DATABASE: wordpress
         MYSQL_USER: wordpress
         MYSQL_PASSWORD: wordpress
     wordpress:
       depends_on:
         - db
       image: wordpress:6.4.3
       ports:
         - "8000:80"
       restart: always
       environment:
         WORDPRESS_DB_HOST: db:3306
         WORDPRESS_DB_USER: wordpress
         WORDPRESS_DB_PASSWORD: wordpress
   volumes:
     db_data:
   ```

2. **Terraform configuration:**
   ```hcl
   provider "azurerm" {
     features {}
   }

   resource "azurerm_resource_group" "main" {
     name     = "${var.prefix}-resources"
     location = var.location
   }

   resource "azurerm_app_service_plan" "main" {
     name                = "${var.prefix}-asp"
     location            = azurerm_resource_group.main.location
     resource_group_name = azurerm_resource_group.main.name
     kind                = "Linux"
     reserved            = true
     sku {
       tier = "Standard"
       size = "S1"
     }
   }

   resource "azurerm_app_service" "main" {
     name                = "${var.prefix}-appservice"
     location            = azurerm_resource_group.main.location
     resource_group_name = azurerm_resource_group.main.name
     app_service_plan_id = azurerm_app_service_plan.main.id
     site_config {
       app_command_line = ""
       linux_fx_version = "COMPOSE|${filebase64("docker-compose.yml")}"  # Use filebase64 to encode the compose file
     }
     app_settings = {
       "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
     }
   }
   ```

3. **Deploy with Terraform:**
   ```sh
   terraform init
   terraform apply -var="prefix=myapp" -var="location=westeurope"
   ```

4. **Access your app:**
   - Find the app's URL in the Azure Portal or via Terraform output.

---

## Real-Life Example: CI/CD Integration
- Use GitHub Actions to deploy on every push:
  ```yaml
  - name: Terraform Apply
    run: terraform apply -auto-approve -var="prefix=myapp" -var="location=westeurope"
  ```

---

## Common Pitfalls
- Using `latest` image tags (can cause unexpected updates)
- Not encoding the Docker Compose file with `filebase64`
- Not setting `WEBSITES_ENABLE_APP_SERVICE_STORAGE` (can cause issues with persistent storage)
- Forgetting to open required ports in the Compose file
- Not monitoring app health and logs

---

## References
- [Azure App Service for Containers](https://learn.microsoft.com/en-us/azure/app-service/containers/)
- [Terraform azurerm_app_service Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service)
- [Deploy Docker Compose on Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/quickstart-multi-container?tabs=cli)



