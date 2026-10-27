---
description: Root-cause analysis of a log file or pasted log output
argument-hint: '{path to log file, or paste logs directly}'
---

# Analyze Incident Logs

Perform root-cause analysis on the provided logs.

**Input:** $ARGUMENTS — either a file path (read it) or pasted log text. If neither is clear, ask for the logs.

## Step 1 — Scope

Identify from the logs: source (which pod/container/node/service), time window, and whether the failure is ongoing or historical. If the file is large (>2000 lines), focus on error/warn lines and the last 10% of the file first.

## Step 2 — Extract signal

Grep for patterns, preserving order:

- `error|Error|ERROR|fatal|FATAL|panic|OOM|Killed|Traceback|Exception`
- Exit codes (`exit code`, `ExitCode`, `137`, `139`, `143`)
- Kubernetes events (`Failed`, `Back-off`, `Unhealthy`, `Probe failed`, `Evicted`)
- Timestamp clusters — find the *first* anomaly, not just the last

## Step 3 — Analyze

- Build a timeline: first error → cascade → terminal failure
- Distinguish cause from symptom (e.g. probe timeouts are a symptom; the cause is upstream slowness or deadlock)
- Check for known patterns: OOMKilled (exit 137), liveness-vs-readiness loops, DNS failures, connection pool exhaustion, disk pressure
- Cross-reference `.incidents/` and `docs/runbooks/` if a matching incident or runbook exists

## Step 4 — Report

Deliver:

1. **Likely root cause** — one statement, with the log lines that prove it
2. **Contributing factors** — anything that worsened or masked it
3. **Timeline** — condensed, timestamps included
4. **Recommended fix** — as a GitOps-source change where possible; manual mitigations marked as requiring approval
5. **Prevention** — alerting/config changes to catch it sooner

If an incident ticket in `.incidents/` matches, offer to append these findings to its timeline. Confidence matters: if the logs don't support a definitive cause, say what additional logs (component X, time range Y) would settle it.
