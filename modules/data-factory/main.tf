resource "azurerm_data_factory" "cloud-data-factory" {
  name                = "cloud-data-factory"
  location            = var.location
  resource_group_name = var.resource_group_name
  managed_virtual_network_enabled = true
  
}