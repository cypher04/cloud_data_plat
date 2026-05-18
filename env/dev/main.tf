resource "azurerm_resource_group" "clouddata-rg" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_client_config" "current" {

}

module "data-factory" {
    source              = "../../modules/data-factory"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
}

module "data-lake" {
    source              = "../../modules/data-lake"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    subnet_prefixes = var.subnet_prefixes
    virtual_network_name = var.virtual_network_name

}

module "monitoring" {
    source              = "../../modules/monitoring"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
}

module "networking" {
    source              = "../../modules/networking"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    address_space       = var.address_space
    subnet_prefixes     = var.subnet_prefixes
    virtual_network_name = var.virtual_network_name
}

module "synapse" {
    source              = "../../modules/synapse"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    subnet_prefixes     = var.subnet_prefixes
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    storage_account_id = module.data-lake.storage_account_id
    storage_datalake_gen2_id = module.data-lake.storage_datalake_gen2_id


}