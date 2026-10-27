#!/bin/bash
# .opencode/hooks/pre-commit.sh
# Auto-run before git commit; enforced by opencode

set -e

echo "🔍 Running pre-commit checks..."

# Terraform validation
if [[ $(find . -name "*.tf" | wc -l) -gt 0 ]]; then
    echo "  ✓ Validating Terraform..."
    terraform validate
    terraform fmt -check || terraform fmt -recursive .
    tfsec . --minimum-severity MEDIUM || true
fi

# Helm validation
if [[ -d helm/ ]]; then
    echo "  ✓ Linting Helm charts..."
    for chart in helm/*/; do
        helm lint "$chart"
    done
fi

# Kubernetes manifest validation
if [[ -d k8s/ ]]; then
    echo "  ✓ Validating Kubernetes manifests..."
    kubeval k8s/**/*.yaml || true
fi

echo "✅ Pre-commit checks passed!"

