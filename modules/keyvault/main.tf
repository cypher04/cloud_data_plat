// create keyvault
resource "azurerm_key_vault" "keyvault" {
    name                        = "cloudkeyvault-kv"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    purge_protection_enabled    = false
    enabled_for_deployment      = true
    enabled_for_disk_encryption = true
    enabled_for_template_deployment = true
    rbac_authorization_enabled   = true
    } 

# resource "azurerm_key_vault_access_policy" "keyvault_access_policy" {
#     key_vault_id = azurerm_key_vault.keyvault.id
#     tenant_id    = data.azurerm_client_config.current.tenant_id
#     object_id    = data.azurerm_client_config.current.object_id

#     secret_permissions = [
#         "Get",
#         "List",
#         "Set",
#         "Delete",
#         "Backup",
#         "Restore",
#         "Recover",
#         "Purge"
#     ]
# }


// create secrets with data from terraform variables for kafka gateway and nodes

# data "azurerm_key_vault_secret" "kafka_gateway_name_secret" {
#     name         = "kafka-gateway-name-secret"
#     key_vault_id = azurerm_key_vault.keyvault.id
# }

data "azurerm_client_config" "current" {

}




// creat key vault secret for kafka gateway secret
# resource "azurerm_key_vault_secret" "kafka_gateway_secret" {
#     name         = "kafka-gateway-name-secret"
#     value        = var.kafka_gateway_name
#     key_vault_id = azurerm_key_vault.keyvault.id
#     depends_on = [time_sleep.wait_30_seconds]
# }

resource "azurerm_key_vault_secret" "kafka_gateway_password_secret" {
    name         = "kafka-gateway-password-secret"
    value        = var.kafka_gateway_password
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

// create key vault secret for kafka head node secret
resource "azurerm_key_vault_secret" "kafka_head_node_secret" {
    name         = "kafka-head-node-name-secret"
    value        = var.kafka_head_node_name
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "kafka_head_node_password_secret" {
    name         = "kafka-head-node-password-secret"
    value        = var.kafka_head_node_password
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

// create key vault secret for kafka worker node secret
resource "azurerm_key_vault_secret" "kafka_worker_node_secret" {
    name         = "kafka-worker-node-name-secret"
    value        = var.kafka_worker_node_name
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "kafka_worker_node_password_secret" {
    name         = "kafka-worker-node-password-secret"
    value        = var.kafka_worker_node_password
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

// create key vault secret for kafka zookeeper node secret
resource "azurerm_key_vault_secret" "kafka_zookeeper_node_secret" {
    name         = "kafka-zookeeper-node-name-secret"
    value        = var.kafka_zookeeper_node_name
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "kafka_zookeeper_node_password_secret" {
    name         = "kafka-zookeeper-node-password-secret"
    value        = var.kafka_zookeeper_node_password
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}


// create key vault secrets for github repo connector for synapse
resource "azurerm_key_vault_secret" "github_repo_url_secret" {
    name         = "github-repo-url-secret"
    value        = var.github_repo_url
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "github_repo_branch_secret" {
    name         = "github-repo-branch-secret"
    value        = var.github_repo_branch
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "github_account_name_secret" {
    name         = "github-account-name-secret"
    value        = var.github_account_name
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}

resource "azurerm_key_vault_secret" "github_repo_name_secret" {
    name         = "github-repo-name-secret"
    value        = var.github_repo_name
    key_vault_id = azurerm_key_vault.keyvault.id
    depends_on = [time_sleep.wait_30_seconds]
}



// RBAC for the cluster to access key vault secrets
resource "azurerm_role_assignment" "hdinsight_kv_access" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Administrator"

  // which identity to assign the role to, in this case it's the cluster's managed identity
// since i passed the secret values to the cluster configuration (using data sources), technically the cluster doesn't need access to the key vault, but i assign the role to the SP anyway for better security practice, in case the cluster needs to access the secrets in the future without using data sources

  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_role_assignment.hdinsight_kv_access]
  create_duration = "30s"
}
