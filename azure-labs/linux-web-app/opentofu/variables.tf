variable "resource_group_name" {
  description = "Name of the Azure resource group for the web app lab."
  type        = string
  default     = "example-webapp-rg"
}

variable "deployment_name" {
  description = "Name of the ARM deployment created by OpenTofu."
  type        = string
  default     = "linux-web-app"
}

variable "web_app_name_prefix" {
  description = "Prefix for the Azure Linux Web App name; an eight-character random suffix is appended."
  type        = string
  default     = "example-linux-webapp"

  validation {
    condition     = length(var.web_app_name_prefix) >= 2 && length(var.web_app_name_prefix) <= 46 && can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$", var.web_app_name_prefix))
    error_message = "web_app_name_prefix must be 2-46 characters, contain only letters, numbers, or hyphens, and cannot start or end with a hyphen."
  }
}

variable "location" {
  description = "Azure region for the App Service resources."
  type        = string
  default     = "mexicocentral"
}

variable "hosting_plan_name" {
  description = "Name of the App Service plan."
  type        = string
  default     = "example-linux-plan"
}

variable "always_on" {
  description = "Whether Always On is enabled for the web app."
  type        = bool
  default     = false
}

variable "ftps_state" {
  description = "FTP/FTPS access mode for the web app."
  type        = string
  default     = "Disabled"
}

variable "sku_code" {
  description = "App Service plan SKU code."
  type        = string
  default     = "B1"
}

variable "number_of_workers" {
  description = "Number of workers in the App Service plan."
  type        = number
  default     = 1
}

variable "node_version" {
  description = "Runtime stack for the Linux Web App, for example NODE|20-lts or DOCKER|<image>."
  type        = string
  default     = "20-lts"
}

variable "tags" {
  description = "Optional tags to apply to the resource group."
  type        = map(string)
  default = {
    environment = "lab"
    managed_by  = "opentofu"
  }
}
