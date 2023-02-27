variable "prefix" {
  default = "VMtestin3"
}

locals {
  vm_name = "${var.prefix}-vm"
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
        key                  = "ntwg/terraform.tfstate" 
    } 
} 


resource "azurerm_resource_group" "VMtest" {
  name     = "${var.prefix}-resources"
  location = "West Europe"

  tags = {
    name        = "mani"
    environment = "testing"
  }
}

resource "azurerm_virtual_network" "VMtest" {
  name                = "${var.prefix}-nnetwork"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.VMtest.location
  resource_group_name = azurerm_resource_group.VMtest.name
}

resource "azurerm_subnet" "VMtest" {
  name                 = "vmtest"
  resource_group_name  = azurerm_resource_group.VMtest.name
  virtual_network_name = azurerm_virtual_network.VMtest.name
  address_prefixes     = ["192.168.2.0/24"]
}

output "resource_group_name" {
  value = azurerm_resource_group.VMtest.name
}
output "resource_group_region" {
  value = azurerm_resource_group.VMtest.location
}
output "virtual_network_name" {
  value = azurerm_virtual_network.VMtest.name
}

output "subnet_id" {
  value = azurerm_subnet.VMtest.id
}

output "vnet_id" {
  value = azurerm_virtual_network.VMtest.id
}