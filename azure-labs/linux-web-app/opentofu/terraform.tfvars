resource_group_name = "rg-testing-web-apps"
deployment_name     = "linux-web-app"

# Azure App Service names are globally unique. OpenTofu appends an eight-character
# random suffix, so the default hostname is:
# https://<web_app_name_prefix>-<random_suffix>.azurewebsites.net.
# The suffix is stored in OpenTofu state and remains stable on later applies.
# To generate a new suffix, replace the resource with `tofu taint
# random_string.web_app_suffix` and run plan/apply again.
#
# A custom domain does not remove this requirement. It is an additional
# hostname that must be configured with DNS and an App Service hostname binding
# after the web app is created. This lab does not currently create that binding.
web_app_name_prefix = "example-linux-webapp"
location            = "mexicocentral"
hosting_plan_name   = "example-linux-plan"
always_on           = false
ftps_state          = "Disabled"
sku_code            = "B1"
number_of_workers   = 1
node_version        = "20-lts"

tags = {
  environment = "lab"
  managed_by  = "opentofu"
}
