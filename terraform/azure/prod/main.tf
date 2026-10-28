resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.this.location
  name                = "vnet-${var.name}"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet" "nodes" {
  address_prefixes     = [var.node_subnet_address_prefix]
  name                 = "snet-nodes"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

module "aks" {
  source  = "Azure/avm-ptn-aks-production/azurerm"
  version = "~> 0.5.0"

  location            = var.location
  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  network = {
    node_subnet_id = azurerm_subnet.nodes.id
    pod_cidr       = var.pod_cidr
    service_cidr   = var.service_cidr
  }

  kubernetes_version       = var.kubernetes_version
  orchestrator_version     = var.kubernetes_version
  default_node_pool_vm_sku = var.system_pool_vm_size
  os_sku                   = "AzureLinux"
  os_disk_type             = "Ephemeral"
  outbound_type            = var.outbound_type
  network_policy           = "cilium"

  rbac_aad_azure_rbac_enabled     = true
  rbac_aad_admin_group_object_ids = var.admin_group_object_ids

  node_pools = {
    general = {
      name                 = "general"
      vm_size              = var.general_pool_vm_size
      orchestrator_version = var.kubernetes_version
      min_count            = var.general_pool_min_count
      max_count            = var.general_pool_max_count
      os_sku               = "AzureLinux"
      os_disk_type         = "Ephemeral"
      os_disk_size_gb      = 128
      mode                 = "User"
    }
  }

  lock = {
    kind = "CanNotDelete"
    name = "lock-${var.name}"
  }

  tags = var.tags
}
