# Recovery Services Vault per region (for backup + ASR)

resource "azurerm_recovery_services_vault" "vault" {
  for_each = azurerm_resource_group.rgs

  name                = "${local.naming.prefix}-rsv-${each.key}"
  resource_group_name = each.value.name
  location            = each.value.location
  sku                 = "Standard"
  tags                = var.tags
}

# VM Backup policy (created in primary region)
resource "azurerm_backup_policy_vm" "vm_policy" {
  depends_on          = [azurerm_recovery_services_vault.vault]
  name                = "${local.naming.prefix}-vm-backup"
  resource_group_name = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name = azurerm_recovery_services_vault.vault[local.primary_region].name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# Protect VM with the policy
resource "azurerm_backup_protected_vm" "protected_vm" {
  resource_group_name = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name = azurerm_recovery_services_vault.vault[local.primary_region].name
  source_vm_id        = module.vm_primary.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.vm_policy.id
}
