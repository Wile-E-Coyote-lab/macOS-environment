#!/bin/bash
set -euo pipefail

source .env

CODE="${1:-${OAUTH_CODE:-}}"

if [[ -z "$CODE" ]]; then
  echo "❌ No OAuth code provided. Usage: exchange_token.sh <code>"
  exit 1
fi

echo "🔁 Exchanging code for access token..."

response=$(curl -sS -X POST https://api.linear.app/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$LINEAR_APP_ID&client_secret=$LINEAR_CLIENT_SECRET&redirect_uri=$LINEAR_REDIRECT_URI&grant_type=authorization_code&code=$CODE")

echo "$response" | tee audit/token.latest.json

if echo "$response" | jq -e '.access_token' >/dev/null; then
  echo "✅ Token exchange successful"
else
  echo "❌ Token exchange failed"
  exit 1
fi
