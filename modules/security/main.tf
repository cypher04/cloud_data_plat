// firewall rule for synapse workspace
# resource "azurerm_synapse_firewall_rule" "synapse_firewall_rule" {
#   name                = "AllowAzureServices"
#   synapse_workspace_id = var.synapse_workspace_id
#   start_ip_address    = "0.0.0.0"
#     end_ip_address      = "255.255.255.255"
# }



