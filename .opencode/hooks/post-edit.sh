#!/bin/bash
# .opencode/hooks/post-edit.sh
# Auto-run after OpenCode edits a file

echo "🧹 Auto-formatting..."

# Format Terraform
if [[ $1 == *.tf ]]; then
    terraform fmt "$1"
fi

# Format Helm values
if [[ $1 == *values.yaml ]]; then
    yamllint "$1" || true
fi

echo "✅ Auto-formatting done!"

