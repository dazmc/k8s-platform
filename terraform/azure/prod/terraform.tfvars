# aks-prod-eastus — approved design values (see docs/clusters/aks-prod-eastus.md)

location            = "eastus"
name                = "prod-eastus"
resource_group_name = "rg-aks-prod-eastus"

kubernetes_version = "1.36"

system_pool_vm_size  = "Standard_D4s_v5"
general_pool_vm_size = "Standard_D8s_v5"
# Per-zone counts; the module creates one general pool per AZ (aggregate 6-12 nodes)
general_pool_min_count = 2
general_pool_max_count = 4

vnet_address_space         = ["10.42.0.0/16"]
node_subnet_address_prefix = "10.42.0.0/20"
pod_cidr                   = "10.43.0.0/16"
service_cidr               = "10.44.0.0/16"

outbound_type = "managedNATGateway"

# Entra ID admin group object IDs — fill in before apply
admin_group_object_ids = []

tags = {
  Environment = "prod"
  Owner       = "platform-team"
  CostCenter  = "platform"
  ManagedBy   = "Terraform"
}
