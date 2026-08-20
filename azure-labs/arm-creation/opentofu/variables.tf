variable "resource_group_name" {
  description = "Name of the Azure resource group for the lab."
  type        = string
  default     = "example"
}

variable "location" {
  description = "Azure region for every resource."
  type        = string
  default     = "Mexico Central"
}

variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
  default     = "vm1"
}

variable "availability_zone" {
  description = "Availability zone for the VM and public IP."
  type        = string
  default     = "1"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1ls"
}

variable "admin_username" {
  description = "Administrator account username."
  type        = string
  default     = "azureuser"
}

variable "admin_public_key" {
  description = "Contents of an RSA SSH public key; never a private key."
  type        = string
  sensitive   = true
}

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-mexicocentral-1"
}

variable "subnet_name" {
  description = "Name of the subnet."
  type        = string
  default     = "snet-mexicocentral-1"
}

variable "public_ip_name" {
  description = "Name of the public IP."
  type        = string
  default     = "vm1-ip"
}

variable "network_interface_name" {
  description = "Name of the NIC."
  type        = string
  default     = "vm1-nic"
}

variable "network_security_group_name" {
  description = "Name of the NSG."
  type        = string
  default     = "vm1-nsg"
}

variable "os_disk_size_gb" {
  description = "Provisioned Premium SSD OS disk size in GiB."
  type        = number
  default     = 32
}

variable "tags" {
  description = "Optional tags to apply to all resources."
  type        = map(string)
  default = {
    environment = "lab"
    managed_by  = "opentofu"
  }
}
