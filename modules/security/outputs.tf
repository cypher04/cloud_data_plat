output "synapse_firewall_name" {
    description = "The name of the firewall rule for the Synapse workspace."
    value       = azurerm_synapse_firewall_rule.synapse_firewall_rule.name
}

