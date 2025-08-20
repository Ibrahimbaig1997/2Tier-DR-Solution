resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.prefix}-vm-${var.name_suffix}"
  resource_group_name             = var.resource_group
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.nic.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = var.custom_data

  tags = var.tags
}

output "vm_id" { value = azurerm_linux_virtual_machine.vm.id }
