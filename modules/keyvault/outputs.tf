output "keyvault_name" {
    value = azurerm_key_vault.keyvault.name
}

output "kafka_gateway_name" {
    value = data.azurerm_key_vault_secret.kafka_gateway_name_secret.value
}

output "keyvault_id" {
    value = azurerm_key_vault.keyvault.id
}

output "kafka_gateway_password" {
    value = azurerm_key_vault_secret.kafka_gateway_password_secret.value
}

// output the key vault secrets for kafka head node
output "kafka_head_node_name" {
    value = azurerm_key_vault_secret.kafka_head_node_secret.value
}

output "kafka_head_node_password" {
    value = azurerm_key_vault_secret.kafka_head_node_password_secret.value
}

// output the key vault secrets for kafka worker node

output "kafka_worker_node_name" {
    value = azurerm_key_vault_secret.kafka_worker_node_secret.value
}

output "kafka_worker_node_password" {
    value = azurerm_key_vault_secret.kafka_worker_node_password_secret.value
}

// output the key vault secrets for kafka zookeeper node
output "kafka_zookeeper_node_name" {
    value = azurerm_key_vault_secret.kafka_zookeeper_node_secret.value
}

output "kafka_zookeeper_node_password" {
    value = azurerm_key_vault_secret.kafka_zookeeper_node_password_secret.value
}

// output the key vault secrets for github repo connector for synapse
output "github_repo_url" {
    value = azurerm_key_vault_secret.github_repo_url_secret.value
}
output "github_repo_branch" {
    value = azurerm_key_vault_secret.github_repo_branch_secret.value
}

output "github_account_name" {
    value = azurerm_key_vault_secret.github_account_name_secret.value
}

output "github_repo_name" {
    value = azurerm_key_vault_secret.github_repo_name_secret.value
}

