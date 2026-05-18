resource "azurerm_storage_account" "cloudstorage" {
  name                     = "cloudstorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled = "true"
  
}

resource "azurerm_storage_data_lake_gen2_filesystem" "cloudfilesystem" {
  name               = "cloudfilesystem"
  storage_account_id = azurerm_storage_account.cloudstorage.id

  properties = {
    hello = "aGVsbG8="
  }
  
}

