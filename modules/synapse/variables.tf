variable "resource_group_name" {
    description = "The name of the resource group in which to create the Synapse workspace."
    type        = string
}

variable "location" {
    description = "The Azure region where the Synapse workspace will be created."
    type        = string
}

# variable "storage_account_id" {
#     description = "The ID of the storage account to be used by the Synapse workspace."
#     type        = string
# }

variable "datalake_storage_account_id" {
    description = "The ID of the Data Lake Storage account to be used by the Synapse workspace."
    type        = string
}

variable "storage_datalake_gen2_id" {
    description = "The ID of the Data Lake Gen2 filesystem to be used by the Synapse workspace."
    type        = string
}

variable "admin_username" {
     description = "The administrator username for the Synapse workspace."
     type        = string
}

variable "admin_password" {
    description = "The administrator password for the Synapse workspace."
    type        = string
    sensitive   = true
}

variable "subnet_prefixes" {
    description = "The list of subnet prefixes to be used for the Synapse workspace."
    type        = map(string)
}

variable "synapse_firewall_name" {
    description = "The name of the Synapse firewall rule."
    type        = string
}

variable "keyvault_name" {
    description = "The name of the Key Vault to store secrets for the Synapse workspace."
    type        = string
}

# variable "keyvault_id"{
#     description = "The ID of the Key Vault to store secrets for the Synapse workspace."
#     type        = string
# }

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



