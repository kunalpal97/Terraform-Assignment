variable "resource_group_name" {

    description = "Name of the resource group"
    type = string
  
}

variable "location" {

    description = "Azure region"
    type = string
  
}

variable "public_subnet_id" {

    description = "ID of the public subnet"
    type = string
  
}

variable "private_subnet_id" {

    description = "ID of the private subnet"
    type = string
  
}


variable "admin_username" {

    description = "Administrator username for the vms"
    type = string
  
}

variable "vm_size" {

    description = "Azure VM size"
    type = string
  
}


variable "public_vm_name" {

    description = "Name of the public VM"
    type = string
  
}

variable "private_vm_name" {

    description = "Name of the private VM"
    type = string
  
}

variable "os_publisher" {

    description = "os image publisher"
    type = string
  
}

variable "os_offer" {

    description = "os image offer"
    type = string
  
}

variable "os_sku" {

    description = "OS image sku"
    type = string
  
}

variable "os_version" {

    description = "os image version"
    type = string
  
}

variable "ssh_public_key" {

    description = "SSH public key used to access the VMs"
    type = string  
}