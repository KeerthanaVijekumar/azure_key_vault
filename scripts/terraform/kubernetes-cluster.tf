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
  depends_on = [azurerm_resource_group.flixtubeazurekeyvault]
}

# Assign Key Vault access to the AKS Managed Identity (Key Vault Secrets User)
resource "azurerm_role_assignment" "keyvault_role_assignment" {
  principal_id        = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.my_keyvault.id

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}




