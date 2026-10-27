---
description: Generate an operational runbook in docs/runbooks/
argument-hint: '"topic or scenario" [context]'
---

# Runbook Writer

Write an operational runbook for a common platform scenario.

**Topic:** $ARGUMENTS

## Step 1 — Clarify

If the topic is vague (e.g. just "disk pressure"), ask what triggered the need: a recent incident (check `.incidents/` for one to reference), a recurring alert, or proactive documentation. If a related incident exists, read it for real details.

## Step 2 — Write the runbook

Create `docs/runbooks/{kebab-case-topic}.md` (check first whether it exists — if so, update it rather than overwriting). Structure:

```markdown
# Runbook: {Title}

**Last updated:** {date} · **Audience:** platform on-call

## Symptom
What the on-call sees (alert names, error messages, kubectl output).

## Impact
What breaks for users; severity range.

## Diagnosis
1. Ordered kubectl/CLI checks with the exact commands
2. What each result means (good/bad)
3. Key metrics or log queries (PromQL/KQL) worth checking

## Mitigation
Step-by-step fixes, least-invasive first. Mark anything that touches
production as requiring GitOps (never direct kubectl apply) per repo conventions.

## Escalation
When to page, who owns the affected component.

## Prevention
Alerting, config, or architecture changes that reduce recurrence.
```

## Step 3 — Verify

Content must be concrete: real command syntax, real paths (`{team}-{env}` namespaces, `terraform/{cloud}/{env}/`), no placeholder text left in the finished runbook except clearly-marked fields like `{alert name}`. Show the user a summary of what the runbook covers.
