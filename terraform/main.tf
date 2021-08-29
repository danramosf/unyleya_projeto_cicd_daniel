provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resources"
  location = var.location
}

resource "azurerm_role_assignment" "role_acrpull" {
    scope                               = azurerm_container_registry.acr.id
    role_definition_name                = "AcrPull"
    principal_id                        = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
    skip_service_principal_aad_check    = true
}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistryDFerreira"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-k8s"
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.default_node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
      load_balancer_sku = "Standard"
      network_plugin    = "kubenet"
  }
}