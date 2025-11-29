#!/usr/bin/env bash
set -euo pipefail

[[ "$LINEAR_API_KEY" =~ ^lin_api_[a-zA-Z0-9]{30,}$ ]] || {
  echo "❌ Invalid or missing LINEAR_API_KEY"
  exit 1
}

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -X POST https://api.linear.app/graphql \
  -d '{"query":"{ viewer { id name email } }"}')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n1)

[[ "$STATUS" == "200" ]] || {
  echo "❌ HTTP $STATUS — token rejected"
  echo "$BODY" | jq
  exit 1
}

echo "✅ Token authenticated. Viewer:"
echo "$BODY" | jq '.data.viewer'
