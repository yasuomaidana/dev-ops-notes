resource "azurerm_resource_group" "policy_lab" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_policy_set_definition" "get_secure" {
  name         = var.initiative_name
  policy_type  = "Custom"
  display_name = var.initiative_display_name
  description  = var.initiative_description
  metadata     = jsonencode({ category = var.initiative_category })

  policy_definition_reference {
    policy_definition_id = var.built_in_policy_definition_id
    reference_id         = "windowsVmDiskEncryption"
  }
}

resource "azurerm_resource_group_policy_assignment" "get_secure" {
  name                 = var.assignment_name
  resource_group_id    = azurerm_resource_group.policy_lab.id
  policy_definition_id = azurerm_policy_set_definition.get_secure.id
  display_name         = var.assignment_display_name
  description          = var.assignment_description
  enforce              = true

  non_compliance_message {
    content = var.non_compliance_message
  }
}
