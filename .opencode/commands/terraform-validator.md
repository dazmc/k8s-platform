---
description: Validate Terraform — fmt, validate, tflint, security lint, and plan review
argument-hint: '[terraform directory — defaults to changed dirs or terraform/]'
---

# Terraform Validator

Run the full validation pipeline for Terraform in this repo.

**Target:** $ARGUMENTS (default: directories with unstaged Terraform changes; else all of `terraform/`)

## Pipeline (run in order, per target directory)

```bash
terraform fmt -check -recursive   # report unformatted files
terraform init -backend=false     # needed for validate on fresh clones
terraform validate
tflint --init && tflint           # style/best-practice issues
tfsec .                           # security linting
```

If a tool is not installed, say so and skip it rather than failing — note the gap in the report. Never run `terraform plan` or `terraform apply`; if the user wants a plan, remind them it needs credentials and their explicit go-ahead (per `terraform-guidelines.md`).

## Review pass (manual, on top of tooling)

Also read the `.tf` files and check for repo-convention violations:

- Hardcoded values that should be variables
- Missing required tags (`Environment`, `Owner`, `CostCenter`, `ManagedBy=Terraform`)
- Missing `description`/`type` on variables and outputs
- Secrets committed in code or tfvars
- Redundant `depends_on` where implicit references already exist
- Data sources inside reusable modules (should use inputs/outputs)
- State backend configured remotely, encrypted, versioned

## Output

Per directory: tool results (pass/fail + counts), then findings table with file:line, severity, and the exact fix. End with a pass/fail verdict. Do not auto-fix unless the user asks; if asked, fix only the reported issues and re-run the pipeline.
