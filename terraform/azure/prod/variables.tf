variable "location" {
  description = "Azure region for the cluster."
  type        = string
  default     = "eastus"
}

variable "name" {
  description = "Cluster name suffix; the module creates aks-<name>."
  type        = string
  default     = "prod-eastus"
}

variable "resource_group_name" {
  description = "Resource group for the cluster and network."
  type        = string
  default     = "rg-aks-prod-eastus"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version (no patch). 1.36 is GA LTS-capable as of Oct 2026."
  type        = string
  default     = "1.36"
}

variable "system_pool_vm_size" {
  description = "VM SKU for the system (default) node pool. Minimum 4 vCPU."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "general_pool_vm_size" {
  description = "VM SKU for the general user node pool."
  type        = string
  default     = "Standard_D8s_v5"
}

variable "general_pool_min_count" {
  description = "Autoscaler min nodes PER zone pool (the module creates one pool per AZ; aggregate min = this x 3)."
  type        = number
  default     = 2
}

variable "general_pool_max_count" {
  description = "Autoscaler max nodes PER zone pool (the module creates one pool per AZ; aggregate max = this x 3)."
  type        = number
  default     = 4
}

variable "vnet_address_space" {
  description = "Address space for the cluster VNet."
  type        = list(string)
  default     = ["10.42.0.0/16"]
}

variable "node_subnet_address_prefix" {
  description = "Address prefix for the node subnet."
  type        = string
  default     = "10.42.0.0/20"
}

variable "pod_cidr" {
  description = "Pod CIDR for Azure CNI Overlay. Must not overlap the VNet."
  type        = string
  default     = "10.43.0.0/16"
}

variable "service_cidr" {
  description = "Service CIDR for the cluster. Must not overlap the VNet or pod CIDR."
  type        = string
  default     = "10.44.0.0/16"
}

variable "admin_group_object_ids" {
  description = "Entra ID group object IDs granted cluster admin via Azure RBAC. Set before apply."
  type        = list(string)
  default     = []
}

variable "outbound_type" {
  description = "Cluster outbound routing type. managedNATGateway gives stable managed egress IPs."
  type        = string
  default     = "managedNATGateway"

  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway"], var.outbound_type)
    error_message = "outbound_type must be one of loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway."
  }
}

variable "tags" {
  description = "Tags applied to all resources (repo-required tag keys included by default)."
  type        = map(string)
  default = {
    Environment = "prod"
    Owner       = "platform-team"
    CostCenter  = "platform"
    ManagedBy   = "Terraform"
  }
}
