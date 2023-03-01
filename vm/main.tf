
variable "prefix" {
  default = "MSlocal"
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
        container_name       = "sink" 
        key                  = "vm/terraform.tfstate" 
    } 
} 

data "terraform_remote_state" "rg" {  
    backend = "azurerm" 
    config = {  
        resource_group_name  = "nt-poc-akshaya"
        storage_account_name = "sinkstrgadf" 
        container_name       = "sink" 
        key                  = "rg/terraform.tfstate" 
    } 

 }

data "terraform_remote_state" "ntw" {  
    backend = "azurerm" 
    config = {  
        resource_group_name  = "nt-poc-akshaya"
        storage_account_name = "sinkstrgadf" 
        container_name       = "sink" 
        key                  = "nt/terraform.tfstate" 
    } 

 }
provider "azurerm" { 

  features {} 

}

## Create Network Security Group and rule
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "MStest-nsg"
  location            = data.terraform_remote_state.rg.outputs.resource_group_region
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name

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
    location                     = data.terraform_remote_state.rg.outputs.resource_group_region
    resource_group_name          = data.terraform_remote_state.rg.outputs.resource_group_name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "nai_vm_nic" {
  name                = "MStest-nic"
  location            = data.terraform_remote_state.rg.outputs.resource_group_region
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name

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

# Create virtual machine
resource "azurerm_linux_virtual_machine" "MStest" {
  name                  = local.vm_name
  location              = data.terraform_remote_state.rg.outputs.resource_group_region
  resource_group_name   = data.terraform_remote_state.rg.outputs.resource_group_name
  network_interface_ids =  [
    azurerm_network_interface.nai_vm_nic.id,
  ]
  size                  = "Standard_DS1_v2"
  

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "myosdisk"
  }
  disable_password_authentication = false
  computer_name                   = local.vm_name
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"

 
}

resource "azurerm_managed_disk" "MStest" {
  name                 = "${local.vm_name}-datadrive"
  location             = data.terraform_remote_state.rg.outputs.resource_group_region
  resource_group_name  = data.terraform_remote_state.rg.outputs.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "MStest" {
  managed_disk_id    = azurerm_managed_disk.MStest.id
  virtual_machine_id = azurerm_linux_virtual_machine.MStest.id
  lun                = 10
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "mount_Disk" {
  name                 = join("-", ["mount_Disk", formatdate("YYYYMMDDhhmm", timestamp())] )
  virtual_machine_id = azurerm_linux_virtual_machine.MStest.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("mountdisk.sh")}"
    }
SETTINGS
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.MStest
  ]
}

output "public_ip" {
  value = azurerm_public_ip.vm_publicIP.ip_address
}
