# Get the current Azure client configuration (tenant ID and client ID)
data "azurerm_client_config" "current" {}

# Check if the Key Vault exists using the data block
data "azurerm_key_vault" "existing_kv" {
  name = var.app_name
  # Conditional reference: Check if the resource group exists before accessing its attributes
  resource_group_name = length(azurerm_resource_group.flixtubeazurekeyvault) > 0 ? azurerm_resource_group.flixtubeazurekeyvault[0].name : var.app_name
}

# Only create the Key Vault if it doesn't already exist
resource "azurerm_key_vault" "key_vault" {
  count               = length(data.azurerm_key_vault.existing_kv.id) == 0 ? 1 : 0  # Create if it doesn't exist
  name                = var.app_name
  location            = var.location
  resource_group_name = length(azurerm_resource_group.flixtubeazurekeyvault) > 0 ? azurerm_resource_group.flixtubeazurekeyvault[0].name : var.app_name  # Conditional access
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
    ignore_changes  = [sku_name, tenant_id]  # Ignore changes to sku_name and tenant_id
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}

# Check if the service principal already exists using the client ID from the current Azure configuration
data "azuread_service_principal" "existing_sp" {
  client_id = var.client_id
}

# Only create the service principal if it doesn't exist
resource "azuread_service_principal" "example" {
  count     = length(data.azuread_service_principal.existing_sp.id) == 0 ? 1 : 0
  client_id = var.client_id

  lifecycle {
    ignore_changes = [
      app_role_assignment_required  # Removed app_role_ids as it is managed by Azure
    ]
  }
}

# Assign Key Vault Secrets User role to the Service Principal
resource "azurerm_role_assignment" "key_vault_role_assignment" {
  principal_id = length(azuread_service_principal.example) > 0 ? azuread_service_principal.example[0].id : data.azuread_service_principal.existing_sp.id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault[0].id  # Reference Key Vault directly

  depends_on = [azurerm_key_vault.key_vault]
}
