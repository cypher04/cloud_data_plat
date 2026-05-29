variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "A map of subnet names to their respective prefixes"
  type        = map(string)
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machines"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the virtual machines"
  type        = string
  sensitive   = true
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

