variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = string
}

variable "subnet_prefixes" {
  description = "A map of subnet names to their respective prefixes"
  type        = map(string)
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}
