# Create the resource group (Terraform will manage this resource group)
resource "azurerm_resource_group" "flixtubeazurekeyvault" {
  name     = var.app_name
  location = var.location

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion of existing resource
    ignore_changes  = [name, location]  # Ignore changes if the resource already exists
  }
}

