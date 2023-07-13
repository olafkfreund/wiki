# Terraform

This example provisions a Linux App Service which runs multiple Docker Containers from Docker Compose file.

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
     image: wordpress:latest
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
    linux_fx_version = "COMPOSE|${filebase64("docker-compose.yml")}"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}
```



