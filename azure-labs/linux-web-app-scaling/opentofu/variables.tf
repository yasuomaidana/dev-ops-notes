variable "resource_group_name" {
  description = "Name of the Azure resource group for the scaling lab."
  type        = string
  default     = "example-webapp-scaling-rg"
}

variable "web_app_name_prefix" {
  description = "Prefix for the Azure Linux Web App name; an eight-character random suffix is appended."
  type        = string
  default     = "example-linux-webapp-scaling"

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
  default     = "example-linux-scaling-plan"
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
  description = "App Service plan SKU code; change this to scale vertically, for example B1 to P1v3."
  type        = string
  default     = "B1"
}

variable "number_of_workers" {
  description = "Number of workers in the App Service plan; increase this to scale horizontally."
  type        = number
  default     = 1

  validation {
    condition     = var.number_of_workers >= 1 && floor(var.number_of_workers) == var.number_of_workers
    error_message = "number_of_workers must be a positive whole number."
  }
}

variable "node_version" {
  description = "Node.js runtime version, for example 20-lts or 22-lts."
  type        = string
  default     = "20-lts"
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
  default = {
    environment = "lab"
    managed_by  = "opentofu"
  }
}
