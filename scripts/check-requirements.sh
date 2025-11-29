#!/usr/bin/env bash
# check-requirements.sh — Validates required CLI tools from requirements.freeze

set -euo pipefail

REQ_FILE="requirements.freeze"
[[ -f "$REQ_FILE" ]] || { echo "❌ $REQ_FILE not found"; exit 1; }

MISSING=0
while IFS= read -r tool; do
  [[ -z "$tool" || "$tool" =~ ^# ]] && continue
  if ! command -v "$tool" >/dev/null; then
    echo "❌ Missing required tool: $tool"
    MISSING=1
  fi
done < "$REQ_FILE"

[[ "$MISSING" -eq 0 ]] && echo "✅ All required tools are installed"
exit "$MISSING"
