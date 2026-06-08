resource "azurerm_storage_account" "cloudstorage" {
  name                     = "cloudstoragedl${random_string.storage_account_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled = "true"
  
}

// create random string for unique storage account name
resource "random_string" "storage_account_suffix" {
  length  = 4
  upper   = false
  special = false
}



resource "azurerm_storage_data_lake_gen2_filesystem" "cloudfilesystem" {
  name               = "cloudfilesystem"
  storage_account_id = azurerm_storage_account.cloudstorage.id
  depends_on = [ azurerm_storage_account.cloudstorage ]


  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_storage_data_lake_gen2_path" "cloudpath" {
  path               = "cloudpath"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.cloudfilesystem.name
  storage_account_id = azurerm_storage_account.cloudstorage.id
  resource           = "directory"

  depends_on = [ azurerm_storage_account.cloudstorage ]
}

resource "azurerm_storage_container" "cloudcontainer" {
  name                  = "raw"
  storage_account_id  = azurerm_storage_account.cloudstorage.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "cloudcontainer2" {
  name                  = "processed"
  storage_account_id  = azurerm_storage_account.cloudstorage.id
  container_access_type = "private"
  
}

resource "azurerm_storage_container" "cloudcontainer3" {
  name                  = "curated"
  storage_account_id  = azurerm_storage_account.cloudstorage.id
  container_access_type = "private"
  

}

