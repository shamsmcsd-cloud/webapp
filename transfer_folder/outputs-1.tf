output "resource_group_id" {
  value       = azurerm_resource_group.project1.id
  description = "ID of the resource group"
}

output "web_app_id" {
  value       = azurerm_linux_web_app.project1.id
  description = "ID of the web app"
}

output "web_app_url" {
  value       = "https://${azurerm_linux_web_app.project1.default_hostname}"
  description = "Default hostname URL of the web app"
}

output "service_plan_id" {
  value       = azurerm_service_plan.project1.id
  description = "ID of the App Service Plan"
}
