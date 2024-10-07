# Check if the Kubernetes cluster exists
data "azurerm_kubernetes_cluster" "existing_cluster" {
  name = var.app_name
  resource_group_name = length(azurerm_resource_group.flixtubeazurekeyvault) > 0 ? azurerm_resource_group.flixtubeazurekeyvault[0].name : var.app_name
}

# Create the Kubernetes cluster only if it does not exist
resource "azurerm_kubernetes_cluster" "cluster" {
  count               = length(data.azurerm_kubernetes_cluster.existing_cluster.id) == 0 ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault[0].name
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
}


