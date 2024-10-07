# Create the Kubernetes cluster
resource "azurerm_kubernetes_cluster" "cluster" {
  count               = azurerm_resource_group.flixtubeazurekeyvault.count > 0 ? 1 : 0
  name                = var.app_name
  location            = azurerm_resource_group.flixtubeazurekeyvault[0].location
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
  count               = azurerm_kubernetes_cluster.cluster.count > 0 ? 1 : 0
  principal_id        = azurerm_kubernetes_cluster.cluster[0].identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.key_vault[0].id

  depends_on = [
    azurerm_kubernetes_cluster.cluster,
    azurerm_key_vault.key_vault
  ]
}

# Assign AKS cluster access to the Azure Container Registry (ACR) for pulling images
resource "azurerm_role_assignment" "acr_role_assignment" {
  count               = azurerm_kubernetes_cluster.cluster.count > 0 ? 1 : 0
  principal_id        = azurerm_kubernetes_cluster.cluster[0].identity[0].principal_id
  role_definition_name = "AcrPull"
  scope               = azurerm_container_registry.container_registry[0].id

  depends_on = [
    azurerm_kubernetes_cluster.cluster,
    azurerm_container_registry.container_registry
  ]
}
