variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "project2-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod."
  }
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "project2-asp"
}

variable "web_app_name" {
  description = "Name of the Web App"
  type        = string
  default     = "project2-webapp"
}

variable "sku_name" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "B1"
}
