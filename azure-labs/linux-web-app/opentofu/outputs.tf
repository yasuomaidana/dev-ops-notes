locals {
  raw_deployment_outputs = tomap(
    jsondecode(azurerm_resource_group_template_deployment.web_app_lab.output_content)
  )

  deployment_outputs = {
    hosting_plan_resource_id = lookup(tomap(local.raw_deployment_outputs["hostingPlanResourceId"]), "value", null)
    web_app_resource_id      = lookup(tomap(local.raw_deployment_outputs["webAppResourceId"]), "value", null)
    default_hostname         = lookup(tomap(local.raw_deployment_outputs["defaultHostname"]), "value", null)
    web_app_url              = lookup(tomap(local.raw_deployment_outputs["webAppUrl"]), "value", null)
  }
}

output "resource_group_name" {
  description = "Resource group created for the web app lab."
  value       = azurerm_resource_group.web_app_lab.name
}

output "hosting_plan_resource_id" {
  description = "Resource ID of the App Service plan."
  value       = local.deployment_outputs.hosting_plan_resource_id
}

output "web_app_resource_id" {
  description = "Resource ID of the Linux Web App."
  value       = local.deployment_outputs.web_app_resource_id
}

output "default_hostname" {
  description = "Default hostname assigned to the Linux Web App."
  value       = local.deployment_outputs.default_hostname
}

output "web_app_url" {
  description = "Default HTTPS URL of the Linux Web App."
  value       = local.deployment_outputs.web_app_url
}
