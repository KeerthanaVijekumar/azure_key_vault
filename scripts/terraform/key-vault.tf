# Get the current Azure client configuration (tenant ID and client ID)
data "azurerm_client_config" "current" {}

# Check if the Key Vault exists
data "azurerm_key_vault" "existing_kv" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
  depends_on          = [azurerm_resource_group.flixtubeazurekeyvault]
}

# Create the Key Vault 
resource "azurerm_key_vault" "key_vault" {
  name                = var.app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}


# Check if the service principal already exists using the client ID from the current Azure configuration
data "azuread_service_principal" "existing_sp" {
  client_id = data.azurerm_client_config.current.client_id
}

# Create the Service Principal (with lifecycle to ignore changes)
resource "azuread_service_principal" "example" {
  client_id = var.client_id

  lifecycle {
    ignore_changes = [
      # Ignore changes to attributes to avoid recreation issues
      "app_role_assignment_required",
      "app_role_ids",
      # You can list other attributes here
    ]
  }
}


# Assign Key Vault Secrets User role to the Service Principal
resource "azurerm_role_assignment" "role_assignment" {
  principal_id        = coalesce(azuread_service_principal.example.id, data.azuread_service_principal.existing_sp.id)
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault.id  # Reference the Key Vault directly without index

  depends_on = [azurerm_key_vault.key_vault]
}
