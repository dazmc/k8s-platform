---
description: Security audit of Kubernetes manifests, RBAC, network policies, and Terraform
argument-hint: '[path or component to audit — defaults to whole repo]'
---

# Security Auditor

Audit the target for security issues and produce a findings report.

**Target:** $ARGUMENTS (default: whole repository)

## Scope

Audit the target against the Security Standards in `AGENTS.md` and the checklist in the Kubernetes best practices. Cover:

1. **RBAC** — Roles/ClusterRoles for least privilege; no wildcards in rules; ServiceAccounts bound only to what they need; no default SA usage in workloads
2. **Pod security** — `runAsNonRoot`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem` where possible, `capabilities.drop: [ALL]`, no `privileged: true`, Pod Security Standards enforced (restricted in prod)
3. **Network policies** — default-deny present per namespace; allowed ingress/egress explicit; no `0.0.0.0/0` ingress
4. **Secrets** — no plaintext secrets in manifests/ConfigMaps/Terraform; Sealed Secrets/External Secrets used; no secrets in env vars where file mounting is viable
5. **Images** — pinned tags (no `:latest`), trusted registries, `imagePullPolicy` sane
6. **Terraform** — least-privilege IAM, no permissive security groups, encrypted state backend, required tags
7. **CI/supply chain** — lockfiles committed, no unpinned versions in production paths

## Output

Report findings grouped by severity (CRITICAL / IMPORTANT / SUGGESTION), each with:

- File path and line
- The risky snippet
- The concrete fix (YAML/HCL diff)
- Which check it violates (e.g. PSS restricted, AGENTS.md A01)

For missing-not-wrong items (e.g. no NetworkPolicy at all), list them under "Gaps". End with a summary count. Do NOT modify any files unless the user explicitly asks you to apply the fixes.
