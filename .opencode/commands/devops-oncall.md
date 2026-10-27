---
description: Triage cluster issues — pull status, logs, and suggest fixes (never applies to production)
argument-hint: '[cluster/namespace/pod focus or symptom description]'
---

# DevOps Oncall Triage

Triage a cluster issue and suggest a fix. **Read-only**: investigate and propose, never `kubectl apply`/`patch`/`delete` or any state change on a cluster.

**Focus:** $ARGUMENTS

## Step 1 — Context

Determine the target cluster/context (`kubectl config current-context`, list contexts if the focus mentions a specific cluster). Confirm with the user if ambiguous or if the context looks like production.

## Step 2 — Triage checklist (from `platform-conventions.md`)

Run these, in order, and report findings as you go:

```bash
kubectl get nodes -o wide
kubectl get pods -n {ns} -o wide
kubectl top pods -n {ns}              # resource pressure
kubectl get events -n {ns} --sort-by='.lastTimestamp'
kubectl describe pod {pod} -n {ns}    # events + probe/kill reasons
kubectl logs {pod} -n {ns} --tail=50
kubectl logs {pod} -n {ns} --previous # crashed container
flux get ks --all-namespaces          # GitOps drift, if Flux is installed
```

Filter to the affected namespace/pod when the focus names one.

## Step 3 — Diagnose

Match findings against known failure classes (use `diagnosing-bugs` and `systematic-debugging` skills for hard cases):

- Pending → scheduling (resources, taints, PVC binding, image pull)
- CrashLoopBackOff → app errors, OOM (exit 137), bad probe/config
- Not Ready → readiness probe, dependency down
- Restarts spikes → OOMKilled, liveness misconfig
- ImagePullBackOff → tag typo, registry auth

State a root-cause hypothesis with the evidence that supports it. If evidence is insufficient, list the next 2–3 commands that would narrow it.

## Step 4 — Propose the fix

Provide the fix as a patch/diff against the GitOps source (Kustomize overlay, Helm values, or Terraform) — not a raw `kubectl apply`. For urgent mitigation that requires direct cluster action (e.g. `kubectl rollout restart`), clearly mark it as **manual, requires human approval**, and give the exact command. Update the incident ticket in `.incidents/` if one is open for this issue.
