# Check if the container registry exists
data "azurerm_container_registry" "existing_acr" {
  name = var.app_name
  resource_group_name = length(azurerm_resource_group.flixtubeazurekeyvault) > 0 ? azurerm_resource_group.flixtubeazurekeyvault[0].name : var.app_name
}


# Create the container registry only if it does not exist
resource "azurerm_container_registry" "container_registry" {
  count               = length(data.azurerm_container_registry.existing_acr.id) == 0 ? 1 : 0
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault[0].name
  location            = var.location
  admin_enabled       = true
  sku                 = "Basic"
}
