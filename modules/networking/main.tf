resource "azurerm_virtual_network" "cloud-network" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  
}

resource "azurerm_subnet" "cloud-subnet-web" {
    name                 = "cloud-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.cloud-network.name
    address_prefixes     = [var.subnet_prefixes["web"]]  
}

resource "azurerm_subnet" "cloud-subnet-db" {
    name                 = "cloud-subnet-db"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.cloud-network.name
    address_prefixes     = [var.subnet_prefixes["database"]]
}


resource "azurerm_subnet" "cloud-subnet-1" {
    name                 = "cloud-subnet-1"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.cloud-network.name
    address_prefixes     = [var.subnet_prefixes["data-sub-1"]]
}


resource "azurerm_subnet" "cloud-subnet-2" {
    name                 = "cloud-subnet-2"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.cloud-network.name
    address_prefixes     = [var.subnet_prefixes["data-sub-2"]]
}

resource "azurerm_subnet" "cloud-subnet-synapse" {
    name                 = "cloud-subnet-synapse"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.cloud-network.name
    address_prefixes     = [var.subnet_prefixes["synapse-compute"]]
}