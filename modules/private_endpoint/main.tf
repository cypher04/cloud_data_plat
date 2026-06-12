# // create a private endpoint for the synapse workspace web
# resource "azurerm_private_endpoint" "synapse_private_endpoint" {
#   name                = "synapse-private-endpoint"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_ids[4]

#   private_service_connection {
#     name                           = "synapse-psc"
#     is_manual_connection            = false
#     private_connection_resource_id   = var.synapse_workspace_id
#     subresource_names               = ["web"]
#   }
# }

# resource "azurerm_private_dns_zone" "synapse_private_dns_zone" {
#   name                = "privatelink.azuresynapse.net"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "synapse_dns_zone_link" {
#   name                  = "synapse-dns-zone-link"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.synapse_private_dns_zone.name
#   virtual_network_id    = var.vnet_id
# }

// create a private endpoint for the synapse workspace sql pool
resource "azurerm_private_endpoint" "synapse_sql_pool_private_endpoint" {
  name                = "synapse-sql-pool-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[4]

    private_service_connection {
        name                           = "synapse-sql-pool-psc"
        is_manual_connection            = false
        private_connection_resource_id   = var.synapse_sql_pool_id
        subresource_names               = ["Sql"]
    }
}

resource "azurerm_private_dns_zone" "synapse_sql_pool_private_dns_zone" {
  name                = "privatelink.sql.azuresynapse.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_sql_pool_dns_zone_link" {
  name                  = "synapse-sql-pool-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_sql_pool_private_dns_zone.name
  virtual_network_id    = var.vnet_id
}


// create a private endpoint for synapse development
resource "azurerm_private_endpoint" "synapse_dev_private_endpoint" {
  name                = "synapse-dev-private-endpoint"
  location            = var.location
    resource_group_name = var.resource_group_name
    subnet_id           = var.subnet_ids[4]
    
    private_service_connection {
        name                           = "synapse-dev-psc"
        is_manual_connection            = false
        private_connection_resource_id   = var.synapse_workspace_id
        subresource_names               = ["dev"]
    }
}

resource "azurerm_private_dns_zone" "synapse_dev_private_dns_zone" {
  name                = "privatelink.dev.azuresynapse.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_dev_dns_zone_link" {
  name                  = "synapse-dev-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_dev_private_dns_zone.name
  virtual_network_id    = var.vnet_id
}

// create a private endpoint for the synapse workspace storage account
resource "azurerm_private_endpoint" "synapse_storage_account_private_endpoint" {
  name                = "synapse-storage-account-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[4]
  
    private_service_connection {
        name                           = "synapse-storage-account-psc"
        is_manual_connection            = false
        private_connection_resource_id   = var.synapse_storage_account_id
        subresource_names               = ["blob"]
    }

}

resource "azurerm_private_dns_zone" "synapse_storage_account_private_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_storage_account_dns_zone_link" {
  name                  = "synapse-storage-account-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_storage_account_private_dns_zone.name
  virtual_network_id    = var.vnet_id
}

// create a private endpoint for the synapse workspace data lake gen2 account
resource "azurerm_private_endpoint" "synapse_datalake_gen2_private_endpoint" {
  name                = "synapse-datalake-gen2-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[4]   
  
    private_service_connection {
        name                           = "synapse-datalake-gen2-psc"
        is_manual_connection            = false
        private_connection_resource_id   = var.datalake_storage_account_id
        subresource_names               = ["dfs"]
    }

}

resource "azurerm_private_dns_zone" "synapse_datalake_gen2_private_dns_zone" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_datalake_gen2_dns_zone_link" {
  name                  = "synapse-datalake-gen2-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_datalake_gen2_private_dns_zone.name
  virtual_network_id    = var.vnet_id
}

# // create a private endpoint for the synapse workspace sql on demand pool
# resource "azurerm_private_endpoint" "synapse_sql_on_demand_pool_private_endpoint" {
#   name                = "synapse-sql-on-demand-pool-private-endpoint"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_ids[4]
    
#         private_service_connection {
#             name                           = "synapse-sql-on-demand-pool-psc"
#             is_manual_connection            = false
#             private_connection_resource_id   = var.synapse_sql_pool_id
#             subresource_names               = ["sqlOnDemand"]
#         }

# }   

# resource "azurerm_private_dns_zone" "synapse_sql_on_demand_pool_private_dns_zone" {
#   name                = "privatelink.sql.azuresynapse.net"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "synapse_sql_on_demand_pool_dns_zone_link" {
#   name                  = "synapse-sql-on-demand-pool-dns-zone-link"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.synapse_sql_on_demand_pool_private_dns_zone.name
#   virtual_network_id    = var.vnet_id
# }

//
