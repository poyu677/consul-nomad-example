locals {
  consul_server_count = 1
}

resource "azurerm_network_security_group" "consul" {
  name                = "${var.consul_vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "consul" {
  count               = local.consul_server_count
  name                = "${var.consul_vm_name}-${count.index + 1}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "consul" {
  count                     = local.consul_server_count
  network_interface_id      = azurerm_network_interface.consul[count.index].id
  network_security_group_id = azurerm_network_security_group.consul.id
}

resource "azurerm_linux_virtual_machine" "consul" {
  count               = local.consul_server_count
  name                = "${var.consul_vm_name}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.default_vm_size
  admin_username      = var.vm_admin_name
  network_interface_ids = [
    azurerm_network_interface.consul[count.index].id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_name
    public_key = file(var.vm_public_key_from)
  }

  os_disk {
    name                 = "${var.consul_vm_name}-${count.index + 1}-os-disk"
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
