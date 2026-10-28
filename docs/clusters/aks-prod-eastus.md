# AKS Production Cluster — aks-prod-eastus

- Status: Approved (2026-10-27), scaffolded, not yet applied
- Command: `/design-cluster prod aks with 100 pods`
- Approved defaults: `eastus`, private API server, Standard SKU
- Terraform: `terraform/azure/prod/`

## 1. Workload requirements

- Sizing target: 100 pods, ~25 CPU, ~50Gi memory steady-state
- Zone-aligned, autoscaled, no manual scaling
- Production defaults: private API server, Entra-only auth, policy-guarded supply chain

## 2. Cluster design

| Item | Value |
|---|---|
| Cluster name | `aks-prod-eastus` (module prefix `prod-eastus`) |
| Resource group | `rg-aks-prod-eastus` |
| Region | `eastus` |
| SKU tier | Standard (hardcoded by module) |
| Kubernetes version | `1.36` (GA Jun 2026, LTS-capable; auto-upgrade channel `patch`) |
| Node OS channel | `NodeImage` (auto node image upgrades) |
| API server | Private (`private_cluster_enabled = true`, system-managed private DNS zone) |
| Local accounts | Disabled (Entra ID only, Azure RBAC) |
| Network plugin | Azure CNI Overlay, Cilium data plane, Cilium network policy |
| Outbound | `managedNATGateway` (stable managed egress IPs) |
| Pod CIDR | `10.43.0.0/16` |
| Service CIDR | `10.44.0.0/16` (DNS `10.44.0.10`) |
| VNet / node subnet | `10.42.0.0/16` / `10.42.0.0/20` (snet-nodes) |
| Identity | System-assigned + Workload Identity + OIDC issuer |
| Secrets | Key Vault Secrets Provider with secret rotation enabled |
| Policy | Azure Policy enabled on cluster |
| Observability | Log Analytics + ContainerLogV2/AKS control-plane logs + diagnostic settings (module-managed) |

VNet `10.42.0.0/16` is intentionally distinct from the `10.0.0.0/8` overlay documented in
`.opencode/context/cluster-inventory.md` to avoid any route/peer overlap.

## 3. Node pools

| Pool | VM size | Min | Max | Notes |
|---|---|---|---|---|
| `agentpool` (system) | `Standard_D4s_v5` | 3 | 9 | Tainted `CriticalAddonsOnly` (AKS default for system mode), zone-aligned across all AZs, max 110 pods/node, host encryption, Ephemeral OS |
| `general1/2/3` (user) | `Standard_D8s_v5` | 6 | 12 | Zone-aligned: the AVM module creates one pool per AZ and replicates min/max per zone, so `min_count = 2`, `max_count = 4` yields aggregate 6–12 nodes. Ephemeral OS (128 GiB) |

All pools: AzureLinux OS SKU, autoscaling on, `balance_similar_node_groups = true`.

### Spot pool (not in this scaffold)

The AVM pattern module's `node_pools` schema has no spot/priority field. A spot pool for
best-effort workloads is a Day-1 addition via a separate
`azurerm_kubernetes_cluster_node_pool` resource (`priority = "Spot"`, eviction policy
`Delete`, 0–6 nodes). Budget impact: spot nodes cut node cost 60–80%.

## 4. Security posture

- Private API server; no public control-plane endpoint
- Entra ID RBAC (`azure_rbac_enabled = true`, admin group set via variable
  `admin_group_object_ids`); local accounts disabled
- Workload Identity (no ACR/KV secrets in pod specs)
- Azure Policy on; Deployment Safeguards / PSS-restricted enforcement is Day-1 GitOps policy
- Default-deny NetworkPolicies are Day-1 GitOps manifests (Cilium enforces them)
- ACR: Day-1 — module can create an ACR with private endpoint, or attach an existing
  registry; until then workloads can only pull public or policy-approved images

## 5. Cost estimate (on-demand, East US)

- System pool: 3 × D4s_v5 ~ $420/mo
- General pool: 6 nodes ~ $1,680/mo at floor, 12 nodes ~ $3,360/mo at ceiling
- Managed NAT Gateway ~ $33/mo + data; Standard LB ~ $18/mo; Log Analytics ~ $50/mo
- **Total: ~$2.2k/mo at steady-state minimum, ~$3.8k/mo at full scale**
- Levers: Spot pool (Day-1, -60–80% on best-effort workloads), Azure savings plan or
  reserved instances once usage patterns are known

## 6. Module choice

`Azure/avm-ptn-aks-production/azurerm` `~> 0.5.0` (Azure Verified Module, pattern level).
It wraps `azurerm_kubernetes_cluster` with Microsoft's production standard and hardcodes
the approved decisions:

- `private_cluster_enabled = true`, `sku_tier = "Standard"`, `local_account_disabled = true`
- `automatic_upgrade_channel = "patch"`, `node_os_upgrade_channel = "NodeImage"`
- OIDC + Workload Identity + Azure Policy + Key Vault secret rotation
- Cilium + CNI Overlay, zone-aligned node pools, autoscaler with balanced groups
- Log Analytics workspace + OMS agent + diagnostic settings for all AKS log categories

Root module adds: resource group, VNet + node subnet, module call, tags, AAD admin group.

## 7. Deviations from the approved design (research findings)

1. General pool aggregate floor is 6, not 4 — the module replicates min/max per AZ
   (per-zone 2/4 across 3 zones = aggregate 6/12). 4 cannot be expressed evenly across
   three zone pools; 6 is the closest floor above the design's 4.
2. Outbound is `managedNATGateway`, not Static Egress Gateway — the pattern module does
   not expose Static Egress Gateway. Both provide stable outbound IPs; switch via a
   dedicated static-egress-gateway config or UDR/Firewall if centralized egress is later
   required.
3. No maintenance window, KEDA, Defender, App Routing, or Managed Prometheus in the
   scaffold — not exposed by the pattern module. All are Day-1 post-deploy settings.

## 8. Day-1 follow-ups (post-apply, GitOps-first)

1. `az aks get-credentials` with Entra admin group, verify private DNS resolution from a
   jumpbox/vNet peered network
2. Maintenance window: `az aks update --maintenance-configuration`
3. Defender for Containers: `az aks update --enable-defender`
4. KEDA addon: `az aks update --enable-keda`
5. App Routing / Gateway API addon, or ingress-nginx via GitOps
6. ACR with private endpoint (module `acr` input) + image policy
7. Spot node pool for best-effort workloads
8. Azure Managed Prometheus workspace + Grafana, then set `monitor_metrics`
9. GitOps: Flux/ArgoCD, default-deny NetworkPolicies, PSS-restricted namespace policy
10. Alerting: AKS node/pool health, CPU/mem saturation, probe failures

## 9. Validation

- `terraform fmt` and `terraform init -backend=false && terraform validate` pass
  (2026-10-27)
- `terraform plan`/`apply` intentionally not run — remote-state backend and subscription
  binding are prerequisites; prod changes are applied only after human approval
