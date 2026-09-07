

output "public_ip_address" {
  description = "Public IP address of the public VM"
  value       = azurerm_public_ip.public.ip_address
}

output "public_vm_private_ip" {
  description = "Private IP address of the public VM"
  value       = azurerm_network_interface.public.private_ip_address
}

output "private_vm_private_ip" {
  description = "Private IP address of the private VM"
  value       = azurerm_network_interface.private.private_ip_address
}