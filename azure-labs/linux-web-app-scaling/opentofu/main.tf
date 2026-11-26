resource "random_string" "web_app_suffix" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}

locals {
  web_app_name = "${lower(var.web_app_name_prefix)}-${random_string.web_app_suffix.result}"
}

resource "azurerm_resource_group" "web_app_scaling" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "web_app_scaling" {
  name                = var.hosting_plan_name
  resource_group_name = azurerm_resource_group.web_app_scaling.name
  location            = azurerm_resource_group.web_app_scaling.location
  os_type             = "Linux"
  sku_name            = var.sku_code
  worker_count        = var.number_of_workers
  tags                = var.tags
}

resource "azurerm_linux_web_app" "web_app_scaling" {
  name                                           = local.web_app_name
  resource_group_name                            = azurerm_resource_group.web_app_scaling.name
  location                                       = azurerm_resource_group.web_app_scaling.location
  service_plan_id                                = azurerm_service_plan.web_app_scaling.id
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  tags                                           = var.tags

  site_config {
    always_on  = var.always_on
    ftps_state = var.ftps_state

    application_stack {
      node_version = var.node_version
    }
  }
}

resource "azurerm_resource_group_template_deployment" "web_app_basic_publishing_policies" {
  name                = "${var.hosting_plan_name}-publishing-policies"
  resource_group_name = azurerm_resource_group.web_app_scaling.name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources = [
      {
        type       = "Microsoft.Web/sites/basicPublishingCredentialsPolicies"
        apiVersion = "2022-09-01"
        name       = "${azurerm_linux_web_app.web_app_scaling.name}/scm"
        properties = {
          allow = false
        }
      },
      {
        type       = "Microsoft.Web/sites/basicPublishingCredentialsPolicies"
        apiVersion = "2022-09-01"
        name       = "${azurerm_linux_web_app.web_app_scaling.name}/ftp"
        properties = {
          allow = false
        }
      }
    ]
  })

  depends_on = [azurerm_linux_web_app.web_app_scaling]
}
