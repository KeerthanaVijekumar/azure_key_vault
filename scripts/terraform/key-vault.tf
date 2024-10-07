# Check if the Key Vault exists
data "azurerm_key_vault" "existing_kv" {
  name                = var.app_name
  resource_group_name = var.app_name
}

# Create the Key Vault only if it does not exist
resource "azurerm_key_vault" "key_vault" {
  count               = length(data.azurerm_key_vault.existing_kv.id) == 0 ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = var.app_name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Optional: Enable soft delete with retention policy
  soft_delete_retention_days = 7
}

# Check if the Service Principal exists
data "azurerm_ad_service_principal" "existing_sp" {
  display_name = "my-service-principal-${var.app_name}"  # Adjust to your naming convention
}

# Create the Service Principal only if it does not exist
resource "azurerm_ad_service_principal" "sp" {
  count          = length(data.azurerm_ad_service_principal.existing_sp.id) == 0 ? 1 : 0
  application_id = azurerm_key_vault.key_vault.*.id[count.index]  # Guard against non-existence with count.index
}

# Check for existing role assignment to avoid duplications
data "azurerm_role_assignment" "existing_role_assignment" {
  count               = length(azurerm_ad_service_principal.sp) > 0 ? 1 : 0
  scope               = azurerm_key_vault.key_vault.*.id[count.index]
  principal_id        = azurerm_ad_service_principal.sp.*.id[count.index]
  role_definition_name = "Key Vault Secrets User"
}

# Assign Key Vault Secrets User role to the Service Principal only if it does not exist
resource "azurerm_role_assignment" "role_assignment" {
  count               = length(data.azurerm_role_assignment.existing_role_assignment) == 0 ? 1 : 0
  principal_id        = azurerm_ad_service_principal.sp.*.id[count.index]
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault.*.id[count.index]
}

