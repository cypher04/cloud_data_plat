// backend configuration for Terraform state
terraform {
  backend "azurerm" {
    resource_group_name  = "clouddatadev-rg"
    storage_account_name = "clouddatastatedev"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}


