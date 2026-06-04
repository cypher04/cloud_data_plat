output "datalake_storage_account_id" {
    value = azurerm_storage_account.cloudstorage.id
}

output "storage_datalake_gen2_id" {
    value = azurerm_storage_data_lake_gen2_filesystem.cloudfilesystem.id
}