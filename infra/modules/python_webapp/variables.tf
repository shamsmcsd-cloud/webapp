variable "name" {
  description = "Base name, e.g. \"hello-dev-x7k2\". Resources get a type prefix (app-, asp-, appi-, log-)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  description = "dev | uat | prod. Exposed to the app as APP_ENV."
  type        = string
}

variable "sku_name" {
  description = "App Service plan SKU, e.g. B1, P0v3, P1v3."
  type        = string
}

variable "worker_count" {
  description = "Number of instances."
  type        = number
  default     = 1
}

variable "always_on" {
  type    = bool
  default = true
}

variable "python_version" {
  type    = string
  default = "3.12"
}

variable "zip_deploy_file" {
  description = "Local path to the app zip. Null deploys no code."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "Extra app settings merged over the defaults."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
