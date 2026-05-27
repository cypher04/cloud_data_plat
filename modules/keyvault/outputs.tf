output "keyvault_name" {
    value = azurerm_key_vault.keyvault.name
}

output "kafka_gateway_name_secret_name" {
    value = data.azurerm_key_vault_secret.kafka_gateway_name_secret.value
}



# // output the key vault secrets for kafka gateway
# output "kafka_gateway_name_secret_name" {
#     value = azurerm_key_vault_secret.kafka_gateway_secret.name
# }

# output "kafka_gateway_password_secret_name" {
#     value = azurerm_key_vault_secret.kafka_gateway_password_secret.name
# }

# // output the key vault secrets for kafka head node
# output "kafka_head_node_name_secret_name" {
#     value = azurerm_key_vault_secret.kafka_head_node_secret.name
# }

# output "kafka_head_node_password_secret_name" {
#     value = azurerm_key_vault_secret.kafka_head_node_password_secret.name
# }

# // output the key vault secrets for kafka worker node

# output "kafka_worker_node_name_secret_name" {
#     value = azurerm_key_vault_secret.kafka_worker_node_secret.name
# }

# output "kafka_worker_node_password_secret_name" {
#     value = azurerm_key_vault_secret.kafka_worker_node_password_secret.name
# }

# // output the key vault secrets for kafka zookeeper node
# output "kafka_zookeeper_node_name_secret_name" {
#     value = azurerm_key_vault_secret.kafka_zookeeper_node_secret.name
# }

# output "kafka_zookeeper_node_password_secret_name" {
#     value = azurerm_key_vault_secret.kafka_zookeeper_node_password_secret.name
# }