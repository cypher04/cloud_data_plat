output "keyvault_name" {
    value = azurerm_key_vault.keyvault.name
}

# output "kafka_gateway_name" {
#     value = data.azurerm_key_vault_secret.kafka_gateway_name_secret.value
# }

output "keyvault_id" {
    value = azurerm_key_vault.keyvault.id
}

output "kafka_gateway_password_secret_name" {
    value = azurerm_key_vault_secret.kafka_gateway_password_secret.name
}

// output the key vault secrets for kafka head node
output "kafka_head_node_secret_name" {
    value = azurerm_key_vault_secret.kafka_head_node_secret.name
}

output "kafka_head_node_password_secret_name" {
    value = azurerm_key_vault_secret.kafka_head_node_password_secret.name
}

// output the key vault secrets for kafka worker node

output "kafka_worker_node_secret_name" {
    value = azurerm_key_vault_secret.kafka_worker_node_secret.name
}

output "kafka_worker_node_password_secret_name" {
    value = azurerm_key_vault_secret.kafka_worker_node_password_secret.name
}

// output the key vault secrets for kafka zookeeper node
output "kafka_zookeeper_node_secret_name" {
    value = azurerm_key_vault_secret.kafka_zookeeper_node_secret.name
}

output "kafka_zookeeper_node_password_secret_name" {
    value = azurerm_key_vault_secret.kafka_zookeeper_node_password_secret.name
}

// output the key vault secrets for github repo connector for synapse
output "github_repo_url_secret_name" {
    value = azurerm_key_vault_secret.github_repo_url_secret.name
}
output "github_repo_branch_secret_name" {
    value = azurerm_key_vault_secret.github_repo_branch_secret.name
}

output "github_account_name_secret_name" {
    value = azurerm_key_vault_secret.github_account_name_secret.name
}

output "github_repo_name_secret_name" {
    value = azurerm_key_vault_secret.github_repo_name_secret.name
}

