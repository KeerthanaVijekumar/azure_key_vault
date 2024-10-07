# Check if the Kubernetes cluster exists
data "azurerm_kubernetes_cluster" "existing_cluster" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name
}

# Create the Kubernetes cluster 
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
    create_before_destroy = true
  }

  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}
