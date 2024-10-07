data "azurerm_resource_group" "existing_rg" {
  name = var.app_name
}

resource "azurerm_resource_group" "flixtubeazurekeyvault" {
  count    = length(data.azurerm_resource_group.existing_rg.*) == 0 ? 1 : 0
  name     = var.app_name
  location = var.location
}
