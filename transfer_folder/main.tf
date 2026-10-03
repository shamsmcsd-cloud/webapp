terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod"
    container_name       = "project3"
    key                  = "project3.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "project3" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Project3"
    ManagedBy   = "Terraform"
  }
}

# App Service Plan
resource "azurerm_service_plan" "project3" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.project3.location
  resource_group_name = azurerm_resource_group.project3.name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = azurerm_resource_group.project3.tags
}

# Web App
resource "azurerm_linux_web_app" "project3" {
  name                = var.web_app_name
  location            = azurerm_resource_group.project3.location
  resource_group_name = azurerm_resource_group.project3.name
  service_plan_id     = azurerm_service_plan.project3.id

  site_config {
    application_stack {
      python_version = "3.11"
    }

    startup_command = "./startup.sh"
  }

  app_settings = {
    ENVIRONMENT = var.environment
    PORT        = "8000"
  }

  tags = azurerm_resource_group.project3.tags
}

output "web_app_url" {
  value       = "https://${azurerm_linux_web_app.project3.default_hostname}"
  description = "URL of the deployed web app"
}
