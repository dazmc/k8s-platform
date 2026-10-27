    # Incident Response for OpenCode

    ## Immediate (0-5 minutes)

    1. Page oncall team
    2. `opencode`
    3. "SEV{n}: {issue} — create incident ticket in .incidents/ with timeline and RCA skeleton"
    4. Describe symptoms to OpenCode
    5. Ask OpenCode to pull logs and diagnose (kubectl, metrics)

    ## Investigation (5-30 minutes)

    - OpenCode queries cluster, metrics, logs
    - Ask: "Root cause hypothesis?"
    - Agent suggests fixes with validation
    - Test locally with `kind` cluster if possible

    ## Remediation (30+ minutes)

    - Apply fix via GitOps (not direct kubectl)
    - Verify metrics return to normal
    - Document timeline in incident ticket
    - Assign RCA owner

    ## Post-Incident (24h)

    1. Write post-mortem in `docs/runbooks/` (Markdown is fine)
    2. Add prevention steps to `.opencode/hooks/`
    3. Update runbook: `docs/runbooks/{issue-type}.md`
    4. Share RCA with team

