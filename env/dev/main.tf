import{
  to = azurerm_resource_group.clouddata-rg
  id = "/subscriptions/fe797b99-c79d-4fe3-baa0-091bacc96c3a/resourceGroups/clouddata"
}

resource "azurerm_resource_group" "clouddata-rg" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_client_config" "current" {

}



resource "azurerm_user_assigned_identity" "uai" {
  name                = "uai-${var.resource_group_name}"
  resource_group_name = azurerm_resource_group.clouddata-rg.name
  location            = var.location
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
    # storage_account_id = module.data-lake.storage_account_id
    storage_datalake_gen2_id = module.data-lake.storage_datalake_gen2_id
    # synapse_firewall_name = module.security.synapse_firewall_name
    datalake_storage_account_id = module.data-lake.datalake_storage_account_id
    keyvault_name = module.keyvault.keyvault_name
    github_repo_url = module.keyvault.github_repo_url_secret_name
    github_repo_branch = module.keyvault.github_repo_branch_secret_name
    github_account_name = module.keyvault.github_account_name_secret_name
    github_repo_name = module.keyvault.github_repo_name_secret_name
    # keyvault_id = module.keyvault.keyvault_id
    depends_on = [ module.keyvault ]

}

# module "security" {
#     source              = "../../modules/security"
#     resource_group_name = azurerm_resource_group.clouddata-rg.name
#     location            = var.location
#     synapse_workspace_id = module.synapse.synapse_workspace_id
# }

module "private_endpoint" {
    source              = "../../modules/private_endpoint"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    synapse_workspace_id = module.synapse.synapse_workspace_id
    storage_datalake_gen2_id = module.data-lake.storage_datalake_gen2_id
    vnet_id = module.networking.vnet_id
    subnet_ids = module.networking.subnet_ids
    synapse_sql_pool_id = module.synapse.synapse_sql_pool_id
    synapse_storage_account_id = module.synapse.synapse_storage_account_id
    datalake_storage_account_id = module.data-lake.datalake_storage_account_id
    eventhub_id = module.eventhub.eventhub_id
}

module "eventhub" {
    source              = "../../modules/eventhub"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    vnet_id = module.networking.vnet_id
    subnet_ids = module.networking.subnet_ids
    keyvault_name = module.keyvault.keyvault_name
    keyvault_id = module.keyvault.keyvault_id
    kafka_gateway_name = var.kafka_gateway_name
    kafka_head_node_name_secret_name = module.keyvault.kafka_head_node_secret_name
    kafka_worker_node_secret_name = module.keyvault.kafka_worker_node_secret_name
    kafka_zookeeper_node_secret_name = module.keyvault.kafka_zookeeper_node_secret_name
    kafka_zookeeper_node_password_secret_name = module.keyvault.kafka_zookeeper_node_password_secret_name
    kafka_gateway_password_secret_name = module.keyvault.kafka_gateway_password_secret_name
    kafka_head_node_password_secret_name = module.keyvault.kafka_head_node_password_secret_name
    kafka_worker_node_password_secret_name = module.keyvault.kafka_worker_node_password_secret_name
    datalake_storage_account_id = module.data-lake.datalake_storage_account_id
    depends_on = [ module.keyvault ]

    
}

module "keyvault" {
    source              = "../../modules/keyvault"
    resource_group_name = azurerm_resource_group.clouddata-rg.name
    location            = var.location
    kafka_gateway_name = var.kafka_gateway_name
    kafka_gateway_password = var.kafka_gateway_password
    kafka_head_node_name = var.kafka_head_node_name
    kafka_head_node_password = var.kafka_head_node_password
    kafka_worker_node_name = var.kafka_worker_node_name
    kafka_worker_node_password = var.kafka_worker_node_password
    kafka_zookeeper_node_name = var.kafka_zookeeper_node_name
    kafka_zookeeper_node_password = var.kafka_zookeeper_node_password
    github_repo_url = var.github_repo_url
    github_repo_branch = var.github_repo_branch
    github_account_name = var.github_account_name
    github_repo_name = var.github_repo_name
    keyvault_id = module.keyvault.keyvault_id
}

