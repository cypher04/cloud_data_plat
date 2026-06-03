// create storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = "hdinsightstorageacct"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


// create storage container
resource "azurerm_storage_container" "storage_container" {
  name                  = "hdinsightcontainer"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}


locals {
  kafka_secret_names = {
    gateway_user    = var.kafka_gateway_name
    gateway_pass    = var.kafka_gateway_password
    head_user       = var.kafka_head_node_username
    head_pass       = var.kafka_head_node_password
    worker_user     = var.kafka_worker_node_username
    worker_pass     = var.kafka_worker_node_password
    zookeeper_user  = var.kafka_zookeeper_node_username
    zookeeper_pass  = var.kafka_zookeeper_node_password
  }
}

data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  depends_on = [var.keyvault_name]
}

data "azurerm_key_vault_secret" "kafka" {
  for_each     = local.kafka_secret_names
  name         = each.value
  key_vault_id = data.azurerm_key_vault.kv.id
}



// create kafka cluster
resource "azurerm_hdinsight_kafka_cluster" "kafka_cluster" {
  name                = "kafka-cluster"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_version     = "5.0"
  tier                = "Standard"
  encryption_in_transit_enabled = true
  network {
    connection_direction = "Inbound"
  }
  

  component_version {
    kafka = "2.1"
  }

  // Note: kafka doesn't resolve the URI from secret vault, so i use data source to get the secret value and pass it to the cluster configuration





  gateway {
    username = "admin"
    password = data.azurerm_key_vault_secret.kafka["gateway_pass"].value
  }

  storage_account {
    storage_container_id = azurerm_storage_container.storage_container.id
    storage_account_key  = azurerm_storage_account.storage_account.primary_access_key
    is_default            = true
  }

  roles {
    head_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["head_user"].value
      password  = data.azurerm_key_vault_secret.kafka["head_pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
      script_actions {
        name = "Install Kafka Manager"
        uri  = "https://hdinsightscriptactions.blob.core.windows.net/scriptactions/kafka-manager-installation.sh"
      }
    }
    worker_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["worker_user"].value
      password  = data.azurerm_key_vault_secret.kafka["worker_pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
      target_instance_count = 3
      number_of_disks_per_node = 4
    }
    zookeeper_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["zookeeper_user"].value
      password  = data.azurerm_key_vault_secret.kafka["zookeeper_pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
    }
  }


}