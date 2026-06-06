variable "resource_group_name" {
  description = "The name of the resource group in which to create the HDInsight cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the HDInsight cluster will be created."
  type        = string
}


variable "keyvault_name" {
  description = "The name of the Azure Key Vault to store the cluster credentials."
  type        = string
}

variable "kafka_gateway_name" {
  description = "The name of the secret in Azure Key Vault that contains the gateway username."
  type        = string
}

variable "kafka_gateway_password" {
  description = "The name of the secret in Azure Key Vault that contains the gateway password."
  type        = string
}

// variable for kafka head node
variable "kafka_head_node_name" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka head node username."
  type        = string
}

variable "kafka_head_node_password" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka head node password."
  type        = string
}

// variable for kafka worker node
variable "kafka_worker_node_name" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka worker node username."
  type        = string
}

variable "kafka_worker_node_password" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka worker node password."
  type        = string
}

// variable for kafka zookeeper node

variable "kafka_zookeeper_node_name" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka zookeeper node username."
  type        = string
}

variable "kafka_zookeeper_node_password" {
  description = "The name of the secret in Azure Key Vault that contains the Kafka zookeeper node password."
  type        = string
}


variable "subnet_ids" {
  description = "A list of subnet IDs to which the HDInsight cluster will be connected."
  type        = list(string)
}

variable "vnet_id" {
  description = "The ID of the virtual network to which the HDInsight cluster will be connected."
  type        = string
}