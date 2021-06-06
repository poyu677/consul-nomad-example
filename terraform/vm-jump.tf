resource "azurerm_network_security_group" "jump" {
  name                = "jump-1-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "jump" {
  name                = "jump-1-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jump" {
  name                = "jump-1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump.id
  }
}

resource "azurerm_network_interface_security_group_association" "jump" {
  network_interface_id      = azurerm_network_interface.jump.id
  network_security_group_id = azurerm_network_security_group.jump.id
}

resource "azurerm_linux_virtual_machine" "jump" {
  name                = "jump-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.default_vm_size
  admin_username      = var.vm_admin_name
  network_interface_ids = [
    azurerm_network_interface.jump.id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_name
    public_key = file(var.vm_public_key_from)
  }

  os_disk {
    name                 = "jump-1-disk"
    disk_size_gb         = 30
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "jump_ip_addr" {
  value = azurerm_public_ip.jump.ip_address
}
