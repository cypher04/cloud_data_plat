variable "resource_group_name" {
    description = "The name of the resource group in which the private endpoint will be created."
    type        = string
}

variable "location" {
    description = "The Azure region where the private endpoint will be created."
    type        = string
}

# variable "subnet_prefixes" {
#     description = "A map of subnet prefixes for the private endpoint."
#     type        = map(object({
#         id = string
#     }))
# }

variable "datalake_storage_account_id" {
    description = "The ID of the data lake storage account to which the private endpoint will connect."
    type        = string
}

variable "synapse_workspace_id" {
    description = "The ID of the Synapse workspace to which the private endpoint will connect."
    type        = string
}

variable "vnet_id" {
    description = "The ID of the virtual network to which the private endpoint will be connected."
    type        = string
}

variable "subnet_ids" {
    description = "The IDs of the subnets to which the private endpoint will be connected."
    type        = list(string)
}

variable "storage_datalake_gen2_id" {
    description = "The ID of the Data Lake Gen2 filesystem to be used by the Synapse workspace."
    type        = string
}

variable "synapse_sql_pool_id" {
    description = "The ID of the Synapse SQL pool to which the private endpoint will connect."
    type        = string
}

variable "synapse_storage_account_id" {
    description = "The ID of the Synapse storage account to which the private endpoint will connect."
    type        = string
}

variable "eventhub_id" {
    description = "The ID of the Event Hub to which the private endpoint will connect."
    type        = string
}