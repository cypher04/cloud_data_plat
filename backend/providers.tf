terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.73.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1" 
  }

  time ={
    source  = "hashicorp/time"
    version = "0.14.0"
  }
}
}

provider "azurerm" {
  features {}
}

