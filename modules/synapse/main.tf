resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                = "cloudsynapseworkspace"
  resource_group_name = var.resource_group_name
  location            = var.location
  sql_administrator_login          = var.admin_username
  sql_administrator_login_password = var.admin_password
  storage_data_lake_gen2_filesystem_id = var.storage_datalake_gen2_id
  managed_virtual_network_enabled = true
  data_exfiltration_protection_enabled = true
  
  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                = "cloudsynapsesqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  create_mode = "Default"
  storage_account_type = "GRS"
  sku_name            = "DW100c"
}

resource "azurerm_storage_account" "synapse_storage_account" {
  name                     = "cloudsynapsestorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_managed_private_endpoint" {
  name                = "synapse-managed-private-endpoint"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = azurerm_storage_account.synapse_storage_account.id
  subresource_name               = "blob"
  
  depends_on = [var.synapse_firewall_name]
}



