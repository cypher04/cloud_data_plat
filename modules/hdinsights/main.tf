// create storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = "hdinsightstorageacct${random_string.storage_account_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "storage_account_suffix" {
  length  = 8
  upper   = false
  special = false
}


// create storage container
resource "azurerm_storage_container" "storage_container" {
  name                  = "hdinsightcontainer"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

data "azurerm_client_config" "current" {
  
}
locals {
  kafka-secret-names = {
    gateway-user    = var.kafka_gateway_name
    gateway-pass    = var.kafka_gateway_password
    head-user       = var.kafka_head_node_name
    head-pass       = var.kafka_head_node_password
    worker-user     = var.kafka_worker_node_name
    worker-pass     = var.kafka_worker_node_password
    zookeeper-user  = var.kafka_zookeeper_node_name
    zookeeper-pass  = var.kafka_zookeeper_node_password
  }
}

data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  depends_on = [var.keyvault_name]
}

data "azurerm_key_vault_secret" "kafka" {
  for_each     = local.kafka-secret-names
  name         = each.value
  key_vault_id = data.azurerm_key_vault.keyvault.id
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
    password = data.azurerm_key_vault_secret.kafka["gateway-pass"].value
  }

  storage_account {
    storage_container_id = azurerm_storage_container.storage_container.id
    storage_account_key  = azurerm_storage_account.storage_account.primary_access_key
    is_default            = true
  }

  roles {
    head_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["head-user"].value
      password  = data.azurerm_key_vault_secret.kafka["head-pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
      script_actions {
        name = "Install Kafka Manager"
        uri  = "https://hdinsightscriptactions.blob.core.windows.net/scriptactions/kafka-manager-installation.sh"
      }
    }
    worker_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["worker-user"].value
      password  = data.azurerm_key_vault_secret.kafka["worker-pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
      target_instance_count = 3
      number_of_disks_per_node = 4
    }
    zookeeper_node {
      vm_size   = "Standard_D3_V2"
      username  = data.azurerm_key_vault_secret.kafka["zookeeper-user"].value
      password  = data.azurerm_key_vault_secret.kafka["zookeeper-pass"].value
      subnet_id = var.subnet_ids[5]
      virtual_network_id = var.vnet_id
    }
  }


}

// RBAC for the cluster to access key vault secrets
resource "azurerm_role_assignment" "hdinsight_kv_access" {
  scope                = data.azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"

  // which identity to assign the role to, in this case it's the cluster's managed identity
// since i passed the secret values to the cluster configuration (using data sources), technically the cluster doesn't need access to the key vault, but i assign the role to the SP anyway for better security practice, in case the cluster needs to access the secrets in the future without using data sources

  principal_id         = data.azurerm_client_config.current.object_id
}