---
description: Design a new Kubernetes cluster for an environment (dev/staging/prod) and scaffold starter Terraform
argument-hint: '{env} [cloud] [extra requirements]'
---

# Cluster Design

Design a production-ready Kubernetes cluster for the requested environment, then scaffold starter Terraform.

**Request:** $ARGUMENTS

## Step 1 — Parse and clarify

Extract from the request: environment (`dev`/`staging`/`prod`), cloud (`aks`/`eks`/`gke` — default to the cloud already used for that env in `terraform/`; ask if unclear), region, expected pod count, and any HA/cost/security constraints. Ask at most 3 clarifying questions if the request is ambiguous; if it is specific enough, proceed.

## Step 2 — Load the right skill

Invoke the matching skill before designing, and follow its Day-0 checklist:

- AKS → `azure-kubernetes`
- GKE → `gke-basics`
- EKS → research current EKS best practices

Also apply the Kubernetes, Docker, and Terraform conventions from `.opencode/instructions/`.

## Step 3 — Produce a design

Deliver a design covering (as a section in `docs/clusters/{cloud}-{env}.md`, creating the directory if needed):

1. **Sizing** — node pools, instance types, autoscaling (min/max), spot strategy if applicable
2. **Networking** — CNI choice, private API server, egress, pod/service CIDRs
3. **Security** — RBAC, workload identity (IRSA/WI/Workload Identity), network policies, Pod Security Standards
4. **Operations** — autoscaling (CA/ Karpenter / node auto-provisioning), upgrade strategy, backups
5. **Observability** — metrics, logs, alerting integration (Azure Managed Prometheus, CloudWatch, etc.)
6. **Cost estimate** — rough monthly range and optimization levers

Present the design summary in chat and wait for approval before scaffolding Terraform.

## Step 4 — Scaffold Terraform (after approval)

Follow the repo layout and conventions in `platform-conventions.md` and `terraform-guidelines.md`:

- Location: `terraform/{cloud}/{env}/` (e.g. `terraform/azure/prod/`)
- Files: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
- Use remote state backend, required tags (`Environment`, `Owner`, `CostCenter`, `ManagedBy=Terraform`), least-privilege IAM
- For AKS, prefer Azure Verified Modules where available

Then run `terraform fmt` and `terraform validate` in the new directory. Do NOT run `plan` or `apply`.
