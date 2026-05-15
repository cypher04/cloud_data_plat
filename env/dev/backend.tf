// backend configuration for Terraform state
terraform {
  backend "azurerm" {
    resource_group_name  = "myprojectdev-rg"
    storage_account_id = "${azurerm_storage_account.state_storage.id}"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}