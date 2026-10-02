locals {
  app_dir = "${path.module}/../app"

  # Hash of the app source, so a code change produces a new zip name and redeploys.
  app_files = sort([
    for f in fileset(local.app_dir, "**") : f
    if !startswith(f, ".venv/") && !strcontains(f, "__pycache__")
  ])
  app_hash = substr(sha1(join(",", [for f in local.app_files : "${f}:${filesha1("${local.app_dir}/${f}")}"])), 0, 12)

  name = "${var.app_name}-${var.environment}-${random_string.suffix.result}"

  tags = merge(var.tags, {
    application = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

# Keeps the globally unique web app name stable per environment (stored in that env's state).
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

data "archive_file" "app" {
  type        = "zip"
  source_dir  = local.app_dir
  output_path = "${path.module}/.build/app-${local.app_hash}.zip"
  excludes    = [".venv", "__pycache__"]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

module "webapp" {
  source = "./modules/python_webapp"

  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  environment         = var.environment

  sku_name           = var.sku_name
  worker_count       = var.worker_count
  python_version     = var.python_version
  log_retention_days = var.log_retention_days
  zip_deploy_file    = data.archive_file.app.output_path

  tags = local.tags
}
