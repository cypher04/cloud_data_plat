variable "resource_group_name" {
  description = "The name of the resource group in which the Synapse workspace is located."
  type        = string
}

variable "synapse_workspace_id" {
  description = "The ID of the Synapse workspace."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

