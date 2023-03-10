variable "prefix" {
  default = "MSlocal"
}
variable "location"{
  default = "Central India"
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
        container_name       = "sink" 
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
  name                     = "storageaccountmslocal"
  resource_group_name      = azurerm_resource_group.MStest.name
  location                 = azurerm_resource_group.MStest.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
resource "azurerm_storage_container" "MStest" {
  name                  = "terra"
  storage_account_name  = azurerm_storage_account.MStest.name
  container_access_type = "private"
}

output "resource_group_name" {
  value = azurerm_resource_group.MStest.name
}
output "resource_group_region" {
  value = azurerm_resource_group.MStest.location
}
