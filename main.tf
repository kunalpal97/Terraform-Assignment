
resource "azurerm_resource_group" "terraform_task" {

  name     = var.resource_group_name
  location = var.location

}


module "networking" {

  source = "./networking"

  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  public_subnet_name           = var.public_subnet_name
  public_subnet_address_prefix = var.public_subnet_address_prefix

  private_subnet_name           = var.private_subnet_name
  private_subnet_address_prefix = var.private_subnet_address_prefix

  public_nsg_name  = var.public_nsg_name
  private_nsg_name = var.private_nsg_name

  admin_source_cidr = var.admin_source_cidr


}


module "ssh_key" {

  source = "./ssh-key"

  key_name = var.key_name

}

module "vm" {

  source = "./vm"

  resource_group_name = var.resource_group_name
  location            = var.location

  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id

  admin_username = var.admin_username
  vm_size        = var.vm_size

  public_vm_name  = var.public_vm_name
  private_vm_name = var.private_vm_name

  os_publisher = var.os_publisher
  os_offer     = var.os_offer
  os_sku       = var.os_sku
  os_version   = var.os_version

  ssh_public_key = module.ssh_key.public_key_openssh
}