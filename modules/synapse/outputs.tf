output "synapse_workspace_id" {
    value = azurerm_synapse_workspace.synapse_workspace.id
}

output "synapse_sql_pool_id" {
    value = azurerm_synapse_sql_pool.sql_pool.id
}

output "synapse_storage_account_id" {
    value = azurerm_storage_account.synapse_storage_account.id
}

// output the synapse connectivity endpoints sql, web, dev, sql_on_demand
output "synapse_connectivity_endpoints" {
    value = azurerm_synapse_workspace.synapse_workspace.connectivity_endpoints
}

output "synapse_principal_id" {
    value = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}