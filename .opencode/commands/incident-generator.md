---
description: Create an incident ticket in .incidents/ with timeline template and RCA skeleton
argument-hint: 'SEV{n} "short issue description"'
---

# Incident Generator

Create a new incident ticket with a timeline and RCA skeleton.

**Request:** $ARGUMENTS

## Step 1 — Parse

Extract the severity (`SEV1`–`SEV4`) and a short issue description from the request. If missing, ask. Apply the severity definitions from `platform-conventions.md` (Incident Response Tiers) if the user is unsure.

## Step 2 — Create the ticket

Determine the next sequence number from existing files in `.incidents/` (pattern `INCIDENT_YYYY_MM_DD_NNN.md`, NNN zero-padded, increment per day). Create `.incidents/INCIDENT_{today's date}_{NNN}.md` with this structure:

```markdown
# INCIDENT_{date}_{nnn}: {issue description}

- **Severity:** SEV{n}
- **Status:** Active
- **Commander:** {unassigned}
- **Started:** {current time, ISO 8601 with timezone}
- **Affected services:** {list if known}

## Summary
{2-3 sentences: what is broken, user impact, current state}

## Timeline

| Time | Event |
|------|-------|
| {detection time} | Alert fired: {alert name if known} |
| {current time} | Incident ticket created |

## Hypotheses
- {initial root-cause guess, or "under investigation"}

## Mitigation
- {none yet}

## Action items
- [ ] Confirm scope (which clusters/namespaces/users affected)
- [ ] Update timeline as investigation proceeds
- [ ] Assign RCA owner
- [ ] Draft RCA within 24h (required for SEV1/SEV2)
```

## Step 3 — Report

Show the user the created file path and remind them of the immediate steps from `.opencode/instructions/incident-response.md` (page oncall for SEV1, notify #incidents for SEV2). Do not page anyone or send notifications automatically.
