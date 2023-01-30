#Resource Group
resource "azurerm_resource_group" "rg-demo" {
  name     = "rg-demo"
  location = "eastus2"
}

#Public IP
resource "azurerm_public_ip" "pip-demo" {
  name                = "public-ip"
  resource_group_name = azurerm_resource_group.rg-demo.name
  location            = azurerm_resource_group.rg-demo.location
  allocation_method   = "Static"
}

#Virtual Network
resource "azurerm_virtual_network" "vnet-demo" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-demo.location
  resource_group_name = azurerm_resource_group.rg-demo.name
}

#Subnet
resource "azurerm_subnet" "subnet-demo" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.rg-demo.name
  virtual_network_name = azurerm_virtual_network.vnet-demo.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Network Interface
resource "azurerm_network_interface" "nic-demo" {
  name                = "nic-demo"
  location            = azurerm_resource_group.rg-demo.location
  resource_group_name = azurerm_resource_group.rg-demo.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-demo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-demo.id
  }
}

#Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm-demo" {
  name                            = "vm-demo"
  resource_group_name             = azurerm_resource_group.rg-demo.name
  location                        = azurerm_resource_group.rg-demo.location
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic-demo.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name = "vm-demo"
}

