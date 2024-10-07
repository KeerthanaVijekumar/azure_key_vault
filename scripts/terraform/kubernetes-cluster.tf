# Check if the Kubernetes cluster exists
data "azurerm_kubernetes_cluster" "existing_cluster" {
  name                = var.app_name
  resource_group_name = var.app_name  # Use var.app_name instead of accessing resource group directly
  depends_on          = [azurerm_resource_group.flixtubeazurekeyvault]  # Ensure resource group is created first
}

# Create the Kubernetes cluster only if it does not exist
resource "azurerm_kubernetes_cluster" "cluster" {
  count               = length(data.azurerm_kubernetes_cluster.existing_cluster.id) == 0 ? 1 : 0
  name                = var.app_name
  location            = azurerm_resource_group.flixtubeazurekeyvault.location  # No need for [0] index
  resource_group_name = azurerm_resource_group.flixtubeazurekeyvault.name      # No need for [0] index
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
  count               = length(azurerm_kubernetes_cluster.cluster) > 0 ? 1 : 0
  principal_id        = azurerm_kubernetes_cluster.cluster[0].identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault.id  # No need for [0] index

  depends_on = [
    azurerm_kubernetes_cluster.cluster,
    azurerm_key_vault.key_vault
  ]
}