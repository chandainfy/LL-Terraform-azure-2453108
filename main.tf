# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

variable "prefix"{

  default = "learn-tf"
}

#create RG
resource "azurerm_resource_group" "main" {

  name = "${var.prefix}-rg-eastus"
  location = "eastus"

}

#create virtual network
resource "azurerm_virtual_network" "main"{
  name ="${var.prefix}-vnet-eastus"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}
#create subnet, can be done separately as well as within vnet resource block
resource "azurerm_subnet" "main"{
  name = "${var.prefix}-subnet-eastus"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = ["10.0.0.0/24"]

}
#cerete NIC
resource "azurerm_network_interface" "internal"{
  name = "${var.prefix}-nic-eastus"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
    ip_configuration{
      name = "internal"
      subnet_id = azurerm_subnet.main.id
      private_ip_address_allocation = "Dynamic"
    }
}

#create VM
resource "azurerm_windows_virtual_machine" "main" {
  name = "${var.prefix}-vm-eus"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  size = "Standard_B1s"
  admin_username = "user.admin"
  admin_password = "adminPassword12"
    
  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}