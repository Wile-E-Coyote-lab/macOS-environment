#!/bin/bash
set -euo pipefail

echo "🔍 Checking Linear OAuth session status..."

# Load environment if needed
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Validate OAuth code freshness
CODE_FILE=".linear/oauth_code"
if [ ! -s "$CODE_FILE" ]; then
  echo "❌ No OAuth code found at $CODE_FILE"
  exit 1
fi

AGE=$(($(date +%s) - $(stat -f %m "$CODE_FILE")))
if [[ "$AGE" -gt 300 ]]; then
  echo "⚠️ OAuth code is older than 5 minutes. Likely expired."
else
  echo "✅ OAuth code is fresh ($AGE seconds old)"
fi

# Check for API response log
RESPONSE_FILE=".linear/api_response.json"
if [ -s "$RESPONSE_FILE" ]; then
  echo "📬 Last Linear API response:"
  jq . "$RESPONSE_FILE"
else
  echo "⚠️ No API response log found at $RESPONSE_FILE"
fi

# Optional: check for access token presence
if [ -n "${ACCESS_TOKEN:-}" ]; then
  echo "🔐 Access token is present in environment"
else
  echo "⚠️ No access token detected in current shell"
fi

echo "✅ Session status check complete"
