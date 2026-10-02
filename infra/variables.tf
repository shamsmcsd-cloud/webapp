variable "subscription_id" {
  description = "Null = read from the ARM_SUBSCRIPTION_ID environment variable (azurerm v4 requires one or the other)."
  type        = string
  default     = null
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be dev, uat or prod."
  }
}

variable "app_name" {
  description = "Short lowercase name used in every resource name."
  type        = string
  default     = "hello"
}

variable "location" {
  type    = string
  default = "centralus"
}

variable "sku_name" {
  type = string
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "python_version" {
  type    = string
  default = "3.12"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
