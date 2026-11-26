output "resource_group_name" {
  description = "Resource group created for the web app lab."
  value       = azurerm_resource_group.web_app_lab.name
}

output "hosting_plan_resource_id" {
  description = "Resource ID of the App Service plan."
  value       = azurerm_service_plan.web_app_lab.id
}

output "web_app_resource_id" {
  description = "Resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.web_app_lab.id
}

output "default_hostname" {
  description = "Default hostname assigned to the Linux Web App."
  value       = azurerm_linux_web_app.web_app_lab.default_hostname
}

output "web_app_url" {
  description = "Default HTTPS URL of the Linux Web App."
  value       = "https://${azurerm_linux_web_app.web_app_lab.default_hostname}"
}
