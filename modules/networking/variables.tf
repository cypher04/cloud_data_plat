variable "resource_group_name" {
    description = "The name of the resource group in which to create the virtual network."
    type        = string
}

variable "virtual_network_name" {
    description = "The name of the virtual network."
    type        = string
}

variable "address_space" {
    description = "The address space of the virtual network."
    type        = list(string)
}

variable "location" {
    description = "The Azure region where the virtual network will be created."
    type        = string
}

variable "subnet_prefixes" {
    description = "A map of subnet names to their respective address prefixes."
    type        = map(string)
}


