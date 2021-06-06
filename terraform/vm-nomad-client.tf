locals {
  nomad_client_count = 1
}

resource "azurerm_network_security_group" "nomad_client" {
  name                = "${var.nomad_client_vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHttp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "nomad_client" {
  name                = "nomad-client-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nomad_client" {
  count               = local.nomad_client_count
  name                = "${var.nomad_client_vm_name}-${count.index + 1}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nomad_client.id
  }
}

resource "azurerm_network_interface_security_group_association" "nomad_client" {
  count                     = local.nomad_client_count
  network_interface_id      = azurerm_network_interface.nomad_client[count.index].id
  network_security_group_id = azurerm_network_security_group.nomad_client.id
}

resource "azurerm_linux_virtual_machine" "nomad_client" {
  count               = local.nomad_client_count
  name                = "${var.nomad_client_vm_name}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.default_worker_vm_size
  admin_username      = var.vm_admin_name
  network_interface_ids = [
    azurerm_network_interface.nomad_client[count.index].id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_name
    public_key = file(var.vm_public_key_from)
  }

  os_disk {
    name                 = "${var.nomad_client_vm_name}-${count.index + 1}-os-disk"
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

output "nomad_client_ip_addr" {
  value = azurerm_public_ip.nomad_client.ip_address
}
