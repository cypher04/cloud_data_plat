output "vnet_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.cloud-network.id
}

output "subnet_ids" {
  description = "The IDs of the subnets."
  value       = [
    azurerm_subnet.cloud-subnet-web.id,
    azurerm_subnet.cloud-subnet-db.id,
    azurerm_subnet.cloud-subnet-1.id,
    azurerm_subnet.cloud-subnet-2.id,
    azurerm_subnet.cloud-subnet-synapse.id
  ]
}

