output "cluster_name" {
  description = "Name of the AKS cluster (the module names it aks-<name>)."
  value       = "aks-${var.name}"
}

output "cluster_resource_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.resource_id
}

output "node_resource_group" {
  description = "Resource group AKS created for node resources."
  value       = module.aks.node_resource_group
}

output "private_fqdn" {
  description = "Private FQDN of the API server."
  value       = module.aks.private_fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL used for Workload Identity federation."
  value       = module.aks.oidc_issuer_url
}

output "kubelet_identity_client_id" {
  description = "Client ID of the kubelet user-assigned identity (ACR/KV RBAC target)."
  value       = module.aks.kubelet_identity_client_id
}

output "resource_group_name" {
  description = "Resource group containing the cluster and network."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the cluster VNet."
  value       = azurerm_virtual_network.this.id
}

output "node_subnet_id" {
  description = "ID of the node subnet."
  value       = azurerm_subnet.nodes.id
}
