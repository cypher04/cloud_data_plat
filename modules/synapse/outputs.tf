output "synapse_workspace_id" {
    value = azurerm_synapse_workspace.synapse_workspace.id
}

output "synapse_sql_pool_id" {
    value = azurerm_synapse_sql_pool.sql_pool.id
}

output "synapse_storage_account_id" {
    value = azurerm_storage_account.synapse_storage_account.id
}