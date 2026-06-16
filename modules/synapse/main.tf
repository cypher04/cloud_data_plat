
locals {
  github_secret_names = {
     "github-repo-url" = var.github_repo_url,
     "github-repo-branch" = var.github_repo_branch,
     "github-account-name" = var.github_account_name,
     "github-repo-name" = var.github_repo_name
  }
} 

resource "random_string" "random_string" {
  length  = 4
  upper   = false
  special = false
}


data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  
}

data "azurerm_key_vault_secret" "github" {
  for_each     = local.github_secret_names
  name         = each.value
  key_vault_id = data.azurerm_key_vault.keyvault.id
}


resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                = "cloudsynapseworkspace"
  resource_group_name = var.resource_group_name
  location            = var.location
  sql_administrator_login          = var.admin_username
  sql_administrator_login_password = var.admin_password
  storage_data_lake_gen2_filesystem_id = var.storage_datalake_gen2_id
  managed_virtual_network_enabled = true
  data_exfiltration_protection_enabled = true

  github_repo {
    account_name = data.azurerm_key_vault_secret.github["github-account-name"].value
    branch_name = data.azurerm_key_vault_secret.github["github-repo-branch"].value
    repository_name = data.azurerm_key_vault_secret.github["github-repo-name"].value
    git_url = data.azurerm_key_vault_secret.github["github-repo-url"].value
    root_folder = "/"
  }
  
  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                = "cloudsynapsesqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  create_mode = "Default"
  storage_account_type = "GRS"
  sku_name            = "DW100c"
}

resource "azurerm_storage_account" "synapse_storage_account" {
  name                     = "cloudsynapsestorage${random_string.random_string.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
}


// firewall rule for synapse workspace to allow access from all azure services

data "http" "public_ip" {
  url = "https://api.ipify.org"
}


resource "azurerm_synapse_firewall_rule" "runner" {
  name                = "AllowTerraformRunner"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address    = chomp(data.http.public_ip.response_body)
    end_ip_address      = chomp(data.http.public_ip.response_body)
}

resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name                = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_managed_private_endpoint" {
  name                = "synapse-managed-private-endpoint"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = azurerm_storage_account.synapse_storage_account.id
  subresource_name               = "blob"
  
  depends_on = [azurerm_synapse_firewall_rule.runner]
}

// role assignment for synapse workspace identity to access datalake storage account
resource "azurerm_role_assignment" "synapse_storage_account_role_assignment" {
  scope                = var.datalake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}


// role assignment for synapse workspace identity to access key vault
resource "azurerm_role_assignment" "synapse_keyvault_role_assignment" {
  scope                = data.azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}

// managed private endpoint for synapse workspace to access datalake storage account
resource "azurerm_synapse_managed_private_endpoint" "synapse_datalake_gen2_managed_private_endpoint" {
  name                = "synapse-datalake-gen2-managed-private-endpoint"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = var.datalake_storage_account_id
  subresource_name               = "dfs"

  depends_on = [azurerm_synapse_firewall_rule.runner]
}
