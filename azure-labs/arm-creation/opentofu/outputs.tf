output "resource_group_name" {
  description = "Resource group created for the lab."
  value       = azurerm_resource_group.vm_lab.name
}

output "vm_resource_id" {
  description = "Resource ID of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.vm_lab.id
}

output "public_ip_address" {
  description = "Assigned public IPv4 address."
  value       = azurerm_public_ip.vm_lab.ip_address
}

output "ssh_command" {
  description = "SSH command for connecting to the VM."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm_lab.ip_address}"
}
