

resource "azurerm_virtual_network" "main" {

    name = var.vnet_name
    location = var.location
    resource_group_name = var.resource_group_name
    address_space = [var.vnet_address_space]
  
}



resource "azurerm_subnet" "public" {

    name = var.public_subnet_name
    resource_group_name =  var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = [var.public_subnet_address_prefix]
  
}

resource "azurerm_subnet" "private" {

    name = var.private_subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = [var.private_subnet_address_prefix]
  
}


resource "azurerm_network_security_group" "public" {

    name = var.public_nsg_name
    location = var.location
    resource_group_name = var.resource_group_name
  
}


resource "azurerm_network_security_rule" "public_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.admin_source_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public.name
}


resource "azurerm_network_security_rule" "public_http" {
  name                        = "allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public.name
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_network_security_group" "private" {

    name = var.private_nsg_name
    location = var.location
    resource_group_name =  var.resource_group_name
  
}


resource "azurerm_network_security_rule" "private_ssh" {
  name                        = "allow-ssh-from-public-subnet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.public_subnet_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}


resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}