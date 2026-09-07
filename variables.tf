variable "resource_group_name" {

  description = "Name of the Azure resource Group"
  type        = string

}

variable "location" {

  description = "Azure region where resource will be created"
  type        = string
}


variable "vnet_name" {

  description = "Name of the Azure Virtual network"
  type        = string

}

variable "vnet_address_space" {

  description = "Address space of the Azure Virtual Network"
  type        = string

}

variable "public_subnet_name" {

  description = "Name of the public subnet"
  type        = string

}

variable "public_subnet_address_prefix" {

  description = "CIDR address prefix for the public subnet"
  type        = string

}

variable "private_subnet_name" {

  description = "Name of the private subnet"
  type        = string

}

variable "private_subnet_address_prefix" {

  description = "CIDR address prefix for the private subnet"
  type        = string

}


variable "public_nsg_name" {

  description = "Name of the public network security group"
  type        = string

}


variable "private_nsg_name" {

  description = "Name of the private network security group"
  type        = string

}


variable "admin_source_cidr" {

  description = "CIDR allowed to access the public VM over SSH"
  type        = string
}


variable "key_name" {

  description = "SSH key name"
  type        = string


}

# VM ke variables yaha pe define kr raha hu 


variable "admin_username" {
  description = "Administrator username for the VMs"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
}

variable "public_vm_name" {
  description = "Name of the public VM"
  type        = string
}

variable "private_vm_name" {
  description = "Name of the private VM"
  type        = string
}

variable "os_publisher" {
  description = "OS image publisher"
  type        = string
}

variable "os_offer" {
  description = "OS image offer"
  type        = string
}

variable "os_sku" {
  description = "OS image SKU"
  type        = string
}

variable "os_version" {
  description = "OS image version"
  type        = string
}