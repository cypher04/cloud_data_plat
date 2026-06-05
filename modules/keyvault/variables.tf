variable "resource_group_name" {
    description = "The name of the resource group in which the private endpoint will be created."
    type        = string
}

variable "location" {
    description = "The Azure region where the private endpoint will be created."
    type        = string
}

variable "kafka_gateway_name" {
  description = "The name of the Kafka gateway"
  type        = string
}

variable "kafka_gateway_password" {
  description = "The password for the Kafka gateway"
  type        = string
  sensitive   = true
}

variable "kafka_head_node_name" {
  description = "The name of the Kafka head node"
  type        = string
}

variable "kafka_head_node_password" {
  description = "The password for the Kafka head node"
  type        = string
  sensitive   = true
}

variable "kafka_worker_node_name" {
  description = "The name of the Kafka worker node"
  type        = string
}

variable "kafka_worker_node_password" {
  description = "The password for the Kafka worker node"
  type        = string
  sensitive   = true
}

variable "kafka_zookeeper_node_name" {
  description = "The name of the Kafka zookeeper node"
  type        = string
}

variable "kafka_zookeeper_node_password" {
  description = "The password for the Kafka zookeeper node"
  type        = string
  sensitive   = true
}

// variables for github repo connector for synapse
variable "github_repo_url" {
  description = "The URL of the GitHub repository for Synapse"
  type        = string
}

variable "github_repo_branch" {
  description = "The branch of the GitHub repository for Synapse"
  type        = string
}

variable "github_account_name" {
  description = "The GitHub account name for Synapse"
  type        = string
}

variable "github_repo_name" {
  description = "The name of the GitHub repository for Synapse"
  type        = string
}
