# Terraform Guidelines for OpenCode

## Before Writing Terraform

1. Design on paper: draw networking, IAM, and state flow
2. Ask for initial scaffolding (e.g. use the `azure-kubernetes` skill for AKS)
3. Review cloud best practices for your target (AKS, EKS, GKE)
4. Estimate costs with `terraform plan`

## During Development

```bash
# Always validate before plan
terraform validate

# Check formatting
terraform fmt -check

# Run security linting
tfsec .

# Generate plan for review
terraform plan -out=tfplan.out
terraform show tfplan.out  # Read the changes

# Estimate costs
terraform plan -out=tfplan.out
# Ask OpenCode: "/analyze-costs tfplan.out"

