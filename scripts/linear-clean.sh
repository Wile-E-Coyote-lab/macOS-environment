#!/bin/bash
set -euo pipefail

mkdir -p .linear

LOG_FILE=".linear/auth_log.ndjson"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🔧 Cleaning OAuth remnants and logging auth context..."

# Detect auth mode
if [[ -n "${LINEAR_API_KEY:-}" ]]; then
  AUTH_MODE="api_key"
  AUTH_ID="$LINEAR_API_KEY"
elif [[ -s .linear/token_response.json ]]; then
  AUTH_MODE="oauth"
  AUTH_ID=$(jq -r '.access_token // .token' .linear/token_response.json)
else
  AUTH_MODE="unknown"
  AUTH_ID="n/a"
fi

# Log auth context
jq -n --arg time "$TIMESTAMP" \
      --arg mode "$AUTH_MODE" \
      --arg id "$AUTH_ID" \
      '{timestamp: $time, mode: $mode, token: $id}' >> "$LOG_FILE"

echo "🧾 Logged auth context to $LOG_FILE"

# Delete OAuth artifacts
DELETED=()
for f in \
  .linear/oauth_code \
  .linear/token_response.json \
  scripts/linear-validate-session.sh \
  scripts/validate_oauth_code.sh \
  scripts/validate-linear-token.sh \
  scripts/linear-session-status.sh \
  cli/oauth \
  scripts/archive/exchange_token.sh; do
  if [[ -e "$f" ]]; then
    rm -rf "$f"
    DELETED+=("$f")
  fi
done

# Log deletions
if [[ ${#DELETED[@]} -gt 0 ]]; then
  echo "🧹 Deleted OAuth remnants:"
  for f in "${DELETED[@]}"; do
    echo " - $f"
  done
else
  echo "✅ No OAuth remnants found"
fi

echo "✅ Clean complete"
