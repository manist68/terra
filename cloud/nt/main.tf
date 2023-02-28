variable "prefix" {
  default = "MStest"
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
        key                  = "nt/terraform.tfstate" 
    } 
} 
data "terraform_remote_state" "rg" {
  backend = "azurerm"

  config = {
        resource_group_name  = "nt-poc-akshaya"
        storage_account_name = "sinkstrgadf" 
        container_name       = "terra"  
        key                  = "rg/terraform.tfstate"  
  }
}

resource "azurerm_virtual_network" "MStest" {
  name                = "${var.prefix}-network"
  address_space       = ["192.168.0.0/16"]
  location            = data.terraform_remote_state.rg.outputs.resource_group_region
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name
}

resource "azurerm_subnet" "MStest" {
  name                 = "MStest"
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name
  virtual_network_name = azurerm_virtual_network.MStest.name
  address_prefixes     = ["192.168.2.0/24"]
}

# output "resource_group_name" {
#   value = azurerm_resource_group.MStest.name
# }
# output "resource_group_region" {
#   value = azurerm_resource_group.MStest.location
# }
output "virtual_network_name" {
  value = azurerm_virtual_network.MStest.name
}

output "subnet_id" {
  value = azurerm_subnet.MStest.id
}

output "vnet_id" {
  value = azurerm_virtual_network.MStest.id
}
