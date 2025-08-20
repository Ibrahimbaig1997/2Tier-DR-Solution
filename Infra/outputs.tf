output "resource_groups" {
  value = { for k, rg in azurerm_resource_group.rgs : k => rg.name }
}

output "storage_accounts" {
  value = { for k, sa in azurerm_storage_account.sa : k => sa.name }
}

# output "recovery_vaults" {
#   value = { for k, v in azurerm_recovery_services_vault.vault : k => v.name }
# }

output "primary_vm_id" {
  value = module.vm_primary.vm_id
}
