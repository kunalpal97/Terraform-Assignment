

# bool  ,list , map , string , number , set , tuple and object are the data type in tf

variable "vnet_name" {

    description = "Name of the Azure Virtual Network"
    type = string
  
}

variable "location" {

    description = "Azure region"
    type = string
  
}

variable "resource_group_name" {

    description = "Name of the resource group"
    type = string
  
}


variable "vnet_address_space" {
    
    description = "CIDR address space of the vnet"
    type = string
  
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
  description = "CIDR allowed to SSH to the public VM"
  type        = string
}