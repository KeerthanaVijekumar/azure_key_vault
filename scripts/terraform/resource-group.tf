# Create the resource group (Terraform will manage this resource group)
resource "azurerm_resource_group" "flixtubeazurekeyvault" {
  name     = var.app_name
  location = var.location
}

