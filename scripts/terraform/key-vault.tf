# Get the current Azure client configuration (tenant ID and client ID)
data "azurerm_client_config" "current" {}

# Create the Key Vault only if it does not exist
resource "azurerm_key_vault" "key_vault" {
  count               = length(data.azurerm_key_vault.existing_kv.id) == 0 ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = coalesce(azurerm_resource_group.flixtubeazurekeyvault[count.index].name, var.app_name)
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Optional: Enable soft delete with retention policy
  soft_delete_retention_days = 7
}

# Check if the service principal already exists using the client ID from the current Azure configuration
data "azuread_service_principal" "existing_sp" {
  client_id = data.azurerm_client_config.current.client_id
}

# Create the Service Principal only if it does not exist
resource "azuread_service_principal" "example" {
  count          = length(data.azuread_service_principal.existing_sp.id) == 0 ? 1 : 0
  application_id = data.azurerm_client_config.current.client_id  # Use the clientId from the current configuration
}

# Check if role assignment already exists
data "azurerm_role_assignment" "existing_role_assignment" {
  for_each            = length(azurerm_ad_service_principal.sp) > 0 ? toset([azurerm_ad_service_principal.sp.*.id]) : []
  scope               = azurerm_key_vault.key_vault[count.index].id
  principal_id        = each.key
  role_definition_name = "Key Vault Secrets User"
}

# Assign Key Vault Secrets User role to the Service Principal only if it does not exist
resource "azurerm_role_assignment" "role_assignment" {
  count               = length(data.azurerm_role_assignment.existing_role_assignment) == 0 ? 1 : 0
  principal_id        = azurerm_ad_service_principal.sp[count.index].id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault[count.index].id
}
