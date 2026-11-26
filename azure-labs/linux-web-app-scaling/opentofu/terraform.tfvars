resource_group_name = "rg-testing-web-apps"
web_app_name_prefix = "example-linux-webapp"
location            = "mexicocentral"
hosting_plan_name   = "example-linux-plan"
always_on           = false
ftps_state          = "Disabled"

# Vertical scaling: choose a larger App Service SKU, such as P1v3.
sku_code = "B1"

# Horizontal scaling: increase the number of workers.
number_of_workers = 2
node_version      = "22-lts"

tags = {
  environment = "lab"
  managed_by  = "opentofu"
}
