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
    container_name       = "project1"
    key                  = "project1.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "project1" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Project1"
    ManagedBy   = "Terraform"
  }
}

# App Service Plan
resource "azurerm_service_plan" "project1" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = azurerm_resource_group.project1.tags
}

# Web App
resource "azurerm_linux_web_app" "project1" {
  name                = var.web_app_name
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name
  service_plan_id     = azurerm_service_plan.project1.id

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

  tags = azurerm_resource_group.project1.tags
}

output "web_app_url" {
  value       = "https://${azurerm_linux_web_app.project1.default_hostname}"
  description = "URL of the deployed web app"
}
