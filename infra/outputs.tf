output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "web_app_name" {
  value = module.webapp.web_app_name
}

output "url" {
  value = "https://${module.webapp.default_hostname}"
}

output "app_package" {
  value = basename(data.archive_file.app.output_path)
}
