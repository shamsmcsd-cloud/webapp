output "web_app_name" {
  value = azurerm_linux_web_app.this.name
}

output "web_app_id" {
  value = azurerm_linux_web_app.this.id
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  description = "System-assigned identity, for role assignments the app needs later."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "application_insights_name" {
  value = azurerm_application_insights.this.name
}
