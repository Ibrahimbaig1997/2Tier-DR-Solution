# Recovery Services Vaults were created in backup.tf; ASR replication setup uses same vaults.

# Replication policy (create in primary vault)
resource "azurerm_site_recovery_replication_policy" "rep_policy" {
  name                                = "${local.naming.prefix}-rep-policy"
  resource_group_name                 = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name                 = azurerm_recovery_services_vault.vault[local.primary_region].name
  recovery_point_retention_in_minutes = "4320" # 3 days

  # retention and snapshot frequency tuned for RPO/RTO targets
  application_consistent_snapshot_frequency_in_minutes = 120

}

# Fabric (logical construct)
resource "azurerm_site_recovery_fabric" "primary_fabric" {
  name                = "${local.naming.prefix}-fabric-${local.primary_region}"
  resource_group_name = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name = azurerm_recovery_services_vault.vault[local.primary_region].name
  location            = local.primary_region
}

resource "azurerm_site_recovery_fabric" "dr_fabric" {
  name                = "${local.naming.prefix}-fabric-${local.dr_region}"
  resource_group_name = azurerm_resource_group.rgs[local.dr_region].name
  recovery_vault_name = azurerm_recovery_services_vault.vault[local.dr_region].name
  location            = local.dr_region
}

# Protection container placeholder: this resource often requires the fabric/container ID returned after discovery.
# Some clouds require manual import steps. This block is here as a template and may need small adjustments.
resource "azurerm_site_recovery_protection_container" "primary_container" {
  name                 = "${local.naming.prefix}-pcont-${local.primary_region}"
  resource_group_name  = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name  = azurerm_recovery_services_vault.vault[local.primary_region].name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
}

# Replicated VM: replicate the VM deployed in primary to the DR region.
# NOTE: In many subscriptions, azurerm_site_recovery_replicated_vm requires provider/fabric/container IDs that are created/filled by Azure asynchronously.
# If you get an error referencing fabric/container IDs, do a partial apply, query the actual fabric/container IDs, and import or set data sources.
resource "azurerm_site_recovery_replicated_vm" "replicated_vm" {
  name                                      = "${local.naming.prefix}-replicated-vm"
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary_fabric.name
  target_recovery_fabric_id                 = azurerm_site_recovery_fabric.dr_fabric.id
  resource_group_name                       = azurerm_resource_group.rgs[local.primary_region].name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault[local.primary_region].name
  target_resource_group_id                  = azurerm_resource_group.rgs[local.dr_region].id
  source_vm_id                              = module.vm_primary.vm_id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary_container.name
  target_recovery_protection_container_id   = azurerm_site_recovery_protection_container.primary_container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.rep_policy.id

  # The following fields are placeholders — depending on your tenant you may need to provide:
  # target_protection_container_id, target_fabric_name, target_vault_id, azure_to_azure_machine_type, etc.
  # Adjust based on TF provider docs and environment.
  depends_on = [azurerm_site_recovery_replication_policy.rep_policy]
}
