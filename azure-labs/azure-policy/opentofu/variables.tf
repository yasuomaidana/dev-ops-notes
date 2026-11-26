variable "resource_group_name" {
  description = "Name of the resource group that receives the policy assignment."
  type        = string
  default     = "dca-tech-policy-rg"
}

variable "resource_group_location" {
  description = "Azure region for the lab resource group."
  type        = string
  default     = "eastus"
}

variable "initiative_name" {
  description = "Resource name of the custom Azure Policy initiative."
  type        = string
  default     = "get-secure"
}

variable "initiative_display_name" {
  description = "Display name of the custom Azure Policy initiative."
  type        = string
  default     = "Get Secure"
}

variable "initiative_description" {
  description = "Description of the custom Azure Policy initiative."
  type        = string
  default     = "Audits Windows virtual machines that do not use Azure Disk Encryption or EncryptionAtHost."
}

variable "initiative_category" {
  description = "Category displayed for the custom Azure Policy initiative."
  type        = string
  default     = "Compute"
}

variable "built_in_policy_definition_id" {
  description = "Resource ID of the built-in Windows VM disk encryption policy."
  type        = string
  default     = "/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0"
}

variable "assignment_name" {
  description = "Resource name of the resource-group policy assignment."
  type        = string
  default     = "get-secure-assignment"
}

variable "assignment_display_name" {
  description = "Display name of the resource-group policy assignment."
  type        = string
  default     = "Get Secure assignment"
}

variable "assignment_description" {
  description = "Description of the resource-group policy assignment."
  type        = string
  default     = "Assigns the Get Secure initiative to the lab resource group."
}

variable "non_compliance_message" {
  description = "Message shown when a resource is non-compliant with the initiative."
  type        = string
  default     = "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
}
