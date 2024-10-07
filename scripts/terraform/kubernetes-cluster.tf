resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
  dns_prefix          = var.app_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      # Add attributes you don't want to manage after creation
      kubernetes_version,
      identity
    ]
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}
