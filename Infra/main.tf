# Create resource group per region
resource "azurerm_resource_group" "rgs" {
  for_each = local.region_map
  name     = "${local.naming.prefix}-rg-${each.key}"
  location = each.value.location
  tags     = var.tags
}

# Random suffix for global unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Storage Account per region with GRS
resource "azurerm_storage_account" "sa" {
  for_each = azurerm_resource_group.rgs

  name                     = substr(lower("${local.naming.prefix}sa${random_string.suffix.result}${replace(each.key, "-", "")}"), 0, 24)
  resource_group_name      = each.value.name
  location                 = each.value.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags
}

# Network: use module to create vnet/subnet per region
module "network" {
  for_each          = azurerm_resource_group.rgs
  source            = "./modules/network"
  region_id         = each.key
  location          = each.value.location
  resource_group    = each.value.name
  prefix            = local.naming.prefix
  address_space     = "10.${index(var.regions, each.key)}.0.0/16" # simple per-region allocation
  subnet_prefix     = "10.${index(var.regions, each.key)}.1.0/24"
  tags              = var.tags
  service_endpoints = ["Microsoft.Storage"]
}


# Create a single VM in primary region
module "vm_primary" {
  source         = "./modules/vm"
  prefix         = local.naming.prefix
  name_suffix    = "primary"
  location       = azurerm_resource_group.rgs[local.primary_region].location
  resource_group = azurerm_resource_group.rgs[local.primary_region].name
  subnet_id      = module.network[local.primary_region].subnet_id
  size           = "Standard_B2s"
  admin_username = var.admin_username
  admin_password = var.admin_password
  custom_data    = base64encode("#!/bin/bash\napt-get update\napt-get -y install nginx\nsystemctl enable --now nginx")
  tags           = var.tags
}


