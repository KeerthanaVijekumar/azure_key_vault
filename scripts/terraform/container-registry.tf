resource "azurerm_container_registry" "container_registry" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
  location            = var.location
  admin_enabled       = true
  sku                 = "Basic"

  lifecycle {
    ignore_changes = [
      # Add attributes you don't want Terraform to manage after initial creation
      admin_enabled, 
      sku
    ]
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}
