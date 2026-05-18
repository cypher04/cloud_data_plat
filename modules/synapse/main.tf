resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                = "cloudsynapseworkspace"
  resource_group_name = var.resource_group_name
  location            = var.location
  sql_administrator_login          = var.admin_username
  sql_administrator_login_password = var.admin_password
  storage_data_lake_gen2_filesystem_id = var.storage_datalake_gen2_id
#   compute_subnet_id = var.subnet_prefixes["synapse-compute"].id
  managed_virtual_network_enabled = true
  
  identity {
    type = "SystemAssigned"
  }

}