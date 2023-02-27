variable "prefix" {
  default = "MStesting"
}
variable "location"{
  default = "West Europe"
}

provider "azurerm" {
  skip_provider_registration = "true"
  #version = "=2.15"
  features {}
}
terraform { 
  required_providers { 
    azurerm = { 
      source  = "hashicorp/azurerm" 
      version = "=2.46.0" 
    } 
  } 
    backend "azurerm" {   
        resource_group_name  = "nt-poc-akshaya"
        storage_account_name = "sinkstrgadf" 
        container_name       = "terra" 
        key                  = "rg/terraform.tfstate" 
    } 
} 


resource "azurerm_resource_group" "MStest" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"

  tags = {
    name        = "mani"
    environment = "testing"
  }
}

resource "azurerm_storage_account" "MStest" {
  name                     = "storageaccountmstest"
  resource_group_name      = azurerm_resource_group.MStest.name
  location                 = azurerm_resource_group.MStest.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.MStest.name
}
output "resource_group_region" {
  value = azurerm_resource_group.MStest.location
}

