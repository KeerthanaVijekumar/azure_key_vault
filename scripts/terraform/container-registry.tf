# Check if the container registry exists
data "azurerm_container_registry" "existing_acr" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
}


# Create the container registry 
resource "azurerm_container_registry" "container_registry" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
  location            = var.location
  admin_enabled       = true
  sku                 = "Basic"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}


