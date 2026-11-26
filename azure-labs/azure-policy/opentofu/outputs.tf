output "resource_group_id" {
  description = "Resource ID of the lab resource group."
  value       = azurerm_resource_group.policy_lab.id
}

output "initiative_id" {
  description = "Resource ID of the Get Secure initiative."
  value       = azurerm_policy_set_definition.get_secure.id
}

output "assignment_id" {
  description = "Resource ID of the resource-group policy assignment."
  value       = azurerm_resource_group_policy_assignment.get_secure.id
}
