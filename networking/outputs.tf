

output "public_subnet_id" {

    description = "ID of the public subnet"
    value = azurerm_subnet.public.id
  
}

output "private_subnet_id" {

    description = "ID of the private subnet"
    value = azurerm_subnet.private.id
  
}