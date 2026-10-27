---
description: Review a Helm chart — lint, values, security context, and dependency hygiene
argument-hint: '[chart path — defaults to changed charts]'
---

# Helm Chart Reviewer

Review the target Helm chart(s) and report issues.

**Target:** $ARGUMENTS (default: charts with unstaged changes; else all `Chart.yaml` files found in the repo)

## Automated checks

```bash
helm lint {chart}
helm dependency list {chart}
helm template {chart} --values {chart}/values.yaml   # render to catch template errors
```

If `helm` is not installed, note the gap and do the manual review only.

## Manual review

1. **Chart hygiene** — `Chart.yaml` version bumped when templates change; `Chart.lock` committed and in sync; dependencies pinned to exact versions
2. **Values** — sensible defaults; no hardcoded secrets or environment-specific values that belong in overlays; values documented with comments
3. **Security context** — templates emit `runAsNonRoot`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`; PSS-restricted-compatible in prod values
4. **Resources** — every container template sets requests/limits (per AGENTS.md K8s conventions)
5. **Probes** — liveness/readiness emitted for Deployments, configurable paths/ports
6. **Images** — tag parameterized, never `:latest` default
7. **Best practice** — `_helpers.tpl` used for naming/labels; `NOTES.txt` present; no raw namespace creation (namespace managed by platform)
8. **Rendered-manifest spot check** — pipe `helm template` output and verify selector/label matching, and that prod-ish values produce a restricted-compliant pod spec

## Output

Findings with file:line, severity (CRITICAL/IMPORTANT/SUGGESTION), and the concrete template/values fix. Then the `helm lint` result. Do not modify files unless asked to apply fixes.
