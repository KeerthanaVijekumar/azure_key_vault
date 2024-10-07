# Get the current Azure client configuration (tenant ID and client ID)
data "azurerm_client_config" "current" {}

# Create the Key Vault (with lifecycle rules)
resource "azurerm_key_vault" "key_vault" {
  name                = var.app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault[0].name  # Reference the resource group using [0] due to count
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
  client_id = var.client_id  # Use var.client_id instead of data source client_id
}

# Only create the service principal if it doesn't exist
resource "azuread_service_principal" "example" {
  count     = length(data.azuread_service_principal.existing_sp.id) == 0 ? 1 : 0
  client_id = var.client_id

  lifecycle {
    ignore_changes = [
      app_role_assignment_required,
      app_role_ids
    ]
  }
}

# Assign Key Vault Secrets User role to the Service Principal
resource "azurerm_role_assignment" "key_vault_role_assignment" {
  principal_id = length(azuread_service_principal.example) > 0 ? azuread_service_principal.example[0].id : data.azuread_service_principal.existing_sp.id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault.id  # Reference the Key Vault directly

  depends_on = [azurerm_key_vault.key_vault]
}
