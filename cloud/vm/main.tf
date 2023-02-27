
variable "prefix" {
  default = "MStest"
}

locals {
  vm_name = "${var.prefix}-vm"
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
        key                  = "vm/terraform.tfstate" 
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

data "terraform_remote_state" "ntw" {  
    backend = "azurerm" 
    config = {  
        resource_group_name  = "nt-poc-akshaya" 
        storage_account_name = "sinkstrgadf" 
        container_name       = "terra" 
        key                  = "ntwg/terraform.tfstate"
    } 

 }
provider "azurerm" { 

  features {} 

}

## Create Network Security Group and rule
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "MStest-nsg"
  location            = data.terraform_remote_state.ntw.outputs.resource_group_region
  resource_group_name = data.terraform_remote_state.ntw.outputs.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                        = "UI_Https_443"
    priority                    = 310
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
  }
  security_rule {
    name                        = "UI_Https_80"
    priority                    = 311
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
  }
  
}

resource "azurerm_public_ip" "vm_publicIP" {
    name                         = "MStest-pubip"
    location                     = data.terraform_remote_state.ntw.outputs.resource_group_region
    resource_group_name          = data.terraform_remote_state.ntw.outputs.resource_group_name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "nai_vm_nic" {
  name                = "MStest-nic"
  location            = data.terraform_remote_state.ntw.outputs.resource_group_region
  resource_group_name = data.terraform_remote_state.ntw.outputs.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.ntw.outputs.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_publicIP.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_link" {
  network_interface_id      = azurerm_network_interface.nai_vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}


resource "azurerm_virtual_machine" "VMtest" {
  name                  = local.vm_name
  location              = data.terraform_remote_state.ntw.outputs.resource_group_region
  resource_group_name   = data.terraform_remote_state.ntw.outputs.resource_group_name
  network_interface_ids =  [
    azurerm_network_interface.nai_vm_nic.id,
  ]
  vm_size               = "Standard_F4"
  
  delete_os_disk_on_termination = true


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
output "public_ip" {
  value = azurerm_public_ip.vm_publicIP.ip_address
}