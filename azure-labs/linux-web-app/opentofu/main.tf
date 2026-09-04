resource "azurerm_resource_group" "web_app_lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "web_app_lab" {
  name                = var.hosting_plan_name
  resource_group_name = azurerm_resource_group.web_app_lab.name
  location            = azurerm_resource_group.web_app_lab.location
  os_type             = "Linux"
  sku_name            = var.sku_code
  worker_count        = var.number_of_workers
  tags                = var.tags
}

resource "azurerm_linux_web_app" "web_app_lab" {
  name                = var.name
  resource_group_name = azurerm_resource_group.web_app_lab.name
  location            = azurerm_resource_group.web_app_lab.location
  service_plan_id     = azurerm_service_plan.web_app_lab.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on  = var.always_on
    ftps_state = var.ftps_state
    application_stack {
      node_version = var.node_version
    }
  }
}
