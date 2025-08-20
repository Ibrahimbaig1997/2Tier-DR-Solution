# Creates vnet + subnet per region
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet-${var.region_id}"
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = [var.address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-snet-${var.region_id}"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
  service_endpoints    = var.service_endpoints
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
