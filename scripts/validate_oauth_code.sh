#!/bin/bash
set -euo pipefail

CODE=$(cat .linear/oauth_code 2>/dev/null || echo "")
if [[ -z "$CODE" ]]; then
  echo "❌ No OAuth code found"
  exit 1
fi

AGE=$(($(date +%s) - $(stat -f %m .linear/oauth_code)))
if [[ "$AGE" -gt 300 ]]; then
  echo "❌ OAuth code is older than 5 minutes. Please re-authenticate."
  exit 1
fi

echo "✅ OAuth code is fresh"
